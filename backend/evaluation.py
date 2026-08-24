import json
import sys
import os
import time
from decimal import Decimal

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from llm.ambiguity_detector import detect_ambiguity
from llm.sql_generator import generate_sql
import psycopg
from dotenv import load_dotenv

load_dotenv()

DATASET_PATH = os.path.join(os.path.dirname(__file__), "evaluation_dataset.json")
RESULTS_PATH = os.path.join(os.path.dirname(__file__), "evaluation_results.json")
DELAY_BETWEEN_TESTS = 70


def get_db_connection():
    database_url = os.getenv("DATABASE_URL")
    if database_url:
        return psycopg.connect(database_url)
    return psycopg.connect(
        host=os.getenv("DB_HOST", "localhost"),
        dbname=os.getenv("DB_NAME", "olist_db"),
        user=os.getenv("DB_USER", "postgres"),
        password=os.getenv("DB_PASSWORD", "postgres"),
        port=os.getenv("DB_PORT", "5433"),
    )


def load_dataset():
    with open(DATASET_PATH, "r") as f:
        return json.load(f)


def load_progress():
    if os.path.exists(RESULTS_PATH):
        try:
            with open(RESULTS_PATH, "r") as f:
                return json.load(f)
        except (json.JSONDecodeError, ValueError):
            return None
    return None


def save_progress(summary, results):
    with open(RESULTS_PATH, "w") as f:
        json.dump({"summary": summary, "details": results}, f, indent=2)
    print(f"Progress saved to {RESULTS_PATH}")


def check_sql_validity(sql_query):
    try:
        conn = get_db_connection()
        with conn.cursor() as cur:
            cur.execute(f"EXPLAIN {sql_query}")
        conn.close()
        return True
    except Exception:
        return False


def serialize_value(val):
    if val is None:
        return None
    from datetime import datetime, date
    if isinstance(val, (datetime, date)):
        return val.isoformat()
    if isinstance(val, Decimal):
        return float(val)
    return val


def execute_sql(sql_query):
    try:
        conn = get_db_connection()
        with conn.cursor() as cur:
            cur.execute(sql_query)
            columns = [desc[0] for desc in cur.description]
            rows = cur.fetchall()
        conn.close()
        serialized = [[serialize_value(v) for v in row] for row in rows]
        return {"columns": columns, "rows": serialized, "error": None}
    except Exception as e:
        return {"columns": [], "rows": [], "error": str(e)}


def check_keywords(sql_query, expected_keywords):
    sql_upper = sql_query.upper()
    found = [kw for kw in expected_keywords if kw.upper() in sql_upper]
    return len(found) / len(expected_keywords) if expected_keywords else 0


def check_tables(sql_query, expected_tables):
    sql_lower = sql_query.lower()
    found = [t for t in expected_tables if t.lower() in sql_lower]
    return len(found) / len(expected_tables) if expected_tables else 0


def check_columns_match(actual_columns, expected_columns):
    if not expected_columns or not actual_columns:
        return 0
    actual_lower = [c.lower() for c in actual_columns]
    matches = sum(1 for ec in expected_columns if any(ec.lower() in al for al in actual_lower))
    return matches / len(expected_columns)


def check_row_count(actual_count, expected_range):
    if not expected_range or len(expected_range) < 2:
        return 1
    return 1 if expected_range[0] <= actual_count <= expected_range[1] else 0.5


def evaluate_single_question(test):
    question = test["question"]
    clarification = test["clarification"]

    print(f"\n{'='*60}")
    print(f"Test {test['id']}: {question}")
    print(f"Difficulty: {test['difficulty']}")
    print(f"{'='*60}")

    result_without = {
        "question": question,
        "difficulty": test["difficulty"],
        "sql": None,
        "valid": False,
        "execution_result": None,
        "accuracy": 0,
        "keyword_score": 0,
        "table_score": 0,
        "column_score": 0,
        "row_count_score": 0,
        "status": "failed",
    }
    result_with = {
        "question": question,
        "clarification": clarification,
        "difficulty": test["difficulty"],
        "sql": None,
        "valid": False,
        "execution_result": None,
        "accuracy": 0,
        "keyword_score": 0,
        "table_score": 0,
        "column_score": 0,
        "row_count_score": 0,
        "status": "failed",
    }

    print(f"\n  [Without Clarification]")
    sql_no_clarify = generate_sql(question)
    result_without["sql"] = sql_no_clarify.query
    print(f"  SQL: {sql_no_clarify.query[:100] if sql_no_clarify.query else 'None'}...")

    if sql_no_clarify.query:
        result_without["valid"] = check_sql_validity(sql_no_clarify.query)
        execution = execute_sql(sql_no_clarify.query)
        result_without["execution_result"] = {
            "columns": execution["columns"],
            "row_count": len(execution["rows"]),
            "sample_rows": [list(r) for r in execution["rows"][:3]],
            "error": execution["error"],
        }

        result_without["keyword_score"] = check_keywords(sql_no_clarify.query, test["expected_sql_keywords"])
        result_without["table_score"] = check_tables(sql_no_clarify.query, test["expected_tables"])
        result_without["column_score"] = check_columns_match(execution["columns"], test["expected_result_columns"])
        result_without["row_count_score"] = check_row_count(len(execution["rows"]), test["expected_row_count_range"])

        weights = [0.2, 0.2, 0.3, 0.3]
        scores = [
            result_without["keyword_score"],
            result_without["table_score"],
            result_without["column_score"],
            result_without["row_count_score"],
        ]
        result_without["accuracy"] = round(sum(w * s for w, s in zip(weights, scores)) * 100, 1)
        result_without["status"] = "success" if result_without["valid"] else "invalid_sql"
    else:
        result_without["status"] = "generation_failed"

    print(f"  Valid: {result_without['valid']}")
    print(f"  Accuracy: {result_without['accuracy']}%")
    print(f"  Status: {result_without['status']}")

    print(f"\n  [With Clarification]")
    print(f"  Clarification: {clarification}")
    sql_with_clarify = generate_sql(question, clarification)
    result_with["sql"] = sql_with_clarify.query
    print(f"  SQL: {sql_with_clarify.query[:100] if sql_with_clarify.query else 'None'}...")

    if sql_with_clarify.query:
        result_with["valid"] = check_sql_validity(sql_with_clarify.query)
        execution = execute_sql(sql_with_clarify.query)
        result_with["execution_result"] = {
            "columns": execution["columns"],
            "row_count": len(execution["rows"]),
            "sample_rows": [list(r) for r in execution["rows"][:3]],
            "error": execution["error"],
        }

        result_with["keyword_score"] = check_keywords(sql_with_clarify.query, test["expected_sql_keywords"])
        result_with["table_score"] = check_tables(sql_with_clarify.query, test["expected_tables"])
        result_with["column_score"] = check_columns_match(execution["columns"], test["expected_result_columns"])
        result_with["row_count_score"] = check_row_count(len(execution["rows"]), test["expected_row_count_range"])

        weights = [0.2, 0.2, 0.3, 0.3]
        scores = [
            result_with["keyword_score"],
            result_with["table_score"],
            result_with["column_score"],
            result_with["row_count_score"],
        ]
        result_with["accuracy"] = round(sum(w * s for w, s in zip(weights, scores)) * 100, 1)
        result_with["status"] = "success" if result_with["valid"] else "invalid_sql"
    else:
        result_with["status"] = "generation_failed"

    print(f"  Valid: {result_with['valid']}")
    print(f"  Accuracy: {result_with['accuracy']}%")
    print(f"  Status: {result_with['status']}")

    return result_without, result_with


def compute_summary(results, total):
    avg_no = sum(r["accuracy"] for r in results["without_clarification"]) / total
    avg_with = sum(r["accuracy"] for r in results["with_clarification"]) / total
    valid_no = sum(1 for r in results["without_clarification"] if r["valid"])
    valid_with = sum(1 for r in results["with_clarification"] if r["valid"])
    success_no = sum(1 for r in results["without_clarification"] if r["status"] == "success")
    success_with = sum(1 for r in results["with_clarification"] if r["status"] == "success")

    by_difficulty = {}
    for r_no, r_with in zip(results["without_clarification"], results["with_clarification"]):
        diff = r_no["difficulty"]
        if diff not in by_difficulty:
            by_difficulty[diff] = {"no_clarify": [], "with_clarify": []}
        by_difficulty[diff]["no_clarify"].append(r_no["accuracy"])
        by_difficulty[diff]["with_clarify"].append(r_with["accuracy"])

    difficulty_summary = {}
    for diff, scores in by_difficulty.items():
        avg_no_diff = sum(scores["no_clarify"]) / len(scores["no_clarify"])
        avg_with_diff = sum(scores["with_clarify"]) / len(scores["with_clarify"])
        difficulty_summary[diff] = {
            "without_clarification": round(avg_no_diff, 1),
            "with_clarification": round(avg_with_diff, 1),
            "improvement": round(avg_with_diff - avg_no_diff, 1),
            "count": len(scores["no_clarify"]),
        }

    return {
        "total_tests": total,
        "without_clarification": {
            "avg_accuracy": round(avg_no, 1),
            "valid_sql_count": valid_no,
            "valid_sql_percent": round((valid_no / total) * 100, 1),
            "successful_executions": success_no,
        },
        "with_clarification": {
            "avg_accuracy": round(avg_with, 1),
            "valid_sql_count": valid_with,
            "valid_sql_percent": round((valid_with / total) * 100, 1),
            "successful_executions": success_with,
        },
        "improvement": {
            "accuracy_gain": round(avg_with - avg_no, 1),
            "valid_sql_gain": round(((valid_with - valid_no) / total) * 100, 1),
        },
        "by_difficulty": difficulty_summary,
    }


def run_evaluation():
    dataset = load_dataset()
    results = {"without_clarification": [], "with_clarification": []}
    total = len(dataset)

    existing = load_progress()
    if existing and "details" in existing:
        results = existing["details"]
        print(f"Resuming from previous progress ({len(results['without_clarification'])} tests done)")

    start_idx = len(results["without_clarification"])
    print(f"Running evaluation on {total} test questions (starting from test {start_idx + 1})...")

    for i, test in enumerate(dataset[start_idx:], start=start_idx):
        r_no, r_with = evaluate_single_question(test)
        results["without_clarification"].append(r_no)
        results["with_clarification"].append(r_with)

        summary = compute_summary(results, total)
        save_progress(summary, results)

        if i < total - 1:
            print(f"\n  Waiting {DELAY_BETWEEN_TESTS}s before next test (rate limit)...")
            time.sleep(DELAY_BETWEEN_TESTS)

    summary = compute_summary(results, total)

    print(f"\n{'='*60}")
    print("EVALUATION SUMMARY")
    print(f"{'='*60}")
    print(f"Total Tests: {total}")
    print(f"\nWithout Clarification:")
    print(f"  Avg Accuracy: {summary['without_clarification']['avg_accuracy']}%")
    print(f"  Valid SQL: {summary['without_clarification']['valid_sql_count']}/{total} ({summary['without_clarification']['valid_sql_percent']}%)")
    print(f"  Successful Executions: {summary['without_clarification']['successful_executions']}/{total}")
    print(f"\nWith Clarification:")
    print(f"  Avg Accuracy: {summary['with_clarification']['avg_accuracy']}%")
    print(f"  Valid SQL: {summary['with_clarification']['valid_sql_count']}/{total} ({summary['with_clarification']['valid_sql_percent']}%)")
    print(f"  Successful Executions: {summary['with_clarification']['successful_executions']}/{total}")
    print(f"\nImprovement:")
    print(f"  Accuracy Gain: +{summary['improvement']['accuracy_gain']}%")
    print(f"  Valid SQL Gain: +{summary['improvement']['valid_sql_gain']}%")

    print(f"\nBy Difficulty:")
    for diff, stats in summary.get("by_difficulty", {}).items():
        print(f"  {diff}: Without {stats['without_clarification']}% -> With {stats['with_clarification']}% (+{stats['improvement']}%)")

    save_progress(summary, results)

    return summary, results


if __name__ == "__main__":
    run_evaluation()

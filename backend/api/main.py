from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from models.schemas import QueryRequest, QueryResponse
from llm.ambiguity_detector import detect_ambiguity
from llm.sql_generator import generate_sql
import psycopg
import os
import json
from decimal import Decimal
from datetime import datetime, date
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="Text2SQL API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


def get_db_connection():
    return psycopg.connect(
        host=os.getenv("DB_HOST", "localhost"),
        dbname=os.getenv("DB_NAME", "olist_db"),
        user=os.getenv("DB_USER", "postgres"),
        password=os.getenv("DB_PASSWORD", "postgres"),
        port=os.getenv("DB_PORT", "5432")
    )


@app.post("/query", response_model=QueryResponse)
async def process_query(request: QueryRequest):
    original_question = request.question

    if request.clarification_answer:
        sql_result = generate_sql(original_question, request.clarification_answer)
        return QueryResponse(
            original_question=original_question,
            is_ambiguous=False,
            clarification_questions=[],
            clarified_question=f"{original_question} | Clarification: {request.clarification_answer}",
            sql_query=sql_result.query,
            explanation=sql_result.explanation
        )

    ambiguity = detect_ambiguity(original_question)

    if ambiguity.is_ambiguous:
        return QueryResponse(
            original_question=original_question,
            is_ambiguous=True,
            clarification_questions=ambiguity.clarification_questions
        )

    sql_result = generate_sql(original_question)

    return QueryResponse(
        original_question=original_question,
        is_ambiguous=False,
        clarification_questions=[],
        sql_query=sql_result.query,
        explanation=sql_result.explanation
    )


def serialize_value(val):
    if val is None:
        return None
    if isinstance(val, (datetime, date)):
        return val.isoformat()
    if isinstance(val, Decimal):
        return float(val)
    return val


@app.post("/execute")
async def execute_query(request: QueryRequest):
    try:
        sql_result = generate_sql(request.question, request.clarification_answer)

        if not sql_result.query:
            return {"error": "Failed to generate SQL", "details": sql_result.explanation}

        conn = get_db_connection()
        with conn.cursor() as cur:
            cur.execute(sql_result.query)
            columns = [desc[0] for desc in cur.description]
            rows = cur.fetchall()
        conn.close()

        results = [dict(zip(columns, [serialize_value(v) for v in row])) for row in rows]

        return {
            "sql": sql_result.query,
            "explanation": sql_result.explanation,
            "results": results
        }
    except Exception as e:
        return {"error": str(e)}


@app.get("/health")
async def health_check():
    return {"status": "ok"}


@app.get("/evaluation-results")
async def get_evaluation_results():
    results_path = os.path.join(os.path.dirname(__file__), "..", "evaluation_results.json")
    try:
        with open(results_path, "r") as f:
            return json.load(f)
    except FileNotFoundError:
        return {"error": "Evaluation results not found"}

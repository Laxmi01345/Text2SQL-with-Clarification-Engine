from llm.gemini_client import get_response
from models.schemas import AmbiguityCheck
import json


SCHEMA = """customers(customer_id, customer_city, customer_state), orders(order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_customer_date), reviews(review_id, order_id, review_score, review_comment_message), payments(order_id, payment_type, payment_installments, payment_value), sellers(seller_id, seller_city, seller_state), products(product_id, product_category_name), order_items(order_id, product_id, seller_id, price, freight_value)
Data range: 2016-09 to 2018-08"""

AMBIGUITY_PROMPT = """Determine if this question needs clarification before writing SQL.

AMBIGUOUS: vague terms ("best", "top", "show me customers"), no time period, unclear metric.
CLEAR: specific columns, conditions, time ranges given.

{question}

Database: {schema}

Return ONLY this JSON, nothing else:
{{"is_ambiguous": true, "reason": "why", "clarification_questions": ["q1", "q2"]}}

If CLEAR, return:
{{"is_ambiguous": false, "reason": "clear question", "clarification_questions": []}}"""


def extract_json(text: str) -> dict:
    text = text.strip()
    if "```" in text:
        parts = text.split("```")
        for part in parts:
            part = part.strip()
            if part.startswith("json"):
                part = part[4:].strip()
            if part.startswith("{"):
                try:
                    return json.loads(part)
                except json.JSONDecodeError:
                    continue
    start = text.find("{")
    end = text.rfind("}") + 1
    if start != -1 and end > start:
        try:
            return json.loads(text[start:end])
        except json.JSONDecodeError:
            pass
    raise ValueError(f"No valid JSON found in: {text}")


def detect_ambiguity(question: str) -> AmbiguityCheck:
    prompt = AMBIGUITY_PROMPT.format(question=question, schema=SCHEMA)
    response = get_response(prompt)

    try:
        data = extract_json(response)
        return AmbiguityCheck(**data)
    except Exception as e:
        return AmbiguityCheck(
            is_ambiguous=True,
            reason=f"Error: {str(e)}",
            clarification_questions=["Can you rephrase more specifically?"]
        )

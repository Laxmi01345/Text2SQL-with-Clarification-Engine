from llm.gemini_client import get_response
from models.schemas import SQLQuery
import json


SCHEMA = """customers(customer_id, customer_city, customer_state), orders(order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_customer_date), reviews(review_id, order_id, review_score, review_comment_message), payments(order_id, payment_type, payment_installments, payment_value), sellers(seller_id, seller_city, seller_state), products(product_id, product_category_name), order_items(order_id, product_id, seller_id, price, freight_value)
JOINs: orders.customer_id=customers.customer_id, order_items.order_id=orders.order_id, order_items.product_id=products.product_id, order_items.seller_id=sellers.seller_id, payments.order_id=orders.order_id, reviews.order_id=orders.order_id"""

SQL_PROMPT = """Generate a PostgreSQL query.

Schema: {schema}

Question: {question}
{clarification}

Rules: Use aliases, LIMIT 100 default.

Return ONLY this JSON, nothing else:
{{"query": "SELECT ...", "explanation": "what it does"}}"""


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


def generate_sql(question: str, clarification_answer: str = None) -> SQLQuery:
    clarification = ""
    if clarification_answer:
        clarification = f"Clarification: {clarification_answer}"

    prompt = SQL_PROMPT.format(
        schema=SCHEMA,
        question=question,
        clarification=clarification
    )

    response = get_response(prompt)

    try:
        data = extract_json(response)
        return SQLQuery(**data)
    except Exception as e:
        return SQLQuery(
            query="",
            explanation=f"Error: {str(e)}"
        )

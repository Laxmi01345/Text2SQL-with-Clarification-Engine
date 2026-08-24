# Text2SQL with Clarification Engine

A natural language to SQL query converter that uses an intelligent Clarification Engine to detect ambiguous questions and ask follow-up clarifications before generating SQL queries.

---

## Why I Built This

SQL is powerful but not everyone knows how to write it. The goal was simple: **let anyone ask questions about their data in plain English and get accurate SQL queries back**.

But I quickly realized the real problem wasn't just converting text to SQL — it was **ambiguous questions**. When someone says "show me top customers", what do they mean? Top by revenue? By order count? By recency? Without clarifying, the LLM guesses — and often gets it wrong.

That's where the **Clarification Engine** comes in. It detects vague questions, asks the user to clarify, and then generates much more accurate SQL.

---

## How It Works

### The Flow

```
User Question
     │
     ▼
┌─────────────────────┐
│  Ambiguity Detector  │ ◄── LLM checks if question is vague
└─────────────────────┘
     │
     ├── Ambiguous ──► Ask Clarification ──► Generate SQL
     │
     └── Clear ──────► Generate SQL
                              │
                              ▼
                    ┌─────────────────┐
                    │  Execute on DB   │
                    └─────────────────┘
                              │
                              ▼
                       Return Results
```

### Step 1: Ambiguity Detection

The system sends the question to the LLM with the database schema and asks: *"Is this question clear enough to write SQL?"*

```python
AMBIGUITY_PROMPT = """Determine if this question needs clarification before writing SQL.

AMBIGUOUS: vague terms ("best", "top", "show me customers"), no time period, unclear metric.
CLEAR: specific columns, conditions, time ranges given.

{question}

Database: {schema}

Return ONLY this JSON, nothing else:
{{"is_ambiguous": true, "reason": "why", "clarification_questions": ["q1", "q2"]}}

If CLEAR, return:
{{"is_ambiguous": false, "reason": "clear question", "clarification_questions": []}}"""
```

**Example:**
- Question: "Show me top customers"
- Detection: `is_ambiguous: true`
- Clarification: "By total spend, top 10?"

### Step 2: SQL Generation

Once clarified, the system generates SQL using the database schema:

```python
SQL_PROMPT = """Generate a PostgreSQL query.

Schema: {schema}

Question: {question}
{clarification}

Rules: Use aliases, LIMIT 100 default.

Return ONLY this JSON, nothing else:
{{"query": "SELECT ...", "explanation": "what it does"}}"""
```

**Example:**
- Question: "Show me top customers"
- Clarification: "By total spend, top 10"
- Generated SQL:
```sql
SELECT c.customer_id, c.customer_city, SUM(p.payment_value) AS total_spend
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY c.customer_id, c.customer_city
ORDER BY total_spend DESC
LIMIT 10;
```

### Step 3: Multi-Provider LLM Fallback

The system uses Groq as primary LLM with Gemini as fallback for reliability:

```python
def get_response(prompt: str) -> str:
    if groq_client:
        try:
            print("  Trying Groq...")
            return get_groq_response(prompt)
        except Exception as e:
            print(f"  Groq failed: {e}")

    try:
        print("  Falling back to Gemini...")
        return get_gemini_response(prompt)
    except Exception as e:
        raise Exception(f"All providers failed.")
```

| Provider | Rate Limit | Purpose |
|----------|------------|---------|
| Groq | 1,000 req/day, 30 req/min | Primary (fast, free) |
| Gemini | 5 req/min | Fallback |

---

## Dataset: Brazilian E-Commerce by Olist

I used the [Olist Brazilian E-Commerce Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — a real-world dataset with 100K+ orders from 2016-2018.

### Tables Used

| Table | Description | Rows (Sample) |
|-------|-------------|---------------|
| `customers` | Customer info (city, state) | 500 |
| `orders` | Order details (status, dates) | 500 |
| `order_items` | Products per order (price, freight) | 700 |
| `payments` | Payment info (type, value) | 600 |
| `products` | Product categories | 200 |
| `sellers` | Seller info (city, state) | 50 |
| `reviews` | Customer reviews (score, comments) | 500 |

### Sample Queries

**Q: "Show me top 10 cities by order count"**
```sql
SELECT c.customer_city AS city, COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_city
ORDER BY order_count DESC
LIMIT 10;
```
**Result:** Porto Alegre (17), Maceio (17), Aracaju (17)...

**Q: "What are the best products by revenue?"**
```sql
SELECT p.product_id, p.product_category_name, SUM(oi.price) AS total_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_category_name
ORDER BY total_revenue DESC
LIMIT 10;
```
**Result:** sinalizacao_e_seguranca (1464.0), utilidades_domesticas (1460.0)...

---

## Evaluation Results

I built an evaluation system with 10 test questions (easy, medium, hard) to compare accuracy with and without the clarification engine.

### Summary

| Metric | Without Clarification | With Clarification | Improvement |
|--------|----------------------|-------------------|-------------|
| **Avg Accuracy** | 67.9% | 91.0% | **+23.1%** |
| **Valid SQL** | 90.0% | 100.0% | +10.0% |
| **Successful Executions** | 90.0% | 100.0% | +10.0% |

### By Difficulty

| Difficulty | Without | With | Improvement |
|------------|---------|------|-------------|
| Easy (4 questions) | 54.6% | 85.0% | **+30.4%** |
| Medium (3 questions) | 75.0% | 95.0% | +20.0% |
| Hard (3 questions) | 78.7% | 95.0% | +16.3% |

### How Accuracy is Measured

Each generated SQL is scored on 4 criteria:

1. **Keyword Match (20%)** — Does SQL contain expected keywords (SELECT, JOIN, GROUP BY)?
2. **Table Match (20%)** — Does SQL use the correct tables?
3. **Column Match (30%)** — Do result columns match expected columns?
4. **Row Count (30%)** — Does result have expected number of rows?

---

## Tech Stack

| Component | Technology |
|-----------|------------|
| LLM (Primary) | Groq (OpenAI-compatible API) |
| LLM (Fallback) | Google Gemini |
| Database | PostgreSQL 17 |
| Backend | FastAPI + Uvicorn |
| Frontend | Streamlit |
| Python | 3.13 |

---

## Setup

### 1. Clone Repository
```bash
git clone https://github.com/Laxmi01345/Text2SQL-with-Clarification-Engine.git
cd Text2SQL-with-Clarification-Engine
```

### 2. Backend Setup
```bash
cd backend
python -m venv venv
venv\Scripts\activate  # Windows
pip install -r requirements.txt
```

### 3. Environment Variables
Create `backend/.env`:
```
GEMINI_API_KEY=your_gemini_key
GROQ_API_KEY=your_groq_key
DB_HOST=localhost
DB_NAME=olist_db
DB_USER=postgres
DB_PASSWORD=postgres
DB_PORT=5433
```

### 4. Database Setup
```bash
psql -U postgres -d olist_db -f database/sample_data.sql
```

### 5. Run Backend
```bash
cd backend
uvicorn api.main:app --reload --port 8000
```

### 6. Run Frontend
```bash
cd frontend
streamlit run app.py
```

---

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/query` | POST | Detect ambiguity and generate SQL |
| `/execute` | POST | Generate and execute SQL against PostgreSQL |
| `/evaluate` | GET | Run evaluation (10 test questions) |
| `/health` | GET | Health check |

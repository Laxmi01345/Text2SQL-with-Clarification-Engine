# Text2SQL

Natural language to SQL query converter with an intelligent Clarification Engine. Ask questions about your data in plain English, and get accurate SQL queries back.

## Features

- **Clarification Engine** - Detects ambiguous questions and asks follow-up clarifications before generating SQL
- **Multi-Provider LLM** - Groq (primary) with Gemini fallback for reliability
- **PostgreSQL Execution** - Generates and executes SQL against PostgreSQL databases
- **Streamlit UI** - Chat interface with real-time SQL display and result tables
- **Evaluation System** - Compares accuracy with vs without clarification engine

## Tech Stack

| Component | Technology |
|-----------|------------|
| LLM (Primary) | Groq (OpenAI-compatible) |
| LLM (Fallback) | Google Gemini |
| Database | PostgreSQL |
| Backend | FastAPI |
| Frontend | Streamlit |

## Evaluation Results

| Metric | Without Clarification | With Clarification | Improvement |
|--------|----------------------|-------------------|-------------|
| Avg Accuracy | 67.9% | 91.0% | **+23.1%** |
| Valid SQL | 90.0% | 100.0% | +10.0% |
| Successful Executions | 90.0% | 100.0% | +10.0% |

## Setup

### 1. Clone Repository
```bash
git clone https://github.com/YOUR_USERNAME/text2sql.git
cd text2sql
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

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/query` | POST | Detect ambiguity and generate SQL |
| `/execute` | POST | Generate and execute SQL |
| `/evaluate` | GET | Run evaluation (10 test questions) |
| `/health` | GET | Health check |

## Project Structure

```
text2sql/
├── backend/
│   ├── api/
│   │   └── main.py          # FastAPI routes
│   ├── llm/
│   │   ├── gemini_client.py  # LLM client with fallback
│   │   ├── ambiguity_detector.py  # Ambiguity detection
│   │   └── sql_generator.py  # SQL generation
│   ├── models/
│   │   └── schemas.py        # Pydantic models
│   ├── evaluation.py         # Evaluation system
│   ├── evaluation_dataset.json  # Test questions
│   └── requirements.txt
├── frontend/
│   └── app.py                # Streamlit UI
├── database/
│   └── sample_data.sql       # Schema + sample data
└── README.md
```

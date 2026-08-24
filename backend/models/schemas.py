from pydantic import BaseModel
from typing import Optional


class AmbiguityCheck(BaseModel):
    is_ambiguous: bool
    reason: str
    clarification_questions: list[str]


class SQLQuery(BaseModel):
    query: str
    explanation: str


class QueryRequest(BaseModel):
    question: str
    clarification_answer: Optional[str] = None


class QueryResponse(BaseModel):
    original_question: str
    is_ambiguous: bool
    clarification_questions: list[str]
    clarified_question: Optional[str] = None
    sql_query: Optional[str] = None
    explanation: Optional[str] = None
    results: Optional[list[dict]] = None
    error: Optional[str] = None

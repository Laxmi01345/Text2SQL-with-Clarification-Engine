from llm.gemini_client import get_gemini_response


CLARIFICATION_PROMPT = """You are a clarification engine for database queries.

The user asked an ambiguous question. Generate a clear, specific follow-up question
that helps them get the exact SQL query they need.

Original question: {original_question}
Ambiguity reason: {ambiguity_reason}
Suggested clarifications: {clarification_questions}

Generate ONE clear follow-up question that resolves the ambiguity.
The question should be conversational and helpful.

Your response should be JUST the follow-up question, nothing else.
"""


def generate_clarification(original_question: str, ambiguity_reason: str, clarification_questions: list) -> str:
    prompt = CLARIFICATION_PROMPT.format(
        original_question=original_question,
        ambiguity_reason=ambiguity_reason,
        clarification_questions=clarification_questions
    )
    return get_gemini_response(prompt).strip()

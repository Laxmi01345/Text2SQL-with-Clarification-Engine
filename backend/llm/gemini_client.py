import google.generativeai as genai
from openai import OpenAI
from dotenv import load_dotenv
import os
import time

load_dotenv()

genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

groq_client = None
groq_key = os.getenv("GROQ_API_KEY")
if groq_key:
    groq_client = OpenAI(
        api_key=groq_key,
        base_url="https://api.groq.com/openai/v1"
    )

GROQ_MODEL = "openai/gpt-oss-20b"


def get_gemini_response(prompt: str, retries: int = 2) -> str:
    model = genai.GenerativeModel("gemini-3.6-flash")
    for attempt in range(retries):
        try:
            response = model.generate_content(
                prompt,
                generation_config=genai.GenerationConfig(
                    max_output_tokens=1024,
                    temperature=0.1,
                ),
            )
            return response.text
        except Exception as e:
            if "RESOURCE_EXHAUSTED" in str(e) or "429" in str(e):
                wait = 10 * (attempt + 1)
                print(f"  Gemini rate limited, waiting {wait}s...")
                time.sleep(wait)
            else:
                raise
    raise Exception("Gemini retries exceeded")


def get_groq_response(prompt: str, retries: int = 2) -> str:
    if not groq_client:
        raise Exception("Groq API key not configured")
    for attempt in range(retries):
        try:
            response = groq_client.chat.completions.create(
                model=GROQ_MODEL,
                messages=[{"role": "user", "content": prompt}],
                temperature=0.1,
                max_tokens=1024,
            )
            return response.choices[0].message.content
        except Exception as e:
            if "429" in str(e) or "rate" in str(e).lower():
                wait = 10 * (attempt + 1)
                print(f"  Groq rate limited, waiting {wait}s...")
                time.sleep(wait)
            else:
                raise
    raise Exception("Groq retries exceeded")


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
        print(f"  Gemini failed: {e}")
        raise Exception(f"All providers failed. Groq: not configured or failed; Gemini: {e}")


def get_gemini_response_standalone(prompt: str, retries: int = 3) -> str:
    """Standalone Gemini call without fallback (for evaluation)."""
    model = genai.GenerativeModel("gemini-3.6-flash")
    for attempt in range(retries):
        try:
            response = model.generate_content(
                prompt,
                generation_config=genai.GenerationConfig(
                    max_output_tokens=1024,
                    temperature=0.1,
                ),
            )
            return response.text
        except Exception as e:
            if "RESOURCE_EXHAUSTED" in str(e) or "429" in str(e):
                wait = 65
                print(f"  Gemini rate limited, waiting {wait}s...")
                time.sleep(wait)
            else:
                raise
    raise Exception("Gemini retries exceeded")

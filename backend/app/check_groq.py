"""Checks the configured Groq model with a short, real API request."""
import os
import sys
from pathlib import Path

from dotenv import load_dotenv

import httpx


def main() -> int:
    load_dotenv(Path(__file__).resolve().parents[1] / ".env")
    key = os.getenv("GROQ_API_KEY", "").strip()
    model = os.getenv("GROQ_MODEL", "llama-3.1-8b-instant").strip()
    if not key:
        print("GROQ_API_KEY is missing. Load backend/.env before running this check.")
        return 1
    try:
        response = httpx.post(
            "https://api.groq.com/openai/v1/chat/completions",
            headers={"Authorization": f"Bearer {key}"},
            json={"model": model, "messages": [
                {"role": "user", "content": "Reply with OK."}
            ], "max_tokens": 12},
            timeout=15,
        )
    except httpx.HTTPError as error:
        print(f"Could not reach Groq: {type(error).__name__}")
        return 1
    if response.status_code == 200:
        print(f"Groq is working with model: {model}")
        return 0
    reason = {401: "Invalid API key", 403: "API key is not authorized",
              404: "Model name not found", 429: "Groq rate limit reached"}.get(
                  response.status_code, "Request rejected")
    print(f"Groq returned HTTP {response.status_code}: {reason}")
    return 1


if __name__ == "__main__":
    sys.exit(main())

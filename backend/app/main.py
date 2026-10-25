"""Optional SkinX online educational chat API. Screening never calls this API."""
import json
import os
import re
import time
from collections import defaultdict, deque
from pathlib import Path

import httpx
from fastapi import Depends, FastAPI, Header, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

FAQ = json.loads((Path(__file__).parent / "skin_health_faq.json").read_text())
INTRO = "Educational information only. SkinX cannot diagnose skin conditions."
app = FastAPI(title="SkinX optional chat API", version="0.1.0")
origins = [x.strip() for x in os.getenv("CORS_ORIGINS", "").split(",") if x.strip()]
if origins:
    app.add_middleware(CORSMiddleware, allow_origins=origins, allow_methods=["GET", "POST"], allow_headers=["Authorization", "Content-Type"])

_limits: dict[str, deque[float]] = defaultdict(deque)


class ChatRequest(BaseModel):
    question: str = Field(min_length=3, max_length=500)


class ChatResponse(BaseModel):
    answer: str
    source: str | None = None
    mode: str = "online"


def match_faq(question: str) -> dict | None:
    """Small retrieval helper, not a medical triage or diagnosis classifier."""
    terms = set(re.findall(r"[a-z]{3,}", question.lower()))
    if not terms:
        return None
    best = None
    score = 0
    for entry in FAQ:
        keys = entry["keywords"] + entry["questions"]
        candidates = set(re.findall(r"[a-z]{3,}", " ".join(keys).lower()))
        hits = len(terms & candidates)
        if hits > score:
            score, best = hits, entry
    return best if score > 0 else None


async def user_id_from_token(authorization: str | None = Header(default=None)) -> str:
    """Validate the user's access token with Supabase Auth; never trust client claims."""
    url = os.getenv("SUPABASE_URL", "").rstrip("/")
    key = os.getenv("SUPABASE_PUBLISHABLE_KEY", "")
    if not url or not key:
        raise HTTPException(503, "Online chat authentication is not configured")
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(401, "Sign in to use online chat")
    token = authorization[7:]
    if len(token) > 8192:
        raise HTTPException(401, "Invalid authorization")
    try:
        async with httpx.AsyncClient(timeout=8) as client:
            response = await client.get(f"{url}/auth/v1/user", headers={"apikey": key, "Authorization": f"Bearer {token}"})
    except httpx.HTTPError:
        raise HTTPException(503, "Authentication unavailable") from None
    if response.status_code != 200:
        raise HTTPException(401, "Session expired or invalid")
    uid = response.json().get("id")
    if not uid:
        raise HTTPException(401, "Invalid account")
    return str(uid)


def check_rate_limit(uid: str) -> None:
    """Development-only per-process limit; replace with Redis for multiple workers."""
    now = time.monotonic()
    bucket = _limits[uid]
    while bucket and now - bucket[0] > 3600:
        bucket.popleft()
    if len(bucket) >= 20:
        raise HTTPException(429, "Online chat limit reached. Try again later or use offline answers.")
    bucket.append(now)


@app.get("/health")
def health() -> dict:
    return {"status": "ok", "chat_configured": bool(os.getenv("GROQ_API_KEY") and os.getenv("SUPABASE_URL") and os.getenv("SUPABASE_PUBLISHABLE_KEY"))}


@app.post("/chat", response_model=ChatResponse)
async def chat(payload: ChatRequest, uid: str = Depends(user_id_from_token)) -> ChatResponse:
    api_key = os.getenv("GROQ_API_KEY", "")
    if not api_key:
        raise HTTPException(503, "Online AI not enabled. Use offline education instead.")
    check_rate_limit(uid)
    question = payload.question.strip()
    # Do not take images or patient records. Only general education text is supported.
    entry = match_faq(question)
    if not entry:
        return ChatResponse(answer=f"{INTRO} I don't have an approved source for that question. Please ask a health professional if you are concerned.", mode="offline_fallback")
    system = (
        "You are SkinX's cautious skin-health EDUCATION assistant for people with albinism. "
        "Use only the approved reference below. Do not diagnose, prescribe, assign probabilities, "
        "explain specific photos, or promise the user a lesion is harmless. "
        "If the question asks for diagnosis or personalized assessment, say you cannot determine this and suggest a health professional. "
        "For a changing, bleeding, growing, or non-healing lesion suggest prompt clinical assessment. "
        "Write 2-4 short, plain-English sentences. Do not invent citations. "
        f"Approved reference: {entry['answer']}"
    )
    try:
        async with httpx.AsyncClient(timeout=20) as client:
            result = await client.post(
                "https://api.groq.com/openai/v1/chat/completions",
                headers={"Authorization": f"Bearer {api_key}"},
                json={"model": os.getenv("GROQ_MODEL", "llama-3.1-8b-instant"),
                      "temperature": 0.1, "max_tokens": 240,
                      "messages": [{"role": "system", "content": system}, {"role": "user", "content": question}]},
            )
            result.raise_for_status()
            answer = result.json()["choices"][0]["message"]["content"].strip()
    except (httpx.HTTPError, KeyError, IndexError, TypeError, ValueError):
        # Safe, known content remains available when the provider fails.
        return ChatResponse(answer=f"{entry['answer']}\n\n{INTRO}", source=entry['source'] or None, mode="offline_fallback")
    if not answer:
        answer = entry['answer']
    return ChatResponse(answer=f"{answer}\n\n{INTRO}", source=entry['source'] or None)

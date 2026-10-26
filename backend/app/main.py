"""SkinX online educational chat service."""
import os
import logging
from pathlib import Path

from dotenv import load_dotenv
import time
from collections import defaultdict, deque
from typing import Literal

import httpx
from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, ConfigDict, Field

load_dotenv(Path(__file__).resolve().parents[1] / ".env")
logger = logging.getLogger("skinx.chat")
app = FastAPI(title="SkinX Chat API", version="1.1.0")
origins = [value.strip() for value in os.getenv("CORS_ORIGINS", "").split(",") if value.strip()]
if origins:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=origins,
        allow_methods=["GET", "POST"],
        allow_headers=["Authorization", "Content-Type"],
    )

_limits: dict[str, deque[float]] = defaultdict(deque)


class ChatMessage(BaseModel):
    model_config = ConfigDict(extra="forbid")

    role: Literal["user", "assistant"]
    content: str = Field(min_length=1, max_length=1500)


class ChatRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    question: str = Field(min_length=1, max_length=1500)
    history: list[ChatMessage] = Field(default_factory=list, max_length=8)
    language: Literal["en", "rw"] = "en"


class ChatResponse(BaseModel):
    answer: str
    source: str | None = None
    mode: str = "online"


def check_rate_limit(identity: str) -> None:
    now = time.monotonic()
    bucket = _limits[identity]
    while bucket and now - bucket[0] > 3600:
        bucket.popleft()
    # Application-level cost protection, not a limit on conversation topics.
    if len(bucket) >= int(os.getenv("CHAT_HOURLY_LIMIT", "60")):
        raise HTTPException(429, "Chat is busy for this connection. Try again shortly.")
    bucket.append(now)


@app.get("/health")
def health() -> dict:
    return {"status": "ok", "chat_configured": bool(os.getenv("GROQ_API_KEY"))}


@app.post("/chat", response_model=ChatResponse)
async def chat(payload: ChatRequest, request: Request) -> ChatResponse:
    api_key = os.getenv("GROQ_API_KEY", "").strip()
    if not api_key:
        raise HTTPException(503, "GROQ_KEY_MISSING")

    # Never trust forwarding headers as a client identity without a trusted proxy.
    remote = request.client.host if request.client else "unknown"
    check_rate_limit(remote)

    system = (
        "You are SkinX, a friendly, clear conversational assistant in a skin-health education app "
        "used by people with albinism and community health workers in Rwanda. "
        "You can answer everyday questions and general questions on health, skin cancer, albinism, "
        "sun protection, education, and using the app. Do not limit answers to a predefined FAQ. "
        "Explain in simple, natural language. Be open about uncertainty, and never invent sources. "
        "Do not diagnose skin conditions or interpret someone's screening image, prescribe treatment, "
        "claim a screening result rules out cancer, or give an assurance that a lesion is harmless. "
        "For growing, bleeding or non-healing lesions, recommend prompt examination by a qualified "
        "health professional. For emergency symptoms, advise local urgent care. "
        "Screening itself happens on the phone and does not require this chat service. "
        "No image, screening record or account details are provided to you. "
        "Do not request identifying health details, and remind the user not to share them."
    )
    if payload.language == "rw":
        system += (" Respond in natural, clear Kinyarwanda. Use simple wording that a person "
                   "in Rwanda can understand. Keep medical explanations cautious. ")
    history = [{"role": item.role, "content": item.content} for item in payload.history]
    messages = [{"role": "system", "content": system}, *history,
                {"role": "user", "content": payload.question.strip()}]
    try:
        async with httpx.AsyncClient(timeout=30) as client:
            response = await client.post(
                "https://api.groq.com/openai/v1/chat/completions",
                headers={"Authorization": f"Bearer {api_key}"},
                json={
                    "model": os.getenv("GROQ_MODEL", "llama-3.1-8b-instant"),
                    "messages": messages,
                    "temperature": 0.3,
                    "max_tokens": 550,
                },
            )
            if response.status_code >= 400:
                logger.warning("Groq chat returned HTTP %s", response.status_code)
                if response.status_code in (401, 403):
                    raise HTTPException(503, "GROQ_AUTH_FAILED")
                if response.status_code == 404:
                    raise HTTPException(503, "GROQ_MODEL_NOT_FOUND")
                if response.status_code == 429:
                    raise HTTPException(503, "GROQ_RATE_LIMITED")
                if response.status_code == 400:
                    raise HTTPException(503, "GROQ_REQUEST_REJECTED")
                raise HTTPException(503, "GROQ_UNAVAILABLE")
            answer = response.json()["choices"][0]["message"]["content"].strip()
    except httpx.TimeoutException:
        logger.warning("Groq chat timed out")
        raise HTTPException(503, "GROQ_TIMEOUT") from None
    except httpx.HTTPError:
        logger.warning("Groq chat could not be reached")
        raise HTTPException(503, "GROQ_NETWORK_ERROR") from None
    except (ValueError, TypeError, KeyError, IndexError, AttributeError):
        raise HTTPException(503, "Online chat returned an invalid response") from None

    if not answer:
        raise HTTPException(503, "Online chat returned an empty response")
    return ChatResponse(answer=answer)

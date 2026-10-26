import pytest
import httpx
from fastapi.testclient import TestClient
from app.main import app, _limits

client = TestClient(app)


def test_health(monkeypatch):
    monkeypatch.setenv('GROQ_API_KEY', 'test-key')
    response = client.get('/health')
    assert response.status_code == 200
    assert response.json() == {'status': 'ok', 'chat_configured': True}


def test_chat_requires_configuration(monkeypatch):
    monkeypatch.delenv('GROQ_API_KEY', raising=False)
    response = client.post('/chat', json={'question': 'What is albinism?'})
    assert response.status_code == 503


def test_unauthenticated_open_conversation(monkeypatch):
    monkeypatch.setenv('GROQ_API_KEY', 'test-key')
    _limits.clear()
    captured = {}

    class FakeClient:
        async def __aenter__(self):
            return self

        async def __aexit__(self, *args):
            return False

        async def post(self, url, headers=None, json=None):
            captured['body'] = json
            return httpx.Response(200, json={'choices': [{'message': {'content': 'Hello there!'}}]},
                                  request=httpx.Request('POST', url))

    monkeypatch.setattr('app.main.httpx.AsyncClient', lambda **kwargs: FakeClient())
    response = client.post('/chat', json={
        'question': 'Can we just talk?',
        'history': [{'role': 'user', 'content': 'Hi'}],
    })
    assert response.status_code == 200
    assert response.json()['answer'] == 'Hello there!'
    assert captured['body']['messages'][-2:] == [
        {'role': 'user', 'content': 'Hi'},
        {'role': 'user', 'content': 'Can we just talk?'},
    ]
    assert 'Bearer test-key' not in str(captured['body'])


def test_rejects_long_question(monkeypatch):
    monkeypatch.setenv('GROQ_API_KEY', 'test-key')
    response = client.post('/chat', json={'question': 'x' * 1501})
    assert response.status_code == 422


def test_rate_limit(monkeypatch):
    monkeypatch.setenv('GROQ_API_KEY', 'test-key')
    monkeypatch.setenv('CHAT_HOURLY_LIMIT', '0')
    _limits.clear()
    response = client.post('/chat', json={'question': 'Hi'})
    assert response.status_code == 429


def test_rejects_image_payload(monkeypatch):
    monkeypatch.setenv('GROQ_API_KEY', 'test-key')
    response = client.post('/chat', json={'question': 'Hello', 'image': 'base64-placeholder'})
    assert response.status_code == 422


def test_rejects_too_much_history(monkeypatch):
    monkeypatch.setenv('GROQ_API_KEY', 'test-key')
    response = client.post('/chat', json={'question': 'Hello',
        'history': [{'role': 'user', 'content': 'Hi'}] * 9})
    assert response.status_code == 422


def test_groq_bad_key_reports_a_reason(monkeypatch):
    monkeypatch.setenv('GROQ_API_KEY', 'invalid-test-key')
    _limits.clear()

    class FakeClient:
        async def __aenter__(self):
            return self

        async def __aexit__(self, *args):
            return False

        async def post(self, url, headers=None, json=None):
            return httpx.Response(401, json={'error': {'message': 'Sensitive provider details'}},
                                  request=httpx.Request('POST', url))

    monkeypatch.setattr('app.main.httpx.AsyncClient', lambda **kwargs: FakeClient())
    response = client.post('/chat', json={'question': 'Hello'})
    assert response.status_code == 503
    assert response.json()['detail'] == 'GROQ_AUTH_FAILED'
    assert 'Sensitive' not in response.text


def test_kinyarwanda_language_is_passed_to_model(monkeypatch):
    monkeypatch.setenv('GROQ_API_KEY', 'test-key')
    _limits.clear()
    captured = {}

    class FakeClient:
        async def __aenter__(self):
            return self

        async def __aexit__(self, *args):
            return False

        async def post(self, url, headers=None, json=None):
            captured['data'] = json
            return httpx.Response(200, json={'choices': [{'message': {'content': 'Ni byiza.'}}]},
                                  request=httpx.Request('POST', url))

    monkeypatch.setattr('app.main.httpx.AsyncClient', lambda **kwargs: FakeClient())
    response = client.post('/chat', json={'question': 'Muraho', 'language': 'rw'})
    assert response.status_code == 200
    assert 'Kinyarwanda' in captured['data']['messages'][0]['content']

from fastapi.testclient import TestClient
from app.main import app, match_faq, user_id_from_token

client = TestClient(app)

def test_health():
    response = client.get('/health')
    assert response.status_code == 200
    assert response.json()['status'] == 'ok'

def test_faq():
    assert match_faq('How can I use sunscreen?')['id'] == 'prevention'
    assert match_faq('SCC') is not None

def test_online_requires_auth():
    response = client.post('/chat', json={'question':'How do I use sunscreen?'})
    assert response.status_code in (401, 503)

def test_rejects_overlong():
    app.dependency_overrides[user_id_from_token] = lambda: 'test-user'
    try:
        response = client.post('/chat', json={'question': 'x'*501})
        assert response.status_code == 422
    finally:
        app.dependency_overrides.clear()


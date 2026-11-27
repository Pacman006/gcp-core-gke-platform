import unittest
from app.main import app

class TestHealthEndpoint(unittest.TestCase):
    def test_health_check(self):
        client = app.test_client()
        response = client.get("/health")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.get_json(), {"status": "healthy"})

if __name__ == "__main__":
    unittest.main()

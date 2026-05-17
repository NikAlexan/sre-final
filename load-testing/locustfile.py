"""
FoodDelivery Platform — Locust Load Test
Target: api-gateway (HTTP on port 80)

Traffic model (weighted tasks):
  40% — health checks            (lightweight, represents readiness polling)
  25% — list restaurants         (read-heavy, most common user action)
  15% — get restaurant menu      (read, per-restaurant drill-down)
  10% — user authentication      (login, generates JWT)
   5% — place an order           (write, heaviest backend path)
   5% — get order status         (read after write)

Run headlessly (from within the cluster):
  locust -f locustfile.py --headless -u 100 -r 10 --run-time 5m \
         --host http://api-gateway

Run with web UI (port-forwarded):
  locust -f locustfile.py --host http://api-gateway
  # then open http://localhost:8089
"""

import random
import string
from locust import HttpUser, task, between, events


def _rand_email() -> str:
    tag = "".join(random.choices(string.ascii_lowercase, k=6))
    return f"testuser_{tag}@locust.test"


class FoodDeliveryUser(HttpUser):
    """Simulates an anonymous + authenticated food delivery customer."""

    wait_time = between(0.5, 2.0)

    # JWT token obtained after login (None until login() runs)
    _token: str | None = None

    def on_start(self):
        """Optionally pre-authenticate so authenticated tasks can use the token."""
        self._login()

    # ── Read paths ────────────────────────────────────────────────────────────

    @task(8)
    def health_check(self):
        self.client.get("/health", name="/health")

    @task(5)
    def list_restaurants(self):
        self.client.get("/api/v1/restaurants", name="GET /api/v1/restaurants",
                        headers=self._auth_headers())

    @task(3)
    def get_restaurant_menu(self):
        restaurant_id = random.randint(1, 20)
        self.client.get(
            f"/api/v1/restaurants/{restaurant_id}/menu",
            name="GET /api/v1/restaurants/[id]/menu",
            headers=self._auth_headers(),
        )

    @task(2)
    def get_order_status(self):
        order_id = random.randint(1, 200)
        self.client.get(
            f"/api/v1/orders/{order_id}",
            name="GET /api/v1/orders/[id]",
            headers=self._auth_headers(),
        )

    # ── Write paths ───────────────────────────────────────────────────────────

    @task(2)
    def login(self):
        self._login()

    @task(1)
    def place_order(self):
        payload = {
            "restaurant_id": random.randint(1, 20),
            "delivery_address": "123 Test Street, Amsterdam",
            "items": [
                {
                    "product_id": random.randint(1, 50),
                    "quantity": random.randint(1, 3),
                }
            ],
        }
        self.client.post(
            "/api/v1/orders",
            json=payload,
            name="POST /api/v1/orders",
            headers=self._auth_headers(),
        )

    @task(1)
    def register_user(self):
        payload = {
            "name": "Load Test User",
            "email": _rand_email(),
            "password": "LoadTest@123",
            "phone": "+31612345678",
        }
        self.client.post(
            "/api/v1/auth/register",
            json=payload,
            name="POST /api/v1/auth/register",
        )

    # ── Helpers ───────────────────────────────────────────────────────────────

    def _login(self):
        with self.client.post(
            "/api/v1/auth/login",
            json={"email": "sre-loadtest@example.com", "password": "LoadTest@123"},
            name="POST /api/v1/auth/login",
            catch_response=True,
        ) as resp:
            if resp.status_code == 200:
                data = resp.json()
                # Handle both {"token": "..."} and {"data": {"token": "..."}}
                self._token = data.get("token") or (
                    data.get("data", {}).get("token") if isinstance(data.get("data"), dict) else None
                )
                resp.success()
            else:
                # 401/404 are expected during load test (test user may not exist)
                resp.success()

    def _auth_headers(self) -> dict:
        if self._token:
            return {"Authorization": f"Bearer {self._token}"}
        return {}


class HeavyWriteUser(HttpUser):
    """
    Simulates a burst of write traffic — used for spike testing.
    Spawn a small percentage of these (e.g. 10% of total users) to stress
    the order-service and delivery-service backends.
    """

    wait_time = between(0.2, 0.8)
    weight = 1  # 1 HeavyWriteUser spawned per 9 FoodDeliveryUsers

    @task(3)
    def burst_orders(self):
        payload = {
            "restaurant_id": random.randint(1, 5),
            "delivery_address": "Spike Test Avenue 99",
            "items": [{"product_id": random.randint(1, 10), "quantity": 2}],
        }
        self.client.post(
            "/api/v1/orders",
            json=payload,
            name="POST /api/v1/orders (burst)",
        )

    @task(1)
    def burst_health(self):
        self.client.get("/health", name="/health (burst)")

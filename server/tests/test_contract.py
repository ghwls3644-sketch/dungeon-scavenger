import asyncio
import json
import unittest

from websockets.asyncio.client import connect
from websockets.asyncio.server import serve

from app import handle_client


class ContractHarnessTest(unittest.IsolatedAsyncioTestCase):
    async def asyncSetUp(self) -> None:
        self.server = await serve(handle_client, "127.0.0.1", 0)
        assert self.server.sockets is not None
        self.port = self.server.sockets[0].getsockname()[1]
        self.ws = await connect(f"ws://127.0.0.1:{self.port}")

        hello = await self._recv_type("hello")
        self.assertEqual(hello["threatState"], "Idle")
        self.assertEqual(hello["dangerScore"], 0.0)

    async def asyncTearDown(self) -> None:
        await self.ws.close()
        self.server.close()
        await self.server.wait_closed()

    async def _send(self, payload: dict) -> None:
        await self.ws.send(json.dumps(payload))

    async def _recv(self) -> dict:
        raw = await asyncio.wait_for(self.ws.recv(), timeout=2.5)
        return json.loads(raw)

    async def _recv_type(self, message_type: str) -> dict:
        while True:
            message = await self._recv()
            if message.get("type") == message_type:
                return message

    async def _send_event(self, event_name: str, payload: dict | None = None) -> tuple[dict, dict]:
        await self._send({"type": "run_event", "event": event_name, "payload": payload or {}})
        ack = await self._recv_type("event_ack")
        update = await self._recv_type("threat_update")
        return ack, update

    async def test_client_ready_returns_tick(self) -> None:
        await self._send({"type": "client_ready"})
        msg = await self._recv_type("tick")
        self.assertEqual(msg["note"], "Client ready")
        self.assertEqual(msg["tick"], 0)

    async def test_trap_trigger_increases_danger_and_sets_investigating(self) -> None:
        ack, update = await self._send_event("trap_trigger", {"trapId": "T-01"})
        self.assertEqual(ack["note"], "ack:trap_trigger")
        self.assertEqual(update["threatState"], "Investigating")
        self.assertEqual(update["dangerScore"], 14.0)

    async def test_chaser_hit_sets_chasing(self) -> None:
        _, update = await self._send_event("chaser_hit", {"health": 92})
        self.assertEqual(update["threatState"], "Chasing")
        self.assertGreaterEqual(update["dangerScore"], 15.0)

    async def test_run_extract_resets_to_idle(self) -> None:
        await self._send_event("chaser_spotted", {"distance": 10})
        _, update = await self._send_event("run_extract", {"extractValue": 100})
        self.assertEqual(update["threatState"], "Idle")
        self.assertGreaterEqual(update["dangerScore"], 0.0)

    async def test_danger_score_is_clamped(self) -> None:
        for _ in range(10):
            _, update = await self._send_event("chaser_hit", {"health": 90})
        self.assertLessEqual(update["dangerScore"], 100.0)
        self.assertGreaterEqual(update["dangerScore"], 0.0)


if __name__ == "__main__":
    unittest.main()

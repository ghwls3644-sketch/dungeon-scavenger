import asyncio
import json
import unittest

from websockets.asyncio.client import connect
from websockets.asyncio.server import serve

from app import handle_client


class TransitionMatrixTest(unittest.IsolatedAsyncioTestCase):
    async def asyncSetUp(self) -> None:
        self.server = await serve(handle_client, "127.0.0.1", 0)
        assert self.server.sockets is not None
        self.port = self.server.sockets[0].getsockname()[1]

    async def asyncTearDown(self) -> None:
        self.server.close()
        await self.server.wait_closed()

    async def _recv(self, ws) -> dict:
        raw = await asyncio.wait_for(ws.recv(), timeout=2.5)
        return json.loads(raw)

    async def _recv_type(self, ws, message_type: str) -> dict:
        while True:
            message = await self._recv(ws)
            if message.get("type") == message_type:
                return message

    async def _run_case(self, event_name: str, payload: dict, expected_state: str, expected_score: float) -> None:
        async with connect(f"ws://127.0.0.1:{self.port}") as ws:
            hello = await self._recv_type(ws, "hello")
            self.assertEqual(hello["threatState"], "Idle")
            self.assertEqual(hello["dangerScore"], 0.0)

            await ws.send(json.dumps({"type": "run_event", "event": event_name, "payload": payload}))
            ack = await self._recv_type(ws, "event_ack")
            update = await self._recv_type(ws, "threat_update")

            self.assertEqual(ack["note"], f"ack:{event_name}")
            self.assertEqual(update["threatState"], expected_state)
            self.assertEqual(update["dangerScore"], expected_score)

    async def test_event_transition_matrix_from_idle(self) -> None:
        cases: list[tuple[str, dict, str, float]] = [
            ("run_start", {"runNumber": 1}, "Idle", 0.0),
            ("trap_trigger", {"trapId": "T-01"}, "Investigating", 14.0),
            ("loot_pick", {"lootId": "L-01"}, "Idle", 3.0),
            ("loot_drop", {"lootId": "L-01"}, "Idle", 2.0),
            ("chaser_spotted", {"distance": 12.3}, "Chasing", 8.0),
            ("chaser_hit", {"health": 92}, "Chasing", 15.0),
            ("run_extract", {"extractValue": 120}, "Idle", 0.0),
            ("run_fail", {"carriedValue": 420}, "Idle", 0.0),
        ]

        for event_name, payload, expected_state, expected_score in cases:
            with self.subTest(event=event_name):
                await self._run_case(event_name, payload, expected_state, expected_score)


if __name__ == "__main__":
    unittest.main()

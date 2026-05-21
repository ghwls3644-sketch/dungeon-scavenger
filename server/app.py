import asyncio
import contextlib
import json
from typing import Any

from websockets.asyncio.server import serve


def clamp(value: float, min_value: float, max_value: float) -> float:
    return max(min_value, min(max_value, value))


async def handle_client(websocket) -> None:
    tick = 0
    danger_score = 0.0
    threat_state = "Idle"

    async def send_message(payload: dict[str, Any]) -> None:
        await websocket.send(json.dumps(payload))

    async def send_threat_update(note: str) -> None:
        await send_message(
            {
                "type": "threat_update",
                "tick": tick,
                "note": note,
                "threatState": threat_state,
                "dangerScore": round(danger_score, 1),
            }
        )

    await send_message(
        {
            "type": "hello",
            "tick": tick,
            "note": "Server connected",
            "threatState": threat_state,
            "dangerScore": danger_score,
        }
    )

    async def ticker() -> None:
        nonlocal tick, danger_score, threat_state
        while True:
            await asyncio.sleep(1.0)
            tick += 1
            danger_score = clamp(danger_score - 1.8, 0, 100)
            if danger_score < 15:
                threat_state = "Idle"
            await send_message(
                {
                    "type": "tick",
                    "tick": tick,
                    "note": f"heartbeat danger={danger_score:.1f}",
                    "threatState": threat_state,
                    "dangerScore": round(danger_score, 1),
                }
            )

    ticker_task = asyncio.create_task(ticker())
    try:
        async for message in websocket:
            payload: dict[str, Any] = json.loads(message)
            message_type = str(payload.get("type", ""))

            if message_type == "client_ready":
                await send_message(
                    {
                        "type": "tick",
                        "tick": tick,
                        "note": "Client ready",
                        "threatState": threat_state,
                        "dangerScore": round(danger_score, 1),
                    }
                )
                continue

            if message_type != "run_event":
                continue

            event_name = str(payload.get("event", "unknown"))
            event_payload = payload.get("payload", {})
            print(f"[run_event] {event_name}: {event_payload}")

            if event_name == "trap_trigger":
                danger_score = clamp(danger_score + 14, 0, 100)
                threat_state = "Investigating"
            elif event_name == "loot_pick":
                danger_score = clamp(danger_score + 3, 0, 100)
            elif event_name == "loot_drop":
                danger_score = clamp(danger_score + 2, 0, 100)
            elif event_name == "chaser_spotted":
                danger_score = clamp(danger_score + 8, 0, 100)
                threat_state = "Chasing"
            elif event_name == "chaser_hit":
                danger_score = clamp(danger_score + 15, 0, 100)
                threat_state = "Chasing"
            elif event_name == "run_extract":
                danger_score = clamp(danger_score - 30, 0, 100)
                threat_state = "Idle"
            elif event_name == "run_fail":
                danger_score = clamp(danger_score - 40, 0, 100)
                threat_state = "Idle"
            elif event_name == "run_start":
                danger_score = clamp(danger_score - 10, 0, 100)
                if danger_score < 20:
                    threat_state = "Idle"

            await send_message({"type": "event_ack", "tick": tick, "note": f"ack:{event_name}"})
            await send_threat_update(note=f"threat update from {event_name}")
    finally:
        ticker_task.cancel()
        with contextlib.suppress(asyncio.CancelledError):
            await ticker_task


async def main() -> None:
    async with serve(handle_client, "127.0.0.1", 8765):
        print("Dungeon Scavenger server listening on ws://127.0.0.1:8765")
        await asyncio.Future()


if __name__ == "__main__":
    asyncio.run(main())

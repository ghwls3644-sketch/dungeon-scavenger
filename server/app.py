import asyncio
import contextlib
import json
from typing import Any

from websockets.asyncio.server import serve


async def handle_client(websocket) -> None:
    tick = 0
    await websocket.send(
        json.dumps({"type": "hello", "tick": tick, "note": "서버 연결 완료"})
    )

    async def ticker() -> None:
        nonlocal tick
        while True:
            await asyncio.sleep(1.0)
            tick += 1
            await websocket.send(
                json.dumps({"type": "tick", "tick": tick, "note": "런타임 heartbeat"})
            )

    ticker_task = asyncio.create_task(ticker())
    try:
        async for message in websocket:
            payload: dict[str, Any] = json.loads(message)
            if payload.get("type") == "client_ready":
                await websocket.send(
                    json.dumps(
                        {
                            "type": "tick",
                            "tick": tick,
                            "note": "클라이언트 준비 완료, Sprint 1 시작 가능",
                        }
                    )
                )
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

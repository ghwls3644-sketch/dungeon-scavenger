import argparse
import asyncio
import json
from pathlib import Path
from typing import Any

from websockets.asyncio.client import connect


def load_scenario(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


async def recv_until_types(ws, expected_types: set[str], timeout: float) -> list[dict[str, Any]]:
    collected: list[dict[str, Any]] = []
    seen: set[str] = set()

    while not expected_types.issubset(seen):
        raw = await asyncio.wait_for(ws.recv(), timeout=timeout)
        message = json.loads(raw)
        collected.append(message)
        msg_type = str(message.get("type", ""))
        if msg_type in expected_types:
            seen.add(msg_type)

    return collected


def validate_trace(trace: list[dict[str, Any]]) -> None:
    for msg in trace:
        msg_type = str(msg.get("type", ""))
        if msg_type in {"hello", "tick", "threat_update"}:
            danger = float(msg.get("dangerScore", 0.0))
            if danger < 0 or danger > 100:
                raise ValueError(f"dangerScore out of range: {danger}")


def last_message_of_type(trace: list[dict[str, Any]], message_type: str) -> dict[str, Any] | None:
    for msg in reversed(trace):
        if str(msg.get("type", "")) == message_type:
            return msg
    return None


def assert_expectations(scenario: dict[str, Any], trace: list[dict[str, Any]]) -> None:
    expect = scenario.get("expect", {})
    if not expect:
        return

    require_types = expect.get("requireTypes", [])
    if require_types:
        found_types = {str(msg.get("type", "")) for msg in trace}
        for required_type in require_types:
            if required_type not in found_types:
                raise AssertionError(f"missing required message type: {required_type}")

    ack_sequence = expect.get("ackSequence", [])
    if ack_sequence:
        ack_notes = [str(msg.get("note", "")) for msg in trace if str(msg.get("type", "")) == "event_ack"]
        expected_notes = [f"ack:{event_name}" for event_name in ack_sequence]
        if ack_notes != expected_notes:
            raise AssertionError(f"ack sequence mismatch: expected={expected_notes} actual={ack_notes}")

    final_state_msg = (
        last_message_of_type(trace, "threat_update")
        or last_message_of_type(trace, "tick")
        or last_message_of_type(trace, "hello")
    )
    if final_state_msg is None:
        raise AssertionError("no state-bearing message found in trace")

    if "finalThreatState" in expect:
        actual_state = str(final_state_msg.get("threatState", ""))
        expected_state = str(expect["finalThreatState"])
        if actual_state != expected_state:
            raise AssertionError(
                f"finalThreatState mismatch: expected={expected_state} actual={actual_state}"
            )

    if "dangerScoreMin" in expect or "dangerScoreMax" in expect:
        score = float(final_state_msg.get("dangerScore", 0.0))
        min_score = float(expect.get("dangerScoreMin", score))
        max_score = float(expect.get("dangerScoreMax", score))
        if score < min_score or score > max_score:
            raise AssertionError(
                f"final dangerScore out of expected range: score={score} range=[{min_score}, {max_score}]"
            )


async def run_scenario(
    ws_url: str, scenario: dict[str, Any], timeout: float, settle_sec: float
) -> list[dict[str, Any]]:
    trace: list[dict[str, Any]] = []
    events = scenario.get("events", [])

    async with connect(ws_url) as ws:
        initial = await recv_until_types(ws, {"hello"}, timeout=timeout)
        trace.extend(initial)

        await ws.send(json.dumps({"type": "client_ready"}))
        trace.extend(await recv_until_types(ws, {"tick"}, timeout=timeout))

        for event in events:
            name = str(event["event"])
            payload = event.get("payload", {})
            await ws.send(json.dumps({"type": "run_event", "event": name, "payload": payload}))
            trace.extend(await recv_until_types(ws, {"event_ack", "threat_update"}, timeout=timeout))

            delay = float(event.get("afterSec", 0))
            if delay > 0:
                await asyncio.sleep(delay)

        if settle_sec > 0:
            await asyncio.sleep(settle_sec)

    validate_trace(trace)
    assert_expectations(scenario, trace)
    return trace


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Replay client->server run_event scenarios.")
    parser.add_argument("scenario", type=str, help="Path to scenario json")
    parser.add_argument(
        "--url",
        type=str,
        default="ws://127.0.0.1:8765",
        help="Websocket server URL (default: ws://127.0.0.1:8765)",
    )
    parser.add_argument(
        "--timeout",
        type=float,
        default=2.5,
        help="Per-message receive timeout in seconds",
    )
    parser.add_argument(
        "--settle-sec",
        type=float,
        default=0.0,
        help="Optional settle delay after final event",
    )
    parser.add_argument(
        "--out",
        type=str,
        default="",
        help="Optional output path for replay trace JSON",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    scenario_path = Path(args.scenario)
    scenario = load_scenario(scenario_path)
    trace = asyncio.run(run_scenario(args.url, scenario, args.timeout, args.settle_sec))

    out_path = Path(args.out) if args.out else scenario_path.with_suffix(".trace.json")
    with out_path.open("w", encoding="utf-8") as f:
        json.dump(
            {
                "scenario": scenario.get("name", scenario_path.stem),
                "serverUrl": args.url,
                "messages": trace,
            },
            f,
            ensure_ascii=False,
            indent=2,
        )

    print(f"Replay complete: {scenario.get('name', scenario_path.stem)}")
    print(f"Trace written to: {out_path}")
    print(f"Message count: {len(trace)}")


if __name__ == "__main__":
    main()

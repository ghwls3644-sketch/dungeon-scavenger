export type SocketSnapshot = {
  status: "connecting" | "connected" | "disconnected";
  tick: number;
  note: string;
  threatState: string;
  dangerScore: number;
};

type ServerEnvelope = {
  type: "hello" | "tick" | "event_ack" | "threat_update";
  tick: number;
  note: string;
  threatState?: string;
  dangerScore?: number;
};

export type ClientEventSender = (event: string, payload?: Record<string, unknown>) => void;

export function connectGameSocket(
  onUpdate: (s: SocketSnapshot) => void,
  onReady?: (sendEvent: ClientEventSender) => void
) {
  const ws = new WebSocket("ws://127.0.0.1:8765");
  const current: SocketSnapshot = {
    status: "connecting",
    tick: 0,
    note: "Connecting...",
    threatState: "Idle",
    dangerScore: 0
  };
  onUpdate({ ...current });

  const sendEvent: ClientEventSender = (event, payload = {}) => {
    if (ws.readyState !== WebSocket.OPEN) return;
    ws.send(
      JSON.stringify({
        type: "run_event",
        event,
        payload
      })
    );
  };

  ws.onopen = () => {
    ws.send(JSON.stringify({ type: "client_ready" }));
    onReady?.(sendEvent);
  };

  ws.onmessage = (event) => {
    const data = JSON.parse(event.data) as ServerEnvelope;
    current.status = "connected";
    current.tick = data.tick;
    current.note = data.note;
    if (typeof data.threatState === "string") current.threatState = data.threatState;
    if (typeof data.dangerScore === "number") current.dangerScore = data.dangerScore;
    onUpdate({ ...current });
  };

  ws.onclose = () => {
    onUpdate({
      ...current,
      status: "disconnected",
      tick: 0,
      note: "Connection closed"
    });
  };

  ws.onerror = () => {
    onUpdate({
      ...current,
      status: "disconnected",
      tick: 0,
      note: "Connection error"
    });
  };

  return () => ws.close();
}

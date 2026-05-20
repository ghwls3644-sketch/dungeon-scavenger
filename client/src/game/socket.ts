export type SocketSnapshot = {
  status: "connecting" | "connected" | "disconnected";
  tick: number;
  note: string;
};

type ServerEnvelope = {
  type: "hello" | "tick" | "event_ack";
  tick: number;
  note: string;
};

export type ClientEventSender = (event: string, payload?: Record<string, unknown>) => void;

export function connectGameSocket(
  onUpdate: (s: SocketSnapshot) => void,
  onReady?: (sendEvent: ClientEventSender) => void
) {
  const ws = new WebSocket("ws://127.0.0.1:8765");
  onUpdate({ status: "connecting", tick: 0, note: "Connecting..." });

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
    onUpdate({
      status: "connected",
      tick: data.tick,
      note: data.note
    });
  };

  ws.onclose = () => {
    onUpdate({ status: "disconnected", tick: 0, note: "Connection closed" });
  };

  ws.onerror = () => {
    onUpdate({ status: "disconnected", tick: 0, note: "Connection error" });
  };

  return () => ws.close();
}

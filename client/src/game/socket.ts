export type SocketSnapshot = {
  status: "connecting" | "connected" | "disconnected";
  tick: number;
  note: string;
};

type ServerEnvelope = {
  type: "hello" | "tick";
  tick: number;
  note: string;
};

export function connectGameSocket(onUpdate: (s: SocketSnapshot) => void) {
  const ws = new WebSocket("ws://127.0.0.1:8765");
  onUpdate({ status: "connecting", tick: 0, note: "연결 시도 중" });

  ws.onopen = () => {
    ws.send(JSON.stringify({ type: "client_ready" }));
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
    onUpdate({ status: "disconnected", tick: 0, note: "연결 종료" });
  };

  ws.onerror = () => {
    onUpdate({ status: "disconnected", tick: 0, note: "연결 오류" });
  };

  return () => ws.close();
}

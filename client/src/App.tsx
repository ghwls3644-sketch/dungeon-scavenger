import { useEffect, useState } from "react";
import { GameCanvas, type GameSnapshot } from "./game/GameCanvas";
import { connectGameSocket, type SocketSnapshot } from "./game/socket";

export function App() {
  const [snapshot, setSnapshot] = useState<SocketSnapshot>({
    status: "disconnected",
    tick: 0,
    note: "Waiting for server"
  });
  const [game, setGame] = useState<GameSnapshot>({
    roomId: "Entrance",
    position: { x: 0, y: 0 },
    inventoryCount: 0,
    carriedWeight: 0,
    lootRemaining: 0,
    noiseNow: 0,
    noiseTier: "Quiet",
    completedRuns: 0,
    lastExtractValue: 0,
    totalExtractedValue: 0,
    canExtract: false,
    runElapsedSec: 0,
    sessionElapsedSec: 0,
    lastRunDurationSec: 0,
    inputDebugLastKey: "-",
    inputDebugLastCode: "-",
    inputDebugPressedCount: 0
  });
  const [sendRunEvent, setSendRunEvent] = useState<
    ((event: string, payload?: Record<string, unknown>) => void) | null
  >(null);

  useEffect(() => {
    const cleanup = connectGameSocket(setSnapshot, (sendEvent) => {
      setSendRunEvent(() => sendEvent);
    });
    return cleanup;
  }, []);

  return (
    <main className="layout">
      <header className="panel">
        <h1>Dungeon Scavenger</h1>
        <p>Sprint 1 Vertical Slice Scaffold</p>
      </header>

      <section className="hud panel">
        <div className="hud-title">Server</div>
        <div>Socket: {snapshot.status}</div>
        <div>Server Tick: {snapshot.tick}</div>
        <div>Note: {snapshot.note}</div>
        <div className="hud-gap" />
        <div className="hud-title">Run Snapshot</div>
        <div>Room: {game.roomId}</div>
        <div>
          Pos: ({game.position.x.toFixed(0)}, {game.position.y.toFixed(0)})
        </div>
        <div>Inventory: {game.inventoryCount} / 8</div>
        <div>Weight: {game.carriedWeight.toFixed(1)} / 40</div>
        <div>Loot Left: {game.lootRemaining}</div>
        <div>Noise: {game.noiseNow.toFixed(1)} ({game.noiseTier})</div>
        <div>Completed Runs: {game.completedRuns}</div>
        <div>Last Extract: {game.lastExtractValue}</div>
        <div>Total Extracted: {game.totalExtractedValue}</div>
        <div>Run Time: {game.runElapsedSec.toFixed(1)}s</div>
        <div>Last Run Time: {game.lastRunDurationSec.toFixed(1)}s</div>
        <div>Session Time: {game.sessionElapsedSec.toFixed(1)}s</div>
        <div>Extract Ready: {game.canExtract ? "Yes" : "No"}</div>
        <div>Input Last Key: {game.inputDebugLastKey}</div>
        <div>Input Last Code: {game.inputDebugLastCode}</div>
        <div>Input Pressed: {game.inputDebugPressedCount}</div>
        <div className="hud-gap" />
        <div className="hint">Move: WASD / Arrow</div>
        <div className="hint">Run: Shift</div>
        <div className="hint">Loot: E</div>
        <div className="hint">Drop: Q</div>
        <div className="hint">Extract at Exit: Space</div>
      </section>

      <section className="canvas-shell panel">
        <GameCanvas
          onSnapshot={setGame}
          onRunEvent={(event, payload) => sendRunEvent?.(event, payload)}
        />
      </section>
    </main>
  );
}

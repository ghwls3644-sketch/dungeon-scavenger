import { useEffect, useState } from "react";
import { GameCanvas, type GameSnapshot } from "./game/GameCanvas";
import { connectGameSocket, type SocketSnapshot } from "./game/socket";

export function App() {
  const [snapshot, setSnapshot] = useState<SocketSnapshot>({
    status: "disconnected",
    tick: 0,
    note: "서버 대기 중"
  });
  const [game, setGame] = useState<GameSnapshot>({
    roomId: "Entrance",
    position: { x: 0, y: 0 },
    inventoryCount: 0,
    carriedWeight: 0,
    lootRemaining: 0,
    noiseNow: 0,
    noiseTier: "Quiet",
    runCount: 0,
    lastExtractValue: 0,
    totalExtractedValue: 0,
    canExtract: false
  });

  useEffect(() => {
    const cleanup = connectGameSocket(setSnapshot);
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
        <div>Runs: {game.runCount}</div>
        <div>Last Extract: {game.lastExtractValue}</div>
        <div>Total Extracted: {game.totalExtractedValue}</div>
        <div>Extract Ready: {game.canExtract ? "Yes" : "No"}</div>
        <div className="hud-gap" />
        <div className="hint">Move: WASD / Arrow</div>
        <div className="hint">Run: Shift</div>
        <div className="hint">Loot: E</div>
        <div className="hint">Drop: Q</div>
        <div className="hint">Extract at Exit: Space</div>
      </section>

      <section className="canvas-shell panel">
        <GameCanvas onSnapshot={setGame} />
      </section>
    </main>
  );
}

import { useEffect, useRef } from "react";
import {
  classifyThreatState,
  clamp,
  nextRunNumber,
  settleExtract,
  settleFail,
  type ThreatState
} from "./gameCore";

type Vec2 = { x: number; y: number };
type Rect = {
  id: string;
  kind: "room" | "corridor";
  x: number;
  y: number;
  w: number;
  h: number;
};

type Loot = {
  id: string;
  name: string;
  weight: number;
  value: number;
  pos: Vec2;
  picked: boolean;
};

type Trap = {
  id: string;
  pos: Vec2;
  radius: number;
  damage: number;
  noiseBoost: number;
  cooldownSec: number;
};

type InventoryItem = Omit<Loot, "pos" | "picked">;

export type GameSnapshot = {
  roomId: string;
  position: Vec2;
  inventoryCount: number;
  carriedWeight: number;
  lootRemaining: number;
  noiseNow: number;
  noiseTier: "Quiet" | "Caution" | "Loud" | "Critical";
  playerHealth: number;
  threatState: ThreatState;
  trapHits: number;
  failedRuns: number;
  chaserDistance: number;
  stashValue: number;
  totalRecoveredValue: number;
  lastRecoveredValue: number;
  lastFailureLossValue: number;
  completedRuns: number;
  lastExtractValue: number;
  totalExtractedValue: number;
  canExtract: boolean;
  runElapsedSec: number;
  sessionElapsedSec: number;
  lastRunDurationSec: number;
  inputDebugLastKey: string;
  inputDebugLastCode: string;
  inputDebugPressedCount: number;
};

const WIDTH = 760;
const HEIGHT = 460;
const PLAYER_RADIUS = 10;
const BASE_SPEED = 130;
const RUN_MULTIPLIER = 1.35;
const INVENTORY_SLOTS = 8;
const MAX_WEIGHT = 40;
const MAX_HEALTH = 100;
const RUN_START_POS: Vec2 = { x: 120, y: 100 };
const CHASER_SPAWN: Vec2 = { x: 650, y: 120 };

const WALKABLE_ZONES: Rect[] = [
  { id: "Entrance", kind: "room", x: 40, y: 40, w: 180, h: 120 },
  { id: "Storage", kind: "room", x: 280, y: 40, w: 180, h: 120 },
  { id: "Archive", kind: "room", x: 520, y: 40, w: 180, h: 120 },
  { id: "Flooded", kind: "room", x: 280, y: 240, w: 180, h: 140 },
  { id: "Exit", kind: "room", x: 520, y: 240, w: 180, h: 140 },
  { id: "C_AB", kind: "corridor", x: 220, y: 85, w: 60, h: 30 },
  { id: "C_BC", kind: "corridor", x: 460, y: 85, w: 60, h: 30 },
  { id: "C_BD", kind: "corridor", x: 355, y: 160, w: 30, h: 80 },
  { id: "C_DE", kind: "corridor", x: 460, y: 295, w: 60, h: 30 },
  { id: "C_CE", kind: "corridor", x: 595, y: 160, w: 30, h: 80 }
];

const TRAPS: Trap[] = [
  { id: "T-01", pos: { x: 510, y: 100 }, radius: 16, damage: 12, noiseBoost: 18, cooldownSec: 3.2 },
  { id: "T-02", pos: { x: 370, y: 208 }, radius: 16, damage: 10, noiseBoost: 15, cooldownSec: 3.0 }
];

const INITIAL_LOOT: Loot[] = [
  { id: "L-01", name: "Rusty Relic", weight: 5, value: 120, pos: { x: 330, y: 95 }, picked: false },
  { id: "L-02", name: "Ancient Coin", weight: 2, value: 90, pos: { x: 410, y: 125 }, picked: false },
  { id: "L-03", name: "Archive Lens", weight: 4, value: 150, pos: { x: 640, y: 110 }, picked: false },
  { id: "L-04", name: "Waterlogged Idol", weight: 7, value: 180, pos: { x: 350, y: 290 }, picked: false },
  { id: "L-05", name: "Exit Cache", weight: 6, value: 210, pos: { x: 610, y: 295 }, picked: false }
];

function distance(a: Vec2, b: Vec2) {
  const dx = a.x - b.x;
  const dy = a.y - b.y;
  return Math.hypot(dx, dy);
}

function zoneContainsPoint(zone: Rect, pos: Vec2, radius = 0) {
  return (
    pos.x - radius >= zone.x &&
    pos.x + radius <= zone.x + zone.w &&
    pos.y - radius >= zone.y &&
    pos.y + radius <= zone.y + zone.h
  );
}

function isWalkable(pos: Vec2) {
  return WALKABLE_ZONES.some((zone) => zoneContainsPoint(zone, pos, 0));
}

function findZoneId(pos: Vec2) {
  const room = WALKABLE_ZONES.find((zone) => zone.kind === "room" && zoneContainsPoint(zone, pos));
  if (room) return room.id;
  return "Corridor";
}

function weightTier(weight: number) {
  const ratio = weight / MAX_WEIGHT;
  if (ratio < 0.35) return { moveFactor: 1, noiseBonus: 0 };
  if (ratio < 0.65) return { moveFactor: 0.9, noiseBonus: 1.5 };
  if (ratio < 0.85) return { moveFactor: 0.78, noiseBonus: 3 };
  return { moveFactor: 0.65, noiseBonus: 5 };
}

function noiseTier(noise: number): GameSnapshot["noiseTier"] {
  if (noise < 20) return "Quiet";
  if (noise < 40) return "Caution";
  if (noise < 70) return "Loud";
  return "Critical";
}

function lootForRun(runNumber: number): Loot[] {
  return INITIAL_LOOT.map((loot, idx) => {
    const offsetX = ((runNumber * 17 + idx * 11) % 15) - 7;
    const offsetY = ((runNumber * 13 + idx * 19) % 11) - 5;
    return {
      ...loot,
      pos: { x: loot.pos.x + offsetX, y: loot.pos.y + offsetY },
      picked: false
    };
  });
}

type GameState = {
  player: Vec2;
  inventory: InventoryItem[];
  loot: Loot[];
  noiseNow: number;
  playerHealth: number;
  threatState: ThreatState;
  trapHits: number;
  failedRuns: number;
  chaserPos: Vec2;
  chaserAttackReadyAt: number;
  noisyAnchor: Vec2;
  trapReadyAt: Record<string, number>;
  stashValue: number;
  totalRecoveredValue: number;
  lastRecoveredValue: number;
  lastFailureLossValue: number;
  completedRuns: number;
  lastExtractValue: number;
  totalExtractedValue: number;
  runElapsedSec: number;
  sessionElapsedSec: number;
  lastRunDurationSec: number;
  inputDebugLastKey: string;
  inputDebugLastCode: string;
};

function draw(ctx: CanvasRenderingContext2D, state: GameState) {
  ctx.clearRect(0, 0, WIDTH, HEIGHT);

  ctx.fillStyle = "#11151d";
  ctx.fillRect(0, 0, WIDTH, HEIGHT);

  for (const zone of WALKABLE_ZONES) {
    ctx.fillStyle = zone.kind === "room" ? "#1f2a38" : "#253244";
    if (zone.id === "Exit") {
      ctx.fillStyle = "#233b2f";
    }
    ctx.fillRect(zone.x, zone.y, zone.w, zone.h);
    ctx.strokeStyle = "#50627b";
    ctx.lineWidth = 1;
    ctx.strokeRect(zone.x, zone.y, zone.w, zone.h);

    if (zone.id === "Exit") {
      ctx.fillStyle = "#9fe2ae";
      ctx.font = "12px Segoe UI";
      ctx.fillText("EXIT", zone.x + 8, zone.y + 16);
    }
  }

  for (const trap of TRAPS) {
    ctx.beginPath();
    ctx.fillStyle = "rgba(209, 65, 65, 0.35)";
    ctx.arc(trap.pos.x, trap.pos.y, trap.radius, 0, Math.PI * 2);
    ctx.fill();
    ctx.closePath();
    ctx.strokeStyle = "#d14141";
    ctx.strokeRect(trap.pos.x - 4, trap.pos.y - 4, 8, 8);
  }

  for (const loot of state.loot) {
    if (loot.picked) continue;
    ctx.fillStyle = "#d8b15b";
    ctx.fillRect(loot.pos.x - 6, loot.pos.y - 6, 12, 12);
    ctx.strokeStyle = "#7d6735";
    ctx.strokeRect(loot.pos.x - 6, loot.pos.y - 6, 12, 12);
  }

  ctx.beginPath();
  ctx.fillStyle = state.threatState === "Chasing" ? "#ff8a8a" : "#ff6b6b";
  ctx.arc(state.chaserPos.x, state.chaserPos.y, 9, 0, Math.PI * 2);
  ctx.fill();
  ctx.closePath();

  ctx.beginPath();
  ctx.fillStyle = "#6fd4ff";
  ctx.arc(state.player.x, state.player.y, PLAYER_RADIUS, 0, Math.PI * 2);
  ctx.fill();
  ctx.closePath();
}

export function GameCanvas(props: {
  onSnapshot: (snapshot: GameSnapshot) => void;
  onRunEvent?: (event: string, payload?: Record<string, unknown>) => void;
}) {
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const onSnapshotRef = useRef(props.onSnapshot);
  const onRunEventRef = useRef(props.onRunEvent);

  useEffect(() => {
    onSnapshotRef.current = props.onSnapshot;
    onRunEventRef.current = props.onRunEvent;
  }, [props.onSnapshot, props.onRunEvent]);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext("2d");
    if (!ctx) return;
    canvas.tabIndex = 0;
    canvas.focus();

    let raf = 0;
    let prevTs = performance.now();
    let telemetryAccum = 0;
    const pressed = new Set<string>();
    const onceFlags = { interact: false, drop: false, extract: false };

    const state: GameState = {
      player: { ...RUN_START_POS },
      inventory: [],
      loot: lootForRun(1),
      noiseNow: 0,
      playerHealth: MAX_HEALTH,
      threatState: "Idle",
      trapHits: 0,
      failedRuns: 0,
      chaserPos: { ...CHASER_SPAWN },
      chaserAttackReadyAt: 0,
      noisyAnchor: { ...RUN_START_POS },
      trapReadyAt: {},
      stashValue: 0,
      totalRecoveredValue: 0,
      lastRecoveredValue: 0,
      lastFailureLossValue: 0,
      completedRuns: 0,
      lastExtractValue: 0,
      totalExtractedValue: 0,
      runElapsedSec: 0,
      sessionElapsedSec: 0,
      lastRunDurationSec: 0,
      inputDebugLastKey: "-",
      inputDebugLastCode: "-"
    };

    onRunEventRef.current?.("run_start", { runNumber: 1 });

    const emitSnapshot = () => {
      const roomId = findZoneId(state.player);
      const carriedWeight = state.inventory.reduce((sum, item) => sum + item.weight, 0);
      onSnapshotRef.current({
        roomId,
        position: { ...state.player },
        inventoryCount: state.inventory.length,
        carriedWeight,
        lootRemaining: state.loot.filter((l) => !l.picked).length,
        noiseNow: state.noiseNow,
        noiseTier: noiseTier(state.noiseNow),
        playerHealth: state.playerHealth,
        threatState: state.threatState,
        trapHits: state.trapHits,
        failedRuns: state.failedRuns,
        chaserDistance: distance(state.player, state.chaserPos),
        stashValue: state.stashValue,
        totalRecoveredValue: state.totalRecoveredValue,
        lastRecoveredValue: state.lastRecoveredValue,
        lastFailureLossValue: state.lastFailureLossValue,
        completedRuns: state.completedRuns,
        lastExtractValue: state.lastExtractValue,
        totalExtractedValue: state.totalExtractedValue,
        canExtract: roomId === "Exit" && state.inventory.length > 0,
        runElapsedSec: state.runElapsedSec,
        sessionElapsedSec: state.sessionElapsedSec,
        lastRunDurationSec: state.lastRunDurationSec,
        inputDebugLastKey: state.inputDebugLastKey,
        inputDebugLastCode: state.inputDebugLastCode,
        inputDebugPressedCount: pressed.size
      });
    };

    const handledCodes = new Set([
      "ArrowRight",
      "ArrowLeft",
      "ArrowUp",
      "ArrowDown",
      "KeyW",
      "KeyA",
      "KeyS",
      "KeyD",
      "KeyE",
      "KeyQ",
      "ShiftLeft",
      "ShiftRight",
      "Space"
    ]);
    const handledKeys = new Set([
      "ArrowRight",
      "ArrowLeft",
      "ArrowUp",
      "ArrowDown",
      "w",
      "W",
      "a",
      "A",
      "s",
      "S",
      "d",
      "D",
      "e",
      "E",
      "q",
      "Q",
      " ",
      "Shift"
    ]);

    const keyDown = (e: KeyboardEvent) => {
      const code = e.code;
      const key = e.key;
      if (handledCodes.has(code) || handledKeys.has(key)) e.preventDefault();
      state.inputDebugLastCode = code || "-";
      state.inputDebugLastKey = key || "-";
      pressed.add(code);
      if (code === "KeyW" || key === "w" || key === "W") pressed.add("KeyW");
      if (code === "KeyA" || key === "a" || key === "A") pressed.add("KeyA");
      if (code === "KeyS" || key === "s" || key === "S") pressed.add("KeyS");
      if (code === "KeyD" || key === "d" || key === "D") pressed.add("KeyD");
      if (code === "ShiftLeft" || code === "ShiftRight" || key === "Shift") pressed.add("ShiftLeft");
      if ((code === "KeyE" || key === "e" || key === "E") && !e.repeat) onceFlags.interact = true;
      if ((code === "KeyQ" || key === "q" || key === "Q") && !e.repeat) onceFlags.drop = true;
      if ((code === "Space" || key === " ") && !e.repeat) onceFlags.extract = true;
    };

    const keyUp = (e: KeyboardEvent) => {
      const code = e.code;
      const key = e.key;
      if (handledCodes.has(code) || handledKeys.has(key)) e.preventDefault();
      pressed.delete(code);
      if (code === "KeyW" || key === "w" || key === "W") pressed.delete("KeyW");
      if (code === "KeyA" || key === "a" || key === "A") pressed.delete("KeyA");
      if (code === "KeyS" || key === "s" || key === "S") pressed.delete("KeyS");
      if (code === "KeyD" || key === "d" || key === "D") pressed.delete("KeyD");
      if (code === "ShiftLeft" || code === "ShiftRight" || key === "Shift") {
        pressed.delete("ShiftLeft");
        pressed.delete("ShiftRight");
      }
    };

    const resetForNextRun = (extractValue: number, reason: "extract" | "fail", carriedValue = 0) => {
      if (reason === "extract") {
        const settled = settleExtract(
          {
            stashValue: state.stashValue,
            totalRecoveredValue: state.totalRecoveredValue,
            totalExtractedValue: state.totalExtractedValue,
            completedRuns: state.completedRuns,
            failedRuns: state.failedRuns
          },
          extractValue
        );
        state.completedRuns = settled.completedRuns;
        state.stashValue = settled.stashValue;
        state.totalExtractedValue = settled.totalExtractedValue;
        state.lastExtractValue = settled.lastExtractValue;
        state.lastRecoveredValue = settled.lastRecoveredValue;
        state.lastFailureLossValue = settled.lastFailureLossValue;
      } else {
        const settled = settleFail(
          {
            stashValue: state.stashValue,
            totalRecoveredValue: state.totalRecoveredValue,
            totalExtractedValue: state.totalExtractedValue,
            completedRuns: state.completedRuns,
            failedRuns: state.failedRuns
          },
          carriedValue
        );
        state.failedRuns = settled.failedRuns;
        state.stashValue = settled.stashValue;
        state.totalRecoveredValue = settled.totalRecoveredValue;
        state.lastExtractValue = settled.lastExtractValue;
        state.lastRecoveredValue = settled.lastRecoveredValue;
        state.lastFailureLossValue = settled.lastFailureLossValue;
      }

      state.lastRunDurationSec = state.runElapsedSec;
      state.runElapsedSec = 0;
      state.player = { ...RUN_START_POS };
      state.inventory = [];
      state.loot = lootForRun(nextRunNumber(state.completedRuns, state.failedRuns));
      state.noiseNow = 0;
      state.playerHealth = MAX_HEALTH;
      state.threatState = "Idle";
      state.trapHits = 0;
      state.chaserPos = { ...CHASER_SPAWN };
      state.chaserAttackReadyAt = 0;
      state.noisyAnchor = { ...RUN_START_POS };
      state.trapReadyAt = {};

      if (reason === "extract") {
        onRunEventRef.current?.("run_extract", {
          runNumber: state.completedRuns,
          extractValue,
          totalExtractedValue: state.totalExtractedValue,
          runDurationSec: Number(state.lastRunDurationSec.toFixed(1))
        });
      } else {
        onRunEventRef.current?.("run_fail", {
          failedRuns: state.failedRuns,
          carriedValue,
          recoveredValue: state.lastRecoveredValue,
          lostValue: state.lastFailureLossValue,
          runDurationSec: Number(state.lastRunDurationSec.toFixed(1))
        });
      }

      onRunEventRef.current?.("run_start", {
        runNumber: nextRunNumber(state.completedRuns, state.failedRuns)
      });
    };

    window.addEventListener("keydown", keyDown, { capture: true });
    window.addEventListener("keyup", keyUp, { capture: true });
    document.addEventListener("keydown", keyDown, { capture: true });
    document.addEventListener("keyup", keyUp, { capture: true });

    const tick = (ts: number) => {
      const dt = clamp((ts - prevTs) / 1000, 0, 0.05);
      prevTs = ts;
      telemetryAccum += dt;

      state.sessionElapsedSec += dt;
      state.runElapsedSec += dt;

      const inputX =
        (pressed.has("ArrowRight") || pressed.has("KeyD") ? 1 : 0) -
        (pressed.has("ArrowLeft") || pressed.has("KeyA") ? 1 : 0);
      const inputY =
        (pressed.has("ArrowDown") || pressed.has("KeyS") ? 1 : 0) -
        (pressed.has("ArrowUp") || pressed.has("KeyW") ? 1 : 0);
      const len = Math.hypot(inputX, inputY);

      const carriedWeight = state.inventory.reduce((sum, item) => sum + item.weight, 0);
      const tier = weightTier(carriedWeight);
      const running = pressed.has("ShiftLeft") || pressed.has("ShiftRight");
      const speed = BASE_SPEED * tier.moveFactor * (running ? RUN_MULTIPLIER : 1);

      let moving = false;
      if (len > 0) {
        moving = true;
        const dirX = inputX / len;
        const dirY = inputY / len;

        const proposedX = { x: state.player.x + dirX * speed * dt, y: state.player.y };
        if (isWalkable(proposedX)) state.player.x = proposedX.x;

        const proposedY = { x: state.player.x, y: state.player.y + dirY * speed * dt };
        if (isWalkable(proposedY)) state.player.y = proposedY.y;

        state.noisyAnchor = { ...state.player };
      }

      if (onceFlags.interact) {
        const target = state.loot
          .filter((l) => !l.picked)
          .find((l) => distance(l.pos, state.player) <= 24);

        if (
          target &&
          state.inventory.length < INVENTORY_SLOTS &&
          carriedWeight + target.weight <= MAX_WEIGHT
        ) {
          target.picked = true;
          state.inventory.push({
            id: target.id,
            name: target.name,
            value: target.value,
            weight: target.weight
          });
          state.noiseNow = clamp(state.noiseNow + 6, 0, 100);
          state.noisyAnchor = { ...state.player };
          onRunEventRef.current?.("loot_pick", {
            lootId: target.id,
            inventoryCount: state.inventory.length,
            carriedWeight: Number((carriedWeight + target.weight).toFixed(1))
          });
        }
        onceFlags.interact = false;
      }

      if (onceFlags.drop) {
        const item = state.inventory.pop();
        if (item) {
          state.loot.push({
            ...item,
            pos: { x: state.player.x + 16, y: state.player.y + 4 },
            picked: false
          });
          state.noiseNow = clamp(state.noiseNow + 3, 0, 100);
          state.noisyAnchor = { ...state.player };
          onRunEventRef.current?.("loot_drop", {
            lootId: item.id,
            inventoryCount: state.inventory.length
          });
        }
        onceFlags.drop = false;
      }

      if (onceFlags.extract) {
        const roomId = findZoneId(state.player);
        if (roomId === "Exit" && state.inventory.length > 0) {
          const extractValue = state.inventory.reduce((sum, item) => sum + item.value, 0);
          resetForNextRun(extractValue, "extract", 0);
        }
        onceFlags.extract = false;
      }

      for (const trap of TRAPS) {
        const readyAt = state.trapReadyAt[trap.id] ?? 0;
        const inRange = distance(state.player, trap.pos) <= trap.radius;
        if (inRange && state.sessionElapsedSec >= readyAt) {
          state.trapReadyAt[trap.id] = state.sessionElapsedSec + trap.cooldownSec;
          state.playerHealth = clamp(state.playerHealth - trap.damage, 0, MAX_HEALTH);
          state.noiseNow = clamp(state.noiseNow + trap.noiseBoost, 0, 100);
          state.trapHits += 1;
          state.noisyAnchor = { ...trap.pos };
          onRunEventRef.current?.("trap_trigger", {
            trapId: trap.id,
            health: state.playerHealth,
            trapHits: state.trapHits
          });
        }
      }

      const distToPlayer = distance(state.chaserPos, state.player);
      state.threatState = classifyThreatState(distToPlayer, state.noiseNow);

      let chaseTarget = CHASER_SPAWN;
      let chaseSpeed = 46;
      if (state.threatState === "Investigating") {
        chaseTarget = state.noisyAnchor;
        chaseSpeed = 68;
      }
      if (state.threatState === "Chasing") {
        chaseTarget = state.player;
        chaseSpeed = 94;
      }

      const dx = chaseTarget.x - state.chaserPos.x;
      const dy = chaseTarget.y - state.chaserPos.y;
      const chaseLen = Math.hypot(dx, dy);
      if (chaseLen > 1) {
        const chaserNextX = {
          x: state.chaserPos.x + (dx / chaseLen) * chaseSpeed * dt,
          y: state.chaserPos.y
        };
        if (isWalkable(chaserNextX)) state.chaserPos.x = chaserNextX.x;

        const chaserNextY = {
          x: state.chaserPos.x,
          y: state.chaserPos.y + (dy / chaseLen) * chaseSpeed * dt
        };
        if (isWalkable(chaserNextY)) state.chaserPos.y = chaserNextY.y;
      }

      const chaserDist = distance(state.chaserPos, state.player);
      if (
        state.threatState === "Chasing" &&
        chaserDist <= 20 &&
        state.sessionElapsedSec >= state.chaserAttackReadyAt
      ) {
        state.chaserAttackReadyAt = state.sessionElapsedSec + 0.85;
        state.playerHealth = clamp(state.playerHealth - 8, 0, MAX_HEALTH);
        state.noiseNow = clamp(state.noiseNow + 4, 0, 100);
        onRunEventRef.current?.("chaser_hit", {
          health: state.playerHealth,
          distance: Number(chaserDist.toFixed(1))
        });
      }

      if (state.threatState === "Chasing" && telemetryAccum >= 0.5) {
        telemetryAccum = 0;
        onRunEventRef.current?.("chaser_spotted", {
          distance: Number(chaserDist.toFixed(1)),
          noiseNow: Number(state.noiseNow.toFixed(1)),
          health: state.playerHealth
        });
      }

      if (moving) {
        const movementNoise = (running ? 13 : 7) * dt;
        state.noiseNow = clamp(state.noiseNow + movementNoise + tier.noiseBonus * dt, 0, 100);
      } else {
        state.noiseNow = clamp(state.noiseNow - 10 * dt, 0, 100);
      }

      if (state.playerHealth <= 0) {
        const carriedValue = state.inventory.reduce((sum, item) => sum + item.value, 0);
        resetForNextRun(0, "fail", carriedValue);
      }

      draw(ctx, state);
      emitSnapshot();
      raf = requestAnimationFrame(tick);
    };

    emitSnapshot();
    raf = requestAnimationFrame(tick);

    return () => {
      cancelAnimationFrame(raf);
      window.removeEventListener("keydown", keyDown, { capture: true });
      window.removeEventListener("keyup", keyUp, { capture: true });
      document.removeEventListener("keydown", keyDown, { capture: true });
      document.removeEventListener("keyup", keyUp, { capture: true });
    };
  }, []);

  return (
    <canvas
      ref={canvasRef}
      width={WIDTH}
      height={HEIGHT}
      className="game-canvas"
      onMouseDown={() => canvasRef.current?.focus()}
    />
  );
}


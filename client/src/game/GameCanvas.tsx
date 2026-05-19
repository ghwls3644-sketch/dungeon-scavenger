import { useEffect, useRef } from "react";

type Vec2 = { x: number; y: number };
type Rect = { id: string; kind: "room" | "corridor"; x: number; y: number; w: number; h: number };

type Loot = {
  id: string;
  name: string;
  weight: number;
  value: number;
  pos: Vec2;
  picked: boolean;
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
  runCount: number;
  lastExtractValue: number;
  totalExtractedValue: number;
  canExtract: boolean;
};

const WIDTH = 760;
const HEIGHT = 460;
const PLAYER_RADIUS = 10;
const BASE_SPEED = 130;
const RUN_MULTIPLIER = 1.35;
const INVENTORY_SLOTS = 8;
const MAX_WEIGHT = 40;

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

const INITIAL_LOOT: Loot[] = [
  { id: "L-01", name: "Rusty Relic", weight: 5, value: 120, pos: { x: 330, y: 95 }, picked: false },
  { id: "L-02", name: "Ancient Coin", weight: 2, value: 90, pos: { x: 410, y: 125 }, picked: false },
  { id: "L-03", name: "Archive Lens", weight: 4, value: 150, pos: { x: 640, y: 110 }, picked: false },
  { id: "L-04", name: "Waterlogged Idol", weight: 7, value: 180, pos: { x: 350, y: 290 }, picked: false },
  { id: "L-05", name: "Exit Cache", weight: 6, value: 210, pos: { x: 610, y: 295 }, picked: false }
];

function clamp(v: number, min: number, max: number) {
  return Math.max(min, Math.min(max, v));
}

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
  return WALKABLE_ZONES.some((zone) => zoneContainsPoint(zone, pos, PLAYER_RADIUS));
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

type GameState = {
  player: Vec2;
  inventory: InventoryItem[];
  loot: Loot[];
  noiseNow: number;
  runCount: number;
  lastExtractValue: number;
  totalExtractedValue: number;
};

function draw(ctx: CanvasRenderingContext2D, state: GameState) {
  ctx.clearRect(0, 0, WIDTH, HEIGHT);

  ctx.fillStyle = "#11151d";
  ctx.fillRect(0, 0, WIDTH, HEIGHT);

  for (const zone of WALKABLE_ZONES) {
    ctx.fillStyle = zone.kind === "room" ? "#1f2a38" : "#253244";
    ctx.fillRect(zone.x, zone.y, zone.w, zone.h);
    ctx.strokeStyle = "#50627b";
    ctx.lineWidth = 1;
    ctx.strokeRect(zone.x, zone.y, zone.w, zone.h);
  }

  for (const loot of state.loot) {
    if (loot.picked) continue;
    ctx.fillStyle = "#d8b15b";
    ctx.fillRect(loot.pos.x - 6, loot.pos.y - 6, 12, 12);
    ctx.strokeStyle = "#7d6735";
    ctx.strokeRect(loot.pos.x - 6, loot.pos.y - 6, 12, 12);
  }

  ctx.beginPath();
  ctx.fillStyle = "#6fd4ff";
  ctx.arc(state.player.x, state.player.y, PLAYER_RADIUS, 0, Math.PI * 2);
  ctx.fill();
  ctx.closePath();
}

export function GameCanvas(props: { onSnapshot: (snapshot: GameSnapshot) => void }) {
  const canvasRef = useRef<HTMLCanvasElement | null>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    let raf = 0;
    let prevTs = performance.now();
    const pressed = new Set<string>();
    const onceFlags = { interact: false, drop: false, extract: false };

    const state: GameState = {
      player: { x: 120, y: 100 },
      inventory: [],
      loot: INITIAL_LOOT.map((l) => ({ ...l })),
      noiseNow: 0,
      runCount: 0,
      lastExtractValue: 0,
      totalExtractedValue: 0
    };

    const emitSnapshot = () => {
      const roomId = findZoneId(state.player);
      const carriedWeight = state.inventory.reduce((sum, item) => sum + item.weight, 0);
      props.onSnapshot({
        roomId,
        position: { ...state.player },
        inventoryCount: state.inventory.length,
        carriedWeight,
        lootRemaining: state.loot.filter((l) => !l.picked).length,
        noiseNow: state.noiseNow,
        noiseTier: noiseTier(state.noiseNow),
        runCount: state.runCount,
        lastExtractValue: state.lastExtractValue,
        totalExtractedValue: state.totalExtractedValue,
        canExtract: roomId === "Exit" && state.inventory.length > 0
      });
    };

    const keyDown = (e: KeyboardEvent) => {
      const code = e.code;
      pressed.add(code);
      if (code === "KeyE" && !e.repeat) onceFlags.interact = true;
      if (code === "KeyQ" && !e.repeat) onceFlags.drop = true;
      if (code === "Space" && !e.repeat) onceFlags.extract = true;
    };

    const keyUp = (e: KeyboardEvent) => {
      pressed.delete(e.code);
    };

    window.addEventListener("keydown", keyDown);
    window.addEventListener("keyup", keyUp);

    const tick = (ts: number) => {
      const dt = clamp((ts - prevTs) / 1000, 0, 0.05);
      prevTs = ts;

      const inputX = (pressed.has("ArrowRight") || pressed.has("KeyD") ? 1 : 0) - (pressed.has("ArrowLeft") || pressed.has("KeyA") ? 1 : 0);
      const inputY = (pressed.has("ArrowDown") || pressed.has("KeyS") ? 1 : 0) - (pressed.has("ArrowUp") || pressed.has("KeyW") ? 1 : 0);
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
        }
        onceFlags.drop = false;
      }

      if (onceFlags.extract) {
        const roomId = findZoneId(state.player);
        if (roomId === "Exit" && state.inventory.length > 0) {
          const extractValue = state.inventory.reduce((sum, item) => sum + item.value, 0);
          state.lastExtractValue = extractValue;
          state.totalExtractedValue += extractValue;
          state.runCount += 1;
          state.inventory = [];
          state.noiseNow = clamp(state.noiseNow - 12, 0, 100);
        }
        onceFlags.extract = false;
      }

      if (moving) {
        const movementNoise = (running ? 13 : 7) * dt;
        state.noiseNow = clamp(state.noiseNow + movementNoise + tier.noiseBonus * dt, 0, 100);
      } else {
        state.noiseNow = clamp(state.noiseNow - 10 * dt, 0, 100);
      }

      draw(ctx, state);
      emitSnapshot();
      raf = requestAnimationFrame(tick);
    };

    emitSnapshot();
    raf = requestAnimationFrame(tick);

    return () => {
      cancelAnimationFrame(raf);
      window.removeEventListener("keydown", keyDown);
      window.removeEventListener("keyup", keyUp);
    };
  }, [props.onSnapshot]);

  return (
    <canvas
      ref={canvasRef}
      width={WIDTH}
      height={HEIGHT}
      className="game-canvas"
    />
  );
}

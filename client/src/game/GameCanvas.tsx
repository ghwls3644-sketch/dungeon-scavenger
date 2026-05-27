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
  label: string;
  kind: "room" | "hall" | "gate";
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
  tool?: "lockpick";
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
type DoorState = "open" | "closed" | "locked" | "rusted" | "jammed" | "barred" | "broken" | "sealed";
type DoorAction = "openCarefully" | "openQuickly" | "pickLock" | "forceOpen" | "breakDoor";

type Door = {
  id: string;
  from: string;
  to: string;
  state: DoorState;
  lockType: "none" | "simple" | "sealed";
  anchor: Vec2;
  noiseOnCareful: number;
  noiseOnQuick: number;
  noiseOnBreak: number;
};

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
  lockpickCharges: number;
  nearDoorId: string;
  nearDoorState: DoorState | "none";
};

const WIDTH = 760;
const HEIGHT = 460;
const PLAYER_RADIUS = 10;
const BASE_SPEED = 130;
const RUN_MULTIPLIER = 1.35;
const INVENTORY_SLOTS = 8;
const MAX_WEIGHT = 40;
const MAX_HEALTH = 100;
const RUN_START_POS: Vec2 = { x: 90, y: 135 };
const CHASER_SPAWN: Vec2 = { x: 520, y: 345 };

const WALKABLE_ZONES: Rect[] = [
  { id: "Entrance", label: "Broken Entrance", kind: "room", x: 40, y: 90, w: 120, h: 90 },
  { id: "Antechamber", label: "Old Antechamber", kind: "room", x: 160, y: 90, w: 130, h: 90 },
  { id: "MainHall", label: "Cracked Main Hall", kind: "hall", x: 290, y: 70, w: 160, h: 190 },
  { id: "Storage", label: "Ransacked Storage", kind: "room", x: 160, y: 170, w: 130, h: 110 },
  { id: "Dormitory", label: "Moldy Dormitory", kind: "room", x: 160, y: 240, w: 130, h: 120 },
  { id: "Chapel", label: "Collapsed Chapel", kind: "room", x: 450, y: 70, w: 140, h: 100 },
  { id: "GuardRoom", label: "Silent Guard Room", kind: "room", x: 290, y: 280, w: 160, h: 110 },
  { id: "Archive", label: "Wet Archive", kind: "room", x: 450, y: 170, w: 140, h: 130 },
  { id: "LowerGate", label: "Sealed Lower Gate", kind: "gate", x: 450, y: 300, w: 140, h: 90 }
];

const INITIAL_DOORS: Door[] = [
  {
    id: "D_ENT_ANT",
    from: "Entrance",
    to: "Antechamber",
    state: "closed",
    lockType: "none",
    anchor: { x: 160, y: 135 },
    noiseOnCareful: 1,
    noiseOnQuick: 2,
    noiseOnBreak: 4
  },
  {
    id: "D_ANT_HALL",
    from: "Antechamber",
    to: "MainHall",
    state: "open",
    lockType: "none",
    anchor: { x: 290, y: 135 },
    noiseOnCareful: 0,
    noiseOnQuick: 1,
    noiseOnBreak: 3
  },
  {
    id: "D_HALL_STORAGE",
    from: "MainHall",
    to: "Storage",
    state: "rusted",
    lockType: "none",
    anchor: { x: 290, y: 210 },
    noiseOnCareful: 2,
    noiseOnQuick: 4,
    noiseOnBreak: 7
  },
  {
    id: "D_HALL_DORMITORY",
    from: "MainHall",
    to: "Dormitory",
    state: "jammed",
    lockType: "none",
    anchor: { x: 290, y: 250 },
    noiseOnCareful: 1,
    noiseOnQuick: 3,
    noiseOnBreak: 6
  },
  {
    id: "D_HALL_CHAPEL",
    from: "MainHall",
    to: "Chapel",
    state: "locked",
    lockType: "simple",
    anchor: { x: 450, y: 135 },
    noiseOnCareful: 2,
    noiseOnQuick: 5,
    noiseOnBreak: 8
  },
  {
    id: "D_STORAGE_GUARD",
    from: "Storage",
    to: "GuardRoom",
    state: "barred",
    lockType: "simple",
    anchor: { x: 225, y: 280 },
    noiseOnCareful: 2,
    noiseOnQuick: 4,
    noiseOnBreak: 8
  },
  {
    id: "D_GUARD_LOWER",
    from: "GuardRoom",
    to: "LowerGate",
    state: "closed",
    lockType: "none",
    anchor: { x: 450, y: 345 },
    noiseOnCareful: 1,
    noiseOnQuick: 2,
    noiseOnBreak: 6
  },
  {
    id: "D_CHAPEL_ARCHIVE",
    from: "Chapel",
    to: "Archive",
    state: "closed",
    lockType: "none",
    anchor: { x: 520, y: 170 },
    noiseOnCareful: 1,
    noiseOnQuick: 3,
    noiseOnBreak: 5
  },
  {
    id: "D_ARCHIVE_LOWER",
    from: "Archive",
    to: "LowerGate",
    state: "sealed",
    lockType: "sealed",
    anchor: { x: 520, y: 300 },
    noiseOnCareful: 1,
    noiseOnQuick: 2,
    noiseOnBreak: 6
  }
];

const TRAPS: Trap[] = [
  { id: "T-01", pos: { x: 360, y: 165 }, radius: 16, damage: 12, noiseBoost: 18, cooldownSec: 3.2 },
  { id: "T-02", pos: { x: 390, y: 340 }, radius: 16, damage: 10, noiseBoost: 15, cooldownSec: 3.0 }
];

const INITIAL_LOOT: Loot[] = [
  { id: "L-01", name: "Rusted Dagger", weight: 5, value: 120, pos: { x: 220, y: 215 }, picked: false },
  { id: "L-02", name: "Cracked Mana Stone", weight: 2, value: 90, pos: { x: 230, y: 305 }, picked: false },
  { id: "L-03", name: "Wet Ledger Case", weight: 4, value: 150, pos: { x: 520, y: 215 }, picked: false },
  { id: "L-04", name: "Guard Crest Fragment", weight: 7, value: 180, pos: { x: 375, y: 340 }, picked: false },
  { id: "L-05", name: "Lower Gate Scrap", weight: 6, value: 210, pos: { x: 540, y: 345 }, picked: false },
  {
    id: "L-06",
    name: "Worn Pick Set",
    weight: 1,
    value: 45,
    pos: { x: 505, y: 120 },
    picked: false,
    tool: "lockpick"
  }
];

function distance(a: Vec2, b: Vec2) {
  const dx = a.x - b.x;
  const dy = a.y - b.y;
  return Math.hypot(dx, dy);
}

function zoneContainsPoint(zone: Rect, pos: Vec2, radius = 0) {
  return (
    pos.x - radius >= zone.x &&
    pos.x + radius < zone.x + zone.w &&
    pos.y - radius >= zone.y &&
    pos.y + radius < zone.y + zone.h
  );
}

function isWalkable(pos: Vec2) {
  return WALKABLE_ZONES.some((zone) => zoneContainsPoint(zone, pos, 0));
}

function findZoneId(pos: Vec2) {
  const zone = WALKABLE_ZONES.find((candidate) => zoneContainsPoint(candidate, pos));
  if (zone) return zone.id;
  return "Unknown";
}

function isDoorPassable(door: Door) {
  return door.state === "open" || door.state === "broken";
}

function findDoorBetween(doors: Door[], a: string, b: string) {
  return doors.find(
    (door) => (door.from === a && door.to === b) || (door.from === b && door.to === a)
  );
}

function canMoveBetweenZones(currentPos: Vec2, nextPos: Vec2, doors: Door[]) {
  if (!isWalkable(nextPos)) return false;
  const fromZone = findZoneId(currentPos);
  const toZone = findZoneId(nextPos);
  if (fromZone === "Unknown" || toZone === "Unknown") return false;
  if (fromZone === toZone) return true;
  const door = findDoorBetween(doors, fromZone, toZone);
  if (!door) return false;
  return isDoorPassable(door);
}

function findNearestDoor(pos: Vec2, doors: Door[], maxDistance: number) {
  let nearest: Door | null = null;
  let nearestDistance = maxDistance;

  for (const door of doors) {
    const d = distance(pos, door.anchor);
    if (d <= nearestDistance) {
      nearest = door;
      nearestDistance = d;
    }
  }

  return nearest;
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

function doorStateForRun(baseState: DoorState, runNumber: number, doorIndex: number): DoorState {
  if (baseState === "sealed") return "sealed";
  const roll = (runNumber * 17 + doorIndex * 31) % 100;

  if (baseState === "open") {
    if (roll < 15) return "closed";
    return "open";
  }

  if (baseState === "locked") {
    if (roll < 10) return "closed";
    if (roll < 35) return "rusted";
    return "locked";
  }

  if (baseState === "rusted") {
    if (roll < 30) return "rusted";
    if (roll < 65) return "closed";
    return "jammed";
  }

  if (baseState === "jammed") {
    if (roll < 50) return "jammed";
    if (roll < 80) return "closed";
    return "barred";
  }

  if (baseState === "barred") {
    if (roll < 45) return "barred";
    if (roll < 75) return "locked";
    return "jammed";
  }

  if (baseState === "broken") return "broken";
  return baseState;
}

function doorsForRun(runNumber: number): Door[] {
  return INITIAL_DOORS.map((door, index) => ({
    ...door,
    anchor: { ...door.anchor },
    state: doorStateForRun(door.state, runNumber, index)
  }));
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
  lockpickCharges: number;
  nearDoorId: string;
  nearDoorState: DoorState | "none";
  doors: Door[];
};

function draw(ctx: CanvasRenderingContext2D, state: GameState) {
  ctx.clearRect(0, 0, WIDTH, HEIGHT);

  ctx.fillStyle = "#11151d";
  ctx.fillRect(0, 0, WIDTH, HEIGHT);

  for (const zone of WALKABLE_ZONES) {
    ctx.fillStyle = "#1f2a38";
    if (zone.kind === "hall") ctx.fillStyle = "#243346";
    if (zone.kind === "gate") ctx.fillStyle = "#2f2638";
    ctx.fillRect(zone.x, zone.y, zone.w, zone.h);
    ctx.strokeStyle = "#50627b";
    ctx.lineWidth = 1;
    ctx.strokeRect(zone.x, zone.y, zone.w, zone.h);
    ctx.fillStyle = "#9fb3cc";
    ctx.font = "11px Segoe UI";
    ctx.fillText(zone.label, zone.x + 6, zone.y + 16);
  }

  for (const door of state.doors) {
    let color = "#87a0bd";
    if (door.state === "open") color = "#78d39d";
    if (door.state === "locked") color = "#f3bf61";
    if (door.state === "rusted") color = "#b88f68";
    if (door.state === "jammed") color = "#8e8e8e";
    if (door.state === "barred") color = "#8a6fb5";
    if (door.state === "sealed") color = "#b15e9f";
    if (door.state === "broken") color = "#df6f6f";
    ctx.fillStyle = color;
    ctx.fillRect(door.anchor.x - 4, door.anchor.y - 4, 8, 8);
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
    const onceFlags = {
      interact: false,
      drop: false,
      extract: false,
      doorQuick: false,
      doorPick: false,
      doorForce: false,
      doorBreak: false
    };

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
      inputDebugLastCode: "-",
      lockpickCharges: 2,
      nearDoorId: "-",
      nearDoorState: "none",
      doors: doorsForRun(1)
    };

    onRunEventRef.current?.("run_start", { runNumber: 1 });

    const emitSnapshot = () => {
      const roomId = findZoneId(state.player);
      const carriedWeight = state.inventory.reduce((sum, item) => sum + item.weight, 0);
      const nearestDoor = findNearestDoor(state.player, state.doors, 32);
      state.nearDoorId = nearestDoor?.id ?? "-";
      state.nearDoorState = nearestDoor?.state ?? "none";
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
        canExtract: roomId === "Entrance" && state.inventory.length > 0,
        runElapsedSec: state.runElapsedSec,
        sessionElapsedSec: state.sessionElapsedSec,
        lastRunDurationSec: state.lastRunDurationSec,
        inputDebugLastKey: state.inputDebugLastKey,
        inputDebugLastCode: state.inputDebugLastCode,
        inputDebugPressedCount: pressed.size,
        lockpickCharges: state.lockpickCharges,
        nearDoorId: state.nearDoorId,
        nearDoorState: state.nearDoorState
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
      "KeyF",
      "KeyG",
      "KeyQ",
      "KeyR",
      "KeyT",
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
      "f",
      "F",
      "g",
      "G",
      "q",
      "Q",
      "r",
      "R",
      "t",
      "T",
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
      if ((code === "KeyF" || key === "f" || key === "F") && !e.repeat) onceFlags.doorQuick = true;
      if ((code === "KeyT" || key === "t" || key === "T") && !e.repeat) onceFlags.doorPick = true;
      if ((code === "KeyG" || key === "g" || key === "G") && !e.repeat) onceFlags.doorForce = true;
      if ((code === "KeyQ" || key === "q" || key === "Q") && !e.repeat) onceFlags.drop = true;
      if ((code === "KeyR" || key === "r" || key === "R") && !e.repeat) onceFlags.doorBreak = true;
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
      state.lockpickCharges = 2;
      state.nearDoorId = "-";
      state.nearDoorState = "none";
      state.doors = doorsForRun(nextRunNumber(state.completedRuns, state.failedRuns));

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

    const tryDoorAction = (action: DoorAction) => {
      const door = findNearestDoor(state.player, state.doors, 28);
      if (!door) return false;

      let changed = false;
      let noise = 0;
      let usedLockpick = false;
      let result:
        | "opened"
        | "already_open"
        | "locked"
        | "jammed"
        | "barred"
        | "sealed"
        | "no_tool"
        | "failed"
        | "broken" = "already_open";

      if (door.state === "sealed" && action !== "breakDoor") {
        noise = door.noiseOnQuick;
        result = "sealed";
      } else if (action === "openCarefully") {
        if (door.state === "open" || door.state === "broken") {
          result = "already_open";
        } else if (door.state === "closed") {
          door.state = "open";
          noise = door.noiseOnCareful;
          changed = true;
          result = "opened";
        } else if (door.state === "rusted") {
          door.state = "open";
          noise = door.noiseOnCareful + 1;
          changed = true;
          result = "opened";
        } else if (door.state === "jammed") {
          noise = door.noiseOnCareful + 1;
          result = "jammed";
        } else if (door.state === "barred" || door.state === "locked") {
          if (state.lockpickCharges > 0 && door.lockType === "simple") {
            state.lockpickCharges -= 1;
            door.state = "open";
            noise = door.noiseOnCareful + 1;
            changed = true;
            usedLockpick = true;
            result = "opened";
          } else {
            noise = door.noiseOnCareful;
            result = state.lockpickCharges <= 0 ? "no_tool" : "locked";
          }
        }
      } else if (action === "openQuickly") {
        if (door.state === "open" || door.state === "broken") {
          result = "already_open";
        } else if (door.state === "closed" || door.state === "rusted") {
          const wasRusted = door.state === "rusted";
          door.state = "open";
          noise = door.noiseOnQuick + (wasRusted ? 1 : 0);
          changed = true;
          result = "opened";
        } else if (door.state === "jammed") {
          noise = door.noiseOnQuick + 1;
          result = "jammed";
        } else {
          noise = door.noiseOnQuick;
          result = "locked";
        }
      } else if (action === "pickLock") {
        if (door.state === "open" || door.state === "broken") {
          result = "already_open";
        } else if (door.lockType !== "simple" || door.state === "sealed") {
          noise = door.noiseOnCareful;
          result = door.state === "sealed" ? "sealed" : "failed";
        } else if (state.lockpickCharges <= 0) {
          noise = door.noiseOnCareful;
          result = "no_tool";
        } else if (door.state === "locked" || door.state === "barred") {
          state.lockpickCharges -= 1;
          usedLockpick = true;
          door.state = "open";
          noise = door.noiseOnCareful + 1;
          changed = true;
          result = "opened";
        } else {
          noise = door.noiseOnCareful;
          result = "failed";
        }
      } else if (action === "forceOpen") {
        if (door.state === "open" || door.state === "broken") {
          result = "already_open";
        } else if (door.state === "sealed") {
          noise = door.noiseOnQuick + 2;
          result = "sealed";
        } else if (door.state === "jammed" || door.state === "rusted" || door.state === "closed") {
          door.state = "open";
          noise = door.noiseOnQuick + 2;
          changed = true;
          result = "opened";
        } else if (door.state === "barred" || door.state === "locked") {
          noise = door.noiseOnQuick + 2;
          result = door.state === "barred" ? "barred" : "locked";
        }
      } else if (action === "breakDoor") {
        if (door.state === "sealed") {
          noise = door.noiseOnBreak + 1;
          result = "sealed";
        } else if (door.state === "broken") {
          result = "broken";
        } else {
          door.state = "broken";
          noise = door.noiseOnBreak;
          changed = true;
          result = "broken";
        }
      }

      if (noise > 0) {
        state.noiseNow = clamp(state.noiseNow + noise, 0, 100);
        state.noisyAnchor = { ...door.anchor };
      }

      onRunEventRef.current?.("door_interact", {
        doorId: door.id,
        action,
        result,
        changed,
        usedLockpick,
        lockpickCharges: state.lockpickCharges,
        noise
      });

      return true;
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
        if (canMoveBetweenZones(state.player, proposedX, state.doors)) state.player.x = proposedX.x;

        const proposedY = { x: state.player.x, y: state.player.y + dirY * speed * dt };
        if (canMoveBetweenZones(state.player, proposedY, state.doors)) state.player.y = proposedY.y;

        state.noisyAnchor = { ...state.player };
      }

      if (onceFlags.interact) {
        const consumedByDoor = tryDoorAction("openCarefully");
        if (!consumedByDoor) {
          const target = state.loot
            .filter((l) => !l.picked)
            .find((l) => distance(l.pos, state.player) <= 24);

          const canCarryItem =
            !!target &&
            state.inventory.length < INVENTORY_SLOTS &&
            carriedWeight + target.weight <= MAX_WEIGHT;
          const canTakeTool = !!target && target.tool === "lockpick";

          if (target && (canCarryItem || canTakeTool)) {
            target.picked = true;
            if (target.tool === "lockpick") {
              state.lockpickCharges += 2;
              onRunEventRef.current?.("tool_pick", {
                tool: "lockpick",
                sourceLootId: target.id,
                gainedCharges: 2,
                totalCharges: state.lockpickCharges
              });
            } else {
              state.inventory.push({
                id: target.id,
                name: target.name,
                value: target.value,
                weight: target.weight
              });
            }
            state.noiseNow = clamp(state.noiseNow + 6, 0, 100);
            state.noisyAnchor = { ...state.player };
            onRunEventRef.current?.("loot_pick", {
              lootId: target.id,
              inventoryCount: state.inventory.length,
              carriedWeight: Number((carriedWeight + target.weight).toFixed(1))
            });
          }
        }
        onceFlags.interact = false;
      }

      if (onceFlags.doorQuick) {
        tryDoorAction("openQuickly");
        onceFlags.doorQuick = false;
      }

      if (onceFlags.doorPick) {
        tryDoorAction("pickLock");
        onceFlags.doorPick = false;
      }

      if (onceFlags.doorForce) {
        tryDoorAction("forceOpen");
        onceFlags.doorForce = false;
      }

      if (onceFlags.doorBreak) {
        tryDoorAction("breakDoor");
        onceFlags.doorBreak = false;
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
        if (roomId === "Entrance" && state.inventory.length > 0) {
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
        if (canMoveBetweenZones(state.chaserPos, chaserNextX, state.doors))
          state.chaserPos.x = chaserNextX.x;

        const chaserNextY = {
          x: state.chaserPos.x,
          y: state.chaserPos.y + (dy / chaseLen) * chaseSpeed * dt
        };
        if (canMoveBetweenZones(state.chaserPos, chaserNextY, state.doors))
          state.chaserPos.y = chaserNextY.y;
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


import {
  clamp,
  classifyThreatState,
  nextRunNumber,
  settleExtract,
  settleFail,
  type RunEconomyState
} from "../src/game/gameCore.ts";

function assert(condition: boolean, message: string): void {
  if (!condition) throw new Error(message);
}

function assertEqual<T>(actual: T, expected: T, label: string): void {
  if (actual !== expected) {
    throw new Error(`${label}: expected=${String(expected)} actual=${String(actual)}`);
  }
}

function run(): void {
  assertEqual(clamp(-1, 0, 100), 0, "clamp lower bound");
  assertEqual(clamp(150, 0, 100), 100, "clamp upper bound");
  assertEqual(clamp(42, 0, 100), 42, "clamp in range");

  assertEqual(classifyThreatState(200, 0), "Idle", "idle classification");
  assertEqual(classifyThreatState(95, 0), "Chasing", "distance threshold classification");
  assertEqual(classifyThreatState(200, 32), "Investigating", "noise investigate threshold");
  assertEqual(classifyThreatState(200, 40), "Investigating", "investigating classification");
  assertEqual(classifyThreatState(94, 0), "Chasing", "distance chasing classification");
  assertEqual(classifyThreatState(200, 60), "Chasing", "noise chasing classification");

  const base: RunEconomyState = {
    stashValue: 10,
    totalRecoveredValue: 20,
    totalExtractedValue: 30,
    completedRuns: 1,
    failedRuns: 2
  };

  const fail = settleFail(base, 420);
  assertEqual(fail.lastRecoveredValue, 147, "fail recovered");
  assertEqual(fail.lastFailureLossValue, 273, "fail lost");
  assertEqual(fail.failedRuns, 3, "fail count");
  assertEqual(fail.stashValue, 157, "fail stash");
  assertEqual(fail.totalRecoveredValue, 167, "fail recovered total");
  const failZero = settleFail(base, 0);
  assertEqual(failZero.lastRecoveredValue, 0, "fail zero recovered");
  assertEqual(failZero.lastFailureLossValue, 0, "fail zero loss");

  const extracted = settleExtract(base, 120);
  assertEqual(extracted.completedRuns, 2, "extract completed count");
  assertEqual(extracted.stashValue, 130, "extract stash");
  assertEqual(extracted.totalExtractedValue, 150, "extract total");
  assertEqual(extracted.lastRecoveredValue, 0, "extract recovered reset");

  assertEqual(nextRunNumber(2, 3), 6, "next run number");
  assert(nextRunNumber(fail.completedRuns, fail.failedRuns) > 0, "next run positive");

  console.log("game_core_harness: PASS");
}

run();

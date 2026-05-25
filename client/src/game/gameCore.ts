export type ThreatState = "Idle" | "Investigating" | "Chasing";

export function clamp(value: number, minValue: number, maxValue: number): number {
  return Math.max(minValue, Math.min(maxValue, value));
}

export function classifyThreatState(distanceToPlayer: number, noiseNow: number): ThreatState {
  if (distanceToPlayer <= 95 || noiseNow >= 60) return "Chasing";
  if (noiseNow >= 32) return "Investigating";
  return "Idle";
}

export type RunEconomyState = {
  stashValue: number;
  totalRecoveredValue: number;
  totalExtractedValue: number;
  completedRuns: number;
  failedRuns: number;
};

export type ExtractSettlement = RunEconomyState & {
  lastExtractValue: number;
  lastRecoveredValue: number;
  lastFailureLossValue: number;
};

export type FailSettlement = RunEconomyState & {
  lastExtractValue: number;
  lastRecoveredValue: number;
  lastFailureLossValue: number;
};

export function settleExtract(base: RunEconomyState, extractValue: number): ExtractSettlement {
  return {
    ...base,
    completedRuns: base.completedRuns + 1,
    stashValue: base.stashValue + extractValue,
    totalExtractedValue: base.totalExtractedValue + extractValue,
    lastExtractValue: extractValue,
    lastRecoveredValue: 0,
    lastFailureLossValue: 0
  };
}

export function settleFail(base: RunEconomyState, carriedValue: number): FailSettlement {
  const recoveredValue = Math.floor(carriedValue * 0.35);
  const lostValue = Math.max(0, carriedValue - recoveredValue);

  return {
    ...base,
    failedRuns: base.failedRuns + 1,
    stashValue: base.stashValue + recoveredValue,
    totalRecoveredValue: base.totalRecoveredValue + recoveredValue,
    lastExtractValue: 0,
    lastRecoveredValue: recoveredValue,
    lastFailureLossValue: lostValue
  };
}

export function nextRunNumber(completedRuns: number, failedRuns: number): number {
  return completedRuns + failedRuns + 1;
}

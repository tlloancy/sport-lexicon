export const SNATCH_TRANCHES = [
  { id: 'T1', min: 0, max: 30 },
  { id: 'T2', min: 31, max: 50 },
  { id: 'T3', min: 51, max: 70 },
  { id: 'T4', min: 71, max: 90 },
  { id: 'T5', min: 91, max: Infinity },
] as const;

export function trancheForSnatch(kg: number): string {
  for (const t of SNATCH_TRANCHES) {
    if (kg >= t.min && kg <= t.max) return t.id;
  }
  return 'T5';
}

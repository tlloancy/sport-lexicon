#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p generated
node --input-type=module <<'EOF'
import fs from 'fs';
import path from 'path';
import { Lexicons } from '@atproto/lexicon';

const lexDir = path.join(process.cwd(), 'lexicons');
const outDir = path.join(process.cwd(), 'generated');
const lexicons = new Lexicons();

const files = fs.readdirSync(lexDir).filter((f) => f.endsWith('.json'));
const ids = [];
for (const file of files) {
  const doc = JSON.parse(fs.readFileSync(path.join(lexDir, file), 'utf8'));
  lexicons.add(doc);
  ids.push(doc.id);
}
ids.sort();
const lines = [
  '// Auto-generated from lexicons/*.json — do not edit manually.',
  '',
  ...ids.map((id) => `export const ${id.replace(/\./g, '_').replace(/-/g, '_')} = ${JSON.stringify(id)};`),
  '',
  `export const LEXICON_IDS = ${JSON.stringify(ids, null, 2)} as const;`,
  '',
];

fs.writeFileSync(path.join(outDir, 'index.ts'), lines.join('\n'));

const trancheDoc = JSON.parse(
  fs.readFileSync(path.join(lexDir, 'sport.tranche.json'), 'utf8')
);
const thresholds = trancheDoc.movementThresholds ?? {};
const tranchesTs = [
  '// Auto-generated from lexicons/sport.tranche.json — do not edit manually.',
  '',
  `export const MOVEMENT_THRESHOLDS = ${JSON.stringify(thresholds, null, 2)} as const;`,
  '',
  'export type TrancheUnit = keyof typeof MOVEMENT_THRESHOLDS extends string',
  '  ? "kg"',
  '  : never;',
  '',
  '/** Assign tranche from movement thresholds (kg movements only for now). */',
  'export function assignTranche(movement: string, value: number, unit: string): string {',
  '  if (unit !== "kg") {',
  '    throw new Error(`Tranche assignment not defined for unit: ${unit}`);',
  '  }',
  '  const bands = MOVEMENT_THRESHOLDS[movement as keyof typeof MOVEMENT_THRESHOLDS];',
  '  if (!bands) {',
  '    throw new Error(`Unknown movement for tranche: ${movement}`);',
  '  }',
  '  for (const [id, range] of Object.entries(bands)) {',
  '    const [min, max] = range as [number, number];',
  '    if (value >= min && value <= max) return id;',
  '  }',
  '  const ids = Object.keys(bands);',
  '  return ids[ids.length - 1] ?? "T1";',
  '}',
  '',
].join('\n');
fs.writeFileSync(path.join(outDir, 'tranches.ts'), tranchesTs);
console.log('generated', ids.length, 'lexicons -> generated/');
EOF

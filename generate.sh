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
fs.writeFileSync(
  path.join(outDir, 'tranches.ts'),
  `export const SNATCH_TRANCHES = [
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
`
);
console.log('generated', ids.length, 'lexicons -> generated/');
EOF

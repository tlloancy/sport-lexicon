#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
git add -A
git commit -m "Add sport AT Protocol lexicons and generated TypeScript helpers."

#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
./scripts/setup-python.sh
echo "[update-content] Dependencies synced."

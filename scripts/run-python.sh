#!/usr/bin/env bash
set -euo pipefail

export PATH="${HOME}/.local/bin:${PATH}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

"${ROOT_DIR}/scripts/setup-python.sh"

if [[ "${1:-}" == "--test" ]]; then
  shift
  exec uv run pytest "$@"
fi

exec uv run python "$@"

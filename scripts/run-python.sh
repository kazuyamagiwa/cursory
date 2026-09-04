#!/usr/bin/env bash
# Cursor Cloud Agent entrypoint for Python — use this instead of bare python3.
#
# Usage:
#   ./scripts/run-python.sh script.py [args...]
#   ./scripts/run-python.sh -m pytest tests/ -v
#   ./scripts/run-python.sh --test
#   ./scripts/run-python.sh --sync
#   ./scripts/run-python.sh --repl
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
export PATH="${HOME}/.local/bin:${PATH}"

ensure_uv() {
  if command -v uv >/dev/null 2>&1; then
    return
  fi
  echo "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="${HOME}/.local/bin:${PATH}"
}

sync_env() {
  ensure_uv
  uv python install
  uv sync --all-extras
}

# Quiet bootstrap on every invoke (idempotent)
ensure_uv
uv python install >/dev/null
uv sync --all-extras >/dev/null

UV="$(command -v uv)"

case "${1:-}" in
  --sync)
    sync_env
    ;;
  --test)
    "$UV" run pytest "${@:2}"
    ;;
  --repl)
    "$UV" run python "${@:2}"
    ;;
  --help|-h)
    sed -n '2,10p' "$0" | sed 's/^# \?//'
    ;;
  --)
    shift
    "$UV" run python "$@"
    ;;
  -m)
    "$UV" run "$@"
    ;;
  "")
    echo "Usage: $0 <script.py> [args...] | --test | --sync | --repl | -m <module> [args...]"
    exit 1
    ;;
  *)
    "$UV" run python "$@"
    ;;
esac

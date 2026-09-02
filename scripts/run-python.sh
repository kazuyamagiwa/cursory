#!/usr/bin/env bash
# Agent entrypoint for Python — always use this instead of bare python3.
#
# Usage:
#   ./scripts/run-python.sh script.py [args...]
#   ./scripts/run-python.sh script.py -- --flag value
#   ./scripts/run-python.sh -m pytest tests/ -v
#   ./scripts/run-python.sh --test
#   ./scripts/run-python.sh --sync
#   ./scripts/run-python.sh --repl
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

UV="${UV:-$HOME/.local/bin/uv}"

bash "$ROOT/scripts/setup-python.sh" >/dev/null

run_uv() {
  "$UV" run "$@"
}

case "${1:-}" in
  --sync)
    bash "$ROOT/scripts/setup-python.sh"
    ;;
  --test)
    run_uv pytest "${@:2}"
    ;;
  --repl)
    run_uv python "${@:2}"
    ;;
  --help|-h)
    sed -n '2,10p' "$0" | sed 's/^# \?//'
    ;;
  --)
    shift
    run_uv python "$@"
    ;;
  -m)
    run_uv "$@"
    ;;
  "")
    echo "Usage: $0 <script.py> [args...] | --test | --sync | --repl | -m <module> [args...]"
    exit 1
    ;;
  *)
    if [[ "$1" == *.py && -f "$1" ]]; then
      run_uv python "$@"
    elif [[ -f "$1" ]]; then
      run_uv python "$@"
    else
      # Allow: ./scripts/run-python.sh -c "print(1)" via further args
      run_uv python "$@"
    fi
    ;;
esac
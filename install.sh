#!/usr/bin/env bash
# Install Cursor agent essentials from this kit into the user's repo root.
#
# Expected layout:
#   your-project/           ← TARGET (user repo root)
#     pyproject.toml        ← already exists; never overwritten
#     .cursory/             ← this kit
#       install.sh
#       _AGENTS.md
#       ...
#
# Cursor agent workflow (preferred — Q&A in chat, not bash read):
#   1. ./.cursory/install.sh --plan
#   2. Ask the user in Cursor chat which components to install
#   3. ./.cursory/install.sh --apply --with launcher,agents,run-python --cleanup
#      or everything missing: ./.cursory/install.sh --apply --all
#
# Other modes:
#   ./.cursory/install.sh --scan
#   ./.cursory/install.sh --apply --all --dry-run
#   ./.cursory/install.sh --apply --all --without python-version
#   CURSORY_YES=1 ./.cursory/install.sh     # alias for --apply --all --cleanup
#   ./.cursory/install.sh                   # interactive (humans in a real TTY only)
#
# Override target: CURSORY_TARGET=/path/to/repo ./install.sh ...
set -euo pipefail

CURSORY_DIR="$(cd "$(dirname "$0")" && pwd)"

# id:template_file:dest_rel  (launcher & cleanup are special — empty template)
TEMPLATES=(
  "agents:_AGENTS.md:AGENTS.md"
  "run-python:_run-python.sh:scripts/run-python.sh"
  "python-version:_python-version:.python-version"
  "cursor-rules:_python-testing.mdc:.cursor/rules/python-testing.mdc"
)

ALL_COMPONENT_IDS=(launcher agents run-python python-version cursor-rules cleanup)

MODE="" # scan | plan | apply | interactive
DRY_RUN=0
WANT_ALL=0
WITH_LIST=""
WITHOUT_LIST=""
EXPLICIT_CLEANUP=""
EXPLICIT_LAUNCHER=""

usage() {
  sed -n '2,24p' "$0" | sed 's/^# \?//'
  cat <<'EOF'

Components (--with / --without):
  launcher        Create ./cursory.sh at repo root
  agents          _AGENTS.md → AGENTS.md
  run-python      _run-python.sh → scripts/run-python.sh
  python-version  _python-version → .python-version
  cursor-rules    _python-testing.mdc → .cursor/rules/python-testing.mdc
  cleanup         Remove underscore templates (and safe leftovers) from .cursory/

Examples:
  ./.cursory/install.sh --plan
  ./.cursory/install.sh --apply --all
  ./.cursory/install.sh --apply --with launcher,agents,run-python --cleanup
  ./.cursory/install.sh --apply --all --without python-version --dry-run
EOF
}

resolve_target() {
  local parent
  parent="$(cd "$CURSORY_DIR/.." && pwd)"

  if [[ -n "${CURSORY_TARGET:-}" ]]; then
    TARGET="$(cd "$CURSORY_TARGET" && pwd)"
    return
  fi

  local base
  base="$(basename "$CURSORY_DIR")"

  if [[ "$base" == ".cursory" ]]; then
    TARGET="$parent"
    return
  fi

  # Legacy folder name — still works, but prefer .cursory
  if [[ "$base" == "cursory" ]]; then
    echo "Note: kit folder is 'cursory/'. Prefer renaming to '.cursory/'." >&2
    TARGET="$parent"
    return
  fi

  echo "This kit must live at <your-repo>/.cursory/"
  echo "Current kit directory name: $base"
  echo "Move/rename it to .cursory/, or set CURSORY_TARGET=/path/to/your-repo"
  exit 1
}

exists() { [[ -e "$1" ]]; }

csv_has() {
  # csv_has "a,b,c" "b" → 0 if present
  local csv="$1" needle="$2"
  [[ -z "$csv" ]] && return 1
  local IFS=','
  local item
  for item in $csv; do
    item="$(printf '%s' "$item" | tr -d '[:space:]')"
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

validate_component_id() {
  local id="$1" known
  for known in "${ALL_COMPONENT_IDS[@]}"; do
    [[ "$id" == "$known" ]] && return 0
  done
  echo "Unknown component: $id" >&2
  echo "Valid: ${ALL_COMPONENT_IDS[*]}" >&2
  exit 2
}

validate_csv() {
  local csv="$1"
  [[ -z "$csv" ]] && return 0
  local IFS=',' item
  for item in $csv; do
    item="$(printf '%s' "$item" | tr -d '[:space:]')"
    [[ -z "$item" ]] && continue
    validate_component_id "$item"
  done
}

parse_args() {
  if [[ "${CURSORY_YES:-}" == "1" && $# -eq 0 ]]; then
    MODE=apply
    WANT_ALL=1
    EXPLICIT_CLEANUP=1
    return
  fi

  if [[ $# -eq 0 ]]; then
    MODE=interactive
    return
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        usage
        exit 0
        ;;
      --scan)
        MODE=scan
        shift
        ;;
      --plan)
        MODE=plan
        shift
        ;;
      --apply)
        MODE=apply
        shift
        ;;
      --all)
        WANT_ALL=1
        shift
        ;;
      --dry-run)
        DRY_RUN=1
        shift
        ;;
      --with)
        WITH_LIST="${2:-}"
        shift 2
        ;;
      --with=*)
        WITH_LIST="${1#--with=}"
        shift
        ;;
      --without)
        WITHOUT_LIST="${2:-}"
        shift 2
        ;;
      --without=*)
        WITHOUT_LIST="${1#--without=}"
        shift
        ;;
      --cleanup)
        EXPLICIT_CLEANUP=1
        shift
        ;;
      --no-cleanup)
        EXPLICIT_CLEANUP=0
        shift
        ;;
      --launcher)
        EXPLICIT_LAUNCHER=1
        shift
        ;;
      --no-launcher)
        EXPLICIT_LAUNCHER=0
        shift
        ;;
      *)
        echo "Unknown argument: $1" >&2
        usage >&2
        exit 2
        ;;
    esac
  done

  if [[ -z "$MODE" ]]; then
    echo "Specify --scan, --plan, --apply, or run with no args for interactive." >&2
    exit 2
  fi

  validate_csv "$WITH_LIST"
  validate_csv "$WITHOUT_LIST"

  if [[ "$MODE" == "apply" ]]; then
    if [[ "$WANT_ALL" -eq 0 && -z "$WITH_LIST" && -z "$EXPLICIT_LAUNCHER" && -z "$EXPLICIT_CLEANUP" ]]; then
      echo "--apply requires --all and/or --with <components> (and optional --cleanup / --launcher)." >&2
      exit 2
    fi
  fi
}

want_component() {
  local id="$1"

  if csv_has "$WITHOUT_LIST" "$id"; then
    return 1
  fi

  if [[ "$WANT_ALL" -eq 1 ]]; then
    return 0
  fi

  if csv_has "$WITH_LIST" "$id"; then
    return 0
  fi

  if [[ "$id" == "launcher" && "$EXPLICIT_LAUNCHER" == "1" ]]; then
    return 0
  fi
  if [[ "$id" == "cleanup" && "$EXPLICIT_CLEANUP" == "1" ]]; then
    return 0
  fi

  return 1
}

print_scan() {
  echo ""
  echo "=== Scan of user repo: $TARGET ==="

  check() {
    local label="$1" path="$2"
    if exists "$TARGET/$path"; then
      echo "  [found]    $label"
    else
      echo "  [missing]  $label"
    fi
  }

  check "pyproject.toml" "pyproject.toml"
  check "AGENTS.md" "AGENTS.md"
  check "scripts/run-python.sh" "scripts/run-python.sh"
  check ".python-version" ".python-version"
  check ".cursor/rules/" ".cursor/rules"
  check "cursory.sh" "cursory.sh"
  check "src/" "src"
  check "tests/" "tests"
  check ".git/" ".git"
  echo ""

  if ! exists "$TARGET/pyproject.toml"; then
    echo "Note: no pyproject.toml at repo root."
    echo "      This kit will not create one (project-owned)."
    echo ""
  else
    echo "Note: pyproject.toml exists — it will never be overwritten."
    echo ""
  fi
}

status_for_template() {
  # sets STATUS=missing|exists|no-template and uses globals SRC DEST
  local src_file="$1" dest_rel="$2"
  SRC="$CURSORY_DIR/$src_file"
  DEST="$TARGET/$dest_rel"
  if ! exists "$SRC"; then
    STATUS=no-template
  elif exists "$DEST"; then
    STATUS=exists
  else
    STATUS=missing
  fi
}

print_plan() {
  echo "=== Plan (candidates for Cursor chat Q&A) ==="
  echo "Ask the user which of these to install, then run --apply with --with / --without."
  echo ""

  if exists "$TARGET/cursory.sh"; then
    echo "  [skip]     launcher          ./cursory.sh already exists"
  else
    echo "  [offer]    launcher          create ./cursory.sh"
  fi

  local id src_file dest_rel
  for entry in "${TEMPLATES[@]}"; do
    IFS=':' read -r id src_file dest_rel <<<"$entry"
    status_for_template "$src_file" "$dest_rel"
    case "$STATUS" in
      missing)
        echo "  [offer]    $id  $src_file → $dest_rel"
        ;;
      exists)
        echo "  [skip]     $id  $dest_rel already exists (will not overwrite)"
        ;;
      no-template)
        echo "  [skip]     $id  template $src_file missing from kit"
        ;;
    esac
  done

  echo "  [offer]    cleanup           remove underscore templates from .cursory/ after copy"
  echo ""
  echo "Example after the user answers in chat:"
  echo "  ./.cursory/install.sh --apply --with launcher,agents,run-python,cursor-rules --cleanup"
  echo "  ./.cursory/install.sh --apply --all --without python-version"
  echo "  ./.cursory/install.sh --apply --all"
}

write_root_shell() {
  local dest="$TARGET/cursory.sh"
  if exists "$dest"; then
    echo "  skip     launcher (./cursory.sh already exists)"
    return 0
  fi
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "  dry-run  create ./cursory.sh"
    return 0
  fi
  cat >"$dest" <<'EOF'
#!/usr/bin/env bash
# Launcher at user repo root → .cursory/install.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
exec "$ROOT/.cursory/install.sh" "$@"
EOF
  chmod +x "$dest"
  echo "  created  ./cursory.sh"
}

copy_template() {
  local src_file="$1"
  local dest_rel="$2"
  local src="$CURSORY_DIR/$src_file"
  local dest="$TARGET/$dest_rel"

  if ! exists "$src"; then
    echo "  skip     $src_file (template not in kit)"
    return 1
  fi

  if exists "$dest"; then
    echo "  skip     $dest_rel (already exists — will not overwrite)"
    return 1
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "  dry-run  $src_file → $dest_rel"
    return 0
  fi

  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  if [[ "$dest" == *.sh ]]; then
    chmod +x "$dest"
  fi
  echo "  copied   $src_file → $dest_rel"
  return 0
}

CLEANUP_IF_TARGET_HAS=(
  "AGENTS.md"
  ".python-version"
  "pyproject.toml"
  "uv.lock"
  "README.md"
  "src"
  "tests"
  "scripts"
  ".cursor"
)

run_cleanup() {
  echo ""
  echo "=== Cleanup inside kit: $CURSORY_DIR ==="

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "  dry-run  would remove templates whose destinations exist at repo root"
    return 0
  fi

  local id src_file dest_rel f

  # Remove underscore templates only when the live file already exists at TARGET
  # (copied earlier or pre-existing). Keep unselected templates for a later re-run.
  for entry in "${TEMPLATES[@]}"; do
    IFS=':' read -r id src_file dest_rel <<<"$entry"
    f="$CURSORY_DIR/$src_file"
    if ! exists "$f"; then
      continue
    fi
    if exists "$TARGET/$dest_rel"; then
      rm -f "$f"
      echo "  removed  $src_file (destination exists at repo root)"
    else
      echo "  kept     $src_file (destination not at repo root — still needed)"
    fi
  done

  for name in "${CLEANUP_IF_TARGET_HAS[@]}"; do
    f="$CURSORY_DIR/$name"
    if ! exists "$f"; then
      continue
    fi
    if exists "$TARGET/$name"; then
      rm -rf "$f"
      echo "  removed  $name (same name exists at repo root)"
    else
      echo "  kept     $name (no same-named path at repo root)"
    fi
  done

  echo "Kept install.sh and anything still unique to this kit."
}

apply_selected() {
  echo ""
  echo "=== Apply (never overwrite existing destinations) ==="
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "(dry-run — no files will be written)"
  fi

  if want_component launcher; then
    write_root_shell
  else
    echo "  skip     launcher (not selected)"
  fi

  local id src_file dest_rel
  for entry in "${TEMPLATES[@]}"; do
    IFS=':' read -r id src_file dest_rel <<<"$entry"
    if want_component "$id"; then
      copy_template "$src_file" "$dest_rel" || true
    else
      echo "  skip     $id (not selected)"
    fi
  done

  if want_component cleanup; then
    run_cleanup
  else
    echo "  skip     cleanup (not selected)"
  fi
}

# --- Interactive path (TTY humans only; agents must use --plan / --apply) ---

ask_yn() {
  local prompt="$1"
  local default="${2:-y}"
  local hint
  if [[ "$default" == "y" ]]; then hint="Y/n"; else hint="y/N"; fi

  if [[ ! -t 0 ]]; then
    echo "Interactive prompts require a TTY. Use --plan then --apply (Cursor chat Q&A), or --apply --all." >&2
    exit 2
  fi

  while true; do
    read -r -p "$prompt [$hint] " REPLY || true
    REPLY="${REPLY:-$default}"
    REPLY="$(printf '%s' "$REPLY" | tr '[:upper:]' '[:lower:]')"
    case "$REPLY" in
      y|yes) REPLY=y; return ;;
      n|no)  REPLY=n; return ;;
      *) echo "Please answer y or n." ;;
    esac
  done
}

run_interactive() {
  echo ""
  echo "Interactive mode (terminal). In Cursor, prefer: --plan → chat Q&A → --apply"
  echo ""

  local selected=""
  ask_yn "Create ./cursory.sh at repo root (launcher)?" y
  if [[ "$REPLY" == "y" ]]; then
    selected="launcher"
  fi

  local id src_file dest_rel default
  for entry in "${TEMPLATES[@]}"; do
    IFS=':' read -r id src_file dest_rel <<<"$entry"
    if ! exists "$CURSORY_DIR/$src_file"; then
      echo "  (missing template $src_file)"
      continue
    fi
    if exists "$TARGET/$dest_rel"; then
      echo "Already exists: $dest_rel — will not overwrite."
      continue
    fi
    ask_yn "Copy $src_file → $dest_rel?" y
    if [[ "$REPLY" == "y" ]]; then
      selected="${selected:+$selected,}$id"
    fi
  done

  ask_yn "Delete unnecessary files from .cursory/ now?" y
  if [[ "$REPLY" == "y" ]]; then
    selected="${selected:+$selected,}cleanup"
  fi

  WITH_LIST="$selected"
  WANT_ALL=0
  apply_selected
}

main() {
  parse_args "$@"
  resolve_target

  echo "cursory installer"
  echo "  kit:    $CURSORY_DIR"
  echo "  target: $TARGET"
  echo "  mode:   $MODE"

  if [[ "$TARGET" == "$CURSORY_DIR" ]]; then
    echo "Refusing to install into the kit directory itself."
    exit 1
  fi

  case "$MODE" in
    scan)
      print_scan
      ;;
    plan)
      print_scan
      print_plan
      ;;
    apply)
      print_scan
      apply_selected
      echo ""
      echo "Done."
      echo "  Re-run via: ./cursory.sh  or  ./.cursory/install.sh --plan"
      ;;
    interactive)
      print_scan
      run_interactive
      echo ""
      echo "Done."
      echo "  Re-run via: ./cursory.sh  or  ./.cursory/install.sh --plan"
      ;;
  esac
}

main "$@"

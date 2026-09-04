#!/usr/bin/env bash
# Install Cursor agent essentials from this kit into the user's repo root.
#
# Expected layout:
#   your-project/           ← TARGET (user repo root)
#     pyproject.toml        ← already exists; never overwritten
#     cursory/              ← this kit
#       install.sh
#       _AGENTS.md
#       _run-python.sh
#       ...
#     cursory.sh            ← optional root launcher (created here)
#
# From your-project/:  ./cursory/install.sh
#                  or: ./cursory.sh
#
# Non-interactive (preferred for Cursor natural-language installs):
#   CURSORY_YES=1 ./cursory/install.sh
# Override target:
#   CURSORY_TARGET=/path/to/repo ./install.sh
#
# In Cursor you can ask: "Install cursory non-interactively"
# → the agent should run CURSORY_YES=1 ./cursory/install.sh
set -euo pipefail

CURSORY_DIR="$(cd "$(dirname "$0")" && pwd)"

resolve_target() {
  local parent
  parent="$(cd "$CURSORY_DIR/.." && pwd)"

  if [[ -n "${CURSORY_TARGET:-}" ]]; then
    TARGET="$(cd "$CURSORY_TARGET" && pwd)"
    return
  fi

  if [[ "$(basename "$CURSORY_DIR")" == "cursory" ]]; then
    TARGET="$parent"
    return
  fi

  echo "This kit must live at <your-repo>/cursory/"
  echo "Current kit directory name: $(basename "$CURSORY_DIR")"
  echo "Move/rename it to cursory/, or set CURSORY_TARGET=/path/to/your-repo"
  exit 1
}

# template_file → destination relative to TARGET (leading _ stripped at dest)
TEMPLATES=(
  "_AGENTS.md:AGENTS.md"
  "_run-python.sh:scripts/run-python.sh"
  "_python-version:.python-version"
  "_python-testing.mdc:.cursor/rules/python-testing.mdc"
)

exists() { [[ -e "$1" ]]; }

ask_yn() {
  local prompt="$1"
  local default="${2:-y}"
  local hint
  if [[ "$default" == "y" ]]; then hint="Y/n"; else hint="y/N"; fi

  if [[ "${CURSORY_YES:-}" == "1" ]]; then
    REPLY="$default"
    echo "$prompt [$hint] $REPLY (auto)"
    return
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

install_root_shell() {
  local dest="$TARGET/cursory.sh"
  if exists "$dest"; then
    echo "Root shell already present: cursory.sh"
    return
  fi
  ask_yn "Create ./cursory.sh at repo root (launcher)?" y
  if [[ "$REPLY" != "y" ]]; then
    return
  fi
  cat >"$dest" <<'EOF'
#!/usr/bin/env bash
# Launcher at user repo root → cursory/install.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
exec "$ROOT/cursory/install.sh" "$@"
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

  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  if [[ "$dest" == *.sh ]]; then
    chmod +x "$dest"
  fi
  echo "  copied   $src_file → $dest_rel"
  return 0
}

# Non-template kit paths we may remove after install.
# Rule: delete from this kit ONLY when TARGET already has the same-named path
# (a copy remains at repo root). If the same name does NOT exist at TARGET, keep.
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

cleanup_kit() {
  echo ""
  echo "=== Cleanup inside kit: $CURSORY_DIR ==="
  ask_yn "Delete unnecessary files from cursory/ now?" y
  if [[ "$REPLY" != "y" ]]; then
    echo "Skipped cleanup."
    return
  fi

  local src_file dest_rel f

  # Underscore templates: always removable after the Q&A/copy pass
  for entry in "${TEMPLATES[@]}"; do
    IFS=':' read -r src_file dest_rel <<<"$entry"
    f="$CURSORY_DIR/$src_file"
    if exists "$f"; then
      rm -f "$f"
      echo "  removed  $src_file"
    fi
  done

  # Other leftovers: delete only when same name exists at TARGET
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

main() {
  resolve_target

  echo "cursory installer"
  echo "  kit:    $CURSORY_DIR"
  echo "  target: $TARGET"

  if [[ "$TARGET" == "$CURSORY_DIR" ]]; then
    echo "Refusing to install into the kit directory itself."
    exit 1
  fi

  print_scan
  install_root_shell

  echo ""
  echo "=== Copy underscore templates (never overwrite existing dest) ==="
  local src_file dest_rel default
  for entry in "${TEMPLATES[@]}"; do
    IFS=':' read -r src_file dest_rel <<<"$entry"
    if ! exists "$CURSORY_DIR/$src_file"; then
      echo "  (missing template $src_file)"
      continue
    fi
    echo ""
    if exists "$TARGET/$dest_rel"; then
      echo "Already exists: $dest_rel — will not overwrite."
      continue
    fi
    default=y
    ask_yn "Copy $src_file → $dest_rel?" "$default"
    if [[ "$REPLY" == "y" ]]; then
      copy_template "$src_file" "$dest_rel" || true
    else
      echo "  skipped  $dest_rel"
    fi
  done

  cleanup_kit

  echo ""
  echo "Done."
  echo "  Re-run via: ./cursory.sh  or  ./cursory/install.sh"
}

main "$@"

#!/usr/bin/env bash
set -euo pipefail

echo "==> on-create: first-time container setup"

# Git identity — Codespaces injects these when configured in user settings
if [[ -n "${GIT_USER_NAME:-}" && -n "${GIT_USER_EMAIL:-}" ]]; then
  git config --global user.name "$GIT_USER_NAME"
  git config --global user.email "$GIT_USER_EMAIL"
fi

# gh uses GITHUB_TOKEN automatically in Codespaces
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI authenticated"
else
  echo "Note: gh not authenticated yet (normal outside Codespaces)"
fi
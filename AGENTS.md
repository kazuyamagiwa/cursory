# Agent instructions (Cloud Agent / Cursor)

This repo has **two environments**. Do not confuse them.

| Environment | When it applies | How to run code |
|-------------|-----------------|-----------------|
| **Cloud Agent VM** | When the user asks *you* (the agent) to run or test code | Use `scripts/run-python.sh` — see below |
| **Codespace / devcontainer** | When the *user* opens the repo in GitHub Codespaces or VS Code Dev Containers | Automated by `.devcontainer/` (ignored by the agent) |

## Running Python (agent — required)

When the user asks you to run, test, or debug Python code, **always** use the wrapper script. Do **not** call `python`, `python3`, or `pip` directly.

```bash
# Run a script
./scripts/run-python.sh path/to/script.py

# Run with arguments
./scripts/run-python.sh path/to/script.py -- --flag value

# Run tests
./scripts/run-python.sh --test

# Run a module
./scripts/run-python.sh -m pytest tests/ -v

# Sync deps only (after pyproject.toml changes)
./scripts/run-python.sh --sync
```

The script handles: Python version pin, `uv` install, venv creation, and dependency sync from `pyproject.toml`.

## Source of truth for Python

| File | Purpose |
|------|---------|
| `.python-version` | Exact Python version (currently 3.12) |
| `pyproject.toml` | Dependencies and project metadata |
| `scripts/run-python.sh` | How the agent executes Python |
| `scripts/setup-python.sh` | Setup-only (called by run-python.sh) |

To add a package: edit `pyproject.toml` dependencies, then run `./scripts/run-python.sh --sync`.

## What not to do

- Do not assume `.devcontainer/post-create.sh` has run on the agent VM.
- Do not use system `python3` directly — versions and packages may differ from the project pin.
- Do not create ad-hoc venvs unless the user explicitly asks; use the script.
- Do not commit API keys or secrets — use GitHub Codespaces Secrets or Cursor environment secrets.
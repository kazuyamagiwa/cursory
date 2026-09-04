# Agent instructions (Cursor Cloud Agent)

This repo is for **Cursor Cloud Agents** only.

## Running Python

Always use the wrapper. Do **not** call `python`, `python3`, or `pip` directly.

```bash
./scripts/run-python.sh path/to/script.py
./scripts/run-python.sh path/to/script.py -- --flag value
./scripts/run-python.sh --test
./scripts/run-python.sh -m pytest tests/ -v
./scripts/run-python.sh --sync
```

The script installs `uv` if needed, pins Python from `.python-version`, creates `.venv`, and syncs deps from `pyproject.toml`.

## Source of truth

| File | Purpose |
|------|---------|
| `.python-version` | Exact Python version (3.12) |
| `pyproject.toml` | Dependencies and project metadata |
| `scripts/run-python.sh` | How to run Python / tests / sync |

To add a package: edit `pyproject.toml`, then `./scripts/run-python.sh --sync`.

## Do not

- Use system `python3` directly
- Create ad-hoc venvs — use the script
- Commit API keys — use Cursor environment secrets

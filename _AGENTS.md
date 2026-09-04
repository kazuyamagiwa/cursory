# Agent instructions (Cursor Cloud Agent)

This project is set up for **Cursor Cloud Agents**.

## Running Python

Always use the wrapper. Do **not** call `python`, `python3`, or `pip` directly.

```bash
./scripts/run-python.sh path/to/script.py
./scripts/run-python.sh path/to/script.py -- --flag value
./scripts/run-python.sh --test
./scripts/run-python.sh -m pytest tests/ -v
./scripts/run-python.sh --sync
```

The script installs `uv` if needed, creates `.venv`, and syncs deps from the
project's existing `pyproject.toml`. **Never overwrite `pyproject.toml`.**

## Source of truth

| File | Purpose |
|------|---------|
| `pyproject.toml` | Project-owned deps and metadata (do not overwrite) |
| `.python-version` | Python version pin when present |
| `scripts/run-python.sh` | How to run Python / tests / sync |

To add a package: edit `pyproject.toml`, then `./scripts/run-python.sh --sync`.

## Do not

- Use system `python3` directly
- Create ad-hoc venvs — use the script
- Overwrite an existing `pyproject.toml`
- Commit API keys — use Cursor environment secrets

# Agent instructions (Cursor Cloud Agent)

This project is set up for **Cursor Cloud Agents**.

## Running the cursory installer

If this repo is nested as `cursory/` under a user project and essentials are
not installed yet, run the installer **non-interactively** (do not use bare
interactive prompts — `read` does not work well for agents):

```bash
CURSORY_YES=1 ./cursory/install.sh
```

Or from the repo root after the first install created the launcher:

```bash
CURSORY_YES=1 ./cursory.sh
```

Never overwrite `pyproject.toml` or other existing destinations.

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
- Run `./cursory/install.sh` interactively when acting as an agent — use `CURSORY_YES=1`
- Commit API keys — use Cursor environment secrets

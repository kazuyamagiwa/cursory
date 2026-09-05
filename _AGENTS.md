# Agent instructions (Cursor Cloud Agent)

This project is set up for **Cursor Cloud Agents** — including asking Cursor
from your phone to test-run Python in this repo.

## Running the cursory installer

If `.cursory/` is present (preferred) and essentials are missing, **conduct Q&A
in Cursor chat** (not bash `read`):

1. `./.cursory/install.sh --plan`
2. Ask the user which components to install
3. `./.cursory/install.sh --apply --with … --cleanup` or `--apply --all`

```bash
./.cursory/install.sh --plan
./.cursory/install.sh --apply --with launcher,agents,run-python,cursor-rules --cleanup
./.cursory/install.sh --apply --all
./.cursory/install.sh --apply --all --dry-run
```

`CURSORY_YES=1 ./.cursory/install.sh` = `--apply --all --cleanup` (no questions).

Never overwrite `pyproject.toml` or other existing destinations.
Do **not** gitignore `.cursory/`.

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
- Run interactive `./.cursory/install.sh` (use `--plan` / `--apply` or chat Q&A)
- Add `.cursory/` to `.gitignore`
- Commit API keys — use Cursor environment secrets

# Agent instructions

This repository is a **Python 3.12 prototype**. Follow these rules in every session.

## Run Python through the wrapper script

Always use `./scripts/run-python.sh` — never call `python3`, `python`, or `pytest` directly.

```bash
# Run a script
./scripts/run-python.sh src/hello.py

# Run tests
./scripts/run-python.sh --test

# Pass arguments to Python
./scripts/run-python.sh -c "from hello import greet; print(greet('World'))"
```

`run-python.sh` calls `setup-python.sh` first, which installs `uv`, pins Python 3.12, and runs `uv sync --all-extras`.

## Ignore `.devcontainer/`

The `.devcontainer/` directory is for **GitHub Codespaces** only. Do not read, modify, or rely on it during Cursor Agent work.

## Constraints

- Python **3.12** only (`>=3.12,<3.13`), managed by `uv`
- No JavaScript, no web server, no forwarded ports
- Keep changes minimal and focused on the task at hand
- Run `./scripts/run-python.sh --test` before committing

## Project structure

| Path | Purpose |
|---|---|
| `src/` | Application source code |
| `tests/` | pytest tests (`testpaths = tests`, `pythonpath = src`) |
| `scripts/setup-python.sh` | One-time / idempotent environment setup |
| `scripts/run-python.sh` | Entry point for all Python execution |
| `pyproject.toml` | Dependencies and tool configuration |

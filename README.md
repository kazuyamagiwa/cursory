# cursory

Minimal **Python 3.12** starter for [Cursor Cloud Agents](https://cursor.com/docs).

Clone or copy this into a new repo, then ask the agent to run or edit code.

## Layout

```
AGENTS.md                 # agent contract
scripts/run-python.sh     # only way to run Python
pyproject.toml            # deps (uv)
.python-version           # 3.12
src/                      # application code
tests/                    # pytest
.cursor/rules/            # Cursor IDE rules
```

## Commands

```bash
./scripts/run-python.sh src/hello.py   # run a script
./scripts/run-python.sh --test         # pytest
./scripts/run-python.sh --sync         # after editing pyproject.toml
```

## Secrets

Never commit API keys. Store them as **Cursor environment secrets**; read them via `os.environ["…"]`.

## New dependency

Edit `pyproject.toml`, then:

```bash
./scripts/run-python.sh --sync
```

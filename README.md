# cursory

Drop this kit into a user project as `cursory/`, then run the installer at the
**repo root**. It scans the project, asks a few questions, and copies only the
essential Cursor files (never overwriting `pyproject.toml` or other existing files).

## Use in your project

```text
your-project/                 ← you already have this (with pyproject.toml)
  pyproject.toml
  cursory/                    ← copy of this repo
    install.sh
    _AGENTS.md                ← templates always start with _
    _run-python.sh
    _python-version
    _python-testing.mdc
```

From `your-project/`:

```bash
./cursory/install.sh
```

That creates an optional root launcher `./cursory.sh` and copies selected
templates out of `cursory/` (underscore removed):

| Template | Destination |
|----------|-------------|
| `_AGENTS.md` | `AGENTS.md` |
| `_run-python.sh` | `scripts/run-python.sh` |
| `_python-version` | `.python-version` |
| `_python-testing.mdc` | `.cursor/rules/python-testing.mdc` |

Afterward it cleans unnecessary files **inside `cursory/`**. Non-template
leftovers are removed only when the **same name already exists** at the repo
root (so a copy remains). Underscore templates are removed after the copy pass.

## Rules

- **Never** overwrite existing destinations
- **Never** create or overwrite `pyproject.toml` (project-owned)
- Templates in this kit **must** be named with a leading `_`

## Non-interactive

```bash
CURSORY_YES=1 ./cursory/install.sh
```

## After install

```bash
./scripts/run-python.sh --test
./scripts/run-python.sh path/to/script.py
```

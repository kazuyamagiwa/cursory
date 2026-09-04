# cursory

[![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)](https://github.com/topics/python)
[![uv](https://img.shields.io/badge/uv-package%20manager-DE5FE9)](https://github.com/astral-sh/uv)
[![pytest](https://img.shields.io/badge/pytest-ready-0A9EDC?logo=pytest&logoColor=white)](https://github.com/topics/pytest)
[![Cursor](https://img.shields.io/badge/Cursor-Cloud%20Agent-000000)](https://cursor.com/docs)
[![template](https://img.shields.io/badge/template-install%20kit-007EC6)](https://github.com/topics/template)

**Topics:** [python](https://github.com/topics/python) · [uv](https://github.com/topics/uv) · [pytest](https://github.com/topics/pytest) · [cursor](https://github.com/topics/cursor) · [ai-agents](https://github.com/topics/ai-agents) · [template](https://github.com/topics/template)

Drop this kit into a user project as `cursory/`, then run the installer at the
**repo root**. It scans the project, asks a few questions, and copies only the
essential Cursor files (never overwriting `pyproject.toml` or other existing files).

## Contents

- [Use in your project](#use-in-your-project)
- [Rules](#rules)
- [Non-interactive](#non-interactive)
- [After install](#after-install)

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

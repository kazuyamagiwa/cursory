# cursory

[![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)](https://github.com/topics/python)
[![uv](https://img.shields.io/badge/uv-package%20manager-DE5FE9)](https://github.com/astral-sh/uv)
[![pytest](https://img.shields.io/badge/pytest-ready-0A9EDC?logo=pytest&logoColor=white)](https://github.com/topics/pytest)
[![Cursor](https://img.shields.io/badge/Cursor-Cloud%20Agent-000000)](https://cursor.com/docs)
[![template](https://img.shields.io/badge/template-install%20kit-007EC6)](https://github.com/topics/template)

**Topics:** [python](https://github.com/topics/python) · [uv](https://github.com/topics/uv) · [pytest](https://github.com/topics/pytest) · [cursor](https://github.com/topics/cursor) · [ai-agents](https://github.com/topics/ai-agents) · [template](https://github.com/topics/template)

Minimal install kit that makes an existing Python project **Cursor Cloud Agent–ready**.

You drop this repo into your project as `cursory/`, run a short installer, and get just enough wiring for the agent to run scripts, sync deps, and run tests — without replacing your `pyproject.toml` or copying a whole second environment stack.

## Contents

- [Why this exists](#why-this-exists)
- [Ask Cursor to run Python](#ask-cursor-to-run-python)
- [What you get](#what-you-get)
- [Prerequisites](#prerequisites)
- [Install](#install)
- [What the installer does](#what-the-installer-does)
- [Templates → destinations](#templates--destinations)
- [Rules](#rules)
- [Day-to-day commands](#day-to-day-commands)
- [Adding dependencies](#adding-dependencies)
- [Secrets](#secrets)
- [Non-interactive install](#non-interactive-install)
- [Cleanup behavior](#cleanup-behavior)
- [Layout after install](#layout-after-install)
- [Troubleshooting](#troubleshooting)

## Why this exists

Most “agent templates” either:

- assume a greenfield repo and overwrite project files, or
- ship a large dual setup (e.g. Codespaces + agent) you do not need.

**cursory** is the opposite:

1. Your project already exists (especially its `pyproject.toml`).
2. You copy **only this kit** under `cursory/`.
3. An installer **asks** what is missing and copies **only** those essentials.
4. Template filenames start with `_` so they are never confused with live project files.

## Ask Cursor to run Python

After install, you do **not** need to remember shell commands for routine work.

In Cursor (Cloud Agent or chat with repo tools), you can simply ask:

> Run `src/hello.py` and show me the output.

> Run the tests.

> Sync dependencies after I edited `pyproject.toml`.

The agent reads `AGENTS.md` and is instructed to use:

```bash
./scripts/run-python.sh …
```

instead of bare `python` / `python3` / `pip`. That wrapper:

- installs [`uv`](https://github.com/astral-sh/uv) if needed
- installs the Python version from `.python-version` when present
- creates `.venv` and syncs from **your** `pyproject.toml`
- then runs the script, module, tests, or sync you asked for

So the normal loop is: **write code → ask Cursor to run it → read the result**.

You can still run the same commands yourself in a terminal; the agent and you share one entrypoint.

## What you get

| Piece | Role |
|-------|------|
| `AGENTS.md` | Contract the Cloud Agent follows (how to run Python, what not to overwrite) |
| `scripts/run-python.sh` | Single entrypoint for run / test / sync / REPL |
| `.python-version` | Optional pin (default template: 3.12) |
| `.cursor/rules/python-testing.mdc` | Cursor IDE rules for Python/tests |
| `cursory.sh` | Optional launcher at repo root → re-runs `cursory/install.sh` |

**Not** installed: a second `pyproject.toml`, Codespaces/devcontainer stack, or sample app code. Your project stays the source of truth.

## Prerequisites

- An existing project directory (ideally already a git repo)
- A project-owned `pyproject.toml` at the repo root (recommended). The kit **will not** create or overwrite one.
- Ability to run bash (`install.sh`, `scripts/run-python.sh`)
- Network on first `uv` / Python install (Cloud Agent VMs and fresh machines)

## Install

### 1. Put this kit under your repo

```text
your-project/                 ← your existing repo
  pyproject.toml              ← yours — never overwritten
  src/                        ← yours
  tests/                      ← yours
  cursory/                    ← copy or clone of this repository
    install.sh
    _AGENTS.md
    _run-python.sh
    _python-version
    _python-testing.mdc
    README.md
```

Clone example:

```bash
cd your-project
git clone https://github.com/kazuyamagiwa/cursory.git cursory
```

Or copy the folder in and name it exactly `cursory`.

### 2. Run the installer from the repo root

```bash
./cursory/install.sh
```

The kit directory **must** be named `cursory` (unless you set `CURSORY_TARGET`).

### 3. Answer the prompts

The installer:

1. Scans your repo (what exists / what is missing)
2. Offers to create `./cursory.sh` at the root
3. Asks, for each missing template, whether to copy it
4. Skips any destination that already exists (no overwrite)
5. Optionally cleans leftover template files inside `cursory/`

## What the installer does

```text
your-project/   ← TARGET (parent of cursory/)
cursory/        ← KIT (this repo)
```

1. **Resolve target** — parent of `cursory/` (or `CURSORY_TARGET`)
2. **Scan** — reports `pyproject.toml`, `AGENTS.md`, `scripts/run-python.sh`, `.python-version`, `.cursor/rules/`, `src/`, `tests/`, `.git/`
3. **Root shell** — optional `cursory.sh` that execs `cursory/install.sh`
4. **Q&A copy** — only selected `_` templates, underscore removed at destination
5. **Cleanup** — remove used `_` templates from the kit; other kit files only if the **same name already exists** at the repo root

## Templates → destinations

All templates in this kit **must** start with `_`.

| Template in `cursory/` | Copied to (repo root) |
|------------------------|------------------------|
| `_AGENTS.md` | `AGENTS.md` |
| `_run-python.sh` | `scripts/run-python.sh` |
| `_python-version` | `.python-version` |
| `_python-testing.mdc` | `.cursor/rules/python-testing.mdc` |

If the destination already exists, that file is **left untouched**.

## Rules

- **Never** overwrite existing destinations
- **Never** create or overwrite `pyproject.toml` (project-owned)
- Templates in this kit **must** be named with a leading `_`
- Agents and humans should run Python via `./scripts/run-python.sh`, not bare `python3`
- Do not commit API keys; use Cursor environment secrets

## Day-to-day commands

Prefer asking Cursor (see [Ask Cursor to run Python](#ask-cursor-to-run-python)). Equivalent terminal commands:

```bash
# Run a script
./scripts/run-python.sh path/to/script.py
./scripts/run-python.sh path/to/script.py -- --flag value

# Tests
./scripts/run-python.sh --test
./scripts/run-python.sh -m pytest tests/ -v

# Sync after editing pyproject.toml
./scripts/run-python.sh --sync

# REPL
./scripts/run-python.sh --repl
```

## Adding dependencies

1. Edit **your** `pyproject.toml` (add to `dependencies` or optional groups).
2. Ask Cursor to sync, or run:

```bash
./scripts/run-python.sh --sync
```

Do not replace `pyproject.toml` with anything from this kit.

## Secrets

Never commit real API keys.

- Store secrets as **Cursor environment secrets** for Cloud Agent runs.
- Read them in code with `os.environ["YOUR_KEY_NAME"]`.
- The **name** may appear in docs/code; the **value** must not appear in git.

## Non-interactive install

Useful for CI or scripted setup (accepts defaults: copy missing files, create launcher, clean kit):

```bash
CURSORY_YES=1 ./cursory/install.sh
```

Override target directory if needed:

```bash
CURSORY_TARGET=/path/to/your-repo CURSORY_YES=1 /path/to/cursory/install.sh
```

## Cleanup behavior

After the copy pass, the installer can delete unnecessary files **inside `cursory/`**:

| Kind | Behavior |
|------|----------|
| Underscore templates (`_AGENTS.md`, …) | Removed after the Q&A/copy pass |
| Other kit leftovers (`README.md`, old `src/`, …) | Removed **only if** the same name already exists at the repo root |
| `install.sh` | Always kept so you can re-run |

Re-run anytime:

```bash
./cursory.sh
# or
./cursory/install.sh
```

Existing project files are still never overwritten.

## Layout after install

Typical result:

```text
your-project/
  pyproject.toml                 ← unchanged (yours)
  AGENTS.md                      ← from _AGENTS.md
  cursory.sh                     ← optional root launcher
  .python-version                ← optional
  scripts/
    run-python.sh                ← from _run-python.sh
  .cursor/rules/
    python-testing.mdc           ← from _python-testing.mdc
  cursory/
    install.sh                   ← kept
    README.md                    ← kept if not also at repo root
    …                            ← underscore templates removed
  src/ …                         ← yours
  tests/ …                       ← yours
```

## Troubleshooting

| Problem | What to do |
|---------|------------|
| `This kit must live at <your-repo>/cursory/` | Rename the folder to `cursory`, or set `CURSORY_TARGET` |
| Agent uses system `python3` | Ensure `AGENTS.md` was installed; ask it to follow `AGENTS.md` / use `./scripts/run-python.sh` |
| `uv sync` fails | Fix **your** `pyproject.toml` / build backend; the kit does not own that file |
| Script runs but prints nothing | Many modules only define functions — ask Cursor to call an entrypoint or add a `__main__` block |
| Want a file the installer skipped | Delete or rename the destination only if you intend to replace it, then re-run `./cursory/install.sh` (installer still will not overwrite) — or copy the `_` template manually |
| First run is slow | Normal: `uv` and CPython may download once, then be cached |

## License

See [LICENSE](./LICENSE).

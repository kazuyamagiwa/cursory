# Agent instructions (this kit repo)

This repository is the **cursory** install kit for Cursor Cloud Agents.

## When nested under a user project

Preferred layout: the working tree is `…/.cursory/` inside a user repo (legacy
`cursory/` still works with a warning). If the user asks to install or set up
cursory:

### Do Cursor chat Q&A — do not use bash `read` prompts

1. Scan / show a plan:
   ```bash
   ./.cursory/install.sh --plan
   # or from inside .cursory/:
   ./install.sh --plan
   ```
2. **Ask the user in Cursor chat** which components to install (launcher,
   agents, run-python, python-version, cursor-rules, cleanup). Summarize what
   is already present vs missing from the plan output.
3. Apply their choices non-interactively:
   ```bash
   ./.cursory/install.sh --apply --with launcher,agents,run-python,cursor-rules --cleanup
   ```
   Or everything still missing:
   ```bash
   ./.cursory/install.sh --apply --all
   ```
   Optional dry-run before applying:
   ```bash
   ./.cursory/install.sh --apply --all --dry-run
   ```

Never run interactive `./install.sh` (no flags) as an agent — no TTY Q&A.
`CURSORY_YES=1 ./.cursory/install.sh` is OK only when the user wants defaults
with no questions (alias for `--apply --all --cleanup`).

Never overwrite the parent's `pyproject.toml` or other existing files (the
installer already enforces that).

**Do not add `.cursory/` to `.gitignore`.** The kit should stay committed so
Cloud Agents (including mobile) can find the installer.

## When developing this kit itself

- Templates that get copied to user projects are the `_`-prefixed files.
- Keep template names starting with `_`.
- CI exercises `--apply --all` against a mock parent repo with `.cursory/`.

There is no project `pyproject.toml` in this kit; Python tooling for end users
lives in the parent project after install.

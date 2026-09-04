# Agent instructions (this kit repo)

This repository is the **cursory** install kit for Cursor Cloud Agents.

## When nested under a user project

If the working tree is `…/cursory/` inside a user repo, and the user asks to
install or set up cursory, run:

```bash
CURSORY_YES=1 ./install.sh
```

from this directory, or from the parent:

```bash
CURSORY_YES=1 ./cursory/install.sh
```

Always prefer `CURSORY_YES=1` — interactive `read` prompts are a bad fit for agents.
Never overwrite the parent's `pyproject.toml` or other existing files (the
installer already enforces that).

## When developing this kit itself

- Templates that get copied to user projects are the `_`-prefixed files.
- Keep template names starting with `_`.
- CI exercises `CURSORY_YES=1 ./cursory/install.sh` against a mock parent repo.

There is no project `pyproject.toml` in this kit; Python tooling for end users
lives in the parent project after install.

# Python prototype template (Codespaces + Cursor Agent)

[![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![uv](https://img.shields.io/badge/uv-package%20manager-DE5FE9?logo=python&logoColor=white)](https://github.com/astral-sh/uv)
[![pytest](https://img.shields.io/badge/pytest-enabled-0A9EDC?logo=pytest&logoColor=white)](https://docs.pytest.org/)
[![Ruff](https://img.shields.io/badge/linter-Ruff-D7FF64?logo=ruff&logoColor=black)](https://docs.astral.sh/ruff/)
[![GitHub Codespaces](https://img.shields.io/badge/GitHub-Codespaces-181717?logo=github&logoColor=white)](https://github.com/features/codespaces)
[![Dev Containers](https://img.shields.io/badge/Dev%20Containers-ready-2496ED?logo=docker&logoColor=white)](https://containers.dev/)
[![GitHub Actions](https://img.shields.io/badge/CI-GitHub%20Actions-2088FF?logo=githubactions&logoColor=white)](.github/workflows/ci.yml)
[![Ports](https://img.shields.io/badge/ports-none-brightgreen)]()
[![Template](https://img.shields.io/badge/template-repo-007EC6?logo=github&logoColor=white)](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-template-repository)
[![Cursor Agent](https://img.shields.io/badge/Cursor-Agent%20ready-000000)](./AGENTS.md)
[![Secrets](https://img.shields.io/badge/secrets-GitHub%20Codespaces%20only-orange)](https://docs.github.com/en/codespaces/managing-your-codespaces/managing-encrypted-secrets-for-your-codespaces)

Fork or **Use this template** → **Code → Create codespace on main** → start coding in ~2 minutes.

Everything below is automated by `.devcontainer/`. **No web server, no open ports** — Python runs in the terminal only.

## Caution: two environments, two billing models

This repo is set up for **two different machines**. They are not the same, and they are billed differently.

| Environment | When it runs | Config in this repo | Who pays |
|-------------|--------------|---------------------|----------|
| **GitHub Codespace** | You open the repo in Codespaces / VS Code Dev Containers | `.devcontainer/` | **GitHub** (Codespaces compute; see your GitHub billing) |
| **Cursor Cloud Agent VM** | You ask the Cursor agent to run or test code | `AGENTS.md`, `scripts/run-python.sh`, `pyproject.toml` | **Cursor** (see below) |

`.devcontainer/` is **ignored** by the Cloud Agent. The agent uses its own VM and follows `AGENTS.md` instead. See [AGENTS.md](./AGENTS.md) for agent-side Python runs.

### Cursor Cloud Agent billing (important)

Cloud Agents are **not** priced like a traditional “$X/hour VM” you leave running.

- **You are billed mainly for AI usage** — tokens at the selected model’s [API pricing](https://cursor.com/docs/models-and-pricing), not idle wall-clock time while the VM sits unused.
- **Included plan usage is consumed first** (e.g. monthly API allowance on Pro), then on-demand usage at the same API rates if enabled.
- **On-demand usage and a spending limit** are typically required before Cloud Agents will run; check **Cursor Dashboard → Usage / Billing**.
- **Cost drivers:** expensive models (e.g. Opus), large context windows, long conversations, many tool calls, and repeated **environment builds** (custom `environment.json` / prebuild setup).
- **Generally not charged for:** the VM simply existing after a run finishes, with no new agent work in progress.
- **Environment setup runs** may incur usage; the first few environment creations are sometimes free (promo — confirm in your dashboard).

**GitHub Codespaces is separate.** Using a Codespace bills your GitHub account; asking the Cursor agent to work on this repo bills Cursor. Using both does not merge those charges.

Check your [Cursor dashboard](https://cursor.com/dashboard) for authoritative usage and limits. Rates and promos can change.

## What runs automatically

| When | What happens |
|------|----------------|
| Container build | Python 3.12, `gh`, common CLI tools |
| `onCreateCommand` | Git identity from Codespaces settings |
| `postCreateCommand` | `uv sync` — Python deps installed into `.venv` |
| No ports forwarded | Nothing exposed to the browser |

Manual step after first open: none.

## Quick commands

```bash
./scripts/run-python.sh src/hello.py   # Run a script
./scripts/run-python.sh --test         # Run pytest
./scripts/run-python.sh --sync         # Re-sync after editing pyproject.toml
gh pr create                           # Works in Codespaces with built-in token
```

## API keys and secrets

**Never commit actual API keys to this repo.**

If you need keys (e.g. OpenAI, AWS), store them in:

- **GitHub:** Repo **Settings → Secrets and variables → Codespaces**
- **Cursor:** Cloud Agent environment secrets (for agent runs)

Those services inject the key as an environment variable at runtime. Your code reads `os.environ["OPENAI_API_KEY"]` — the variable **name** can appear in code/docs; the **value** must never be in git.

## Make this a GitHub template repo

1. Push this folder to a new GitHub repository.
2. **Settings → General → Template repository** → enable.
3. (Optional) **Settings → Codespaces → Set up prebuilds** on `main` for faster startup.

## Automate even more

### Prebuilds

Prebuilds run `postCreateCommand` ahead of time so Codespaces start warm.

- Repo **Settings → Codespaces → Set up prebuilds**
- Region: pick closest to your team
- Branch: `main`

### Multi-repo prototypes

Clone sibling repos in `post-create.sh`:

```bash
gh repo clone your-org/shared-lib ../shared-lib
```

## Lifecycle hook cheat sheet

```
onCreateCommand      → once per container (git config)
updateContentCommand → after git pull / branch switch (uv sync)
postCreateCommand    → after create/update (uv sync)
postAttachCommand    → each time you connect from VS Code
```

## Add dependencies

Edit `pyproject.toml`, then:

```bash
./scripts/run-python.sh --sync
```

## Local test without Codespaces

```bash
./scripts/run-python.sh --test
./scripts/run-python.sh src/hello.py
```

Or: **Dev Containers: Reopen in Container** in VS Code with the Dev Containers extension.

## Agent-side Python (Cursor Cloud Agent only)

When the Cursor agent runs Python on its VM (not in Codespaces), it uses the same scripts:

```bash
./scripts/run-python.sh src/hello.py
./scripts/run-python.sh --test
```

See [AGENTS.md](./AGENTS.md) for the full contract.

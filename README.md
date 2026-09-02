# Python Prototype Template

[![Python 3.12](https://img.shields.io/badge/python-3.12-blue.svg)](https://www.python.org/downloads/)
[![uv](https://img.shields.io/badge/managed%20by-uv-DE5FE9.svg)](https://github.com/astral-sh/uv)
[![pytest](https://img.shields.io/badge/tested%20with-pytest-0A9EDC.svg)](https://docs.pytest.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A minimal Python 3.12 prototype template for **Cursor Cloud Agents** and **GitHub Codespaces**. No web server, no JavaScript, no forwarded ports — just Python, `uv`, and `pytest`.

## Quick start

```bash
./scripts/run-python.sh src/hello.py
./scripts/run-python.sh --test
```

## Billing caution

This template supports two development environments. **Choose one** to avoid double billing:

| Environment | When to use | Billing |
|---|---|---|
| **Cursor Cloud Agent** | Autonomous coding tasks via Cursor | Billed by Cursor |
| **GitHub Codespaces** | Interactive browser-based dev | Billed by GitHub |

- **Cursor Agent** uses `scripts/run-python.sh` and ignores `.devcontainer/`.
- **Codespaces** uses `.devcontainer/` lifecycle hooks; the agent does not need them.

Do not run both simultaneously on the same project unless you intend to pay for both.

## Project layout

```
.
├── AGENTS.md              # Instructions for Cursor Cloud Agent
├── pyproject.toml         # Project metadata and pytest config
├── scripts/
│   ├── setup-python.sh    # Install uv, Python 3.12, and dependencies
│   └── run-python.sh      # Always use this to run Python or pytest
├── src/                   # Application source
└── tests/                 # pytest tests
```

## Requirements

- Python **3.12** only (managed by [uv](https://github.com/astral-sh/uv))
- No forwarded ports or web server

## License

MIT — see [LICENSE](LICENSE).

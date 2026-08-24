# Third-party content and licenses

This repo contains skills imported from third-party projects and references one MCP server.
Each project's original license is preserved. All content authored by the repo owner is MIT licensed (see `LICENSE`).

| Component | Plugin | Source repo | License | Status |
|---|---|---|---|---|
| Karpathy behavioral guidelines (1) | `karpathy-guidelines` | [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) | MIT (declared in upstream `plugin.json`; no LICENSE file in upstream repo) | Vendored. |
| Ponytail lazy-dev skills (6) | `ponytail` | [dietrichgebert/ponytail](https://github.com/dietrichgebert/ponytail) | MIT | Vendored. |
| Design/animation skills (10) | `emil-design-skills` | [emilkowalski/skills](https://github.com/emilkowalski/skills) | MIT | Vendored (copied). Original LICENSE file at plugin root. |
| Impeccable skill (1, ~148 files) | `impeccable` | [pbakaus/impeccable](https://github.com/pbakaus/impeccable) | Apache-2.0 | `reference/` + `scripts/` + `SKILL.md` copied as-is. Hooks/agents not included. |
| Superpowers skills (14) | `superpowers` | [obra/superpowers](https://github.com/obra/superpowers) | MIT | Vendored. `skills/` copied as-is (v6.3.0). Hooks/plugin wiring not included — see README note. |
| Agent Reach skill (1 + 7 references) | `agent-reach` | [Panniantong/Agent-Reach](https://github.com/Panniantong/Agent-Reach) | MIT | Vendored. English `SKILL.md` (upstream `SKILL_en.md`) + `references/` copied as-is. CLI not vendored — auto-installs on first use. |
| Frontend design-taste skills (9) | `taste-skill` | [leonxlnx/taste-skill](https://github.com/leonxlnx/taste-skill) | MIT | Vendored. |
| codebase-memory-mcp (MCP server) | install step | [DeusData/codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp) | (its own LICENSE) | **Not vendored** — native binary installed by `setup.sh` / `setup.ps1` via the official installer. |

Note: The MCP server source (a 2000+ file native build) is intentionally **not** copied into this repo; it's installed on the target machine via its installer. This keeps this repo small and maintainable.
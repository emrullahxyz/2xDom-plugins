# Third-party content and licenses

This repo contains skills imported from third-party projects and references one MCP server.
Each project's original license is preserved. All content authored by the repo owner is MIT licensed (see `LICENSE`).

| Component | Plugin | Source repo | License | Status |
|---|---|---|---|---|
| Design/animation skills (10) | `emil-design-skills` | [emilkowalski/skills](https://github.com/emilkowalski/skills) | MIT | Vendored (copied). Original LICENSE file at plugin root. |
| Impeccable skill (1, ~148 files) | `impeccable` | [pbakaus/impeccable](https://github.com/pbakaus/impeccable) | Apache-2.0 | `reference/` + `scripts/` + `SKILL.md` copied as-is. Hooks/agents not included. |
| Frontend design-taste skills (9) | `taste-skill` | [leonxlnx/taste-skill](https://github.com/leonxlnx/taste-skill) | MIT | Vendored. |
| codebase-memory-mcp (MCP server) | install step | [DeusData/codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp) | (its own LICENSE) | **Not vendored** — native binary installed by `setup.sh` / `setup.ps1` via the official installer. |

Note: The MCP server source (a 2000+ file native build) is intentionally **not** copied into this repo; it's installed on the target machine via its installer. This keeps this repo small and maintainable.
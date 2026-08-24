# 2xDom-plugins 🧩

Personal **Claude Code plugin marketplace** by Emrullah. One repo, 7 plugins (42 skills total) + one MCP server, installable with a single command.

---

## Contents

| Plugin | Skills / content | Source |
|---|---|---|
| **karpathy-guidelines** | behavioral coding guidelines to reduce LLM mistakes (1 skill) | [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) |
| **ponytail** | lazy senior dev mode: YAGNI, stdlib first + audit/review/debt/gain/help family (6 skills) | [dietrichgebert/ponytail](https://github.com/dietrichgebert/ponytail) |
| **emil-design-skills** | animate, apple-design, review-animations, pick-ui-library… (10 skills) | [emilkowalski/skills](https://github.com/emilkowalski/skills) |
| **taste-skill** | taste-skill, minimalist, brutalist, soft, redesign, stitch, output, brandkit… (9 skills) | [leonxlnx/taste-skill](https://github.com/leonxlnx/taste-skill) |
| **impeccable** | 23-command frontend UI design skill (`/impeccable polish`, `audit`, `critique`…) | [pbakaus/impeccable](https://github.com/pbakaus/impeccable) |
| **superpowers** | software development methodology: brainstorming, TDD, systematic debugging, plan writing/execution, subagent-driven development, code review, git worktrees (14 skills) | [obra/superpowers](https://github.com/obra/superpowers) |
| **agent-reach** | internet capability router: 15 platforms (Twitter, Reddit, YouTube, GitHub, Bilibili, XiaoHongShu, LinkedIn, V2EX, Xueqiu, RSS, web search) — CLI auto-installs on first use (1 skill) | [Panniantong/Agent-Reach](https://github.com/Panniantong/Agent-Reach) |
| **codebase-memory-mcp** (MCP server) | codebase memory / graph indexing, semantic search (15 tools) | [DeusData/codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp) |

Licenses & attributions: [THIRD_PARTY.md](THIRD_PARTY.md)

---

## 🚀 Install on a new machine — ONE COMMAND

Target: **Claude Desktop's Code section** (Claude Code). It shares `~/.claude/` config with the CLI, and reads user-level skills from `~/.claude/skills/`, so the setup works there without needing the `claude` CLI or a marketplace.

### Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/emrullahxyz/2xDom-plugins/main/setup.ps1 | iex
```
or:
```powershell
git clone https://github.com/emrullahxyz/2xDom-plugins
cd 2xDom-plugins ; .\setup.ps1
```

### macOS / Linux (bash)
```bash
git clone https://github.com/emrullahxyz/2xDom-plugins
cd 2xDom-plugins && ./setup.sh
```

What the script does (idempotent — skips what's already installed):
1. Installs the **codebase-memory-mcp** native binary via its official installer (registers into `~/.claude.json`).
2. Copies the 7 plugins into `~/.claude/skills/` — Claude Code auto-loads them next session (works in the Desktop Code section without CLI/marketplace).
3. Optionally (only with `EMRULLAH_USE_MARKETPLACE=1`) also adds the marketplace and installs via `claude plugin install`.

> If the `claude` CLI isn't found, the script still works via the skills-directory copy (no CLI needed).

---

## 🔄 If everything gets wiped after a gateway change

Claude Desktop can reset skills/plugins/MCP config when you switch the **gateway**. To restore, just re-run the same install command:

- **Windows:** run `irm … | iex` again.
- **macOS/Linux:** run `./setup.sh` again.

The script is idempotent, so re-running is safe.

### Manual path (no CLI / if you prefer the UI)
1. Copy each plugin folder from `plugins/<name>` into `~/.claude/skills/<name>/` (each contains `.claude-plugin/plugin.json` + `skills/`).
2. For the MCP server, run the official installer: [DeusData/codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp).
3. Restart Claude (or run `/reload-plugins`).
4. Verify: `/plugin` (7 plugins), `/mcp` (codebase-memory-mcp).

---

## Repo structure

```
2xDom-plugins/
├── .claude-plugin/marketplace.json   # marketplace declaring the 7 plugins
├── plugins/
│   ├── karpathy-guidelines/   .claude-plugin + skills/karpathy-guidelines (1)
│   ├── ponytail/              .claude-plugin + skills/ponytail* (6)
│   ├── emil-design-skills/    skills/ (10)
│   ├── taste-skill/           skills/ (9)
│   ├── impeccable/            skills/impeccable/ (SKILL.md + reference/ + scripts/)
│   ├── superpowers/           .claude-plugin + skills/ (14)
│   └── agent-reach/           .claude-plugin + skills/agent-reach/ (SKILL.md + references/)
├── setup.sh             bash install + restore
├── setup.ps1            PowerShell install + restore
├── LICENSE              (MIT — personal content)
└── THIRD_PARTY.md       third-party attributions/licenses
```

---

## Verification

- After install, `/plugin` shows the 7 plugins.
- `/mcp` shows `codebase-memory-mcp` with 15 tools.
- Skills: `/ponytail`, `/karpathy-guidelines`, `/impeccable`, one taste skill, one emil skill, `/brainstorming`, `/agent-reach`.
  - Impeccable's `node …/scripts/*` commands may ask for permission on first use — that's expected.
  - Agent Reach's CLI auto-installs on first use of the skill (`agent-reach doctor` to verify channels).
  - Superpowers' `using-superpowers` bootstrap requires the session-start hook; via the skills-copy path, invoke `/brainstorming` etc. manually.

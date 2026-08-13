# Third-party içerik ve lisanslar

Bu repo üçüncü taraf projelerden alınan skill'leri ve bir MCP server referansını içerir.
Her birinin orijinal lisansı korunur. Kullanıcının kendi yazdığı tüm içerik MIT lisansı altındadır (bkz. `LICENSE`).

| Komponent | Plugin | Kaynak repo | Lisans | Durum |
|---|---|---|---|---|
| Design/animation skill'leri (10) | `emil-design-skills` | [emilkowalski/skills](https://github.com/emilkowalski/skills) | MIT | Skill'ler vendored (kopyalandı). Orijinal LICENSE dosyası plugin kökünde. |
| Impeccable skill (1, ~148 dosya) | `impeccable` | [pbakaus/impeccable](https://github.com/pbakaus/impeccable) | Apache-2.0 | `reference/` + `scripts/` + `SKILL.md` olduğu gibi kopyalandı. Hooks/agents dahil edilmedi. |
| Frontend design-taste skill'leri (9) | `taste-skill` | [leonxlnx/taste-skill](https://github.com/leonxlnx/taste-skill) | MIT | Skill'ler vendored. |
| codebase-memory-mcp (MCP server) | kurulum ek adımı | [DeusData/codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp) | (kendi LICENSE'ı) | **Vendored değil** — native binary, `setup.sh` / `setup.ps1` resmi installer'ını çalıştırır. |

Not: MCP server kaynak kodu (2035+ dosyalık native build) bu repoya **kopyalanmaz**; yeni makineye kurucu üzerinden kurulur. Böylece repo küçük ve DSLifetime kalır.
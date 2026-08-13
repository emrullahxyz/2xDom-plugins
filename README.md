# emrullah-plugins 🧩

Emrullah'ın kişisel **Claude Code plugin marketplace'i**. Tek repoda 4 plugin (toplam 27 skill) + bir MCP server kurulumu, tek komutla.

**Public** repo — sadece sahibi (`emrullahxyz`) push/yazma yetkisine sahiptir.

---

## İçerik

| Plugin | Skill / içerik | Kaynak |
|---|---|---|
| **2xDom** | karpathy-guidelines + ponytail ailesi (7 skill) | kullanıcının kendi |
| **emil-design-skills** | animate, apple-design, review-animations, pick-ui-library… (10 skill) | [emilkowalski/skills](https://github.com/emilkowalski/skills) |
| **taste-skill** | taste-skill, minimalist, brutalist, soft, redesign, stitch, output, brandkit… (9 skill) | [leonxlnx/taste-skill](https://github.com/leonxlnx/taste-skill) |
| **impeccable** | 23 komutlu frontend UI design skill (`/impeccable polish`, `audit`, `critique`…) | [pbakaus/impeccable](https://github.com/pbakaus/impeccable) |
| **codebase-memory-mcp** (MCP server) | kod tabanı hafıza/grafik indexleme, semantic arama (15 tool) | [DeusData/codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp) |

Detaylı lisans/atıflar: [THIRD_PARTY.md](THIRD_PARTY.md)

---

## 🚀 Yeni makinede kurulum — TEK KOMUT

### Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/emrullahxyz/emrullah-plugins/main/setup.ps1 | iex
```
veya:
```powershell
git clone https://github.com/emrullahxyz/emrullah-plugins
cd emrullah-plugins ; .\setup.ps1
```

### macOS / Linux (bash)
```bash
git clone https://github.com/emrullahxyz/emrullah-plugins
cd emrullah-plugins && ./setup.sh
```

Script şunları yapar (idempotent — zaten kurulu olanı atlar):
1. **codebase-memory-mcp** native binary'sini resmi installer ile kurar.
2. Marketplaceden bu repo'yu ekler.
3. 4 plugin'i kurar.

> Not: `setup.sh` / `setup.ps1` her CLI'DAKI tam komut adına bağlı olduğundan, `claude` CLI'si yoksa script size elle yapılacak `/plugin` adımlarını yazdırır.

---

## 🔄 Gateway değişince her şey silinirse (geri yükleme)

Claude Desktop'ta **gateway değiştirdiğinizde** skill/plugin/mcp ayarları sıfırlanabiliyor. Bunu geri yüklemek yeterli:

- **Windows:** yukarıdaki `irm … | iex` komutunu tekrar çalıştır.
- **macOS/Linux:** `./setup.sh`'Çalıştır.

Script idempotent olduğu için tekrar çalıştırmak güvenli.

### Manuel yol (CLI yoksa / UI tercih edenler için)
1. `claude` veya `/plugin`: **Add marketplace** → `https://github.com/emrullahxyz/emrullah-plugins`
2. 4 plugin'i de kur: `2xDom`, `emil-design-skills`, `taste-skill`, `impeccable`
3. MCP: `codebase-memory-mcp` için resmi installer'ı çalıştır (bkz. [DeusData/codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp))
4. Doğrula: `/plugin` (4 plugin), `/mcp` (codebase-memory-mcp).

---

## Repo yapısı

```
emrullah-plugins/
├── .claude-plugin/marketplace.json   # 4 plugin'i tanımlayan marketplace
├── plugins/
│   ├── 2xDom/          .claude-plugin + skills/ (7)
│   ├── emil-design-skills/   skills/ (10)
│   ├── taste-skill/          skills/ (9)
│   └── impeccable/           skills/impeccable/ (SKILL.md + reference/ + scripts/)
├── setup.sh             bash kurulum + geri yükleme
├── setup.ps1            PowerShell kurulum + geri yükleme
├── LICENSE              (MIT — kişisel içerik)
└── THIRD_PARTY.md       üçüncü taraf atıflar/lisanslar
```

---

## Doğrulama

- Kurulumdan sonra Claude Code'DA `/plugin`'te 4 plugin görünür.
- `/mcp`'te `codebase-memory-mcp` 15 tool ile görünür.
- Skill'ler: `/ponytail`, `/karpathy-guidelines`, `/impeccable`, bir taste skill, bir emil skill.
  - Impeccable'ın `node …/scripts/*` komutları ilk kullanımda izin onayı isteyebilir — normaldir.
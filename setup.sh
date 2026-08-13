#!/usr/bin/env bash
#
# emrullah-plugins — kurulum + geri yükleme
# Hedef: Claude Desktop uygulamasının CODE bölümü (Claude Code).
#   Claude Code, kullanıcı-level skills'i ~/.claude/skills/ altından otomatik yükler;
#   bu yüzden CLI/marketplace gerekmeden Desktop'ın Code bölümünde de anında çalışır.
#
# Yeni makinede TEK KOMUT:
#   git clone https://github.com/emrullahxyz/emrullah-plugins
#   cd emrullah-plugins && ./setup.sh
#
# Gateway değişip skill/plugin/mcp silinirse: aynı komutu tekrar çalıştır (idempotent).
#
set -uo pipefail

REPO="https://github.com/emrullahxyz/emrullah-plugins"
PLUGINS="2xDom emil-design-skills taste-skill impeccable"

say() { printf '\n\033[1;36m%s\033[0m\n' "$*"; }
has() { command -v "$1" >/dev/null 2>&1; }

# repo root'ta çalıştırılmadıysa (curl|bash vb.) önce kendini getir
if [ ! -d "$PWD/plugins" ]; then
  TMP="$(mktemp -d)"
  if has git; then
    git clone --depth 1 "$REPO" "$TMP" >/dev/null 2>&1 && cd "$TMP" || { echo "klonlanamadı: $REPO"; exit 1; }
  elif has curl && has tar; then
    curl -fsSL "$REPO/archive/refs/heads/main.tar.gz" -o "$TMP/repo.tgz" && \
      tar -xzf "$TMP/repo.tgz" -C "$TMP" && cd "$TMP/emrullah-plugins-main" || { echo "indirilemedi: $REPO"; exit 1; }
  else
    echo "! git veya curl+tar gerekli"; exit 1
  fi
fi

# [1/3] codebase-memory MCP
say "[1/3] codebase-memory-mcp (MCP server)"
if has codebase-memory-mcp || has cbm; then
  echo "  ✓ mevcut, atlandı"
elif has curl; then
  curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.sh | bash \
    && echo "  ✓ kuruldu (kayıt: ~/.claude.json)" \
    || echo "  ! kurulamadı — https://github.com/DeusData/codebase-memory-mcp"
else
  echo "  ! curl yok — kodu manuel kur"
fi

# [2/3] Plugin'leri Claude Code skills dizinine kopyala (auto-load)
say "[2/3] plugin'ler kopyalanıyor → ~/.claude/skills"
SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
mkdir -p "$SKILLS_DIR"
for p in $PLUGINS; do
  rm -rf "$SKILLS_DIR/$p"
  cp -r "$PWD/plugins/$p" "$SKILLS_DIR/$p"
  echo "  ✓ $p"
done

# [3/3] Opsiyonel marketplace (sadece EMRULLAH_USE_MARKETPLACE=1 verilirse)
if has claude && [ "${EMRULLAH_USE_MARKETPLACE:-0}" = "1" ]; then
  say "[3/3] (opsiyonel) marketplace kurulumu"
  claude plugin marketplace add "$REPO" 2>&1 || echo "  ! marketplace eklenemedi"
  for p in $PLUGINS; do
    claude plugin install "$p@emrullah-plugins" 2>&1 || echo "  ! $p kurulamadı"
  done
fi

say "Tamam. Claude Desktop'ı yeniden başlat ya da Code bölümünde /reload-plugins çalıştır."
echo "Doğrulama: /plugin (4 plugin görünmeli) ve /mcp (codebase-memory-mcp, 15 tool)."
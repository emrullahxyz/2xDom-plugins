#!/usr/bin/env bash
#
# 2xDom-plugins - DIFF & RESTORE (bash)
# Repo ile Claude Desktop arasindaki farki bulur, eksik olanlari repodan ceker,
# repo ile ayni olana kadar devam eder. Idempotent - tekrar calistirmak guvenli.
#
# Yeni makinede / gateway degisikliginden sonra:
#   git clone https://github.com/emrullahxyz/2xDom-plugins
#   cd 2xDom-plugins && ./sync.sh
# veya tek satir:
#   curl -fsSL https://raw.githubusercontent.com/emrullahxyz/2xDom-plugins/main/sync.sh | bash
#
set -uo pipefail

REPO="https://github.com/emrullahxyz/2xDom-plugins"
MARKETPLACE=".claude-plugin/marketplace.json"
SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
CLAUDE_JSON="$HOME/.claude.json"
MCP_NAME="codebase-memory-mcp"

say()  { printf '\n\033[1;36m%s\033[0m\n' "$*"; }
has()  { command -v "$1" >/dev/null 2>&1; }
ok()   { printf '\033[1;32m%s\033[0m' "$*"; }
warn() { printf '\033[1;33m%s\033[0m' "$*"; }

# repo root'ta calistirilmadiysa once kendini getir
if [ ! -d "$PWD/plugins" ]; then
  TMP="$(mktemp -d)"
  if has git; then
    git clone --depth 1 "$REPO" "$TMP" >/dev/null 2>&1 && cd "$TMP" || { echo "klonlanamadi: $REPO"; exit 1; }
  elif has curl && has tar; then
    curl -fsSL "$REPO/archive/refs/heads/main.tar.gz" -o "$TMP/repo.tgz" && \
      tar -xzf "$TMP/repo.tgz" -C "$TMP" && cd "$TMP/2xDom-plugins-main" || { echo "indirilemedi: $REPO"; exit 1; }
  else
    echo "! git veya curl+tar gerekli"; exit 1
  fi
fi

# Plugin listesini marketplace.json'dan cikar (./plugins/<name> -> <name>)
PLUGINS=""
if has jq; then
  PLUGINS="$(jq -r '.plugins[].source | sub("^./plugins/"; "")' "$MARKETPLACE" | tr '\n' ' ')"
elif has node; then
  PLUGINS="$(node -e "const j=require('./$MARKETPLACE');console.log(j.plugins.map(p=>p.source.replace(/^.\/plugins\//,'')).join(' '))")"
else
  PLUGINS="karpathy-guidelines ponytail emil-design-skills taste-skill impeccable superpowers agent-reach"
  echo "  (uyari: jq/node yok, sabit liste kullaniliyor)" >&2
fi
PLUGINS="$(echo "$PLUGINS" | xargs)"

say "=== 2xDom-plugins SYNC ==="
echo "Repo:    $REPO"
echo "Target:  $SKILLS_DIR"
echo "MCP:     $MCP_NAME (registered in $CLAUDE_JSON)"

# ---------- PHASE 1: DIFF ----------
say "[1/3] DIFF"
mkdir -p "$SKILLS_DIR"
for p in $PLUGINS; do
  if [ -f "$SKILLS_DIR/$p/.claude-plugin/plugin.json" ]; then
    printf "  %-22s OK\n" "$p"
  else
    printf "  %-22s YOK\n" "$p"
  fi
done

mcp_registered=0
if [ -f "$CLAUDE_JSON" ] && has node; then
  if node -e "const j=JSON.parse(require('fs').readFileSync('$CLAUDE_JSON','utf8'));process.exit(j.mcpServers && j.mcpServers['$MCP_NAME'] ? 0 : 1)" 2>/dev/null; then
    mcp_registered=1
  fi
fi
if [ "$mcp_registered" -eq 1 ]; then
  printf "  %-22s OK\n"  "mcp:$MCP_NAME"
else
  printf "  %-22s YOK\n" "mcp:$MCP_NAME"
fi

# ---------- PHASE 2: RECONCILE ----------
say "[2/3] RECONCILE"
ok=0; fail=0
for p in $PLUGINS; do
  src="$PWD/plugins/$p"
  dst="$SKILLS_DIR/$p"
  if [ ! -d "$src" ]; then
    warn "  ! $p - repoda yok, ATLANIYOR\n"; fail=$((fail+1))
    continue
  fi
  if [ -f "$dst/.claude-plugin/plugin.json" ]; then
    echo "  = $p - guncel"
    ok=$((ok+1))
  else
    rm -rf "$dst"
    cp -r "$src" "$dst"
    ok "  + $p - kopyalandi\n"; ok=$((ok+1))
  fi
done

mcp_result=""
if [ "$mcp_registered" -eq 1 ]; then
  echo "  = mcp:$MCP_NAME - kayitli"; mcp_result="OK"
else
  echo "  + mcp:$MCP_NAME - installer deneniyor..."
  if has curl; then
    if curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.sh | bash; then
      ok "  + mcp:$MCP_NAME - kuruldu\n"; mcp_result="KURULDU"
    else
      warn "  ! mcp:$MCP_NAME - installer basarisiz. Bu makinede kurulamadi.\n"
      warn "    Temiz bir makinede: curl -fsSL $REPO/raw/main/setup.sh | bash\n"
      mcp_result="BASARISIZ"
      fail=$((fail+1))
    fi
  else
    warn "  ! curl yok - MCP atlandi\n"; mcp_result="ATLANAN (curl yok)"; fail=$((fail+1))
  fi
fi

# ---------- PHASE 3: VERIFY ----------
say "[3/3] VERIFY"
for p in $PLUGINS; do
  if [ -f "$SKILLS_DIR/$p/.claude-plugin/plugin.json" ]; then
    printf "  [OK ] %-22s\n" "$p"
  else
    printf "  [?  ] %-22s EKSIK\n" "$p"
  fi
done
case "$mcp_result" in
  OK|KURULDU) tag="OK " ;;
  *)          tag="?  " ;;
esac
printf "  [%s] %-22s %s\n" "$tag" "mcp:$MCP_NAME" "$mcp_result"

say "Toplam: $ok OK, $fail sorun"

# ---------- PHASE 4: MARKETPLACE (Claude plugin CLI) ----------
# ~/.claude/skills/ Claude Code'un auto-load'unu tetikler, ama /plugin menusu
# marketplace tarafini gosterir. Iki tarafin da esit olmasi icin burada
# `claude plugin marketplace add` + `claude plugin install` calistiriyoruz.
# Idempotent: zaten kurulular "already installed" der.
if [ "${EMRULLAH_SKIP_MARKETPLACE:-0}" = "1" ]; then
  echo ""
  echo "(marketplace atladi: EMRULLAH_SKIP_MARKETPLACE=1)"
elif has claude; then
  say "[4/4] MARKETPLACE (claude plugin CLI)"
  echo "  + marketplace ekleniyor: $REPO"
  claude plugin marketplace add "$REPO" >/dev/null 2>&1 \
    && echo "  = marketplace OK" \
    || echo "  ! marketplace eklenemedi (devam ediliyor)"
  for p in $PLUGINS; do
    out="$(claude plugin install "$p@2xDom-plugins" 2>&1)"
    if echo "$out" | grep -q "Successfully installed\|already installed"; then
      echo "  = $p - kurulu (zaten veya yeni)"
    else
      warn "  ! $p - basarisiz: $out\n"
    fi
  done
else
  echo ""
  echo "(marketplace atladi: 'claude' CLI bulunamadi)"
fi

echo ""
ok "Claude Desktop'i yeniden baslat veya Code bolumunde /reload-plugins calistir.\n"
echo "Dogrulama: /plugin (7 plugin) ve /mcp ($MCP_NAME)."

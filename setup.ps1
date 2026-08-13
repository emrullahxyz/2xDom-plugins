# emrullah-plugins — kurulum + geri yükleme (Windows / PowerShell)
# Hedef: Claude Desktop uygulamasının CODE bölümü (Claude Code).
#   Claude Code, kullanıcı-level skills'i ~/.claude/skills/ altından otomatik yükler;
#   CLI/marketplace gerekmeden Desktop'ın Code bölümünde de anında çalışır.
#
# Yeni makinede TEK KOMUT (PowerShell):
#   irm https://raw.githubusercontent.com/emrullahxyz/emrullah-plugins/main/setup.ps1 | iex
#   (veya: git clone https://github.com/emrullahxyz/emrullah-plugins ; cd emrullah-plugins ; .\setup.ps1)
#
# Gateway değişip skill/plugin/mcp silinirse: aynı komutu tekrar çalıştır (idempotent).
#
$ErrorActionPreference = "Continue"
$Repo    = "https://github.com/emrullahxyz/emrullah-plugins"
$Plugins = @("2xDom", "emil-design-skills", "taste-skill", "impeccable")

# repo root'ta değilsek önce kendini klonla
if (-not (Test-Path (Join-Path $PWD "plugins"))) {
  $t = Join-Path $env:TEMP "emrullah-plugins"
  if (Test-Path $t) { Remove-Item $t -Recurse -Force }
  git clone --depth 1 $Repo $t
  Set-Location $t
}

# [1/3] codebase-memory MCP
Write-Host "[1/3] codebase-memory-mcp (MCP server)" -ForegroundColor Cyan
if (Get-Command codebase-memory-mcp -ErrorAction SilentlyContinue) {
  Write-Host "  mevcut, atlandi"
} else {
  try {
    $u  = "https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.ps1"
    $tf = Join-Path $env:TEMP "cbm-install.ps1"
    Invoke-WebRequest -Uri $u -OutFile $tf -ErrorAction Stop
    & $tf
    Write-Host "  kuruldu (kayit: ~/.claude.json)"
  } catch {
    Write-Host "  ! kurulum hatasi: $($_.Exception.Message)" -ForegroundColor Yellow
  }
}

# [2/3] Plugin'leri Claude Code skills dizinine kopyala (auto-load)
Write-Host "[2/3] plugin'ler kopyalaniyor -> ~/.claude/skills" -ForegroundColor Cyan
$SkillsDir = if ($env:CLAUDE_SKILLS_DIR) { $env:CLAUDE_SKILLS_DIR } else { Join-Path $HOME ".claude\skills" }
New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null
foreach ($p in $Plugins) {
  $dst = Join-Path $SkillsDir $p
  if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
  Copy-Item -Recurse (Join-Path $PWD "plugins\$p") $dst
  Write-Host "  OK $p"
}

# [3/3] Opsiyonel marketplace (sadece EMRULLAH_USE_MARKETPLACE=1 verilirse)
if ((Get-Command claude -ErrorAction SilentlyContinue) -and $env:EMRULLAH_USE_MARKETPLACE -eq "1") {
  Write-Host "[3/3] (opsiyonel) marketplace kurulumu" -ForegroundColor Cyan
  claude plugin marketplace add $Repo
  foreach ($p in $Plugins) { claude plugin install "$p@emrullah-plugins" }
}

Write-Host "Tamam. Claude Desktop'i yeniden baslat ya da Code bolumunde /reload-plugins calistir." -ForegroundColor Green
Write-Host "Dogrulama: /plugin (4 plugin) ve /mcp (codebase-memory-mcp, 15 tool)."
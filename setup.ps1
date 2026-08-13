# 2xDom-plugins — kurulum + geri yükleme (Windows / PowerShell)
# Hedef: Claude Desktop uygulamasının CODE bölümü (Claude Code).
#   Claude Code, kullanıcı-level skills'i ~/.claude/skills/ altından otomatik yükler;
#   CLI/marketplace gerekmeden Desktop'ın Code bölümünde de anında çalışır.
#
# Yeni makinede TEK KOMUT (PowerShell):
#   irm https://raw.githubusercontent.com/emrullahxyz/2xDom-plugins/main/setup.ps1 | iex
#   (veya: git clone https://github.com/emrullahxyz/2xDom-plugins ; cd 2xDom-plugins ; .\setup.ps1)
#
# Gateway değişip skill/plugin/mcp silinirse: aynı komutu tekrar çalıştır (idempotent).
#
$ErrorActionPreference = "Continue"
$Repo    = "https://github.com/emrullahxyz/2xDom-plugins"
$Plugins = @("karpathy-guidelines", "ponytail", "emil-design-skills", "taste-skill", "impeccable")

# repo root'ta değilsek (örn. irm | iex) repoyu ZIP olarak indir — git GEREKMEZ
if (-not (Test-Path (Join-Path $PWD "plugins"))) {
  $t   = Join-Path $env:TEMP "2xDom-plugins-main"
  $zip = Join-Path $env:TEMP "2xDom-plugins.zip"
  if (Test-Path $t)   { Remove-Item $t -Recurse -Force }
  if (Test-Path $zip) { Remove-Item $zip -Force }
  Write-Host "  repo indiriliyor (zip)..."
  Invoke-WebRequest -Uri "$Repo/archive/refs/heads/main.zip" -OutFile $zip
  Expand-Archive -Path $zip -DestinationPath $env:TEMP
  Set-Location $t
}

# [1/3] codebase-memory MCP
Write-Host "[1/3] codebase-memory-mcp (MCP server)" -ForegroundColor Cyan
if (Get-Command codebase-memory-mcp -ErrorAction SilentlyContinue) {
  Write-Host "  mevcut, atlandi"
} else {
  $installerExit = 1
  try {
    $u  = "https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.ps1"
    $tf = Join-Path $env:TEMP "cbm-install.ps1"
    Invoke-WebRequest -Uri $u -OutFile $tf -ErrorAction Stop
    & powershell -NoProfile -ExecutionPolicy Bypass -File $tf
    $installerExit = $LASTEXITCODE
  } catch {
    Write-Host "  ! indirme hatasi: $($_.Exception.Message)" -ForegroundColor Yellow
  }
  if ($installerExit -eq 0) {
    Write-Host "  kuruldu (kayit: ~/.claude.json)"
  } else {
    Write-Host "  ! kurucu basarisiz (exit $installerExit) - MCP atlaniyor, plugin'ler kurulmaya devam ediyor" -ForegroundColor Yellow
    Write-Host "    Manuel kurulum: https://github.com/DeusData/codebase-memory-mcp"
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
  foreach ($p in $Plugins) { claude plugin install "$p@2xDom-plugins" }
}

Write-Host "Tamam. Claude Desktop'i yeniden baslat ya da Code bolumunde /reload-plugins calistir." -ForegroundColor Green
Write-Host "Dogrulama: /plugin (4 plugin) ve /mcp (codebase-memory-mcp, 15 tool)."
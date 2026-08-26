# 2xDom-plugins - DIFF & RESTORE (Windows / PowerShell)
# Repo ile Claude Desktop arasindaki farki bulur, eksik olanlari repodan ceker,
# repo ile ayni olana kadar devam eder. Idempotent - tekrar calistirmak guvenli.
#
# Yeni makinede / gateway degisikliginden sonra:
#   irm https://raw.githubusercontent.com/emrullahxyz/2xDom-plugins/main/sync.ps1 | iex
#
$ErrorActionPreference = "Continue"
$Repo        = "https://github.com/emrullahxyz/2xDom-plugins"
$Marketplace = ".claude-plugin/marketplace.json"
$SkillsDir   = if ($env:CLAUDE_SKILLS_DIR) { $env:CLAUDE_SKILLS_DIR } else { Join-Path $HOME ".claude\skills" }
$ClaudeJson  = Join-Path $HOME ".claude.json"
$McpName     = "codebase-memory-mcp"

# `claude` CLI PATH'te yoksa bilinen yerlere de bak (Claude Code default install)
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
  $candidates = @(
    (Join-Path $HOME ".local\bin\claude.cmd"),
    (Join-Path $HOME ".local\bin\claude.exe"),
    "C:\Program Files\nodejs\claude.cmd"
  )
  foreach ($c in $candidates) {
    if (Test-Path $c) {
      $env:Path = (Split-Path $c -Parent) + [IO.Path]::PathSeparator + $env:Path
      break
    }
  }
}

# repo root'ta degilsek (orn. irm | iex) repoyu ZIP olarak indir
if (-not (Test-Path (Join-Path $PWD "plugins"))) {
  $t   = Join-Path $env:TEMP "2xDom-plugins-main"
  $zip = Join-Path $env:TEMP "2xDom-plugins.zip"
  if (Test-Path $t)   { Remove-Item $t -Recurse -Force }
  if (Test-Path $zip) { Remove-Item $zip -Force }
  Write-Host "[bootstrap] repo indiriliyor (zip)..." -ForegroundColor Cyan
  Invoke-WebRequest -Uri "$Repo/archive/refs/heads/main.zip" -OutFile $zip
  Expand-Archive -Path $zip -DestinationPath $env:TEMP
  Set-Location $t
}

# Plugin listesini marketplace.json'dan oku (kaynak: tek gercek)
$catalog = Get-Content $Marketplace -Raw | ConvertFrom-Json
$Plugins = @($catalog.plugins | ForEach-Object {
  ($_.source -replace '^\./plugins/','')
})

Write-Host ""
Write-Host "=== 2xDom-plugins SYNC ===" -ForegroundColor Cyan
Write-Host "Repo:    $Repo"
Write-Host "Target:  $SkillsDir"
Write-Host "MCP:     $McpName (registered in $ClaudeJson)"
Write-Host ""

# ---------- PHASE 1: DIFF ----------
Write-Host "[1/3] DIFF" -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null
$pluginStates = @()
foreach ($p in $Plugins) {
  $pj = Join-Path $SkillsDir "$p\.claude-plugin\plugin.json"
  $present = Test-Path $pj
  $pluginStates += [pscustomobject]@{ Plugin=$p; Present=$present }
  $status = if ($present) { "OK " } else { "YOK" }
  Write-Host ("  {0,-22} {1}" -f $p, $status)
}

$mcpRegistered = $false
if (Test-Path $ClaudeJson) {
  try {
    $cj = Get-Content $ClaudeJson -Raw | ConvertFrom-Json
    if ($cj.PSObject.Properties.Name -contains 'mcpServers' -and
        $cj.mcpServers.PSObject.Properties.Name -contains $McpName) {
      $mcpRegistered = $true
    }
  } catch { }
}
$mcpStatus = if ($mcpRegistered) { "OK " } else { "YOK" }
Write-Host ("  {0,-22} {1}" -f "mcp:$McpName", $mcpStatus)

# ---------- PHASE 2: RECONCILE ----------
Write-Host ""
Write-Host "[2/3] RECONCILE" -ForegroundColor Cyan

$results = @()
foreach ($row in $pluginStates) {
  $p   = $row.Plugin
  $src = Join-Path $PWD "plugins\$p"
  $dst = Join-Path $SkillsDir $p
  if (-not (Test-Path $src)) {
    Write-Host ("  ! {0} - repoda yok, ATLANIYOR" -f $p) -ForegroundColor Yellow
    $results += [pscustomobject]@{ Plugin=$p; Action="ATLANAN" }
    continue
  }
  if ($row.Present) {
    Write-Host ("  = {0} - guncel" -f $p)
    $results += [pscustomobject]@{ Plugin=$p; Action="OK" }
    continue
  }
  if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
  Copy-Item -Recurse $src $dst
  Write-Host ("  + {0} - kopyalandi" -f $p) -ForegroundColor Green
  $results += [pscustomobject]@{ Plugin=$p; Action="KOPYALANDI" }
}

# MCP - eksikse installer dene (basarisiz olursa yalan soyleme)
if ($mcpRegistered) {
  Write-Host "  = mcp:$McpName - kayitli"
  $mcpResult = "OK"
} else {
  Write-Host "  + mcp:$McpName - installer deneniyor..." -ForegroundColor Cyan
  $installerExit = 1
  try {
    $u  = "https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.ps1"
    $tf = Join-Path $env:TEMP "cbm-install-sync.ps1"
    Invoke-WebRequest -Uri $u -OutFile $tf -ErrorAction Stop
    & powershell -NoProfile -ExecutionPolicy Bypass -File $tf
    $installerExit = $LASTEXITCODE
  } catch {
    Write-Host ("    ! indirme hatasi: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
  }
  if ($installerExit -eq 0) {
    Write-Host "  + mcp:$McpName - kuruldu" -ForegroundColor Green
    $mcpResult = "KURULDU"
  } else {
    Write-Host "  ! mcp:$McpName - installer exit $installerExit. Bu makinede kurulamadi." -ForegroundColor Yellow
    Write-Host "    Temiz bir makinede: irm $Repo/raw/main/setup.ps1 | iex" -ForegroundColor Yellow
    $mcpResult = "BASARISIZ"
  }
}

# ---------- PHASE 3: VERIFY ----------
Write-Host ""
Write-Host "[3/3] VERIFY" -ForegroundColor Cyan
$ok = 0; $fail = 0
foreach ($r in $results) {
  $tag = if ($r.Action -eq "OK" -or $r.Action -eq "KOPYALANDI") { "OK " } else { "?  " }
  if ($tag -eq "OK ") { $ok++ } else { $fail++ }
  Write-Host ("  [{0}] {1,-22} {2}" -f $tag, $r.Plugin, $r.Action)
}
$mcpTag = if ($mcpResult -eq "OK" -or $mcpResult -eq "KURULDU") { "OK " } else { "?  " }
Write-Host ("  [{0}] {1,-22} {2}" -f $mcpTag, "mcp:$McpName", $mcpResult)

Write-Host ""
Write-Host ("Toplam: {0} OK, {1} sorun" -f $ok, $fail) -ForegroundColor $(if ($fail -eq 0) {"Green"} else {"Yellow"})

# ---------- PHASE 4: MARKETPLACE (Claude plugin CLI) ----------
# ~/.claude/skills/ Claude Code'un auto-load'unu tetikler, ama /plugin menusu
# marketplace tarafini gosterir. Iki tarafin da esit olmasi icin burada
# `claude plugin marketplace add` + `claude plugin install` calistiriyoruz.
# Idempotent: zaten kurulular "already installed" der.
if ($env:EMRULLAH_SKIP_MARKETPLACE -eq "1") {
  Write-Host ""
  Write-Host "(marketplace atladi: EMRULLAH_SKIP_MARKETPLACE=1)"
} elseif (Get-Command claude -ErrorAction SilentlyContinue) {
  Write-Host ""
  Write-Host "[4/4] MARKETPLACE (claude plugin CLI)" -ForegroundColor Cyan
  Write-Host ("  + marketplace ekleniyor: {0}" -f $Repo)
  & claude plugin marketplace add $Repo *> $null
  if ($LASTEXITCODE -eq 0) { Write-Host "  = marketplace OK" } else { Write-Host "  ! marketplace eklenemedi (devam ediliyor)" -ForegroundColor Yellow }
  foreach ($p in $Plugins) {
    $out = & claude plugin install "$p@2xDom-plugins" 2>&1
    $line = ($out | Select-Object -Last 1)
    if ($line -match "Successfully installed|already installed") {
      Write-Host ("  = {0} - kurulu (zaten veya yeni)" -f $p)
    } else {
      Write-Host ("  ! {0} - basarisiz: {1}" -f $p, $line) -ForegroundColor Yellow
    }
  }
} else {
  Write-Host ""
  Write-Host "(marketplace atladi: 'claude' CLI bulunamadi)"
}

Write-Host ""
Write-Host "Claude Desktop'i yeniden baslat veya Code bolumunde /reload-plugins calistir." -ForegroundColor Green
Write-Host "Dogrulama: /plugin (7 plugin) ve /mcp ($McpName)."
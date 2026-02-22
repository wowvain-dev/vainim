# ============================================================
# vainim — Windows Setup Script
# Creates a directory junction from %LOCALAPPDATA%\nvim
# pointing to this config directory.
#
# Run from PowerShell (no admin required for junctions):
#   powershell -ExecutionPolicy Bypass -File scripts/setup.ps1
# ============================================================

$ConfigSource = (Resolve-Path "$PSScriptRoot\..").Path
$NvimTarget   = Join-Path $env:LOCALAPPDATA "nvim"

Write-Host "vainim setup" -ForegroundColor Cyan
Write-Host "  Source : $ConfigSource" -ForegroundColor DarkCyan
Write-Host "  Target : $NvimTarget"   -ForegroundColor DarkCyan
Write-Host ""

# Check if target already exists
if (Test-Path $NvimTarget) {
    $existing = Get-Item $NvimTarget
    if ($existing.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        Write-Host "[OK] Junction already exists at $NvimTarget" -ForegroundColor Green
        $link = (Get-Item $NvimTarget).Target
        if ($link -eq $ConfigSource) {
            Write-Host "     → Already points to the correct location." -ForegroundColor Green
            exit 0
        } else {
            Write-Host "     → Points to: $link" -ForegroundColor Yellow
            $confirm = Read-Host "     Replace it? [y/N]"
            if ($confirm -notmatch '^[Yy]$') { exit 1 }
            Remove-Item $NvimTarget -Force
        }
    } else {
        Write-Host "[!] $NvimTarget exists but is NOT a junction." -ForegroundColor Red
        Write-Host "    Backup its contents first, then remove it and re-run."
        exit 1
    }
}

# Create the junction
New-Item -ItemType Junction -Path $NvimTarget -Target $ConfigSource | Out-Null

if (Test-Path $NvimTarget) {
    Write-Host "[OK] Junction created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Open Neovim: nvim"
    Write-Host "  2. lazy.nvim will auto-install on first launch"
    Write-Host "  3. Mason will install LSP servers automatically"
    Write-Host "  4. Restart nvim after initial install"
    Write-Host ""
    Write-Host "Quick config locations:" -ForegroundColor Cyan
    Write-Host "  Theme    : lua/plugins/colorscheme.lua  (change ACTIVE_THEME)"
    Write-Host "  LSP      : lua/lsp/servers.lua          (add/remove languages)"
    Write-Host "  Keymaps  : lua/config/keymaps.lua"
    Write-Host "  Options  : lua/config/options.lua"
} else {
    Write-Host "[FAIL] Could not create junction." -ForegroundColor Red
    exit 1
}

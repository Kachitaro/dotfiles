# ==============================================================================
# 🚀 Windows Dotfiles & Dev Environment One-Command Installer
# Usage:
#   irm https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.ps1 | iex
# ==============================================================================

[CmdletBinding()]
param (
    [string]$DotfilesDir = "",
    [switch]$SkipFeatures,
    [switch]$ForceInstall
)

$localScript = Join-Path $PSScriptRoot "scripts\install.ps1"
if ($PSScriptRoot -and (Test-Path $localScript)) {
    & $localScript @PSBoundParameters
} else {
    $installCode = (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/kachitaro/dotfiles/main/scripts/install.ps1')
    Invoke-Expression $installCode
}

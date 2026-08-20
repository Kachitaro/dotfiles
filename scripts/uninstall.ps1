# ==============================================================================
# Dotfiles Uninstaller for Windows
# ==============================================================================

Write-Host "Bắt đầu gỡ cài đặt (Uninstall) Dotfiles..." -ForegroundColor Red

# 1. Xóa symlinks
Write-Host "Xóa các symlink cấu hình..." -ForegroundColor Cyan
$links = @(
    "$env:USERPROFILE\.wezterm.lua",
    "$env:USERPROFILE\.config\wezterm",
    "$env:LOCALAPPDATA\nvim",
    "$env:USERPROFILE\.config\starship",
    "$env:USERPROFILE\.config\powershell\functions.ps1",
    "$env:USERPROFILE\.config\scoop\config.json"
)

foreach ($link in $links) {
    if (Test-Path $link) {
        Remove-Item $link -Force -Recurse
        Write-Host "  Đã xóa: $link" -ForegroundColor Green
    }
}

# 2. Gỡ cấu hình khỏi PowerShell profile
Write-Host "Gỡ cấu hình khỏi PowerShell Profile..." -ForegroundColor Cyan
$profiles = @(
    "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1",
    "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
)

foreach ($pPath in $profiles) {
    if (Test-Path $pPath) {
        $content = Get-Content $pPath -Raw
        $content = $content -replace "(?ms)# Load dotfiles user profile.*?user_profile\.ps1`".*?`n", ""
        Set-Content -Path $pPath -Value $content -Force
        Write-Host "  Đã gỡ cấu hình khỏi: $pPath" -ForegroundColor Green
    }
}

Write-Host "`nHoàn tất gỡ cài đặt! Các file gốc/backup (.bak_*) của bạn vẫn được giữ nguyên." -ForegroundColor Green

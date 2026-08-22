$DotfilesDir = Split-Path -Path $PSScriptRoot -Parent
Write-Host "`n🔹 Đang phục hồi (eject) cấu hình về máy thực..." -ForegroundColor Cyan

$configApps = @{
    "wezterm"    = "$env:USERPROFILE\.config\wezterm"
    "nvim"       = "$env:LOCALAPPDATA\nvim"
    "starship"   = "$env:USERPROFILE\.config\starship"
    "atuin"      = "$env:USERPROFILE\.config\atuin"
    "carapace"   = "$env:USERPROFILE\.config\carapace"
    "powershell" = "$env:USERPROFILE\.config\powershell"
    "scoop"      = "$env:USERPROFILE\.config\scoop"
}

foreach ($app in $configApps.GetEnumerator()) {
    $dest = $app.Value
    $src = "$DotfilesDir\$($app.Key)"
    if (Test-Path $dest) {
        $item = Get-Item $dest -Force
        if ($item.LinkType -eq "SymbolicLink") {
            Remove-Item $dest -Force
            Copy-Item -Path $src -Destination $dest -Recurse -Force
            Write-Host "  ✅ Đã phục hồi: $($app.Key) -> $dest" -ForegroundColor Green
        }
    }
}

# ~/.config/nvim nếu là symlink
if (Test-Path "$env:USERPROFILE\.config\nvim") {
    $item = Get-Item "$env:USERPROFILE\.config\nvim" -Force
    if ($item.LinkType -eq "SymbolicLink") {
        Remove-Item "$env:USERPROFILE\.config\nvim" -Force
        Copy-Item -Path "$DotfilesDir\nvim" -Destination "$env:USERPROFILE\.config\nvim" -Recurse -Force
        Write-Host "  ✅ Đã phục hồi: nvim -> $env:USERPROFILE\.config\nvim" -ForegroundColor Green
    }
}

# Riêng WezTerm file lua
if (Test-Path "$env:USERPROFILE\.wezterm.lua") {
    $wzItem = Get-Item "$env:USERPROFILE\.wezterm.lua"
    if ($wzItem.LinkType -eq "SymbolicLink") {
        Remove-Item "$env:USERPROFILE\.wezterm.lua" -Force
        Copy-Item -Path "$DotfilesDir\wezterm\wezterm.lua" -Destination "$env:USERPROFILE\.wezterm.lua" -Force
        Write-Host "  ✅ Đã phục hồi: wezterm.lua -> $env:USERPROFILE\.wezterm.lua" -ForegroundColor Green
    }
}

# Gỡ cấu hình khỏi PowerShell profile
Write-Host "`n🔹 Gỡ cấu hình khỏi PowerShell Profile..." -ForegroundColor Cyan
$myDocs = [Environment]::GetFolderPath('MyDocuments')
$profiles = @(
    "$myDocs\PowerShell\Microsoft.PowerShell_profile.ps1",
    "$myDocs\PowerShell\profile.ps1",
    "$myDocs\WindowsPowerShell\Microsoft.PowerShell_profile.ps1",
    "$myDocs\WindowsPowerShell\profile.ps1",
    "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1",
    "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
)
if ($PROFILE) {
    if ($PROFILE.CurrentUserCurrentHost) { $profiles += $PROFILE.CurrentUserCurrentHost }
    if ($PROFILE.CurrentUserAllHosts) { $profiles += $PROFILE.CurrentUserAllHosts }
}
$profiles = $profiles | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique

foreach ($pPath in $profiles) {
    if (Test-Path $pPath) {
        $content = Get-Content $pPath -Raw
        $content = $content -replace "(?ms)# Load dotfiles user profile.*?user_profile\.ps1`".*?`n", ""
        $content = $content -replace "(?m)^\s*\.\s*[`"']?.*?[\\/]powershell[\\/]user_profile\.ps1[`"']?\s*`r?`n?", ""
        Set-Content -Path $pPath -Value $content -Force
        Write-Host "  ✅ Đã gỡ cấu hình khỏi: $pPath" -ForegroundColor Green
    }
}

Write-Host "`n🎉 Quá trình EJECT hoàn tất! Máy bạn đã độc lập." -ForegroundColor Green
Write-Host "Giờ bạn có thể xóa an toàn thư mục: $DotfilesDir" -ForegroundColor Yellow

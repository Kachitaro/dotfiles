$DotfilesDir = Split-Path -Path $PSScriptRoot -Parent
Write-Host "`n🔹 Đang phục hồi (eject) cấu hình về máy thực..." -ForegroundColor Cyan

$configApps = @{
    "wezterm" = "$env:USERPROFILE\.config\wezterm"
    "nvim" = "$env:LOCALAPPDATA\nvim"
    "alacritty" = "$env:APPDATA\alacritty"
    "starship" = "$env:USERPROFILE\.config\starship"
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

# Riêng WezTerm file lua
if (Test-Path "$env:USERPROFILE\.wezterm.lua") {
    $wzItem = Get-Item "$env:USERPROFILE\.wezterm.lua"
    if ($wzItem.LinkType -eq "SymbolicLink") {
        Remove-Item "$env:USERPROFILE\.wezterm.lua" -Force
        Copy-Item -Path "$DotfilesDir\wezterm\wezterm.lua" -Destination "$env:USERPROFILE\.wezterm.lua" -Force
        Write-Host "  ✅ Đã phục hồi: wezterm.lua -> $env:USERPROFILE\.wezterm.lua" -ForegroundColor Green
    }
}

Write-Host "`n🎉 Quá trình EJECT hoàn tất! Máy bạn đã độc lập." -ForegroundColor Green
Write-Host "Giờ bạn có thể xóa an toàn thư mục: $DotfilesDir" -ForegroundColor Yellow

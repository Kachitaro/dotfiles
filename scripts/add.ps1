param([string]$TargetPath)

if ([string]::IsNullOrWhiteSpace($TargetPath)) {
    Write-Host "❌ Vui lòng cung cấp đường dẫn cần thu nạp!" -ForegroundColor Red
    Write-Host "Ví dụ: dot add `$env:APPDATA\alacritty" -ForegroundColor Cyan
    exit
}

if (!(Test-Path $TargetPath)) {
    Write-Host "❌ Đường dẫn không tồn tại: $TargetPath" -ForegroundColor Red
    exit
}

$resolvedPath = (Resolve-Path $TargetPath).Path
$item = Get-Item $resolvedPath -Force

if ($item.LinkType -eq "SymbolicLink") {
    Write-Host "❌ Đường dẫn này đã là symlink (đã được quản lý rồi)!" -ForegroundColor Red
    exit
}

$DotfilesDir = Split-Path -Path $PSScriptRoot -Parent
$basename = Split-Path $resolvedPath -Leaf

Write-Host "`n🔹 Đang thu nạp '$basename' vào kho dotfiles..." -ForegroundColor Cyan

Move-Item -Path $resolvedPath -Destination "$DotfilesDir\$basename" -Force

try {
    New-Item -ItemType SymbolicLink -Path $resolvedPath -Target "$DotfilesDir\$basename" -Force | Out-Null
    Write-Host "  ✅ Thu nạp thành công!" -ForegroundColor Green
    Write-Host "`n⚠️  LƯU Ý QUAN TRỌNG:" -ForegroundColor Yellow
    Write-Host "Hãy nhớ mở scripts\install.ps1 và thêm `"$basename`" vào mảng `$configApps để nó được tự động cài đặt vào lần sau nhé!" -ForegroundColor Yellow
} catch {
    Write-Host "  ❌ Lỗi khi tạo lại Symlink. Vui lòng kiểm tra quyền Admin hoặc chế độ Developer Mode!" -ForegroundColor Red
    Write-Host "     Chi tiết lỗi: $($_.Exception.Message)" -ForegroundColor Red
}

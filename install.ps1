# ==============================================================================
# 🚀 Dotfiles One-Command Fast Installer (Windows)
# Usage:
#   irm https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.ps1 | iex
# Or with options:
#   & ([scriptblock]::Create((irm https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.ps1))) -Full
# ==============================================================================

[CmdletBinding()]
param (
    [string]$DotfilesDir = "",
    [switch]$Full,            # Cài đặt toàn bộ môi trường phần mềm (Scoop, Neovim, WezTerm, Font, Tool...) và clone repo
    [switch]$ForceInstall
)

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

function Write-Info { param([string]$msg) Write-Host "🔹 $msg" -ForegroundColor Cyan }
function Write-Succ { param([string]$msg) Write-Host "  ✅ $msg" -ForegroundColor Green }
function Write-Warn { param([string]$msg) Write-Host "  ⚠️ $msg" -ForegroundColor Yellow }
function Write-Err  { param([string]$msg) Write-Host "  ❌ $msg" -ForegroundColor Red }

Write-Host @"
====================================================================
  🚀 KACHITARO DOTFILES CLI BOOTSTRAPPER (Windows)
====================================================================
"@ -ForegroundColor Magenta

# 1. Chuẩn bị thư mục chứa CLI Binary trong PATH (~/.local/bin)
$binDir = "$env:USERPROFILE\.local\bin"
if (!(Test-Path $binDir)) {
    New-Item -ItemType Directory -Path $binDir -Force | Out-Null
}

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$binDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$binDir;$userPath", "User")
}
if ($env:Path -notlike "*$binDir*") {
    $env:Path = "$binDir;" + $env:Path
}

$dotExe = "$binDir\dot.exe"

# 2. Tải Pre-built Binary Release từ GitHub hoặc Build từ nguồn
Write-Info "Thiết lập Dotfiles CLI (dot.exe)..."
$releaseUrl = "https://github.com/kachitaro/dotfiles/releases/latest/download/dot-x86_64-pc-windows-msvc.zip"
$tempZip = "$env:TEMP\dot-release.zip"
$tempExtract = "$env:TEMP\dot-release-extract"

$installedFromRelease = $false
try {
    Write-Host "  Đang tải binary release từ GitHub..." -ForegroundColor Gray
    Invoke-WebRequest -Uri $releaseUrl -OutFile $tempZip -UseBasicParsing -TimeoutSec 30
    if (Test-Path $tempZip) {
        if (Test-Path $tempExtract) { Remove-Item $tempExtract -Recurse -Force }
        Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force
        $extractedExe = Get-ChildItem -Path $tempExtract -Filter "dot.exe" -Recurse | Select-Object -First 1
        if ($extractedExe) {
            Copy-Item -Path $extractedExe.FullName -Destination $dotExe -Force
            $installedFromRelease = $true
            Write-Succ "Đã tải và thiết lập binary 'dot.exe' tại $dotExe"
        }
        Remove-Item $tempZip -Force -ErrorAction SilentlyContinue
        Remove-Item $tempExtract -Recurse -Force -ErrorAction SilentlyContinue
    }
} catch {
    Write-Warn "Không thể tải release từ GitHub (có thể chưa có release hoặc offline): $($_.Exception.Message)"
}

if (!$installedFromRelease) {
    $localRelease = if ($PSScriptRoot) { "$PSScriptRoot\cli\target\release\dot.exe" } else { "" }
    if ($localRelease -and (Test-Path $localRelease)) {
        Copy-Item -Path $localRelease -Destination $dotExe -Force
        Write-Succ "Đã dùng binary có sẵn tại $dotExe"
    } elseif (Get-Command cargo -ErrorAction SilentlyContinue) {
        $manifest = if ($PSScriptRoot) { "$PSScriptRoot\cli\Cargo.toml" } else { "cli\Cargo.toml" }
        if (Test-Path $manifest) {
            Write-Info "Biên dịch CLI từ mã nguồn qua Cargo..."
            cargo build --release --manifest-path $manifest
            $built = (Split-Path $manifest -Parent) + "\target\release\dot.exe"
            if (Test-Path $built) {
                Copy-Item -Path $built -Destination $dotExe -Force
                Write-Succ "Đã biên dịch thành công 'dot.exe' vào $dotExe"
            }
        }
    } else {
        Write-Err "Không thể tải binary release và máy chưa cài đặt Rust/Cargo."
    }
}

# 3. Xử lý chế độ Cài đặt: Toàn diện (-Full) hay Chỉ cài CLI
if ($Full) {
    # Xác định thư mục Dotfiles khi clone
    if ([string]::IsNullOrWhiteSpace($DotfilesDir)) {
        if (Test-Path "$PSScriptRoot\wezterm\wezterm.lua") {
            $DotfilesDir = $PSScriptRoot
        } elseif (Test-Path "D:\work\dotfiles") {
            $DotfilesDir = "D:\work\dotfiles"
        } elseif (Test-Path "D:\work") {
            $DotfilesDir = "D:\work\dotfiles"
        } elseif (Test-Path "D:\") {
            $DotfilesDir = "D:\dotfiles"
        } else {
            $DotfilesDir = "$env:USERPROFILE\.dotfiles"
        }
    }

    [Environment]::SetEnvironmentVariable("DOTFILES_DIR", $DotfilesDir, "User")
    $env:DOTFILES_DIR = $DotfilesDir

    # Clone dotfiles repo
    if (!(Test-Path "$DotfilesDir\.git")) {
        Write-Info "Đang clone dotfiles repository về $DotfilesDir..."
        if (Get-Command git -ErrorAction SilentlyContinue) {
            $parentDir = Split-Path -Path $DotfilesDir -Parent
            if (!(Test-Path $parentDir)) { New-Item -ItemType Directory -Path $parentDir -Force | Out-Null }
            git clone https://github.com/kachitaro/dotfiles.git $DotfilesDir
            Write-Succ "Dotfiles đã sẵn sàng tại $DotfilesDir"
        } else {
            Write-Warn "Git chưa được cài đặt trên máy. Script cài đặt sẽ tiến hành cài đặt Git."
        }
    }

    Write-Info "Tiến hành cài đặt toàn bộ công cụ môi trường (Scoop, WezTerm, Neovim, Font, Node...)..."
    $installScript = "$DotfilesDir\scripts\install.ps1"
    if (Test-Path $installScript) {
        $extraArgs = @()
        if ($ForceInstall) { $extraArgs += "-ForceInstall" }
        & $installScript -DotfilesDir $DotfilesDir @extraArgs
    }
} else {
    # Nếu đang chạy bên trong một repo dotfiles có sẵn, tự động inject
    $currentRepo = if (Test-Path "$PSScriptRoot\wezterm\wezterm.lua") { $PSScriptRoot } elseif (Test-Path ".\wezterm\wezterm.lua") { (Get-Item .).FullName } else { "" }
    if ($currentRepo -and (Test-Path $dotExe)) {
        Write-Info "Đang đồng bộ kho dotfiles hiện tại ($currentRepo) qua 'dot inject'..."
        & $dotExe inject
    }

    Write-Host @"

====================================================================
  🎉 ĐÃ CÀI ĐẶT THÀNH CÔNG DOTFILES CLI ('dot')!
====================================================================
  📍 Vị trí binary: $dotExe
  
  🛠️ Bạn có thể sử dụng ngay 'dot' cho kho dotfile của riêng mình:
     - dot inject       : Đồng bộ / gắn symlink vào hệ thống
     - dot eject        : Gỡ symlink, khôi phục file thực
     - dot add <path>   : Thu nạp thêm config mới
     - dot theme reload : Biên dịch theme sang Lua, Shell, PS1
     - dot theme path   : Lấy đường dẫn theme động
     - dot --help       : Xem toàn bộ hướng dẫn
====================================================================
"@ -ForegroundColor Green
}

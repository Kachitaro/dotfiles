# ==============================================================================
# 🚀 Windows Dotfiles & Dev Environment Installer
# Usage:
#   # ⚡ Fast Install: Tải CLI dot và gắn cấu hình ngay
#   irm https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.ps1 | iex
#
#   # 🚀 Full Machine Setup: Cài đặt toàn bộ phần mềm, Scoop, Font, Node, Tools
#   & ([scriptblock]::Create((irm https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.ps1))) -Full
# ==============================================================================

[CmdletBinding()]
param (
    [string]$DotfilesDir = "",
    [switch]$Full,            # Cài đặt toàn bộ môi trường phần mềm (Scoop, Neovim, WezTerm, Font, Tool...)
    [switch]$SkipFeatures,    # Bỏ qua kích hoạt tính năng ảo hoá Windows (Hyper-V, WSL)
    [switch]$ForceInstall     # Ghi đè file/cấu hình mà không tạo backup .bak_*
)

$ErrorActionPreference = "Continue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

function Write-Step   { param ([string]$msg) Write-Host "`n🔹 [STEP] $msg" -ForegroundColor Cyan }
function Write-Succ   { param ([string]$msg) Write-Host "  ✅ $msg" -ForegroundColor Green }
function Write-Warn   { param ([string]$msg) Write-Host "  ⚠️ $msg" -ForegroundColor Yellow }
function Write-Err    { param ([string]$msg) Write-Host "  ❌ $msg" -ForegroundColor Red }
function Write-Header {
    Write-Host @"
====================================================================
  🚀 KACHITARO DOTFILES & DEV ENVIRONMENT INSTALLER
  Repository: https://github.com/kachitaro/dotfiles
====================================================================
"@ -ForegroundColor Magenta
}

Write-Header

# 1. Xác định thư mục Dotfiles
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

# 2. Chuẩn bị thư mục chứa CLI Binary trong PATH (~/.local/bin)
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

[Environment]::SetEnvironmentVariable("DOTFILES_DIR", $DotfilesDir, "User")
$env:DOTFILES_DIR = $DotfilesDir

$dotExe = "$binDir\dot.exe"

# 3. Tải Pre-built Binary Release từ GitHub hoặc Build từ nguồn
Write-Step "Thiết lập Dotfiles CLI (dot.exe)..."
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
    Write-Warn "Không thể tải release từ GitHub (offline hoặc chưa có release): $($_.Exception.Message)"
}

if (!$installedFromRelease) {
    $localRelease = if ($PSScriptRoot) { "$PSScriptRoot\cli\target\release\dot.exe" } else { "" }
    if ($localRelease -and (Test-Path $localRelease)) {
        Copy-Item -Path $localRelease -Destination $dotExe -Force
        Write-Succ "Đã dùng binary có sẵn tại $dotExe"
    } elseif (Get-Command cargo -ErrorAction SilentlyContinue) {
        $manifest = if ($PSScriptRoot) { "$PSScriptRoot\cli\Cargo.toml" } else { "cli\Cargo.toml" }
        if (Test-Path $manifest) {
            Write-Host "  Biên dịch CLI từ mã nguồn qua Cargo..." -ForegroundColor Gray
            cargo build --release --manifest-path $manifest
            $built = (Split-Path $manifest -Parent) + "\target\release\dot.exe"
            if (Test-Path $built) {
                Copy-Item -Path $built -Destination $dotExe -Force
                Write-Succ "Đã biên dịch thành công 'dot.exe' vào $dotExe"
            }
        }
    }
}

# 4. Nếu có cờ -Full: Cài đặt toàn bộ môi trường phần mềm
if ($Full) {
    Write-Step "Cấu hình PowerShell Execution Policy..."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Write-Succ "Execution Policy đã được đặt thành RemoteSigned."

    Write-Step "Kích hoạt Developer Mode (hỗ trợ Symlink)..."
    try {
        $devModeKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
        if (Test-Path $devModeKey) {
            $currentVal = (Get-ItemProperty -Path $devModeKey -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense
            if ($currentVal -ne 1) {
                Start-Process powershell -Verb RunAs -Wait -ArgumentList "-NoProfile -Command Set-ItemProperty -Path '$devModeKey' -Name 'AllowDevelopmentWithoutDevLicense' -Value 1 -Type DWord"
            }
        }
        Write-Succ "Developer Mode đã sẵn sàng."
    } catch {
        Write-Warn "Không thể tự động bật Developer Mode."
    }

    Write-Step "Kiểm tra và cài đặt Scoop Package Manager..."
    if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "  Đang tải và cài đặt Scoop..." -ForegroundColor Gray
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
        $env:Path = "$env:USERPROFILE\scoop\shims;$env:USERPROFILE\scoop\apps\scoop\current\bin;" + $env:Path
    }
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Succ "Scoop đã sẵn sàng."
        $buckets = @("main", "extras", "nerd-fonts", "nonportable")
        foreach ($bucket in $buckets) {
            scoop bucket add $bucket 2>$null
        }
        scoop update
    }

    Write-Step "Cài đặt các ứng dụng và công cụ qua Scoop..."
    $corePackages = @(
        "main/git", "main/7zip", "main/curl", "main/pwsh", "main/neovim",
        "main/ripgrep", "main/fd", "main/fzf", "main/bat", "main/eza",
        "main/lazygit", "main/starship", "main/carapace", "main/python",
        "main/fnm", "main/bun", "main/yarn", "vcredist-aio",
        "extras/wezterm", "nerd-fonts/JetBrainsMono-NF"
    )
    foreach ($pkg in $corePackages) {
        Write-Host "  Đang kiểm tra / cài đặt: $pkg ..." -ForegroundColor Gray
        scoop install $pkg
    }
    Write-Succ "Hoàn tất cài đặt các gói Scoop."

    Write-Step "Cài đặt các module PowerShell (PSReadLine, PSFzf)..."
    if (!(Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue)) {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser | Out-Null
    }
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted -ErrorAction SilentlyContinue
    $psModules = @("PSReadLine", "PSFzf")
    foreach ($mod in $psModules) {
        if (!(Get-Module -Name $mod -ListAvailable)) {
            Install-Module -Name $mod -Scope CurrentUser -Force -SkipPublisherCheck -AllowClobber
        }
    }
    Write-Succ "Modules PowerShell đã sẵn sàng."

    # Clone dotfiles repo nếu chưa có
    if (!(Test-Path "$DotfilesDir\.git")) {
        Write-Step "Đang clone dotfiles repository về $DotfilesDir..."
        if (Get-Command git -ErrorAction SilentlyContinue) {
            $parentDir = Split-Path -Path $DotfilesDir -Parent
            if (!(Test-Path $parentDir)) { New-Item -ItemType Directory -Path $parentDir -Force | Out-Null }
            git clone https://github.com/kachitaro/dotfiles.git $DotfilesDir
            Write-Succ "Dotfiles đã sẵn sàng tại $DotfilesDir"
        }
    }

    # Bật ảo hoá nếu cần
    if (!$SkipFeatures) {
        Write-Step "Kiểm tra tính năng ảo hoá Windows..."
        $features = @("VirtualMachinePlatform", "Microsoft-Windows-Subsystem-Linux", "HypervisorPlatform")
        foreach ($feat in $features) {
            Enable-WindowsOptionalFeature -Online -FeatureName $feat -All -NoRestart -ErrorAction SilentlyContinue | Out-Null
        }
        Write-Succ "Đã kích hoạt các tính năng ảo hoá (WSL/Hyper-V)."
    }
}

# 5. Đồng bộ liên kết cấu hình (Inject)
if (Test-Path $dotExe) {
    Write-Step "Đồng bộ liên kết cấu hình qua 'dot inject'..."
    $injectArgs = @("inject")
    if ($ForceInstall) { $injectArgs += "--force" }
    & $dotExe @injectArgs
}

Write-Host @"

====================================================================
  🎉 HOÀN TẤT THIẾT LẬP KACHITARO DOTFILES!
====================================================================
  👉 Lệnh 'dot' đã sẵn sàng trong PATH của bạn.
  👉 Bạn có thể dùng 'dot --help' để xem toàn bộ hướng dẫn.
====================================================================
"@ -ForegroundColor Green

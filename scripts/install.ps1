# ==============================================================================
# 🚀 Windows Dotfiles & Dev Environment One-Command Installer
# Usage:
#   irm https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.ps1 | iex
# Or locally:
#   .\install.ps1
# ==============================================================================

[CmdletBinding()]
param (
    [string]$DotfilesDir = "",
    [switch]$SkipFeatures,
    [switch]$ForceInstall
)

# ------------------------------------------------------------------------------
# 0. Setup Environment & Helpers
# ------------------------------------------------------------------------------
$ErrorActionPreference = "Continue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

function Write-Step   { param ([string]$msg) Write-Host "`n🔹 [STEP] $msg" -ForegroundColor Cyan }
function Write-Succ   { param ([string]$msg) Write-Host "  ✅ $msg" -ForegroundColor Green }
function Write-Warn   { param ([string]$msg) Write-Host "  ⚠️ $msg" -ForegroundColor Yellow }
function Write-Err    { param ([string]$msg) Write-Host "  ❌ $msg" -ForegroundColor Red }
function Write-Header {
    Clear-Host
    Write-Host @"
====================================================================
  🚀 WINDOWS DOTFILES & ENVIRONMENT AUTO-INSTALLER
  Repository: https://github.com/kachitaro/dotfiles
====================================================================
"@ -ForegroundColor Magenta
}

Write-Header

# 1. Set Execution Policy
Write-Step "Cấu hình PowerShell Execution Policy..."
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Write-Succ "Execution Policy đã được đặt thành RemoteSigned cho CurrentUser."

# 2. Determine Dotfiles Path
Write-Step "Xác định thư mục Dotfiles..."
$RepoUrl = "https://github.com/kachitaro/dotfiles.git"
if ([string]::IsNullOrWhiteSpace($DotfilesDir)) {
    if (Test-Path "$PSScriptRoot\..\wezterm\wezterm.lua") {
        $DotfilesDir = Split-Path -Path $PSScriptRoot -Parent
    } elseif (Test-Path "D:\work") {
        $DotfilesDir = "D:\work\dotfiles"
    } elseif (Test-Path "D:\") {
        $DotfilesDir = "D:\dotfiles"
    } else {
        $DotfilesDir = "$env:USERPROFILE\.dotfiles"
    }
}
Write-Host "  Thư mục Dotfiles đích: $DotfilesDir" -ForegroundColor White

# 3. Enable Developer Mode (Cho phép tạo SymbolicLink không cần quyền Admin)
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
    Write-Warn "Không thể tự động bật Developer Mode. Các Symlink có thể yêu cầu quyền Admin."
}

# 4. Install Scoop
Write-Step "Kiểm tra và cài đặt Scoop..."
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "  Đang tải và cài đặt Scoop..." -ForegroundColor Gray
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
    
    # Reload Path for Scoop in current session
    $env:Path = "$env:USERPROFILE\scoop\shims;$env:USERPROFILE\scoop\apps\scoop\current\bin;" + $env:Path
}
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Write-Succ "Scoop đã được cài đặt."
} else {
    Write-Err "Không tìm thấy Scoop sau khi cài đặt. Vui lòng kiểm tra lại kết nối mạng."
}

# 5. Configure Scoop Buckets
Write-Step "Cấu hình Scoop Buckets..."
$buckets = @("main", "extras", "nerd-fonts", "nonportable")
foreach ($bucket in $buckets) {
    scoop bucket add $bucket 2>$null
}
scoop update
Write-Succ "Đã cấu hình xong Scoop buckets."

# 6. Install Packages via Scoop
Write-Step "Cài đặt các ứng dụng và công cụ qua Scoop..."

# Danh sách CLI và Utilities cốt lõi bắt buộc
$corePackages = @(
    "main/git",
    "main/7zip",
    "main/curl",
    "main/pwsh",
    "main/neovim",
    "main/ripgrep",
    "main/fd",
    "main/fzf",
    "main/bat",
    "main/eza",
    "main/lazygit",
    "main/starship",
    "main/carapace",
    "main/python",
    "main/fnm",
    "main/bun",
    "main/yarn",
    "vcredist-aio",
    "extras/wezterm",
    "nerd-fonts/JetBrainsMono-NF"
)

foreach ($pkg in $corePackages) {
    $pkgName = $pkg.Split('/')[-1]
    Write-Host "  Đang kiểm tra / cài đặt: $pkg ..." -ForegroundColor Gray
    scoop install $pkg
}
Write-Succ "Hoàn tất cài đặt các gói Scoop."

# 7. Install PowerShell Modules
Write-Step "Cài đặt các module PowerShell (PSReadLine, PSFzf, Terminal-Icons)..."
if (!(Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue)) {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser | Out-Null
}
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted -ErrorAction SilentlyContinue

$psModules = @("PSReadLine", "PSFzf", "Terminal-Icons")
foreach ($mod in $psModules) {
    if (!(Get-Module -Name $mod -ListAvailable)) {
        Write-Host "  Đang cài module: $mod..." -ForegroundColor Gray
        Install-Module -Name $mod -Scope CurrentUser -Force -SkipPublisherCheck -AllowClobber
    } else {
        Write-Succ "Module $mod đã tồn tại."
    }
}

# 8. Clone or Update Dotfiles Repository
Write-Step "Đồng bộ Dotfiles từ GitHub..."
if (!(Test-Path "$DotfilesDir\.git")) {
    $parentDir = Split-Path -Path $DotfilesDir -Parent
    if (!(Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }
    Write-Host "  Cloning repository vào $DotfilesDir ..." -ForegroundColor Gray
    git clone $RepoUrl $DotfilesDir
} else {
    Write-Host "  Cập nhật repository tại $DotfilesDir ..." -ForegroundColor Gray
    git -C $DotfilesDir pull
}
Write-Succ "Dotfiles đã sẵn sàng tại $DotfilesDir."

# 9. Create Symlinks & Link Configurations
Write-Step "Liên kết các tệp cấu hình (Symlink & Profile)..."

function Create-SafeLink {
    param (
        [string]$LinkPath,
        [string]$TargetPath,
        [string]$Type = "File" # "File" or "Directory"
    )

    if (!(Test-Path $TargetPath)) {
        Write-Warn "Target không tồn tại: $TargetPath"
        return
    }

    $parentDir = Split-Path -Path $LinkPath -Parent
    if (!(Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    if (Test-Path $LinkPath) {
        $item = Get-Item $LinkPath -Force
        if ($item.LinkType -eq "SymbolicLink") {
            Remove-Item $LinkPath -Force
        } else {
            if ($ForceInstall) {
                Remove-Item $LinkPath -Recurse -Force
                Write-Warn "Đã xóa (ghi đè) file/thư mục hiện tại: $LinkPath"
            } else {
                $backupPath = "$LinkPath.bak_$(Get-Date -Format 'yyyyMMddHHmmss')"
                Write-Warn "Đã sao lưu file/thư mục hiện tại sang $backupPath"
                Rename-Item -Path $LinkPath -NewName (Split-Path $backupPath -Leaf) -Force
            }
        }
    }

    try {
        if ($Type -eq "Directory") {
            New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath -Force | Out-Null
        } else {
            New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath -Force | Out-Null
        }
        Write-Succ "Linked: $LinkPath -> $TargetPath"
    } catch {
        # Fallback to copy if symlink is restricted
        Write-Warn "Không thể tạo Symlink ($($_.Exception.Message)). Tiến hành copy file thay thế..."
        if ($Type -eq "Directory") {
            Copy-Item -Path $TargetPath -Destination $LinkPath -Recurse -Force
        } else {
            Copy-Item -Path $TargetPath -Destination $LinkPath -Force
        }
        Write-Succ "Copied: $LinkPath -> $TargetPath"
    }
}

# 9.1 Liên kết cấu hình tự động cho các ứng dụng chuẩn
$configApps = @{
    "wezterm"     = "$env:USERPROFILE\.config\wezterm"
    "nvim"        = "$env:LOCALAPPDATA\nvim"
    "starship"    = "$env:USERPROFILE\.config\starship"
    "atuin"       = "$env:USERPROFILE\.config\atuin"
    "carapace"    = "$env:USERPROFILE\.config\carapace"
}

foreach ($app in $configApps.GetEnumerator()) {
    $src = "$DotfilesDir\$($app.Key)"
    $dest = $app.Value
    if (Test-Path $src) {
        Create-SafeLink -LinkPath $dest -TargetPath $src -Type "Directory"
    }
}
# Riêng WezTerm trên Windows thường cần file lua ở thư mục gốc
if (Test-Path "$DotfilesDir\wezterm\wezterm.lua") {
    Create-SafeLink -LinkPath "$env:USERPROFILE\.wezterm.lua" -TargetPath "$DotfilesDir\wezterm\wezterm.lua" -Type "File"
}

# 9.3 Functions file
Create-SafeLink -LinkPath "$env:USERPROFILE\.config\powershell\functions.ps1" -TargetPath "$DotfilesDir\powershell\functions.ps1"

# 9.4 Scoop Config
if (Test-Path "$DotfilesDir\scoop\config.json") {
    Create-SafeLink -LinkPath "$env:USERPROFILE\.config\scoop\config.json" -TargetPath "$DotfilesDir\scoop\config.json"
}

# 9.5 PowerShell Profile Configuration (Hỗ trợ cả pwsh và Windows PowerShell 5.1)
$profiles = @(
    "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1",
    "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
)

$profileSourceLine = ". `"$DotfilesDir\powershell\user_profile.ps1`""

foreach ($pPath in $profiles) {
    $pDir = Split-Path -Path $pPath -Parent
    if (!(Test-Path $pDir)) {
        New-Item -ItemType Directory -Path $pDir -Force | Out-Null
    }

    $needsWrite = $true
    if (Test-Path $pPath) {
        $content = Get-Content $pPath -Raw -ErrorAction SilentlyContinue
        if ($content -and $content.Contains("user_profile.ps1")) {
            $needsWrite = $false
        }
    }

    if ($needsWrite) {
        Add-Content -Path $pPath -Value "`n# Load dotfiles user profile`n$profileSourceLine`n" -Force
        Write-Succ "Đã cấu hình nạp dotfiles vào: $pPath"
    } else {
        Write-Succ "Profile $pPath đã được cấu hình trước đó."
    }
}

# 9.6 Cấu hình biến môi trường & PATH cho Dotfiles CLI (dot)
[Environment]::SetEnvironmentVariable("DOTFILES_DIR", $DotfilesDir, "User")
$env:DOTFILES_DIR = $DotfilesDir

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
$dotBinDir = "$DotfilesDir\bin"
if ($userPath -notlike "*$dotBinDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$dotBinDir;$userPath", "User")
}
if ($env:Path -notlike "*$dotBinDir*") {
    $env:Path = "$dotBinDir;" + $env:Path
}

# Nạp trực tiếp profile vào phiên làm việc hiện tại để lệnh 'dot' dùng được ngay
if (Test-Path "$DotfilesDir\powershell\user_profile.ps1") {
    . "$DotfilesDir\powershell\user_profile.ps1"
    Write-Succ "Đã nạp dot CLI và cấu hình môi trường vào phiên hiện tại."
}

# 10. Node.js & React Native Setup (qua FNM)
Write-Step "Cấu hình Node.js LTS (FNM)..."
try {
    if (Get-Command fnm -ErrorAction SilentlyContinue) {
        fnm install 22
        fnm default 22
        
        # Load FNM in current session to use npm
        fnm env --use-on-cd | Out-String | Invoke-Expression
        
        if (Get-Command npm -ErrorAction SilentlyContinue) {
            Write-Host "  Cài đặt React Native CLI global..." -ForegroundColor Gray
            npm install -g react-native-cli react-native-windows-init --silent
        }
        Write-Succ "Node.js LTS (qua FNM) và NPM packages đã được thiết lập."
    }
} catch {
    Write-Warn "Không thể hoàn thành cấu hình Node qua FNM: $($_.Exception.Message)"
}

# 11. Virtualization & Windows Optional Features (WSL2 / Hyper-V)
if (-not $SkipFeatures) {
    Write-Step "Kích hoạt các tính năng ảo hóa hệ thống (WSL2, Hyper-V, Containers)..."
    try {
        Start-Process powershell -Verb RunAs -Wait -ArgumentList @"
            -NoProfile -Command "
            Write-Host 'Enabling Virtualization Features...' -ForegroundColor Cyan;
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart;
            Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart;
            Enable-WindowsOptionalFeature -Online -FeatureName Containers -All -NoRestart;
            if (!(Get-Command wsl -ErrorAction SilentlyContinue)) {
                wsl --install --no-launch --web-download -d Ubuntu
            } else {
                wsl --update
            }
            "
"@
        Write-Succ "Các tính năng ảo hóa và WSL2 đã được kích hoạt."
    } catch {
        Write-Warn "Không thể tự động kích hoạt ảo hóa: $($_.Exception.Message)"
    }
}

# ------------------------------------------------------------------------------
# Hoàn tất
# ------------------------------------------------------------------------------
Write-Host @"

====================================================================
  🎉 CHÚC MỪNG! BỘ DOTFILES ĐÃ ĐƯỢC THIẾT LẬP THÀNH CÔNG!
====================================================================
  👉 Vui lòng KHỞI ĐỘNG LẠI MÁY TÍNH (Restart) để:
     1. Hoàn tất kích hoạt Hyper-V, WSL2, Docker.
     2. Áp dụng đầy đủ Font JetBrainsMono Nerd Font & biến môi trường.

  👉 Mở terminal mới bằng: WezTerm hoặc pwsh để trải nghiệm!
====================================================================
"@ -ForegroundColor Green

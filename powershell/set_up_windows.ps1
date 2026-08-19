# Set Execution Policy
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Helper functions
function Write-Start { param ([string]$msg) ; Write-Host ("====== " + $msg) -ForegroundColor Green }
function Write-Done { Write-Host "====== Done" -ForegroundColor Blue; Write-Host }

# 1. Disable UAC prompt (Tạm thời tắt để chạy script không bị gián đoạn)
Write-Start -msg "Temporarily disabling UAC prompt ..."
Start-Process -Wait powershell -Verb RunAs -ArgumentList `
    "Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0"
Write-Done

# 2. Install Scoop (Current User - KHÔNG DÙNG ADMIN Ở ĐÂY)
Write-Start -msg "Installing Scoop ..."
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    iwr -useb get.scoop.sh | iex
} else {
    Write-Warning "Scoop already installed"
}
Write-Done

# 3. Configure Scoop buckets (Current User)
Write-Start -msg "Configuring Scoop buckets ..."
scoop bucket add extras
scoop bucket add nerd-fonts
scoop bucket add java
scoop bucket add main
scoop bucket add nonportable
scoop update
Write-Done

# 4. Install all packages (Current User)
# Đã sửa lỗi thiếu dấu phẩy!
Write-Start -msg "Installing all Scoop packages ..."
$allPackages = @(
    "main/nvm",
    "main/yarn",
    "main/python",
    "main/pwsh",
    "java/temurin17-jdk",
    "extras/wezterm",
    "extras/vscode",
    "extras/flutter",
    "extras/android-studio",
    "extras/gradle",
    "nerd-fonts/JetBrainsMono", # Thêm dấu phẩy ở đây
    "vcredist-aio",
    "docker"
)
# Cài đặt dưới quyền User thường để phần mềm vào đúng thư mục C:\Users\<Tên_Bạn>\scoop
scoop install $allPackages
Write-Done

# 5. Set up NVM and install Node.js LTS
Write-Start -msg "Setting up NVM and installing Node.js LTS ..."
nvm install 22
nvm use 22
nvm alias default 22
Write-Done

# 6. Install React Native CLI (Global npm)
Write-Start -msg "Installing React Native CLI ..."
npm install -g react-native-cli react-native-windows-init
Write-Done

# 7. Install React Native Windows dependencies (Run as Admin)
Write-Start -msg "Installing React Native Windows dependencies ..."
Start-Process -Wait powershell -Verb RunAs -ArgumentList `
    "Set-ExecutionPolicy Unrestricted -Scope Process -Force; iex (New-Object System.Net.WebClient).DownloadString('https://aka.ms/rnw-vs2022-deps.ps1')"
Write-Done

# 8. Enable Virtualization & Docker requirements (Run as Admin)
Write-Start -msg "Enabling virtualization features for Docker ..."
Start-Process -Wait powershell -Verb RunAs -ArgumentList @"
    echo y | Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
    echo y | Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart
    echo y | Enable-WindowsOptionalFeature -Online -FeatureName Containers -All -NoRestart
"@
Write-Done

# 9. Installing WSL (Run as Admin)
Write-Start -msg "Installing WSL..."
Start-Process -Wait powershell -Verb RunAs -ArgumentList @"
    If (!(wsl -l -v)){
        wsl --install
        wsl --update
        wsl --install --no-launch --web-download -d Ubuntu
    }
"@
Write-Done

# 10. Restore UAC prompt (QUAN TRỌNG: Bật lại bảo mật cho máy tính)
Write-Start -msg "Restoring UAC prompt for system security ..."
Start-Process -Wait powershell -Verb RunAs -ArgumentList `
    "Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 5"
Write-Done

Write-Host "✅ Setup completed successfully." -ForegroundColor Green
Write-Host "⚠️ Please RESTART YOUR SYSTEM to finalize Docker, Android SDK, and virtualization features." -ForegroundColor Red
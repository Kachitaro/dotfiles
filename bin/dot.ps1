param (
    [Parameter(Position=0)]
    [string]$Command = "help",
    
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$RestArgs
)

$DotfilesDir = Split-Path -Path $PSScriptRoot -Parent

function Show-Help {
    Write-Host "Kachitaro Dotfiles CLI" -ForegroundColor Cyan
    Write-Host "Usage: dot <command> [options]`n"
    Write-Host "Commands:"
    Write-Host "  install          Run the installation script."
    Write-Host "                   Options: -ForceInstall, -SkipFeatures"
    Write-Host "  uninstall        Remove dotfiles symlinks and configurations."
    Write-Host "  add <path>       Adopt a new config folder into dotfiles."
    Write-Host "  eject            Restore real files to your system (unlink)."
    Write-Host "  theme reload     Recompile theme.json and apply dynamically."
    Write-Host "  update           Pull the latest changes from GitHub."
    Write-Host "  help             Show this help menu.`n"
}

switch ($Command) {
    "install" {
        $installScript = "$DotfilesDir\scripts\install.ps1"
        $installArgs = @()
        if ($RestArgs -contains "-ForceInstall" -or $RestArgs -contains "--force") {
            $installArgs += "-ForceInstall"
        }
        if ($RestArgs -contains "-SkipFeatures" -or $RestArgs -contains "--skip-features") {
            $installArgs += "-SkipFeatures"
        }
        & $installScript @installArgs
    }
    "uninstall" {
        & "$DotfilesDir\scripts\uninstall.ps1"
    }
    "add" {
        & "$DotfilesDir\scripts\add.ps1" -TargetPath $RestArgs[0]
    }
    "eject" {
        & "$DotfilesDir\scripts\eject.ps1"
    }
    "theme" {
        if ($RestArgs[0] -eq "reload") {
            Write-Host "Đang tải lại giao diện (Theme Engine)..." -ForegroundColor Cyan
            python "$DotfilesDir\scripts\generate_theme.py"
            Write-Host "Theme compiled! (WezTerm & Neovim reload automatically)" -ForegroundColor Green
            Write-Host "Note: Khởi động lại terminal để biến môi trường áp dụng cho prompt." -ForegroundColor Yellow
        } else {
            Write-Host "Lệnh không hợp lệ. Ý bạn là: dot theme reload?" -ForegroundColor Red
        }
    }
    "update" {
        Write-Host "Đang cập nhật Dotfiles từ GitHub..." -ForegroundColor Cyan
        git -C $DotfilesDir pull
    }
    default {
        Show-Help
    }
}

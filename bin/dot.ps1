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
    Write-Host "                   Options: -ForceInstall (Overwrite existing configs)"
    Write-Host "  uninstall        Remove dotfiles symlinks and configurations."
    Write-Host "  theme reload     Recompile theme.json and apply dynamically."
    Write-Host "  update           Pull the latest changes from GitHub."
    Write-Host "  help             Show this help menu.`n"
}

switch ($Command) {
    "install" {
        $installScript = "$DotfilesDir\install.ps1"
        if ($RestArgs -contains "-ForceInstall" -or $RestArgs -contains "--force") {
            & $installScript -ForceInstall
        } else {
            & $installScript
        }
    }
    "uninstall" {
        & "$DotfilesDir\uninstall.ps1"
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

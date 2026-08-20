# ==========================================
# FILE: functions.ps1
# ==========================================

# ------------------------------------------
# 1. LINUX ALIASES & UTILITIES
# ------------------------------------------
function grep {
    param ([string]$regex, [string]$dir)
    process {
        if ($dir) {
            Get-ChildItem -Path $dir -Recurse -File | Select-String -Pattern $regex
        } else {
            $input | Select-String -Pattern $regex
        }
    }
}

function which($name) {
    Get-Command $name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Definition
}

function touch {
    param (
        [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
        [string[]]$files
    )
    foreach ($file in $files) {
        if (Test-Path $file) {
            (Get-Item $file).LastWriteTime = Get-Date
        } else {
            New-Item -ItemType File -Path $file | Out-Null
        }
    }
}

function cd... { Set-Location ..\.. }
function cd.... { Set-Location ..\..\.. }
function ll { eza -l -g --icons }
function la { eza -a -l -g --icons }

# ------------------------------------------
# 2. SYSTEM SIZE UTILITIES
# ------------------------------------------

# Hàm tính dung lượng thư mục dùng chung
function Get-FolderSize($path) {
    if (Test-Path $path) {
        $size = (Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
        return [math]::Round($size / 1GB, 2)
    }
    return 0
}

# Lệnh kiểm tra dung lượng các ứng dụng đã cài đặt
function Get-AppSizeReport {
    $paths = @(
        "$env:ProgramFiles",
        "${env:ProgramFiles(x86)}",
        "$env:LOCALAPPDATA\Programs",
        "$env:LOCALAPPDATA\Microsoft",
        "$env:APPDATA",
        "$env:USERPROFILE\scoop\apps"
    )

    Write-Host "Đang quét dung lượng các ứng dụng, vui lòng chờ..." -ForegroundColor Cyan

    # Tối ưu hóa: Gán trực tiếp output của vòng lặp thay vì dùng +=
    $results = foreach ($basePath in $paths) {
        if (Test-Path $basePath) {
            Get-ChildItem -Path $basePath -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                $size = Get-FolderSize $_.FullName
                if ($size -gt 0) {
                    [PSCustomObject]@{
                        Application = $_.Name
                        Path        = $_.FullName
                        SizeGB      = $size
                    }
                }
            }
        }
    }

    $results | Sort-Object -Property SizeGB -Descending | Format-Table -AutoSize
}

# Lệnh kiểm tra tổng quan dung lượng hệ điều hành
function Get-SystemSizeReport {
    Write-Host "====== Checking Windows Size ======" -ForegroundColor Green
    Write-Host "Đang tính toán, vui lòng chờ..." -ForegroundColor Cyan

    $totalC = (Get-PSDrive C).Used / 1GB
    $windowsSize = Get-FolderSize "C:\Windows"
    $programFiles = Get-FolderSize "C:\Program Files"
    $programFilesX86 = Get-FolderSize "C:\Program Files (x86)"
    $users = Get-FolderSize "C:\Users"

    $winVer = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ProductName
    $baseline = if ($winVer -like "*Windows 11*") { 25 } else { 18 } 
    $extra = $totalC - $baseline

    Clear-Host
    Write-Host "====== Windows Size Report ======" -ForegroundColor Green
    Write-Host "Windows Version        : $winVer"
    Write-Host ("C: Used                : {0:N2} GB" -f $totalC)
    Write-Host ("C:\Windows             : {0:N2} GB" -f $windowsSize)
    Write-Host ("C:\Program Files       : {0:N2} GB" -f $programFiles)
    Write-Host ("C:\Program Files (x86) : {0:N2} GB" -f $programFilesX86)
    Write-Host ("C:\Users               : {0:N2} GB" -f $users)
    Write-Host ""
    Write-Host ("Baseline (clean install) : {0:N2} GB" -f $baseline)
    Write-Host ("Your system is using     : {0:N2} GB" -f $totalC)
    Write-Host ("Extra over baseline      : {0:N2} GB" -f $extra)
}


# ------------------------------------------------------------------------------
# Dotfiles CLI (dot)
# ------------------------------------------------------------------------------
function dot {
    # Dynamically find the dot.ps1 based on this file's location
    $DotfilesDir = Split-Path -Path (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent) -Parent
    & "$DotfilesDir\bin\dot.ps1" @args
}

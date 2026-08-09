# ==========================================
# FILE: functions.ps1
# ==========================================

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

function head {
    param ([string]$Path, [int]$n = 10)
    process {
        if ($Path) { Get-Content $Path -Head $n } else { $input | Select-Object -First $n }
    }
}

function tail {
    param ([string]$Path, [int]$n = 10)
    process {
        if ($Path) { Get-Content $Path -Tail $n } else { $input | Select-Object -Last $n }
    }
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

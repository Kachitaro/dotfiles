[console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$env:LESSCHARSET = 'utf-8'
$env:EZA_COLORS = "di=36" 
$usrBinPath = Join-Path $env:USERPROFILE "scoop\apps\git\current\usr\bin"
$tigPath = Join-Path $usrBinPath "tig.exe"
$lessPath = Join-Path $usrBinPath "less.exe"

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

if (Get-Command fnm -ErrorAction SilentlyContinue) {
    fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression
}

if (Get-Command carapace -ErrorAction SilentlyContinue) {
    $env:CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
    carapace _carapace powershell | Out-String | Invoke-Expression
}

Import-Module PSFzf -ErrorAction SilentlyContinue
Import-Module PSReadLine -ErrorAction SilentlyContinue

if (Get-Module -Name PSReadLine) {
    Set-PSReadLineOption -BellStyle None -ErrorAction SilentlyContinue
    Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
    Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue
}

if (Get-Module -Name PSFzf -ListAvailable) {
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'
}

Set-Alias g git -ErrorAction SilentlyContinue
Set-Alias vim nvim -ErrorAction SilentlyContinue
Set-Alias vi nvim -ErrorAction SilentlyContinue
Set-Alias ls eza -ErrorAction SilentlyContinue
Set-Alias cat bat -ErrorAction SilentlyContinue
    
if (Test-Path $tigPath) { Set-Alias tig $tigPath -ErrorAction SilentlyContinue }
if (Test-Path $lessPath) { Set-Alias less $lessPath -ErrorAction SilentlyContinue }

# Dynamic load functions.ps1
$funcPath = Join-Path $PSScriptRoot "functions.ps1"
if (-not (Test-Path $funcPath)) {
    $funcPath = Join-Path -Path $env:USERPROFILE -ChildPath ".config\powershell\functions.ps1"
}

if (Test-Path -Path $funcPath) {
    . $funcPath
} else {
    Write-Warning "Không tìm thấy file functions.ps1 tại: $funcPath"
}
# Set DOTFILES_DIR
if (-not $env:DOTFILES_DIR) {
    if ($PSScriptRoot) {
        $env:DOTFILES_DIR = Split-Path -Path $PSScriptRoot -Parent
    }
}
if ($env:DOTFILES_DIR -and (Test-Path "$env:DOTFILES_DIR\bin")) {
    if ($env:PATH -notlike "*$env:DOTFILES_DIR\bin*") {
        $env:PATH = "$env:DOTFILES_DIR\bin;" + $env:PATH
    }
}
$theme_candidates = @(
    (if ($env:DOTFILES_DIR) { Join-Path $env:DOTFILES_DIR "themes\generated\theme.ps1" }),
    "$env:USERPROFILE\.dotfiles\themes\generated\theme.ps1",
    "$env:USERPROFILE\Desktop\Work\dotfiles\themes\generated\theme.ps1"
)
foreach ($t_path in $theme_candidates) {
    if ($t_path -and (Test-Path $t_path)) {
        . $t_path
        break
    }
}

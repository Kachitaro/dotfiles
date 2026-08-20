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

Import-Module Terminal-Icons -ErrorAction SilentlyContinue
Import-Module PSFzf -ErrorAction SilentlyContinue
Import-Module PSReadLine -ErrorAction SilentlyContinue

if (Get-Module -Name PSReadLine) {
    Set-PSReadLineOption -EditMode Emacs -ErrorAction SilentlyContinue
    Set-PSReadLineOption -BellStyle None -ErrorAction SilentlyContinue
    Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
    Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue
    Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar -ErrorAction SilentlyContinue
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
# Load theme environment variables on startup
$theme_path = "$env:USERPROFILE\Desktop\Work\dotfiles\themes\generated\theme.ps1"
if (Test-Path $theme_path) {
    . $theme_path
}

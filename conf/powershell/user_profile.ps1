[console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$env:LESSCHARSET = 'utf-8'
$env:EZA_COLORS = "di=36" 
$usrBinPath = Join-Path $env:USERPROFILE "scoop\apps\git\current\usr\bin"
$tigPath = Join-Path $usrBinPath "tig.exe"
$lessPath = Join-Path $usrBinPath "less.exe"


oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/zash.omp.json" | Invoke-Expression
Import-Module Terminal-Icons -ErrorAction SilentlyContinue
Import-Module PSFzf -ErrorAction SilentlyContinue
Import-Module PSReadLine -ErrorAction SilentlyContinue

Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView 
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar

if (Get-Module -Name PSFzf -ListAvailable) {
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'
}
Set-Alias g git
Set-Alias vim nvim
Set-Alias vi nvim
Set-Alias ls eza
    
if (Test-Path $tigPath) { Set-Alias tig $tigPath }
if (Test-Path $lessPath) { Set-Alias less $lessPath }

$funcPath = Join-Path -Path $env:USERPROFILE -ChildPath ".config\powershell\functions.ps1"
if (Test-Path -Path $funcPath) {
    . $funcPath
} else {
    Write-Warning "Không tìm thấy file functions.ps1 tại: $funcPath"
}

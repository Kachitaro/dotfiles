# Auto-generated PowerShell init cache by 'dot inject' / 'dot theme reload'
# Do not edit manually - regenerate with 'dot inject' or 'dot theme reload'

using namespace System.Management.Automation
using namespace System.Management.Automation.Language

# --- starship init ---
Invoke-Expression (& 'C:\Users\JohnN\scoop\apps\starship\current\starship.exe' init powershell --print-full-init | Out-String)

# --- fnm init ---
$env:PATH = "C:\Users\JohnN\AppData\Local\fnm_multishells\17128_1787588845435;C:\Users\JohnN\AppData\Local\fnm_multishells\3196_1787588817524;C:\Users\JohnN\scoop\apps\pwsh\current;C:/Users/JohnN/.gemini/antigravity-cli/bin;C:\Users\JohnN\.local\bin;C:/Users/JohnN/.config/carapace/bin;C:\Users\JohnN\AppData\Local\fnm_multishells\14740_1787587141425;C:\Users\JohnN\scoop\apps\pwsh\current;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\WINDOWS\System32\OpenSSH\;C:\Program Files\dotnet\;C:\Users\JohnN\scoop\apps\flutter\current\bin;C:\Program Files (x86)\cloudflared\;;D:\work\dotfiles\bin;C:\Users\JohnN\scoop\apps\yarn\current\global\node_modules\.bin;C:\Users\JohnN\scoop\apps\yarn\current\bin;C:\Users\JohnN\scoop\apps\vscode\current\bin;C:\Users\JohnN\scoop\apps\starship\current;C:\Users\JohnN\scoop\apps\flutter\current\bin;C:\Users\JohnN\scoop\apps\gcc\current\bin;C:\Users\JohnN\AppData\Local\agy\bin;C:\Users\JohnN\scoop\apps\rustup\current\.cargo\bin;C:\Users\JohnN\scoop\apps\python\current\Scripts;C:\Users\JohnN\scoop\apps\python\current;C:\Users\JohnN\AppData\Local\Android\Sdk\emulator;C:\Users\JohnN\AppData\Local\Android\Sdk\platforms;C:\Users\JohnN\AppData\Local\Android\Sdk\platform-tools;C:\Users\JohnN\scoop\shims;C:\Users\JohnN\AppData\Local\Microsoft\WindowsApps;C:\Users\JohnN\.dotnet\tools;C:\msys64\mingw64\bin;C:\Users\JohnN\AppData\Local\Microsoft\WinGet\Links;C:\Program Files\Git\bin\bash.exe;C:\Program Files\Sublime Text\;C:\Users\JohnN\AppData\Local\agy\bin;C:\Users\JohnN\AppData\Local\Programs\Ollama"
$env:FNM_MULTISHELL_PATH = "C:\Users\JohnN\AppData\Local\fnm_multishells\17128_1787588845435"
$env:FNM_VERSION_FILE_STRATEGY = "local"
$env:FNM_DIR = "C:\Users\JohnN\scoop\apps\fnm\current"
$env:FNM_LOGLEVEL = "info"
$env:FNM_NODE_DIST_MIRROR = "https://nodejs.org/dist"
$env:FNM_COREPACK_ENABLED = "false"
$env:FNM_RESOLVE_ENGINES = "true"
$env:FNM_ARCH = "x64"
function global:Set-FnmOnLoad { If ((Test-Path .nvmrc) -Or (Test-Path .node-version) -Or (Test-Path package.json)) { & fnm use --silent-if-unchanged }
 }
function global:Set-LocationWithFnm { param($path); if ($path -eq $null) {Set-Location} else {Set-Location $path}; Set-FnmOnLoad }
Set-Alias -Scope global cd_with_fnm Set-LocationWithFnm
Set-Alias -Option AllScope -Scope global cd Set-LocationWithFnm


# --- carapace init ---

# [Environment]::SetEnvironmentVariable("PATH", "C:/Users/JohnN/.config/carapace/bin" + [IO.Path]::PathSeparator + [Environment]::GetEnvironmentVariable("PATH"))

Function get-env([string]$name) { Get-Item "env:$name" }
Function set-env([string]$name, [string]$value) { Set-Item "env:$name" "$value" }
Function unset-env([string]$name) { Remove-Item "env:$name" }

$_carapace_completer = {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", "", Scope="Function", Target="*")]
    param($wordToComplete, $commandAst, $cursorPosition)
    $commandElements = $commandAst.CommandElements

    # double quoted value works but seems single quoted needs some fixing (e.g. "example 'acti" -> "example acti")
    $elems = @()
    foreach ($_ in $commandElements) {
      if ($_.Extent.StartOffset -gt $cursorPosition) {
          break
      }
      $t = $_.Extent.Text
      if ($_.Extent.EndOffset -gt $cursorPosition) {
          $t = $t.Substring(0, $_.Extent.Text.get_Length() - ($_.Extent.EndOffset - $cursorPosition))
      }

      if ($t.Substring(0,1) -eq "'"){
        $t = $t.Substring(1)
      }
      if ($t.get_Length() -gt 0 -and $t.Substring($t.get_Length()-1) -eq "'"){
        $t = $t.Substring(0,$t.get_Length()-1)
      }
      if ($t.get_Length() -eq 0){
        $t = '""'
      }
      $elems += $t.replace('`,', ',') # quick fix
    }

    $completions = @(
      if (!$wordToComplete) {
        carapace ($elems[0] -replace ('\.exe$', '')) powershell $($elems| ForEach-Object {$_}) '' | ConvertFrom-Json | ForEach-Object { [CompletionResult]::new($_.CompletionText, $_.ListItemText.replace('`e[', "`e["), [CompletionResultType]::ParameterValue, $_.ToolTip.replace('`e[', "`e[")) }
      } else {
        carapace ($elems[0] -replace ('\.exe$', '')) powershell $($elems| ForEach-Object {$_}) | ConvertFrom-Json | ForEach-Object { [CompletionResult]::new($_.CompletionText, $_.ListItemText.replace('`e[', "`e["), [CompletionResultType]::ParameterValue, $_.ToolTip.replace('`e[', "`e[")) }
      }
    )

    if ($completions.count -eq 0) {
      return "" # prevent default file completion
    }

    $completions
}

Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'act','act.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'adb','adb.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'age','age.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'agg','agg.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ansible','ansible.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ansible-config','ansible-config.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ansible-console','ansible-console.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ansible-creator','ansible-creator.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ansible-doc','ansible-doc.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ansible-galaxy','ansible-galaxy.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ansible-inventory','ansible-inventory.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ansible-playbook','ansible-playbook.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ansible-pull','ansible-pull.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ansible-vault','ansible-vault.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ant','ant.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'apko','apko.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'apptainer','apptainer.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'apropos','apropos.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'aqua','aqua.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ar','ar.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'argo','argo.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'argocd','argocd.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'aria2c','aria2c.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'artisan','artisan.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'asciinema','asciinema.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'atuin','atuin.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'autoconf','autoconf.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'avdmanager','avdmanager.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'aws','aws.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'az','az.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'bat','bat.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'batdiff','batdiff.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'batgrep','batgrep.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'batman','batman.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'bazel','bazel.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'bc','bc.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'benthos','benthos.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'black','black.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'bloop','bloop.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'boundary','boundary.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'brew','brew.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'brotli','brotli.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'bru','bru.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'buildctl','buildctl.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'bun','bun.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'bunx','bunx.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'but','but.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'cal','cal.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'calibre','calibre.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'capslock','capslock.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'carapace','carapace.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'cargo','cargo.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'cargo-clippy','cargo-clippy.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'cargo-fmt','cargo-fmt.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'cargo-metadata','cargo-metadata.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'cargo-rm','cargo-rm.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'cargo-set-version','cargo-set-version.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'cargo-upgrade','cargo-upgrade.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'cargo-watch','cargo-watch.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'cdebug','cdebug.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'cekit','cekit.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'charm','charm.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'chdman','chdman.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'chezmoi','chezmoi.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'chroma','chroma.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'chromium','chromium.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'circleci','circleci.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'clamav-config','clamav-config.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'clamav-milter','clamav-milter.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'clambc','clambc.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'clamconf','clamconf.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'clamd','clamd.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'clamdscan','clamdscan.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'clamdtop','clamdtop.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'clamonacc','clamonacc.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'clamscan','clamscan.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'clamsubmit','clamsubmit.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'clion','clion.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'code','code.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'code-insiders','code-insiders.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'codecov','codecov.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'colima','colima.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'compare','compare.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'composite','composite.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'conda','conda.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'conda-content-trust','conda-content-trust.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'conda-env','conda-env.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'conky','conky.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'consul','consul.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'cosign','cosign.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'crc','crc.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'crush','crush.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'csview','csview.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'cue','cue.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'cura','cura.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'curl','curl.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'd2','d2.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'dagger','dagger.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'darktable','darktable.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'darktable-cli','darktable-cli.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'dart','dart.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'datagrip','datagrip.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'dataspell','dataspell.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'dbt','dbt.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'dc','dc.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'deadcode','deadcode.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'delta','delta.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'deno','deno.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'devbox','devbox.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'devcontainer','devcontainer.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'devpod','devpod.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'dfc','dfc.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'dict','dict.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'diff','diff.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'diff3','diff3.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'dig','dig.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'direnv','direnv.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'dive','dive.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'dlv','dlv.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'dms','dms.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'dngconverter','dngconverter.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'dnsmasq','dnsmasq.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'doas','doas.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'docker','docker.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'docker-buildx','docker-buildx.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'docker-compose','docker-compose.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'docker-scan','docker-scan.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'doctl','doctl.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'doing','doing.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'dos2unix','dos2unix.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ebook-convert','ebook-convert.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'egrep','egrep.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'electron','electron.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'elvish','elvish.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'exa','exa.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'exercism','exercism.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'eza','eza.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'faas-cli','faas-cli.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'fastfetch','fastfetch.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'fd','fd.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ffmpeg','ffmpeg.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ffplay','ffplay.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ffprobe','ffprobe.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'fgrep','fgrep.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'firefox','firefox.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'flutter','flutter.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'flyctl','flyctl.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'fnm','fnm.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'freeze','freeze.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ftp','ftp.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ftpd','ftpd.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'fury','fury.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'fzf','fzf.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gatsby','gatsby.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gcloud','gcloud.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gdb','gdb.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gdown','gdown.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gdu','gdu.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'get-env','get-env.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gh','gh.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gh-copilot','gh-copilot.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gh-dash','gh-dash.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gh-stack','gh-stack.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ghalint','ghalint.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ghostty','ghostty.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gimp','gimp.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'git','git.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'git-abort','git-abort.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'git-alias','git-alias.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'git-archive-file','git-archive-file.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'git-authors','git-authors.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'git-browse','git-browse.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'git-browse-ci','git-browse-ci.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'git-clang-format','git-clang-format.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'git-clear','git-clear.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'git-clear-soft','git-clear-soft.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'git-coauthor','git-coauthor.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'git-extras','git-extras.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'git-info','git-info.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'git-standup','git-standup.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'git-unlock','git-unlock.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'git-utimes','git-utimes.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gitk','gitk.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gitleaks','gitleaks.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gitlint','gitlint.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gitsign','gitsign.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gitui','gitui.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'glab','glab.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'glow','glow.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gm','gm.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'go','go.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'go-carpet','go-carpet.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'go-tool-asm','go-tool-asm.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'go-tool-buildid','go-tool-buildid.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'go-tool-cgo','go-tool-cgo.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'go-tool-compile','go-tool-compile.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'go-tool-covdata','go-tool-covdata.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'go-tool-cover','go-tool-cover.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'go-tool-dist','go-tool-dist.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'go-tool-doc','go-tool-doc.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'go-tool-fix','go-tool-fix.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'go-tool-link','go-tool-link.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'go-tool-mockgen','go-tool-mockgen.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'go-tool-nm','go-tool-nm.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'go-tool-objdump','go-tool-objdump.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'go-tool-pack','go-tool-pack.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gocyclo','gocyclo.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gofmt','gofmt.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'goimports','goimports.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'goland','goland.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'golangci-lint','golangci-lint.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gomplate','gomplate.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gonew','gonew.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'google-chrome','google-chrome.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gopls','gopls.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'goreleaser','goreleaser.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'goweight','goweight.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gpg','gpg.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gpg-agent','gpg-agent.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gradle','gradle.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'grep','grep.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'grype','grype.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gsa','gsa.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gulp','gulp.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gum','gum.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gunzip','gunzip.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'gzip','gzip.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'hatch','hatch.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'hcloud','hcloud.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'helix','helix.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'helm','helm.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'helmfile','helmfile.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'helmsman','helmsman.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'hexchat','hexchat.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'hexdump','hexdump.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'hostname','hostname.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'htop','htop.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'http','http.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'https','https.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'hugo','hugo.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'hurl','hurl.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'hx','hx.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'hyperfine','hyperfine.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'idea','idea.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'identify','identify.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'img2pdf','img2pdf.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'incus','incus.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'inkscape','inkscape.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'inshellisense','inshellisense.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'iredis','iredis.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'jar','jar.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'java','java.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'javac','javac.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'jj','jj.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'jq','jq.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'julia','julia.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'just','just.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'k3sup','k3sup.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'k6','k6.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'k9s','k9s.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'kak','kak.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'kak-lsp','kak-lsp.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'kcl','kcl.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'keytool','keytool.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'kitten','kitten.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'kitty','kitty.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'kmonad','kmonad.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'kompose','kompose.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'kotlin','kotlin.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'kotlinc','kotlinc.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ktlint','ktlint.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'kubeadm','kubeadm.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'kubebuilder','kubebuilder.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'kubectl','kubectl.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'kubeseal','kubeseal.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'kustomize','kustomize.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'lazygit','lazygit.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'lefthook','lefthook.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'lf','lf.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'limactl','limactl.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'litecli','litecli.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'lnav','lnav.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'lncrawl','lncrawl.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'lua','lua.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'lzma','lzma.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'magick','magick.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'make','make.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'man','man.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'marp','marp.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'maturin','maturin.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'mcomix','mcomix.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'mdbook','mdbook.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'meld','meld.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'melt','melt.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'micro','micro.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'minikube','minikube.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'mitmproxy','mitmproxy.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'mix','mix.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'mkcert','mkcert.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'mogrify','mogrify.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'molecule','molecule.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'montage','montage.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'more','more.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'mosh','mosh.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'mousepad','mousepad.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'mpv','mpv.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'mvn','mvn.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'mycli','mycli.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'n-m3u8dl-re','n-m3u8dl-re.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'nano','nano.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'nc','nc.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ncdu','ncdu.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'neomutt','neomutt.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'nerdctl','nerdctl.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'netcat','netcat.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'newman','newman.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'newrelic','newrelic.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'nfpm','nfpm.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ng','ng.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'nilaway','nilaway.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'nix','nix.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'nix-build','nix-build.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'nix-channel','nix-channel.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'nix-instantiate','nix-instantiate.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'nix-shell','nix-shell.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'node','node.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'nomad','nomad.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'nox','nox.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'npm','npm.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ntpd','ntpd.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'nu','nu.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'nvim','nvim.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'oh-my-posh','oh-my-posh.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ollama','ollama.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'op','op.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'openscad','openscad.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'openssl','openssl.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'optipng','optipng.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'orbctl','orbctl.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'packer','packer.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'palemoon','palemoon.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pandoc','pandoc.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pass','pass.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pathchk','pathchk.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'patool','patool.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pdfattach','pdfattach.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pdfdetach','pdfdetach.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pdffonts','pdffonts.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pdfimages','pdfimages.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pdfinfo','pdfinfo.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pdfseparate','pdfseparate.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pdfsig','pdfsig.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pdftocairo','pdftocairo.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pdftohtml','pdftohtml.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pdftoppm','pdftoppm.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pdftops','pdftops.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pdftotext','pdftotext.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pdfunite','pdfunite.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pgcli','pgcli.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'php','php.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'phpstorm','phpstorm.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'picard','picard.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pigz','pigz.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ping','ping.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pip','pip.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pipenv','pipenv.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pipx','pipx.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pixi','pixi.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pkgsite','pkgsite.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pngcheck','pngcheck.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pnpm','pnpm.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'podman','podman.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pprof','pprof.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'present','present.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'prettybat','prettybat.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'prettyping','prettyping.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'procs','procs.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pscale','pscale.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pulumi','pulumi.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pycharm','pycharm.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'pytest','pytest.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'python','python.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'qmk','qmk.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'qpdf','qpdf.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'qrencode','qrencode.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'qutebrowser','qutebrowser.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'rails','rails.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ramalama','ramalama.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ranger','ranger.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'rclone','rclone.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'redis-cli','redis-cli.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'restic','restic.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'resume-cli','resume-cli.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'reuse','reuse.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'rg','rg.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'rider','rider.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'rifle','rifle.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ripsecrets','ripsecrets.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'rsync','rsync.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'rubymine','rubymine.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'rust-analyzer','rust-analyzer.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'rustc','rustc.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'rustdoc','rustdoc.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'rustrover','rustrover.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'rustup','rustup.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'saw','saw.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'scc','scc.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'scp','scp.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'script','script.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'scriptlive','scriptlive.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'scriptreplay','scriptreplay.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'sd','sd.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'sdkmanager','sdkmanager.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'semver','semver.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'serie','serie.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'set-env','set-env.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'sftp','sftp.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'slides','slides.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'slsa-verifier','slsa-verifier.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'soft','soft.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'speedtest-cli','speedtest-cli.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'sqlite3','sqlite3.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ssh','ssh.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ssh-agent','ssh-agent.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ssh-copy-id','ssh-copy-id.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ssh-keygen','ssh-keygen.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'starship','starship.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'staticcheck','staticcheck.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'strings','strings.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'supervisorctl','supervisorctl.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'supervisord','supervisord.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'svg-term','svg-term.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'svgcleaner','svgcleaner.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'syft','syft.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'talosctl','talosctl.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'taplo','taplo.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'task','task.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'tea','tea.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'telnet','telnet.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'templ','templ.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'termux-apt-repo','termux-apt-repo.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'terraform','terraform.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'terraform-ls','terraform-ls.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'terragrunt','terragrunt.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'terramate','terramate.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'tesseract','tesseract.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'tig','tig.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'tinygo','tinygo.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'tldr','tldr.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'tmate','tmate.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'tofu','tofu.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'toit.lsp','toit.lsp.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'toit.pkg','toit.pkg.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'toolbox','toolbox.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'tor-browser','tor-browser.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'tor-gencert','tor-gencert.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'tor-print-ed-signing-cert','tor-print-ed-signing-cert.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'tor-resolve','tor-resolve.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'torsocks','torsocks.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'tox','tox.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'traefik','traefik.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'transmission-cli','transmission-cli.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'transmission-create','transmission-create.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'transmission-daemon','transmission-daemon.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'transmission-edit','transmission-edit.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'transmission-remote','transmission-remote.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'transmission-show','transmission-show.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'tree','tree.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'trivy','trivy.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ts','ts.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'tsc','tsc.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'tsh','tsh.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'tshark','tshark.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'turbo','turbo.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'typst','typst.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'unbrotli','unbrotli.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'unlzma','unlzma.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'unpigz','unpigz.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'unset-env','unset-env.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'unxz','unxz.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'unzip','unzip.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'upower','upower.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'upx','upx.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'vagrant','vagrant.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'vault','vault.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'vercel','vercel.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'vhs','vhs.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'vi','vi.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'vim','vim.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'viu','viu.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'vivid','vivid.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'vlc','vlc.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'volta','volta.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'vunnel','vunnel.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'watch','watch.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'watchexec','watchexec.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'watchgnupg','watchgnupg.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'waypoint','waypoint.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'webstorm','webstorm.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'wezterm','wezterm.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'wget','wget.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'winget','winget.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'wire','wire.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'wireshark','wireshark.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'wishlist','wishlist.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'wt','wt.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'xh','xh.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'xonsh','xonsh.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'xxhsum','xxhsum.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'xz','xz.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'xzcat','xzcat.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'yarn','yarn.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'yj','yj.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'ykman','ykman.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'youtube-dl','youtube-dl.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'yt-dlp','yt-dlp.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'zig','zig.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'zip','zip.exe'
Register-ArgumentCompleter -Native -ScriptBlock $_carapace_completer -CommandName 'zoxide','zoxide.exe'


# --- atuin init ---
# Atuin PowerShell module
#
# This should support PowerShell 5.1 (which is shipped with Windows) and later versions, on Windows and Linux.
#
# Usage: atuin init powershell | Out-String | Invoke-Expression
#
# Settings:
# - $env:ATUIN_POWERSHELL_PROMPT_OFFSET - Number of lines to offset the prompt position after exiting search.
#   This is useful when using a multi-line prompt: e.g. set this to -1 when using a 2-line prompt.
#   It is initialized from the current prompt line count if not set when the first Atuin search is performed.

if (Get-Module Atuin -ErrorAction Ignore) {
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        Write-Warning "The Atuin module is already loaded, replacing it."
        Remove-Module Atuin
    } else {
        Write-Warning "The Atuin module is already loaded, skipping."
        return
    }
}

if (!(Get-Command atuin -ErrorAction Ignore)) {
    Write-Error "The 'atuin' executable needs to be available in the PATH."
    return
}

if (!(Get-Module PSReadLine -ErrorAction Ignore)) {
    Write-Error "Atuin requires the PSReadLine module to be installed."
    return
}

New-Module -Name Atuin -ScriptBlock {
    if (-not $env:ATUIN_SESSION -or $env:ATUIN_PID -ne $PID) {
        $env:ATUIN_SESSION = atuin uuid
        $env:ATUIN_PID = $PID
    }

    $script:atuinHistoryId = $null
    $script:previousPSConsoleHostReadLine = $Function:PSConsoleHostReadLine

    # The ReadLine overloads changed with breaking changes over time, make sure the one we expect is available.
    $script:hasExpectedReadLineOverload = ([Microsoft.PowerShell.PSConsoleReadLine]::ReadLine).OverloadDefinitions.Contains("static string ReadLine(runspace runspace, System.Management.Automation.EngineIntrinsics engineIntrinsics, System.Threading.CancellationToken cancellationToken, System.Nullable[bool] lastRunStatus)")

    function Get-CommandLine {
        $commandLine = ""
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$commandLine, [ref]$null)
        return $commandLine
    }

    function Set-CommandLine {
        param([string]$Text)

        $commandLine = Get-CommandLine
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $commandLine.Length, $Text)
    }

    # This function name is called by PSReadLine to read the next command line to execute.
    # We replace it with a custom implementation which adds Atuin support.
    function PSConsoleHostReadLine {
        ## 1. Collect the exit code of the previous command.

        # This needs to be done as the first thing because any script run will flush $?.
        $lastRunStatus = $?

        # Exit statuses are maintained separately for native and PowerShell commands, this needs to be taken into account.
        $lastNativeExitCode = $global:LASTEXITCODE
        $exitCode = if ($lastRunStatus) { 0 } elseif ($lastNativeExitCode) { $lastNativeExitCode } else { 1 }

        ## 2. Report the status of the previous command to Atuin (atuin history end).

        if ($script:atuinHistoryId) {
            try {
                # The duration is not recorded in old PowerShell versions, let Atuin handle it. $null arguments are ignored.
                $duration = (Get-History -Count 1).Duration.Ticks * 100
                $durationArg = if ($duration) { "--duration=$duration" } else { $null }

                # Fire and forget the atuin history end command to avoid blocking the shell during a potential sync.
                $process = New-Object System.Diagnostics.Process
                $process.StartInfo.FileName = "atuin"
                $process.StartInfo.Arguments = "history end --hook --exit=$exitCode $durationArg -- $script:atuinHistoryId"
                $process.StartInfo.UseShellExecute = $false
                $process.StartInfo.CreateNoWindow = $true
                $process.StartInfo.RedirectStandardInput = $true
                $process.StartInfo.RedirectStandardOutput = $true
                $process.StartInfo.RedirectStandardError = $true
                $process.Start() | Out-Null
                $process.StandardInput.Close()
                $process.BeginOutputReadLine()
                $process.BeginErrorReadLine()
            }
            catch {
                # Ignore errors to avoid breaking the shell.
                # An error would occur if the user removes atuin from the PATH, for instance.
            }
            finally {
                $script:atuinHistoryId = $null
            }
        }

        ## 3. Read the next command line to execute.

        # PSConsoleHostReadLine implementation from PSReadLine, adjusted to support old versions.
        Microsoft.PowerShell.Core\Set-StrictMode -Off

        $line = if ($script:hasExpectedReadLineOverload) {
            # When the overload we expect is available, we can pass $lastRunStatus to it.
            [Microsoft.PowerShell.PSConsoleReadLine]::ReadLine($Host.Runspace, $ExecutionContext, [System.Threading.CancellationToken]::None, $lastRunStatus)
        } else {
            # Either PSReadLine is older than v2.2.0-beta3, or maybe newer than we expect, so use the function from PSReadLine as-is.
            & $script:previousPSConsoleHostReadLine
        }

        ## 4. Report the next command line to Atuin (atuin history start).

        # PowerShell doesn't handle double quotes in native command line arguments the same way depending on its version,
        # and the value of $PSNativeCommandArgumentPassing - see the about_Parsing help page which explains the breaking changes.
        # This makes it unreliable, so we go through an environment variable, which should always be consistent across versions.
        $prevCommandLine = $env:ATUIN_COMMAND_LINE
        $prevShell = $env:ATUIN_SHELL
        try {
            $env:ATUIN_COMMAND_LINE = $line
            $env:ATUIN_SHELL = "powershell"
            $script:atuinHistoryId = atuin history start --hook --command-from-env
        }
        catch {
            # Ignore errors to avoid breaking the shell, see above.
        }
        finally {
            $env:ATUIN_COMMAND_LINE = $prevCommandLine
            $env:ATUIN_SHELL = $prevShell
        }

        $global:LASTEXITCODE = $lastNativeExitCode
        return $line
    }

    function Invoke-AtuinSearch {
        param([string]$ExtraArgs = "")

        $previousOutputEncoding = [System.Console]::OutputEncoding
        $resultFile = New-TemporaryFile
        $suggestion = ""
        $errorOutput = ""

        try {
            [System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8

            # Start-Process does some crazy stuff, just use the Process class directly to have more control.
            $process = New-Object System.Diagnostics.Process
            $process.StartInfo.FileName = "atuin"
            $process.StartInfo.Arguments = "search -i --result-file ""$($resultFile.FullName)"" $ExtraArgs"
            $process.StartInfo.UseShellExecute = $false
            $process.StartInfo.RedirectStandardError = $true
            $process.StartInfo.StandardErrorEncoding = [System.Text.Encoding]::UTF8
            $process.StartInfo.EnvironmentVariables["ATUIN_SHELL"] = "powershell"
            $process.StartInfo.EnvironmentVariables["ATUIN_QUERY"] = Get-CommandLine
            # PowerShell's Set-Location (cd) doesn't update the process-level working directory, set it explicitly
            $process.StartInfo.WorkingDirectory = (Get-Location -PSProvider FileSystem).ProviderPath

            try {
                $process.Start() | Out-Null

                # A single stream is redirected, so we can read it synchronously, but we have to start reading it
                # before waiting for the process to exit, otherwise the buffer could fill up and cause a deadlock.
                $errorOutput = $process.StandardError.ReadToEnd().Trim()
                $process.WaitForExit()

                $suggestion = (Get-Content -LiteralPath $resultFile.FullName -Raw -Encoding UTF8 | Out-String).Trim()
            }
            catch {
                $errorOutput = $_
            }

            if ($errorOutput) {
                Write-Host -ForegroundColor Red "Atuin error:"
                Write-Host -ForegroundColor DarkRed $errorOutput
            }

            # If no shell prompt offset is set, initialize it from the current prompt line count.
            if ($null -eq $env:ATUIN_POWERSHELL_PROMPT_OFFSET) {
                try {
                    $promptLines = (& $Function:prompt | Out-String | Measure-Object -Line).Lines
                    $env:ATUIN_POWERSHELL_PROMPT_OFFSET = -1 * ($promptLines - 1)
                }
                catch {
                    $env:ATUIN_POWERSHELL_PROMPT_OFFSET = 0
                }
            }

            # PSReadLine maintains its own cursor position, which will no longer be valid if Atuin scrolls the display in inline mode.
            # Fortunately, InvokePrompt can receive a new Y position and reset the internal state.
            $y = $Host.UI.RawUI.CursorPosition.Y + [int]$env:ATUIN_POWERSHELL_PROMPT_OFFSET
            $y = [System.Math]::Max([System.Math]::Min($y, [System.Console]::BufferHeight - 1), 0)
            [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt($null, $y)

            if ($suggestion -eq "") {
                # The previous input was already rendered by InvokePrompt
                return
            }

            $acceptPrefix = "__atuin_accept__:"

            if ( $suggestion.StartsWith($acceptPrefix)) {
                Set-CommandLine $suggestion.Substring($acceptPrefix.Length)
                [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
            } else {
                Set-CommandLine $suggestion
            }
        }
        finally {
            [System.Console]::OutputEncoding = $previousOutputEncoding
            $resultFile.Delete()
        }
    }

    function Enable-AtuinSearchKeys {
        param([bool]$CtrlR = $true, [bool]$UpArrow = $true)

        if ($CtrlR) {
            Set-PSReadLineKeyHandler -Chord "Ctrl+r" -BriefDescription "Runs Atuin search" -ScriptBlock {
                Invoke-AtuinSearch
            }
        }

        if ($UpArrow) {
            Set-PSReadLineKeyHandler -Chord "UpArrow" -BriefDescription "Runs Atuin search" -ScriptBlock {
                $line = Get-CommandLine

                if (!$line.Contains("`n")) {
                    Invoke-AtuinSearch -ExtraArgs "--shell-up-key-binding"
                } else {
                    [Microsoft.PowerShell.PSConsoleReadLine]::PreviousLine()
                }
            }
        }
    }

    $ExecutionContext.SessionState.Module.OnRemove += {
        $env:ATUIN_SESSION = $null
        $Function:PSConsoleHostReadLine = $script:previousPSConsoleHostReadLine
    }

    Export-ModuleMember -Function @("Enable-AtuinSearchKeys", "PSConsoleHostReadLine")
} | Import-Module -Global
Enable-AtuinSearchKeys -CtrlR $true -UpArrow $false


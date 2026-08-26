# Auto-generated PowerShell init cache by 'dot inject' / 'dot theme reload'
# Do not edit manually - regenerate with 'dot inject' or 'dot theme reload'

# --- starship init ---
Invoke-Expression (& '/usr/local/bin/starship' init powershell --print-full-init | Out-String)

# --- fnm init ---
$env:PATH = "/run/user/1000/fnm_multishells/12519_1787724455278/bin:/home/john/.gemini/antigravity-cli/bin:/home/john/.local/share/fnm/node-versions/v22.23.2/installation/bin:/run/user/1000/fnm_multishells/6344_1787723629235/bin:/home/john/.local/share/fnm:/home/john/.bun/bin:/home/john/.local/bin:/home/john/.config/carapace/bin:/home/john/.atuin/bin:/home/john/.bun/bin:/home/john/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/snap/bin"
$env:FNM_MULTISHELL_PATH = "/run/user/1000/fnm_multishells/12519_1787724455278"
$env:FNM_VERSION_FILE_STRATEGY = "local"
$env:FNM_DIR = "/home/john/.local/share/fnm"
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
Set-FnmOnLoad


# --- zoxide init ---
# =============================================================================
#
# Utility functions for zoxide.
#

# Call zoxide binary, returning the output as UTF-8.
function global:__zoxide_bin {
    $encoding = [Console]::OutputEncoding
    try {
        [Console]::OutputEncoding = [System.Text.Utf8Encoding]::new()
        $result = zoxide @args
        return $result
    } finally {
        [Console]::OutputEncoding = $encoding
    }
}

# pwd based on zoxide's format.
function global:__zoxide_pwd {
    $cwd = Get-Location
    if ($cwd.Provider.Name -eq "FileSystem") {
        $cwd.ProviderPath
    }
}

# cd + custom logic based on the value of _ZO_ECHO.
function global:__zoxide_cd($dir, $literal) {
    $dir = if ($literal) {
        Set-Location -LiteralPath $dir -Passthru -ErrorAction Stop
    } else {
        if ($dir -eq '-' -and ($PSVersionTable.PSVersion -lt 6.1)) {
            Write-Error "cd - is not supported below PowerShell 6.1. Please upgrade your version of PowerShell."
        }
        elseif ($dir -eq '+' -and ($PSVersionTable.PSVersion -lt 6.2)) {
            Write-Error "cd + is not supported below PowerShell 6.2. Please upgrade your version of PowerShell."
        }
        else {
            Set-Location -Path $dir -Passthru -ErrorAction Stop
        }
    }
}

# =============================================================================
#
# Hook configuration for zoxide.
#

# Hook to add new entries to the database.
$global:__zoxide_oldpwd = __zoxide_pwd
function global:__zoxide_hook {
    $result = __zoxide_pwd
    if ($result -ne $global:__zoxide_oldpwd) {
        if ($null -ne $result) {
            zoxide add "--" $result
        }
        $global:__zoxide_oldpwd = $result
    }
}

# Initialize hook.
$global:__zoxide_hooked = (Get-Variable __zoxide_hooked -ErrorAction Ignore -ValueOnly)
if ($global:__zoxide_hooked -ne 1) {
    $global:__zoxide_hooked = 1
    $global:__zoxide_prompt_old = $function:prompt

    function global:prompt {
        if ($null -ne $__zoxide_prompt_old) {
            & $__zoxide_prompt_old
        }
        $null = __zoxide_hook
    }
}

# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#

# Jump to a directory using only keywords.
function global:__zoxide_z {
    if ($args.Length -eq 0) {
        __zoxide_cd ~ $true
    }
    elseif ($args.Length -eq 1 -and ($args[0] -eq '-' -or $args[0] -eq '+')) {
        __zoxide_cd $args[0] $false
    }
    elseif ($args.Length -eq 1 -and (Test-Path -PathType Container -LiteralPath $args[0])) {
        __zoxide_cd $args[0] $true
    }
    elseif ($args.Length -eq 1 -and (Test-Path -PathType Container -Path $args[0] )) {
        __zoxide_cd $args[0] $false
    }
    else {
        $result = __zoxide_pwd
        if ($null -ne $result) {
            $result = __zoxide_bin query --exclude $result "--" @args
        }
        else {
            $result = __zoxide_bin query "--" @args
        }
        if ($LASTEXITCODE -eq 0) {
            __zoxide_cd $result $true
        }
    }
}

# Jump to a directory using interactive search.
function global:__zoxide_zi {
    $result = __zoxide_bin query -i "--" @args
    if ($LASTEXITCODE -eq 0) {
        __zoxide_cd $result $true
    }
}

# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

Set-Alias -Name z -Value __zoxide_z -Option AllScope -Scope Global -Force
Set-Alias -Name zi -Value __zoxide_zi -Option AllScope -Scope Global -Force

# =============================================================================
#
# To initialize zoxide, add this to your configuration (find it by running
# `echo $profile` in PowerShell):
#
# Invoke-Expression (& { (zoxide init powershell | Out-String) })

# --- carapace init ---
# export PATH="/home/john/.config/carapace/bin:$PATH"

get-env () { echo "${(P)1}"; }
set-env () { export "$1=$2"; }
unset-env () { unset "$1"; }

function _carapace_completer {
  local command="$(basename $words[1])"
  local compline=${words[@]:0:$CURRENT}
  local IFS=$'\n'
  local lines

  declare -x CARAPACE_COMPLINE="${words}"
  declare -x CARAPACE_ZSH_HASH_DIRS="$(hash -d)"
  declare -x CARAPACE_SHELL=zsh
  declare -x CARAPACE_SHELL_ALIASES="${(k)aliases}"
  declare -x CARAPACE_SHELL_BUILTINS="$(print -roC1 -- ${(k)builtins})"
  declare -x CARAPACE_SHELL_FUNCTIONS="$(print -l ${(ok)functions})"
  declare -x CARAPACE_SHELL_JOBS="$(print -l ${${(k)jobtexts}/#/%%})"
  declare -x CARAPACE_SHELL_VARIABLES="$(print -l ${(ok)parameters})"

  # shellcheck disable=SC2086,SC2154,SC2155
  lines="$(echo "${compline}''" | xargs carapace "${command}" zsh 2>/dev/null)"
  if [ $? -eq 1 ]; then
    lines="$(echo "${compline}'" | xargs carapace "${command}" zsh 2>/dev/null)"
    if [ $? -eq 1 ]; then
      lines="$(echo "${compline}\"" | xargs carapace "${command}" zsh 2>/dev/null)"
    fi
  fi

  local zstyle message noprefix data
  IFS=$'\001' read -r -d '' zstyle message noprefix data <<<"${lines}"
  # shellcheck disable=SC2154
  zstyle ":completion:${curcontext}:*" list-colors "${zstyle}"
  zstyle ":completion:${curcontext}:*" group-name ''
  [ -z "$message" ] || _message -r "${message}"
  [[ "${noprefix}" = "true" ]] && compstate[insert]=menu

  local block tag displays values displaysArr valuesArr
  while IFS=$'\002' read -r -d $'\002' block; do
    IFS=$'\003' read -r -d '' tag displays values <<<"${block}"
    # shellcheck disable=SC2034
    IFS=$'\n' read -r -d $'\004' -A displaysArr <<<"${displays}"$'\004'
    IFS=$'\n' read -r -d $'\004' -A valuesArr <<<"${values}"$'\004'

    [[ ${#valuesArr[@]} -gt 1 ]] && _describe -t "${tag}" "${tag}" displaysArr valuesArr -Q -S ''
  done <<<"${data}"
}

compdef _carapace_completer "000_bash_completion_compat" "2to3" "5g" "5l" "6g" "6l" "7z" "7za" "7zr" "7zz" "7zzs" "8g" "8l" "Mosaic" "SuSEconfig" "a2dismod" "a2dissite" "a2enmod" "a2ensite" "a2ps" "a2x" "aaaa" "aap" "aapt" "abcde" "abook" "ack" "ack-grep" "ack-standalone" "ack2" "aclocal" "aclocal-1.10" "aclocal-1.11" "aclocal-1.12" "aclocal-1.13" "aclocal-1.14" "aclocal-1.15" "aclocal-1.16" "acpi" "acpid" "acpitool" "acroread" "act" "adb" "add-apt-repository" "add-zle-hook-widget" "add-zsh-hook" "add_members" "admin" "age" "agg" "ali" "alpine" "alsamixer" "alternatives" "amaya" "analyseplugin" "animate" "anno" "ansible" "ansible-config" "ansible-console" "ansible-creator" "ansible-doc" "ansible-galaxy" "ansible-inventory" "ansible-playbook" "ansible-pull" "ansible-vault" "ant" "antiword" "aodh" "aoss" "apache2ctl" "apachectl" "apk" "apko" "apksigner" "aplay" "apm" "appdata-validate" "appletviewer" "apport-bug" "apport-cli" "apport-collect" "apport-unpack" "appstreamcli" "apptainer" "apropos" "apt" "apt-add-repository" "apt-build" "apt-cache" "apt-cdrom" "apt-config" "apt-file" "apt-get" "apt-mark" "apt-move" "apt-show-versions" "aptitude" "aptitude-curses" "apvlv" "aqua" "ar" "arch" "archlinux-java" "arduino-ctags" "arecord" "arena" "argo" "argocd" "aria2c" "arm-koji" "arp" "arping" "arpspoof" "artisan" "asciidoc" "asciidoc.py" "asciidoctor" "asciinema" "ash" "aspell" "at" "atq" "atrm" "attr" "atuin" "augtool" "auto-apt" "autoconf" "autoheader" "automake" "automake-1.10" "automake-1.11" "automake-1.12" "automake-1.13" "automake-1.14" "automake-1.15" "automake-1.16" "autoreconf" "autorpm" "autoscan" "autossh" "autoupdate" "avahi-browse" "avahi-browse-domains" "avahi-resolve" "avahi-resolve-address" "avahi-resolve-host-name" "avctrl" "avdmanager" "awk" "aws" "axi-cache" "az" "b2sum" "badblocks" "baobab" "barbican" "base32" "base64" "basename" "basenc" "bash" "bash-language-server" "bat" "batcat" "batch" "batdiff" "batgrep" "batman" "bats" "baz" "bazel" "bc" "beadm" "beep" "benthos" "bibtex" "bison" "bk" "black" "blkdiscard" "blkid" "blockdev" "bloop" "bluetoothctl" "bmake" "bogofilter" "bogotune" "bogoutil" "boundary" "bpftool" "bpftrace" "bpython" "bpython-gtk" "bpython-urwid" "bpython2" "bpython2-gtk" "bpython2-urwid" "bpython3" "bpython3-gtk" "bpython3-urwid" "brctl" "brew" "brotli" "bru" "bsdconfig" "bsdgrep" "bsdinstall" "bsdtar" "btdownloadcurses" "btdownloadcurses.py" "btdownloadgui" "btdownloadgui.py" "btdownloadheadless" "btdownloadheadless.py" "btlaunchmany" "btlaunchmanycurses" "btmakemetafile" "btop" "btreannounce" "btrename" "btrfs" "bts" "btshowmetainfo" "bttrack" "bug" "buildctl" "buildhash" "bun" "bunx" "bunzip2" "burst" "busctl" "but" "bwrap" "bzegrep" "bzfgrep" "bzgrep" "bzip2" "bzip2recover" "bzr" "c++" "cabal" "caffeinate" "cal" "calendar" "calibre" "cancel" "capslock" "carapace" "cardctl" "cargo" "cargo-clippy" "cargo-fmt" "cargo-metadata" "cargo-rm" "cargo-set-version" "cargo-upgrade" "cargo-watch" "carton" "cat" "catchsegv" "cc" "ccache" "ccal" "ccze" "cdbs-edit-patch" "cdc" "cdcd" "cdebug" "cdr" "cdrdao" "cdrecord" "ceilometer" "cekit" "certtool" "cfagent" "cfdisk" "cfrun" "cftp" "chage" "change_pw" "charm" "chattr" "chcon" "chcpu" "chdman" "check_db" "check_perms" "checksec" "cheese" "chezmoi" "chflags" "chfn" "chgrp" "chimera" "chkconfig" "chkstow" "chmod" "choom" "chown" "chpass" "chpasswd" "chroma" "chrome" "chromium" "chromium-browser" "chronyc" "chroot" "chrpath" "chrt" "chsh" "ci" "cifsiostat" "cinder" "ciptool" "circleci" "civclient" "civserver" "ckeygen" "cksfv" "cksum" "clamav-config" "clamav-milter" "clambc" "clamconf" "clamd" "clamdscan" "clamdtop" "clamonacc" "clamscan" "clamsubmit" "clang" "clang++" "clay" "cleanarch" "clear" "clion" "clisp" "clone_member" "cloud-init" "cloudkitty" "clusterdb" "clzip" "cmp" "cmus" "co" "code" "code-insiders" "codecov" "codex" "col" "colcrt" "colima" "colormake" "colormgr" "colrm" "column" "comb" "combine" "combinediff" "comm" "comp" "compare" "composer" "composer.phar" "composite" "compress" "conch" "conda" "conda-content-trust" "conda-env" "config.status" "config_list" "configure" "conjure" "conky" "consul" "convert" "coreadm" "coredumpctl" "cosign" "cowsay" "cowthink" "cp" "cpan2dist" "cpio" "cplay" "cppcheck" "cpupower" "crc" "createdb" "createuser" "crontab" "crsh" "crush" "cryptdisks_start" "cryptdisks_stop" "cryptsetup" "cscope" "csh" "csplit" "cssh" "csup" "csview" "ctags" "ctags-exuberant" "ctags-universal" "cu" "cue" "cura" "curl" "cut" "cvs" "cvsps" "cvsup" "cygcheck" "cygcheck.exe" "cygpath" "cygpath.exe" "cygrunsrv" "cygrunsrv.exe" "cygserver" "cygserver.exe" "cygstart" "cygstart.exe" "d2" "dagger" "dak" "darcs" "darktable" "darktable-cli" "dart" "dash" "datagrip" "dataspell" "date" "dbt" "dbus-launch" "dbus-monitor" "dbus-send" "dc" "dchroot" "dchroot-dsa" "dconf" "dcop" "dcopclient" "dcopfind" "dcopobject" "dcopref" "dcopstart" "dcut" "dd" "deadcode" "debchange" "debcheckout" "debconf" "debconf-show" "debdiff" "debfoster" "deborphan" "debsign" "debsnap" "debuild" "defaults" "deja-dup" "delta" "deno" "designate" "desktop-file-validate" "devbox" "devcontainer" "devlink" "devpod" "devtodo" "df" "dfc" "dfutool" "dhclient" "dhclient3" "dhcpinfo" "dict" "diff" "diff3" "diffstat" "dig" "dillo" "dir" "dircmp" "dircolors" "direnv" "dirname" "display" "dist" "dive" "django-admin" "django-admin.py" "dkms" "dladm" "dlocate" "dlv" "dmake" "dmenu" "dmesg" "dmidecode" "dms" "dmypy" "dnf" "dnf-2" "dnf-3" "dngconverter" "dnsmasq" "dnssec-keygen" "dnsspoof" "doas" "docker" "docker-buildx" "docker-compose" "docker-scan" "dockerd" "doctl" "doing" "domainname" "dos2unix" "dosdel" "dosread" "dot" "downgrade" "dpatch-edit-patch" "dpkg" "dpkg-buildpackage" "dpkg-cross" "dpkg-deb" "dpkg-parsechangelog" "dpkg-query" "dpkg-reconfigure" "dpkg-repack" "dpkg-source" "dpll" "dput" "dracut" "drill" "dropbox" "dropdb" "dropuser" "dscverify" "dselect" "dsh" "dsniff" "dtrace" "dtruss" "du" "dumpadm" "dumpdb" "dumpe2fs" "dumper" "dumper.exe" "dupload" "dvibook" "dviconcat" "dvicopy" "dvidvi" "dvipdf" "dvips" "dviselect" "dvitodvi" "dvitype" "dwb" "e2freefrag" "e2label" "eatmydata" "ebook-convert" "ebtables" "ecasound" "ecryptfs-migrate-home" "ed" "edquota" "egrep" "eject" "electron" "elfdump" "elinks" "elvish" "enscript" "entr" "env" "envsubst" "eog" "epdfview" "epsffit" "erb" "espeak" "etags" "ether-wake" "etherwake" "ethtool" "eu-nm" "eu-objdump" "eu-readelf" "eu-strings" "eview" "evim" "evince" "ex" "exa" "exercism" "expand" "explodepkg" "expr" "express" "extcheck" "extractres" "eza" "f77" "f95" "faas-cli" "factor" "faillog" "fakechroot" "fakeroot" "fallocate" "fastboot" "fastfetch" "fbgs" "fbi" "fc-cache" "fc-cat" "fc-conflist" "fc-list" "fc-match" "fd" "fdisk" "feh" "fetch" "fetchmail" "ffmpeg" "ffplay" "ffprobe" "fgrep" "figlet" "file" "file-roller" "filebucket" "filefrag" "filesnarf" "filterdiff" "find" "find_member" "findaffix" "findfs" "findmnt" "finger" "fink" "fio" "firefox" "firefox-esr" "fish" "fixdlsrps" "fixfmps" "fixmacps" "fixpsditps" "fixpspps" "fixscribeps" "fixtpps" "fixwfwps" "fixwpps" "fixwwps" "flac" "flake8" "flatpak" "flex" "flex++" "flipdiff" "flist" "flists" "flock" "flowadm" "flutter" "flyctl" "fmadm" "fmt" "fmttest" "fned" "fnext" "fnm" "fold" "folder" "folders" "foot" "fortune" "forw" "fprev" "fprintd-delete" "fprintd-enroll" "fprintd-list" "fprintd-verify" "free" "freebsd-make" "freebsd-update" "freeciv" "freeciv-gtk2" "freeciv-gtk3" "freeciv-sdl" "freeciv-server" "freeciv-xaw" "freeze" "freezer" "fs_usage" "fsck" "fsfreeze" "fsh" "fstat" "fstrim" "ftp" "ftpd" "function" "fury" "fuser" "fusermount" "fw_update" "fwhois" "fwupdmgr" "fwupdtool" "fzf" "g++" "g++-5" "g++-6" "g++-7" "g++-8" "g4" "g77" "g95" "galeon" "gapplication" "gatsby" "gawk" "gb2sum" "gbase32" "gbase64" "gbasename" "gcat" "gcc" "gcc-5" "gcc-6" "gcc-7" "gcc-8" "gccgo" "gccgo-5" "gccgo-6" "gccgo-7" "gccgo-8" "gchmod" "gchroot" "gcj" "gcksum" "gcl" "gcloud" "gcmp" "gcomm" "gcore" "gcp" "gcut" "gdate" "gdb" "gdbus" "gdctl" "gdd" "gdf" "gdiff" "gdown" "gdu" "geany" "gegrep" "gem" "genaliases" "gendiff" "genisoimage" "genv" "geoiplookup" "geoiplookup6" "get" "get-env" "getafm" "getclip" "getclip.exe" "getconf" "getent" "getfacl" "getfacl.exe" "getfattr" "getmail" "getopt" "gex" "gexpand" "gfgrep" "gfind" "gfmt" "gfold" "gfortran" "gfortran-5" "gfortran-6" "gfortran-7" "gfortran-8" "gftp" "ggetopt" "ggrep" "ggv" "gh" "gh-copilot" "gh-dash" "gh-stack" "ghalint" "ghead" "ghostscript" "ghostty" "ghostview" "gid" "gimp" "ginstall" "gio" "git" "git-abort" "git-alias" "git-archive-file" "git-authors" "git-browse" "git-browse-ci" "git-buildpackage" "git-clang-format" "git-clear" "git-clear-soft" "git-coauthor" "git-cvsserver" "git-extras" "git-info" "git-prompt" "git-receive-pack" "git-shell" "git-standup" "git-unlock" "git-upload-archive" "git-upload-pack" "git-utimes" "gitk" "gitleaks" "gitlint" "gitsign" "gitui" "gjoin" "gkrellm" "gkrellm2" "glab" "glance" "gln" "global" "global-python-argcomplete" "glocate" "glow" "gls" "gm" "gmake" "gmd5sum" "gmkdir" "gmkfifo" "gmknod" "gmktemp" "gmplayer" "gmv" "gnatmake" "gnl" "gnocchi" "gnokii" "gnome-control-center" "gnome-extensions" "gnome-gv" "gnome-keyring" "gnome-keyring-daemon" "gnome-maps" "gnome-mplayer" "gnome-screenshot" "gnome-terminal" "gnumake" "gnumfmt" "gnupod_INIT" "gnupod_addsong" "gnupod_check" "gnupod_search" "gnutls-cli" "gnutls-cli-debug" "gnutls-serv" "go" "go-carpet" "go-tool-asm" "go-tool-buildid" "go-tool-cgo" "go-tool-compile" "go-tool-covdata" "go-tool-cover" "go-tool-dist" "go-tool-doc" "go-tool-fix" "go-tool-link" "go-tool-mockgen" "go-tool-nm" "go-tool-objdump" "go-tool-pack" "gocryptfs" "gocyclo" "god" "gofmt" "goimports" "goland" "golangci-lint" "gomplate" "gonew" "google-chrome" "google-chrome-stable" "gopls" "goreleaser" "goweight" "gparted" "gpasswd" "gpaste" "gpatch" "gpc" "gpg" "gpg-agent" "gpg-zip" "gpg2" "gpgv" "gpgv2" "gphoto2" "gprintenv" "gprof" "gqview" "gradle" "gradlew" "grail" "greadlink" "grep" "grep-excuses" "grepdiff" "gresource" "grm" "grmdir" "groff" "groupadd" "groupdel" "groupmems" "groupmod" "groups" "growisofs" "grpck" "grub" "grub-editenv" "grub-install" "grub-mkconfig" "grub-mkfont" "grub-mkimage" "grub-mkpasswd-pbkdf2" "grub-mkrescue" "grub-probe" "grub-reboot" "grub-script-check" "grub-set-default" "grype" "gs" "gsa" "gsbj" "gsdj" "gsdj500" "gsed" "gseq" "gsettings" "gsha1sum" "gsha224sum" "gsha256sum" "gsha384sum" "gsha512sum" "gshred" "gshuf" "gslj" "gslp" "gsnd" "gsort" "gsplit" "gssdp-device-sniffer" "gssdp-discover" "gst-inspect-1.0" "gst-launch-1.0" "gstat" "gstdbuf" "gstrings" "gstty" "gsum" "gtac" "gtail" "gtar" "gtee" "gtimeout" "gtk4-builder-tool" "gtk4-image-tool" "gtk4-path-tool" "gtk4-rendernode-tool" "gtouch" "gtr" "gtty" "guilt" "guilt-add" "guilt-applied" "guilt-delete" "guilt-files" "guilt-fold" "guilt-fork" "guilt-header" "guilt-help" "guilt-import" "guilt-import-commit" "guilt-init" "guilt-new" "guilt-next" "guilt-patchbomb" "guilt-pop" "guilt-prev" "guilt-push" "guilt-rebase" "guilt-refresh" "guilt-rm" "guilt-series" "guilt-status" "guilt-top" "guilt-unapplied" "gulp" "gum" "guname" "gunexpand" "guniq" "gunzip" "guptime" "gv" "gview" "gvim" "gvimdiff" "gwc" "gwho" "gxargs" "gzegrep" "gzfgrep" "gzgrep" "gzilla" "gzip" "halt" "hardlink" "hatch" "hciattach" "hciconfig" "hcitool" "hcloud" "hd" "hddtemp" "hdiutil" "head" "heat" "helix" "helm" "helmfile" "helmsman" "help" "hexchat" "hexdump" "hid2hci" "hilite" "histed" "host" "hostid" "hostname" "hostnamectl" "hotjava" "hping" "hping2" "hping3" "htop" "htpasswd" "http" "https" "hugetop" "hugo" "hunspell" "hurl" "hwinfo" "hx" "hyperfine" "i3" "i3-scrot" "i3exit" "i3lock" "i3status" "i3status-rs" "ibus" "iceweasel" "icombine" "iconv" "iconvconfig" "id" "idea" "identify" "idn" "ifconfig" "ifdown" "ifquery" "ifstat" "ifstatus" "iftop" "ifup" "ijoin" "img2pdf" "import" "imv" "inc" "includeres" "incus" "inetadm" "influx" "info" "infocmp" "initctl" "initdb" "inject" "inkscape" "inotifywait" "inotifywatch" "inshellisense" "insmod" "install" "install-info" "installpkg" "interdiff" "invoke-rc.d" "ion" "ionice" "iostat" "ip" "ip6tables" "ip6tables-restore" "ip6tables-save" "ipadm" "ipcalc" "ipcmk" "ipcrm" "ipcs" "iperf" "iperf3" "ipfw" "ipkg" "ipmitool" "ipsec" "ipset" "iptables" "iptables-restore" "iptables-save" "ipv6calc" "irb" "iredis" "ironic" "irssi" "isag" "iscsiadm" "isort" "ispell" "isql" "iwconfig" "iwlist" "iwpriv" "iwspy" "jadetex" "jail" "jar" "jarsigner" "java" "javac" "javadoc" "javah" "javap" "javaws" "jdb" "jexec" "jj" "jls" "joe" "join" "jot" "journalctl" "jpegoptim" "jps" "jq" "jshint" "json_xs" "jsonschema" "julia" "just" "k3b" "k3sup" "k6" "k9s" "kak" "kak-lsp" "kcl" "kcov" "kdeconnect-cli" "kdump" "kernel-install" "keystone" "keytool" "kfmclient" "kill" "killall" "killall5" "kioclient" "kiro" "kitten" "kitty" "kldload" "kldunload" "kmod" "kmonad" "knock" "koji" "kompose" "konqueror" "kotlin" "kotlinc" "kpartx" "kpdf" "kplayer" "ksh" "ksh88" "ksh93" "ktlint" "ktrace" "ktutil" "kubeadm" "kubebuilder" "kubectl" "kubeseal" "kustomize" "kvno" "l2ping" "larch" "last" "lastb" "lastlog" "latex" "latexmk" "lazygit" "lbzip2" "ldap" "ldapadd" "ldapcompare" "ldapdelete" "ldapmodify" "ldapmodrdn" "ldappasswd" "ldapsearch" "ldapvi" "ldapwhoami" "ldconfig" "ldconfig.real" "ldd" "lefthook" "less" "lf" "lftp" "lftpget" "lha" "libreoffice" "light" "lightdm" "lighty-disable-mod" "lighty-enable-mod" "lilo" "limactl" "link" "links" "links2" "lintian" "lintian-info" "linux" "lisp" "list_admins" "list_lists" "list_members" "list_owners" "litecli" "lldb" "llvm-g++" "llvm-gcc" "llvm-objdump" "llvm-otool" "ln" "lnav" "lncrawl" "loadkeys" "locale" "locale-gen" "localectl" "localedef" "localsearch" "locate" "logger" "loginctl" "logname" "look" "losetup" "lp" "lpadmin" "lpinfo" "lpoptions" "lpq" "lpr" "lprm" "lpstat" "lrzip" "ls" "lsattr" "lsb_release" "lsblk" "lscfg" "lsclocks" "lscpu" "lsdev" "lsdiff" "lsfd" "lsinitrd" "lsipc" "lsirq" "lslocks" "lslogins" "lslv" "lsmem" "lsmod" "lsns" "lsof" "lspv" "lsscsi" "lsusb" "lsvg" "ltrace" "lua" "lua5.0" "lua5.1" "lua5.2" "lua5.3" "lua5.4" "lua50" "lua51" "lua52" "lua53" "lua54" "luac" "luac5.0" "luac5.1" "luac5.2" "luac5.3" "luac5.4" "luac50" "luac51" "luac52" "luac53" "luac54" "luarocks" "luseradd" "luserdel" "lusermod" "lvchange" "lvcreate" "lvdisplay" "lvextend" "lvm" "lvmdiskscan" "lvreduce" "lvremove" "lvrename" "lvresize" "lvs" "lvscan" "lynx" "lz4" "lz4c" "lz4c32" "lz4cat" "lzcat" "lzip" "lzma" "lzop" "m-a" "mac2unix" "macof" "madison" "magick" "magnum" "mail" "mailmanctl" "mailsnarf" "make" "make-kpkg" "makeinfo" "makepkg" "man" "manage.py" "manila" "mark" "marp" "mat" "mat2" "matlab" "mattrib" "maturin" "mbimcli" "mc" "mcd" "mcomix" "mcookie" "mcopy" "mcrypt" "md2" "md4" "md5" "md5sum" "mdadm" "mdbook" "mdecrypt" "mdel" "mdeltree" "mdfind" "mdir" "mdls" "mdtool" "mdu" "mdutil" "medusa" "meld" "melt" "members" "mencal" "mencoder" "mere" "merge" "mergechanges" "metaflac" "mfiutil" "mformat" "mgv" "mhfixmsg" "mhlist" "mhmail" "mhn" "mhparam" "mhpath" "mhshow" "mhstore" "micro" "micropython" "mii-diag" "mii-tool" "minicom" "minikube" "mistral" "mitmproxy" "mix" "mixerctl" "mkcert" "mkdir" "mkfifo" "mkfs" "mkinitrd" "mkisofs" "mknod" "mksh" "mkshortcut" "mkshortcut.exe" "mkswap" "mktemp" "mktunes" "mkzsh" "mkzsh.exe" "mlabel" "mlocate" "mmcli" "mmd" "mmm" "mmount" "mmove" "mmsitepass" "modinfo" "modprobe" "module" "module-assistant" "mogrify" "mokutil" "molecule" "monasca" "mondoarchive" "monodevelop" "montage" "moosic" "more" "mosh" "mount" "mountpoint" "mousepad" "mozilla" "mozilla-firefox" "mozilla-xremote-client" "mpc" "mplayer" "mplayer2" "mpstat" "mpv" "mr" "mrd" "mread" "mren" "mrsasutil" "msgchk" "msgsnarf" "msynctool" "mt" "mtn" "mtoolstest" "mtr" "mtx" "mtype" "munchlist" "munin-node-configure" "munin-run" "munin-update" "munindoc" "mupdf" "murano" "mush" "mussh" "mutt" "muttng" "mv" "mvim" "mvn" "mx" "mycli" "mypy" "mysql" "mysqladmin" "mysqldiff" "mysqldump" "mysqlimport" "mysqlshow" "n-m3u8dl-re" "namei" "nano" "native2ascii" "nautilus" "nawk" "nc" "ncal" "ncdu" "ncftp" "nedit" "neomutt" "nerdctl" "netcat" "nethogs" "netplan" "netrik" "netscape" "netstat" "networkctl" "networksetup" "neutron" "new" "newgrp" "newlist" "newman" "newrelic" "newusers" "next" "nfpm" "ng" "nginx" "ngrep" "nh" "nice" "nilaway" "nix" "nix-build" "nix-channel" "nix-instantiate" "nix-shell" "nixos-rebuild" "nkf" "nl" "nm" "nmap" "nmblookup" "nmcli" "nocorrect" "node" "nohup" "nomad" "nova" "nox" "npm" "nproc" "ns" "nsenter" "nslookup" "nsupdate" "ntalk" "ntpd" "ntpdate" "nu" "numfmt" "nvim" "nvram" "objdump" "od" "odme" "odmget" "odmshow" "ogg123" "oggdec" "oggenc" "ogginfo" "oh-my-posh" "oksh" "okular" "ollama" "oomctl" "op" "open" "openscad" "openssl" "openstack" "openvpn" "opera" "opera-next" "opkg" "optipng" "opusdec" "opusenc" "opusinfo" "orbctl" "osascript" "osc" "otool" "p4" "p4d" "pack" "pack200" "packer" "packf" "pacman" "pacman-conf" "pacman-db-upgrade" "pacman-key" "pacman-mirrors" "palemoon" "pamac" "pandoc" "parsehdlist" "partx" "paru" "pass" "passwd" "paste" "patch" "pathchk" "patool" "pax" "pbcopy" "pbpaste" "pbuilder" "pbzip2" "pccardctl" "pcmanfm" "pcp-htop" "pcred" "pdf2dsc" "pdf2ps" "pdfattach" "pdfdetach" "pdffonts" "pdfimages" "pdfinfo" "pdfjadetex" "pdflatex" "pdfopt" "pdfseparate" "pdfsig" "pdftex" "pdftexi2dvi" "pdftk" "pdftocairo" "pdftohtml" "pdftopbm" "pdftoppm" "pdftops" "pdftotext" "pdfunite" "pdksh" "pdlzip" "perf" "perl" "perlcritic" "perldoc" "perltidy" "pfctl" "pfexec" "pfiles" "pflags" "pg_config" "pg_ctl" "pg_dump" "pg_dumpall" "pg_isready" "pg_restore" "pg_upgrade" "pgcli" "pgrep" "phing" "php" "phpstorm" "picard" "pick" "picocom" "pidof" "pidstat" "pidwait" "pigz" "pine" "pinef" "pinfo" "ping" "ping4" "ping6" "pinky" "pip" "pipenv" "pipx" "piuparts" "pixi" "pkg" "pkg-config" "pkg-get" "pkg_add" "pkg_create" "pkg_delete" "pkg_info" "pkgadd" "pkgcli" "pkgconf" "pkgin" "pkginfo" "pkgrm" "pkgsite" "pkgtool" "pkill" "plague-client" "pldd" "plutil" "plzip" "pm-hibernate" "pm-is-supported" "pm-powersave" "pm-suspend" "pm-suspend-hybrid" "pmake" "pman" "pmap" "pmcat" "pmdesc" "pmeth" "pmexp" "pmfunc" "pmload" "pmls" "pmpath" "pmvers" "pngcheck" "pngfix" "pnpm" "podgrep" "podman" "podpath" "podtoc" "poff" "policytool" "pon" "portaudit" "portlint" "portmaster" "portsnap" "postalias" "postcat" "postconf" "postfix" "postgres" "postmap" "postmaster" "postqueue" "postsuper" "povray" "powerd" "poweroff" "powerprofilesctl" "powertop" "ppc-koji" "pprof" "pr" "prelink" "present" "prettybat" "prettyping" "prev" "printenv" "prlimit" "pro" "procs" "procstat" "prompt" "protoc" "prove" "prs" "prstat" "prt" "prun" "ps" "ps2ascii" "ps2epsi" "ps2pdf" "ps2pdf12" "ps2pdf13" "ps2pdf14" "ps2pdfwr" "ps2ps" "psbook" "pscale" "pscp" "pscp.exe" "psed" "psig" "psmerge" "psmulti" "psnup" "psql" "psresize" "psselect" "pstack" "pstoedit" "pstop" "pstops" "pstotgif" "pswrap" "ptree" "ptx" "pulumi" "pump" "puppet" "puppetca" "puppetd" "puppetdoc" "puppetmasterd" "puppetqd" "puppetrun" "putclip" "putclip.exe" "pv" "pvchange" "pvcreate" "pvdisplay" "pvmove" "pvremove" "pvs" "pvscan" "pwait" "pwck" "pwd" "pwdx" "pwgen" "pxz" "py.test" "py.test-2" "py.test-3" "pycharm" "pycodestyle" "pydoc" "pydoc3" "pydocstyle" "pyflakes" "pygmentize" "pyhtmlizer" "pylint" "pylint-2" "pylint-3" "pypy" "pypy3" "pyston" "pyston3" "pytest" "pytest-2" "pytest-3" "python" "python2" "python2.7" "python3" "python3.10" "python3.11" "python3.12" "python3.13" "python3.3" "python3.4" "python3.5" "python3.6" "python3.7" "python3.8" "python3.9" "pyvenv" "pyvenv-3.10" "pyvenv-3.11" "pyvenv-3.12" "pyvenv-3.13" "pyvenv-3.4" "pyvenv-3.5" "pyvenv-3.6" "pyvenv-3.7" "pyvenv-3.8" "pyvenv-3.9" "qdbus" "qemu" "qemu-kvm" "qemu-system-i386" "qemu-system-x86_64" "qiv" "qmicli" "qmk" "qpdf" "qrencode" "qrunner" "qtplay" "querybts" "quilt" "quota" "quotacheck" "quotaoff" "quotaon" "qutebrowser" "radvdump" "rails" "rake" "ralsh" "ramalama" "ranger" "ranlib" "rar" "rc" "rcctl" "rclone" "rcp" "rcs" "rcsdiff" "rdesktop" "rdict" "readelf" "readlink" "readprofile" "readshortcut" "readshortcut.exe" "reboot" "rebootin" "redis-cli" "refile" "reindexdb" "reload" "remove_members" "removepkg" "rename" "renice" "repl" "reportbug" "repquota" "reprepro" "resolvconf" "resolvectl" "restart" "restic" "resume-cli" "retawq" "reuse" "rev" "rfcomm" "rfkill" "rg" "rgrep" "rgview" "rgvim" "ri" "rider" "rifle" "ripsecrets" "rlog" "rlogin" "rm" "rmadison" "rmd160" "rmdel" "rmdir" "rmf" "rmic" "rmid" "rmiregistry" "rmlist" "rmm" "rmmod" "route" "rpcdebug" "rpm" "rpm2targz" "rpm2tgz" "rpm2txz" "rpmbuild" "rpmbuild-md5" "rpmcheck" "rpmkeys" "rpmquery" "rpmsign" "rpmspec" "rpmverify" "rrdtool" "rsh" "rsync" "rtcwake" "rtin" "rubber" "rubber-info" "rubber-pipe" "ruby" "ruby-mri" "rubymine" "run-help" "run0" "runuser" "rup" "rusage" "rust-analyzer" "rust-arch" "rust-b2sum" "rust-base32" "rust-base64" "rust-basename" "rust-basenc" "rust-cat" "rust-chcon" "rust-chgrp" "rust-chmod" "rust-chown" "rust-chroot" "rust-cksum" "rust-comm" "rust-coreutils" "rust-cp" "rust-csplit" "rust-cut" "rust-date" "rust-dd" "rust-df" "rust-dir" "rust-dircolors" "rust-dirname" "rust-du" "rust-echo" "rust-env" "rust-expand" "rust-expr" "rust-factor" "rust-false" "rust-fmt" "rust-fold" "rust-groups" "rust-head" "rust-hostid" "rust-hostname" "rust-id" "rust-install" "rust-join" "rust-kill" "rust-link" "rust-ln" "rust-logname" "rust-ls" "rust-md5sum" "rust-mkdir" "rust-mkfifo" "rust-mknod" "rust-mktemp" "rust-more" "rust-mv" "rust-nice" "rust-nl" "rust-nohup" "rust-nproc" "rust-numfmt" "rust-od" "rust-paste" "rust-pathchk" "rust-pinky" "rust-pr" "rust-printenv" "rust-printf" "rust-ptx" "rust-pwd" "rust-readlink" "rust-realpath" "rust-rm" "rust-rmdir" "rust-runcon" "rust-seq" "rust-sha1sum" "rust-sha224sum" "rust-sha256sum" "rust-sha384sum" "rust-sha512sum" "rust-shred" "rust-shuf" "rust-sleep" "rust-sort" "rust-split" "rust-stat" "rust-stdbuf" "rust-stty" "rust-sum" "rust-sync" "rust-tac" "rust-tail" "rust-tee" "rust-test" "rust-timeout" "rust-touch" "rust-tr" "rust-true" "rust-truncate" "rust-tsort" "rust-tty" "rust-uname" "rust-unexpand" "rust-uniq" "rust-unlink" "rust-uptime" "rust-users" "rust-vdir" "rust-wc" "rust-who" "rust-whoami" "rust-yes" "rustc" "rustdoc" "rustrover" "rustup" "rview" "rvim" "rwho" "rxvt" "s2p" "s390-koji" "sact" "sadf" "sahara" "sar" "savecore" "saw" "say" "sbcl" "sbcl-mt" "sbopkg" "sbuild" "sc_usage" "scan" "scc" "sccs" "sccsdiff" "schedtool" "schroot" "scl" "scons" "scp" "screen" "script" "scriptlive" "scriptreplay" "scrot" "scrub" "scselect" "scutil" "sd" "sdkmanager" "sdptool" "seaf-cli" "sed" "semver" "senlin" "seq" "serialver" "serie" "service" "set-env" "setarch" "setfacl" "setfacl.exe" "setfattr" "setpriv" "setquota" "setsid" "setterm" "setxkbmap" "sfdisk" "sftp" "sh" "sha1" "sha1sum" "sha224sum" "sha256" "sha256sum" "sha384" "sha384sum" "sha512" "sha512sum" "sha512t256" "shasum" "shellcheck" "show" "showchar" "showkey" "showmount" "shred" "shuf" "shutdown" "sidedoor" "signify" "singularity" "sisu" "sitecopy" "skein1024" "skein256" "skein512" "skipstone" "slabtop" "slapt-get" "slapt-src" "sleep" "slides" "slitex" "slocate" "slogin" "slrn" "slsa-verifier" "smartctl" "smbcacls" "smbclient" "smbcontrol" "smbcquotas" "smbget" "smbpasswd" "smbstatus" "smbtar" "smbtree" "smit" "smitty" "snap" "snoop" "snownews" "soa" "socket" "sockstat" "soft" "softwareupdate" "sort" "sortm" "spamassassin" "sparc-koji" "speedtest-cli" "split" "splitdiff" "spovray" "sqlite" "sqlite3" "sqsh" "sr" "srptool" "ss" "ssh" "ssh-add" "ssh-agent" "ssh-copy-id" "ssh-keygen" "ssh-keyscan" "sshfs" "sshmitm" "sshow" "st" "star" "starship" "start" "stat" "staticcheck" "status" "stdbuf" "stg" "stop" "stow" "strace" "strace64" "stream" "strings" "strip" "strongswan" "stty" "su" "subl" "sudo" "sudoedit" "sudoreplay" "sulogin" "sum" "supervisorctl" "supervisord" "surfraw" "sv" "svcadm" "svccfg" "svcprop" "svcs" "svg-term" "svgcleaner" "svk" "svn" "svn-buildpackage" "svnadmin" "sw_vers" "swaks" "swanctl" "swaplabel" "swapoff" "swapon" "sway" "swaybar" "swaybg" "swayidle" "swaylock" "swaymsg" "swaynag" "swift" "swiftc" "syft" "sync" "sync_members" "synclient" "sysbench" "sysclean" "sysctl" "sysmerge" "syspatch" "sysrc" "systat" "system_profiler" "systemctl" "systemd-analyze" "systemd-ask-password" "systemd-cat" "systemd-cgls" "systemd-cgtop" "systemd-confext" "systemd-creds" "systemd-cryptenroll" "systemd-delta" "systemd-detect-virt" "systemd-dissect" "systemd-id128" "systemd-inhibit" "systemd-machine-id-setup" "systemd-notify" "systemd-path" "systemd-resolve" "systemd-run" "systemd-sysext" "systemd-tmpfiles" "systemd-tty-ask-password-agent" "systemd-vpick" "sysupgrade" "tac" "tacker" "tail" "talk" "talosctl" "taplo" "tar" "tardy" "task" "taskset" "tc" "tcp_open" "tcpdump" "tcpkill" "tcpnice" "tcptraceroute" "tcsh" "tda" "tdd" "tde" "tdr" "tea" "tee" "telnet" "templ" "termux-apt-repo" "terraform" "terraform-ls" "terragrunt" "terramate" "tesseract" "tex" "texi2any" "texi2dvi" "texi2pdf" "texindex" "tg" "tidy" "tig" "tightvncviewer" "time" "timedatectl" "timeout" "tin" "tinygo" "tinysparql" "tipc" "tkconch" "tkinfo" "tla" "tldr" "tload" "tmate" "tmux" "todo" "todo.sh" "tofu" "toilet" "toit.lsp" "toit.pkg" "toolbox" "top" "tor-browser" "tor-gencert" "tor-print-ed-signing-cert" "tor-resolve" "torsocks" "totdconfig" "touch" "tox" "tpb" "tpkg-debarch" "tpkg-install" "tpkg-install-libc" "tpkg-make" "tpkg-update" "tput" "tqdm" "tr" "trace-cmd" "tracepath" "tracepath6" "traceroute" "traefik" "transmission-cli" "transmission-create" "transmission-daemon" "transmission-edit" "transmission-remote" "transmission-show" "trash" "tree" "trial" "trivy" "trove" "truncate" "truss" "tryaffix" "ts" "tsc" "tsh" "tshark" "tsig-keygen" "tsort" "tty" "ttyd" "tunctl" "tune2fs" "tunes2pod" "turbo" "twidge" "twist" "twistd" "txt" "typst" "ua" "ubuntu-bug" "ubuntu-insights" "ubuntu-report" "uclampset" "udevadm" "udisksctl" "ufw" "ul" "uml_mconsole" "uml_moo" "uml_switch" "umount" "unace" "uname" "unbrotli" "uncompress" "unexpand" "unget" "uniq" "unison" "units" "unix2dos" "unix2mac" "unlink" "unlz4" "unlzma" "unpack" "unpack200" "unpigz" "unrar" "unset-env" "unshare" "unshunt" "unwrapdiff" "unxz" "unzip" "update-alternatives" "update-initramfs" "update-java-alternatives" "update-rc.d" "upgradepkg" "upower" "uptime" "upx" "urlsnarf" "urpme" "urpmf" "urpmi" "urpmi.addmedia" "urpmi.removemedia" "urpmi.update" "urpmq" "urxvt" "urxvt256c" "urxvt256c-ml" "urxvt256c-mlc" "urxvt256cc" "urxvtc" "usbconfig" "uscan" "useradd" "userdbctl" "userdel" "usermod" "users" "uuidd" "uuidgen" "uuidparse" "vacuumdb" "vagrant" "val" "valgrind" "varlinkctl" "vault" "vcs_info_hookadd" "vcs_info_hookdel" "vdir" "vercel" "vgcfgbackup" "vgcfgrestore" "vgchange" "vgck" "vgconvert" "vgcreate" "vgdisplay" "vgexport" "vgextend" "vgimport" "vgmerge" "vgmknodes" "vgreduce" "vgremove" "vgrename" "vgs" "vgscan" "vgsplit" "vhs" "vi" "view" "viewnior" "vigr" "vim" "vim-addons" "vimdiff" "vipw" "virsh" "virt-admin" "virt-host-validate" "virt-pki-validate" "virt-xml-validate" "visudo" "vitrage" "viu" "vivid" "vlc" "vmctl" "vmstat" "vncserver" "vncviewer" "volta" "vorbiscomment" "vpnc" "vpnc-connect" "vserver" "vunnel" "w" "w3m" "wajig" "wall" "wanna-build" "watch" "watcher" "watchexec" "watchgnupg" "waypoint" "wc" "webmitm" "webstorm" "wezterm" "wget" "what" "whatis" "whereis" "which" "whiptail" "who" "whoami" "whois" "whom" "wiggle" "wine" "wine-development" "wine-stable" "wine64" "wine64-development" "wine64-stable" "wineboot" "winepath" "wineserver" "winetricks" "wipefs" "wire" "wireshark" "wishlist" "withlist" "wl-copy" "wl-mirror" "wl-paste" "wodim" "woeusb" "wol" "wpa_cli" "wpctl" "write" "wsimport" "wt" "wtf" "wvdial" "www" "xargs" "xattr" "xauth" "xautolock" "xbacklight" "xbps-alternatives" "xbps-checkvers" "xbps-create" "xbps-dgraph" "xbps-digest" "xbps-fbulk" "xbps-fetch" "xbps-install" "xbps-pkgdb" "xbps-query" "xbps-reconfigure" "xbps-remove" "xbps-rindex" "xbps-uchroot" "xbps-uhelper" "xbps-uunshare" "xclip" "xcode-select" "xdg-mime" "xdg-settings" "xdotool" "xdpyinfo" "xdvi" "xev" "xfd" "xfig" "xfontsel" "xfreerdp" "xgamma" "xh" "xhost" "xinput" "xkill" "xli" "xloadimage" "xlsatoms" "xlsclients" "xml" "xmllint" "xmlstarlet" "xmlwf" "xmms" "xmms2" "xmodmap" "xmosaic" "xon" "xonsh" "xournal" "xpdf" "xping" "xpovray" "xprop" "xrandr" "xrdb" "xscreensaver-command" "xset" "xsetbg" "xsetroot" "xsltproc" "xterm" "xtightvncviewer" "xtp" "xv" "xvfb-run" "xview" "xvnc4viewer" "xvncviewer" "xwd" "xwininfo" "xwit" "xwud" "xxd" "xxhsum" "xz" "xzcat" "xzdec" "yafc" "yarn" "yash" "yast" "yast2" "yay" "yes" "yj" "ykman" "youtube-dl" "ypbind" "ypcat" "ypmatch" "yppasswd" "yppoll" "yppush" "ypserv" "ypset" "ypwhich" "ypxfr" "yt-dlp" "ytalk" "yum" "yum-arch" "yumdb" "zargs" "zathura" "zcalc" "zcat" "zcp" "zdb" "zdelattr" "zdump" "zeal" "zed" "zegrep" "zen" "zf_chmod" "zf_ln" "zf_mkdir" "zf_mv" "zf_rm" "zf_rmdir" "zfgrep" "zfs" "zgetattr" "zgrep" "zig" "zip" "zipinfo" "zlistattr" "zln" "zlogin" "zmail" "zmv" "zone" "zoneadm" "zopfli" "zopflipng" "zoxide" "zpool" "zpty" "zramctl" "zsetattr" "zsh" "zsh-mime-handler" "zsocket" "ztodo" "zun" "zxpdf" "zypper"


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


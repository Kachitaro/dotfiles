# ==============================================================================
# Dotfiles Shell Configuration (Bash & Zsh compatible for Linux / macOS)
# ==============================================================================

# UTF-8 Encoding
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LESSCHARSET='utf-8'

# Eza colors
export EZA_COLORS="di=36"

# Preferred Editor
if command -v nvim >/dev/null 2>&1; then
    export EDITOR='nvim'
    export VISUAL='nvim'
fi

# ------------------------------------------------------------------------------
# Aliases
# ------------------------------------------------------------------------------
alias g='git'
alias vi='nvim'
alias vim='nvim'

if command -v eza >/dev/null 2>&1; then
    alias ls='eza'
    alias ll='eza -l -g --icons'
    alias la='eza -a -l -g --icons'
    alias lt='eza --tree --level=2 --icons'
else
    alias ll='ls -lh'
    alias la='ls -lah'
fi

if command -v bat >/dev/null 2>&1; then
    alias cat='bat --paging=never'
elif command -v batcat >/dev/null 2>&1; then
    alias cat='batcat --paging=never'
    alias bat='batcat'
fi

# Navigation shortcuts
alias cd..='cd ..'
alias cd...='cd ../..'
alias cd....='cd ../../..'

# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------
# System size utilities (Linux)
get_system_size() {
    echo -e "\033[0;32m====== Disk Usage Report ======\033[0m"
    df -h /
    echo ""
    echo -e "\033[0;32m====== Top 10 Largest Directories in Home ======\033[0m"
    du -h -d 2 "$HOME" 2>/dev/null | sort -hr | head -n 10
}

# ------------------------------------------------------------------------------
# FZF Keybindings & Fuzzy Finder
# ------------------------------------------------------------------------------
if command -v fzf >/dev/null 2>&1; then
    # Load fzf key bindings if available
    [ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && source /usr/share/doc/fzf/examples/key-bindings.bash
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash
fi

# ------------------------------------------------------------------------------
# Oh My Posh Prompt
# ------------------------------------------------------------------------------
if command -v oh-my-posh >/dev/null 2>&1; then
    # Determine current running shell
    CURRENT_SHELL=$(basename "$SHELL")
    if [ "$CURRENT_SHELL" = "zsh" ]; then
        eval "$(oh-my-posh init zsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/zash.omp.json)"
    else
        eval "$(oh-my-posh init bash --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/zash.omp.json)"
    fi
fi

# ------------------------------------------------------------------------------
# NVM (Node Version Manager)
# ------------------------------------------------------------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

#!/usr/bin/env bash
# ==============================================================================
# 🚀 Linux / macOS Dotfiles & Dev Environment One-Command Installer
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.sh | bash
# Or locally:
#   chmod +x ./install.sh && ./install.sh
# ==============================================================================

set -e

# Color definitions
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

write_header() {
    clear 2>/dev/null || true
    echo -e "${MAGENTA}====================================================================${NC}"
    echo -e "${MAGENTA}  🚀 LINUX / MACOS DOTFILES & ENVIRONMENT AUTO-INSTALLER           ${NC}"
    echo -e "${MAGENTA}  Repository: https://github.com/kachitaro/dotfiles                ${NC}"
    echo -e "${MAGENTA}====================================================================${NC}"
    echo ""
}

write_step() { echo -e "\n${CYAN}🔹 [STEP] $1${NC}"; }
write_succ() { echo -e "  ${GREEN}✅ $1${NC}"; }
write_warn() { echo -e "  ${YELLOW}⚠️ $1${NC}"; }
write_err()  { echo -e "  ${RED}❌ $1${NC}"; }

write_header

# ------------------------------------------------------------------------------
# 1. Determine Dotfiles Directory
# ------------------------------------------------------------------------------
write_step "Xác định thư mục Dotfiles..."
REPO_URL="https://github.com/kachitaro/dotfiles.git"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"

if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/wezterm/wezterm.lua" ]; then
    DOTFILES_DIR="$SCRIPT_DIR"
else
    DOTFILES_DIR="$HOME/.dotfiles"
fi
echo -e "  Thư mục Dotfiles đích: ${CYAN}$DOTFILES_DIR${NC}"

# Ensure ~/.local/bin is created and in PATH
mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

# ------------------------------------------------------------------------------
# 2. Detect Package Manager & Install Dependencies
# ------------------------------------------------------------------------------
write_step "Cài đặt các gói công cụ hệ thống..."

SUDO_CMD=""
if [ "$(id -u)" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
        SUDO_CMD="sudo"
    else
        write_warn "sudo không có sẵn. Một số tác vụ hệ thống có thể cần quyền root."
    fi
fi

if command -v apt-get >/dev/null 2>&1; then
    echo "  Phát hiện hệ điều hành dựa trên Debian/Ubuntu (apt)..."
    $SUDO_CMD apt-get update -y
    $SUDO_CMD apt-get install -y git curl wget unzip tar build-essential fzf ripgrep fd-find
    
    # Symlink fdfind to fd if needed
    if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
    fi

    # Cài đặt bat / eza / neovim
    $SUDO_CMD apt-get install -y bat neovim 2>/dev/null || true
    if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
        ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
    fi

    # Install eza if not present
    if ! command -v eza >/dev/null 2>&1; then
        echo "  Đang tải eza cho Ubuntu/Debian..."
        $SUDO_CMD mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | $SUDO_CMD gpg --dearmor -o /etc/apt/keyrings/gierens.gpg 2>/dev/null || true
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | $SUDO_CMD tee /etc/apt/sources.list.d/gierens.list 2>/dev/null || true
        $SUDO_CMD chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list 2>/dev/null || true
        $SUDO_CMD apt-get update -y 2>/dev/null || true
        $SUDO_CMD apt-get install -y eza 2>/dev/null || true
    fi

elif command -v pacman >/dev/null 2>&1; then
    echo "  Phát hiện Arch Linux / Manjaro (pacman)..."
    $SUDO_CMD pacman -Syu --noconfirm git curl wget base-devel unzip neovim ripgrep fd fzf bat eza lazygit wezterm || true

elif command -v dnf >/dev/null 2>&1; then
    echo "  Phát hiện Fedora / RHEL (dnf)..."
    $SUDO_CMD dnf install -y git curl wget make gcc unzip neovim ripgrep fd-find fzf bat eza lazygit || true

elif command -v brew >/dev/null 2>&1; then
    echo "  Phát hiện Homebrew..."
    brew install git curl wget neovim ripgrep fd fzf bat eza lazygit
fi

write_succ "Hoàn tất kiểm tra / cài đặt công cụ hệ thống."

# ------------------------------------------------------------------------------
# 3. Install JetBrainsMono Nerd Font
# ------------------------------------------------------------------------------
write_step "Cài đặt JetBrainsMono Nerd Font..."
FONT_DIR="$HOME/.local/share/fonts"
if [ ! -f "$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf" ]; then
    mkdir -p "$FONT_DIR"
    echo "  Đang tải JetBrainsMono Nerd Font..."
    TEMP_FONT_ZIP="/tmp/JetBrainsMono.zip"
    curl -fsSL -o "$TEMP_FONT_ZIP" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    unzip -q -o "$TEMP_FONT_ZIP" -d "$FONT_DIR" 2>/dev/null || true
    rm -f "$TEMP_FONT_ZIP"
    if command -v fc-cache >/dev/null 2>&1; then
        fc-cache -f "$FONT_DIR" >/dev/null 2>&1 || true
    fi
    write_succ "Đã cài đặt font JetBrainsMono Nerd Font."
else
    write_succ "Font JetBrainsMono Nerd Font đã có sẵn."
fi

# ------------------------------------------------------------------------------
# 4. Install Oh My Posh
# ------------------------------------------------------------------------------
write_step "Cài đặt Oh My Posh..."
if ! command -v oh-my-posh >/dev/null 2>&1; then
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin"
    write_succ "Đã cài đặt Oh My Posh vào ~/.local/bin/oh-my-posh."
else
    write_succ "Oh My Posh đã được cài đặt."
fi

# ------------------------------------------------------------------------------
# 5. Install NVM & Node.js LTS
# ------------------------------------------------------------------------------
write_step "Cài đặt NVM & Node.js LTS..."
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
if command -v nvm >/dev/null 2>&1; then
    nvm install 22
    nvm use 22
    nvm alias default 22
    write_succ "Node.js LTS (v22) đã sẵn sàng."
fi

# ------------------------------------------------------------------------------
# 6. Clone or Update Dotfiles
# ------------------------------------------------------------------------------
write_step "Đồng bộ Dotfiles từ GitHub..."
if [ ! -d "$DOTFILES_DIR/.git" ]; then
    mkdir -p "$(dirname "$DOTFILES_DIR")"
    echo "  Cloning repository vào $DOTFILES_DIR ..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
else
    echo "  Cập nhật repository tại $DOTFILES_DIR ..."
    git -C "$DOTFILES_DIR" pull || true
fi
write_succ "Dotfiles đã sẵn sàng tại $DOTFILES_DIR."

# ------------------------------------------------------------------------------
# 7. Create Symlinks
# ------------------------------------------------------------------------------
write_step "Tạo Symlink cấu hình (WezTerm, Neovim, Shell)..."

create_link() {
    local target="$1"
    local link="$2"

    if [ ! -e "$target" ]; then
        write_warn "Target không tồn tại: $target"
        return
    fi

    mkdir -p "$(dirname "$link")"
    if [ -L "$link" ]; then
        rm -f "$link"
    elif [ -e "$link" ]; then
        mv "$link" "${link}.bak_$(date +%Y%m%d%H%M%S)"
    fi

    ln -sf "$target" "$link"
    write_succ "Linked: $link -> $target"
}

# 7.1 WezTerm
create_link "$DOTFILES_DIR/wezterm" "$HOME/.config/wezterm"

# 7.2 Neovim
create_link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# 7.3 Bash / Zsh Profiles
SHELL_SOURCE_LINE="[ -f \"$DOTFILES_DIR/shell/.bashrc\" ] && source \"$DOTFILES_DIR/shell/.bashrc\""

for rc_file in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc_file" ] || [ "$(basename "$rc_file")" = ".bashrc" ]; then
        touch "$rc_file"
        if ! grep -q "dotfiles/shell/.bashrc" "$rc_file" 2>/dev/null; then
            echo -e "\n# Load dotfiles config\n$SHELL_SOURCE_LINE" >> "$rc_file"
            write_succ "Đã nạp dotfiles vào $rc_file"
        else
            write_succ "$rc_file đã được cấu hình trước đó."
        fi
    fi
done

# 7.4 PowerShell on Linux (if pwsh exists)
if command -v pwsh >/dev/null 2>&1; then
    PWSH_PROFILE_DIR="$HOME/.config/powershell"
    mkdir -p "$PWSH_PROFILE_DIR"
    PWSH_PROFILE="$PWSH_PROFILE_DIR/Microsoft.PowerShell_profile.ps1"
    PWSH_SOURCE_LINE=". \"$DOTFILES_DIR/powershell/user_profile.ps1\""
    if [ ! -f "$PWSH_PROFILE" ] || ! grep -q "user_profile.ps1" "$PWSH_PROFILE" 2>/dev/null; then
        echo -e "\n# Load dotfiles config\n$PWSH_SOURCE_LINE" >> "$PWSH_PROFILE"
        write_succ "Đã nạp dotfiles vào $PWSH_PROFILE"
    fi
fi

# ------------------------------------------------------------------------------
# Hoàn tất
# ------------------------------------------------------------------------------
echo -e "\n${GREEN}====================================================================${NC}"
echo -e "${GREEN}  🎉 CHÚC MỪNG! BỘ DOTFILES ĐÃ ĐƯỢC THIẾT LẬP THÀNH CÔNG TRÊN LINUX!${NC}"
echo -e "${GREEN}====================================================================${NC}"
echo -e "  👉 Chạy lệnh: ${CYAN}source ~/.bashrc${NC} (hoặc mở lại Terminal) để áp dụng ngay!"
echo -e "  👉 Mở Neovim: ${CYAN}nvim${NC} (NvChad sẽ tự động tải các plugin lần đầu)."
echo -e "${GREEN}====================================================================${NC}\n"

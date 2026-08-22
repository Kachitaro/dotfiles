#!/usr/bin/env bash
# ==============================================================================
# 🚀 Dotfiles One-Command Fast Installer (Linux / macOS)
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.sh | bash
# Or with options:
#   curl -fsSL https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.sh | bash -s -- --full
# ==============================================================================
set -e

# Color definitions
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
NC='\033[0m'

FULL_INSTALL=false
FORCE_INSTALL=false

for arg in "$@"; do
    case "$arg" in
        --full)
            FULL_INSTALL=true
            ;;
        --force)
            FORCE_INSTALL=true
            ;;
    esac
done

echo -e "${MAGENTA}====================================================================${NC}"
echo -e "${MAGENTA}  🚀 KACHITARO DOTFILES CLI BOOTSTRAPPER (Unix)                    ${NC}"
echo -e "${MAGENTA}====================================================================${NC}\n"

# 1. Prepare ~/.local/bin
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
export PATH="$BIN_DIR:$PATH"

DOT_BIN="$BIN_DIR/dot"

# 2. Detect Platform & Download Binary Release
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

TARGET=""
case "$OS" in
    linux)
        case "$ARCH" in
            x86_64) TARGET="x86_64-unknown-linux-gnu" ;;
            aarch64|arm64) TARGET="aarch64-unknown-linux-gnu" ;;
        esac
        ;;
    darwin)
        case "$ARCH" in
            arm64|aarch64) TARGET="aarch64-apple-darwin" ;;
            x86_64) TARGET="x86_64-apple-darwin" ;;
        esac
        ;;
esac

INSTALLED_FROM_RELEASE=false
if [ -n "$TARGET" ]; then
    RELEASE_URL="https://github.com/kachitaro/dotfiles/releases/latest/download/dot-${TARGET}.tar.gz"
    TEMP_TAR="/tmp/dot-${TARGET}.tar.gz"
    echo -e "${CYAN}🔹 Đang tải binary release (${TARGET}) từ GitHub...${NC}"
    if curl -fsSL -o "$TEMP_TAR" "$RELEASE_URL" 2>/dev/null; then
        tar -xzf "$TEMP_TAR" -C "$BIN_DIR" dot 2>/dev/null || tar -xzf "$TEMP_TAR" -C "$BIN_DIR"
        chmod +x "$DOT_BIN"
        rm -f "$TEMP_TAR"
        INSTALLED_FROM_RELEASE=true
        echo -e "  ${GREEN}✅ Đã tải và thiết lập binary 'dot' thành công tại $DOT_BIN${NC}"
    else
        echo -e "  ${YELLOW}⚠️ Không thể tải binary release từ GitHub (có thể chưa phát hành).${NC}"
    fi
fi

if [ "$INSTALLED_FROM_RELEASE" = false ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
    LOCAL_RELEASE="$SCRIPT_DIR/cli/target/release/dot"
    if [ -f "$LOCAL_RELEASE" ]; then
        cp "$LOCAL_RELEASE" "$DOT_BIN"
        chmod +x "$DOT_BIN"
        echo -e "  ${GREEN}✅ Đã dùng binary có sẵn tại $DOT_BIN${NC}"
    elif command -v cargo >/dev/null 2>&1 && [ -f "$SCRIPT_DIR/cli/Cargo.toml" ]; then
        echo -e "${CYAN}🔹 Biên dịch CLI từ mã nguồn qua Cargo...${NC}"
        cargo build --release --manifest-path "$SCRIPT_DIR/cli/Cargo.toml"
        if [ -f "$LOCAL_RELEASE" ]; then
            cp "$LOCAL_RELEASE" "$DOT_BIN"
            chmod +x "$DOT_BIN"
            echo -e "  ${GREEN}✅ Đã biên dịch thành công 'dot' vào $DOT_BIN${NC}"
        fi
    fi
fi

# 3. Handle Full Installation vs Standalone CLI install
if [ "$FULL_INSTALL" = true ]; then
    DOTFILES_DIR="$HOME/.dotfiles"
    if [ ! -d "$DOTFILES_DIR/.git" ]; then
        echo -e "${CYAN}🔹 Đang clone dotfiles repository về $DOTFILES_DIR...${NC}"
        if command -v git >/dev/null 2>&1; then
            mkdir -p "$(dirname "$DOTFILES_DIR")"
            git clone https://github.com/kachitaro/dotfiles.git "$DOTFILES_DIR"
            echo -e "  ${GREEN}✅ Dotfiles đã sẵn sàng tại $DOTFILES_DIR${NC}"
        fi
    fi

    echo -e "${CYAN}🔹 Tiến hành cài đặt toàn bộ công cụ môi trường (apt/brew/pacman, Neovim, WezTerm, Font, Node...)...${NC}"
    if [ -f "$DOTFILES_DIR/scripts/install.sh" ]; then
        INSTALL_ARGS=()
        if [ "$FORCE_INSTALL" = true ]; then INSTALL_ARGS+=("--force"); fi
        bash "$DOTFILES_DIR/scripts/install.sh" "${INSTALL_ARGS[@]}"
    fi
else
    # If running inside an existing dotfiles repo, auto-inject
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
    if [ -f "$SCRIPT_DIR/wezterm/wezterm.lua" ] && [ -x "$DOT_BIN" ]; then
        echo -e "${CYAN}🔹 Đang đồng bộ kho dotfiles hiện tại qua 'dot inject'...${NC}"
        "$DOT_BIN" inject
    fi

    echo -e "\n${GREEN}====================================================================${NC}"
    echo -e "${GREEN}  🎉 ĐÃ CÀI ĐẶT THÀNH CÔNG DOTFILES CLI ('dot')!                   ${NC}"
    echo -e "${GREEN}====================================================================${NC}"
    echo -e "  📍 Vị trí binary: ${CYAN}$DOT_BIN${NC}"
    echo -e "  🛠️ Bạn có thể sử dụng ngay 'dot' cho kho dotfile của riêng mình:"
    echo -e "     - ${CYAN}dot inject${NC}       : Đồng bộ / gắn symlink vào hệ thống"
    echo -e "     - ${CYAN}dot eject${NC}        : Gỡ symlink, khôi phục file thực"
    echo -e "     - ${CYAN}dot add <path>${NC}   : Thu nạp thêm config mới"
    echo -e "     - ${CYAN}dot theme reload${NC} : Biên dịch theme sang Lua, Shell, PS1"
    echo -e "     - ${CYAN}dot theme path${NC}   : Lấy đường dẫn theme động"
    echo -e "     - ${CYAN}dot --help${NC}       : Xem toàn bộ hướng dẫn"
    echo -e "${GREEN}====================================================================${NC}\n"
fi

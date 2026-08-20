#!/usr/bin/env bash
# ==============================================================================
# Dotfiles Uninstaller for Linux / macOS
# ==============================================================================

echo -e "\033[0;31mBắt đầu gỡ cài đặt (Uninstall) Dotfiles...\033[0m"

# 1. Xóa symlinks
echo "Xóa các symlink cấu hình..."
rm -f "$HOME/.config/wezterm"
rm -f "$HOME/.config/nvim"
rm -f "$HOME/.config/starship"
rm -f "$HOME/.local/bin/dot"

# 2. Xóa cấu hình khỏi bashrc / zshrc
echo "Gỡ bỏ cấu hình dotfiles khỏi .bashrc / .zshrc..."
if [ -f "$HOME/.bashrc" ]; then
    sed -i '/# Load dotfiles config/d' "$HOME/.bashrc"
    sed -i '\|dotfiles/shell/.bashrc|d' "$HOME/.bashrc"
fi
if [ -f "$HOME/.zshrc" ]; then
    sed -i '/# Load dotfiles config/d' "$HOME/.zshrc"
    sed -i '\|dotfiles/shell/.bashrc|d' "$HOME/.zshrc"
fi

# 3. Gỡ cấu hình pwsh (Linux)
PWSH_PROFILE="$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1"
if [ -f "$PWSH_PROFILE" ]; then
    sed -i '/# Load dotfiles config/d' "$PWSH_PROFILE"
    sed -i '\|user_profile.ps1|d' "$PWSH_PROFILE"
fi

echo -e "\033[0;32mHoàn tất gỡ cài đặt! Các file gốc/backup (.bak_*) của bạn vẫn được giữ nguyên.\033[0m"

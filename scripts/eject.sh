#!/usr/bin/env bash
set -e
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_APPS=("wezterm" "nvim" "starship" "atuin" "carapace")

echo -e "\033[0;36m🔹 Đang phục hồi (eject) cấu hình về máy thực...\033[0m"

for app in "${CONFIG_APPS[@]}"; do
    target="$HOME/.config/$app"
    source="$DOTFILES_DIR/$app"
    if [ -L "$target" ]; then
        rm -f "$target"
        cp -r "$source" "$target"
        echo -e "  \033[0;32m✅ Đã phục hồi: $app -> $target\033[0m"
    fi
done

# Xóa bin/dot symlink nếu có
if [ -L "$HOME/.local/bin/dot" ]; then
    rm -f "$HOME/.local/bin/dot"
    echo -e "  \033[0;32m✅ Đã gỡ symlink CLI: $HOME/.local/bin/dot\033[0m"
fi

# Gỡ bỏ dòng load dotfiles khỏi .bashrc / .zshrc
echo -e "\033[0;36m🔹 Gỡ bỏ dòng load dotfiles khỏi .bashrc / .zshrc...\033[0m"
if [ -f "$HOME/.bashrc" ]; then
    sed -i '/# Load dotfiles config/d' "$HOME/.bashrc"
    sed -i '\|dotfiles/shell/.bashrc|d' "$HOME/.bashrc"
fi
if [ -f "$HOME/.zshrc" ]; then
    sed -i '/# Load dotfiles config/d' "$HOME/.zshrc"
    sed -i '\|dotfiles/shell/.bashrc|d' "$HOME/.zshrc"
    sed -i '\|dotfiles/shell/.zshrc|d' "$HOME/.zshrc"
fi

# Gỡ dòng load pwsh profile nếu có
PWSH_PROFILE="$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1"
if [ -f "$PWSH_PROFILE" ]; then
    sed -i '/# Load dotfiles config/d' "$PWSH_PROFILE"
    sed -i '\|user_profile.ps1|d' "$PWSH_PROFILE"
fi

echo -e "\n\033[0;32m🎉 Quá trình EJECT hoàn tất! Máy bạn đã độc lập.\033[0m"
echo -e "\033[0;33mGiờ bạn có thể xóa an toàn thư mục: $DOTFILES_DIR\033[0m"

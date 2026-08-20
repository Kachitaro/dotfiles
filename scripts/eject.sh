#!/usr/bin/env bash
set -e
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_APPS=("wezterm" "nvim" "alacritty" "tmux" "starship")

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

echo -e "\n\033[0;32m🎉 Quá trình EJECT hoàn tất! Máy bạn đã độc lập.\033[0m"
echo -e "\033[0;33mGiờ bạn có thể xóa an toàn thư mục: $DOTFILES_DIR\033[0m"

#!/usr/bin/env bash
set -e

TARGET_PATH="$1"
if [ -z "$TARGET_PATH" ]; then
    echo -e "\033[0;31m❌ Vui lòng cung cấp đường dẫn cần thu nạp!\033[0m"
    echo -e "Ví dụ: \033[0;36mdot add ~/.config/alacritty\033[0m"
    exit 1
fi

TARGET_PATH=$(realpath "$TARGET_PATH" 2>/dev/null || echo "$TARGET_PATH")

if [ ! -e "$TARGET_PATH" ]; then
    echo -e "\033[0;31m❌ Đường dẫn không tồn tại: $TARGET_PATH\033[0m"
    exit 1
fi

if [ -L "$TARGET_PATH" ]; then
    echo -e "\033[0;31m❌ Đường dẫn này đã là symlink (đã được quản lý rồi)!\033[0m"
    exit 1
fi

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASENAME=$(basename "$TARGET_PATH")

echo -e "\033[0;36m🔹 Đang thu nạp '$BASENAME' vào kho dotfiles...\033[0m"
mv "$TARGET_PATH" "$DOTFILES_DIR/$BASENAME"
ln -sf "$DOTFILES_DIR/$BASENAME" "$TARGET_PATH"

echo -e "  \033[0;32m✅ Thu nạp thành công!\033[0m"
echo -e "\n\033[1;33m⚠️  LƯU Ý QUAN TRỌNG:\033[0m"
echo -e "Hãy nhớ mở \033[0;36mscripts/install.sh\033[0m và thêm \033[1;32m\"$BASENAME\"\033[0m vào mảng \033[1;35mCONFIG_APPS\033[0m để nó được tự động cài đặt vào lần sau nhé!"

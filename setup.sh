#!/bin/bash

# Cập nhật hệ thống
echo "--- Đang cập nhật hệ thống ---"
sudo apt update && sudo apt upgrade -y

# Cài đặt các công cụ cơ bản
echo "--- Cài đặt Build Essentials, Git, Curl ---"
sudo apt install -y build-essential curl wget git xclip

# Cài đặt Zsh và Oh My Zsh
echo "--- Cài đặt Zsh ---"
sudo apt install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Cài đặt Zsh Plugins (Autosuggestions & Syntax Highlighting)
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Cài đặt NVM (Node Version Manager)
echo "--- Cài đặt NVM ---"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Cài đặt Docker
echo "--- Cài đặt Docker ---"
sudo apt install -y ca-certificates gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER

# Cài đặt các công cụ hiện đại (LazyVim, FZF, Starship)
echo "--- Cài đặt công cụ bổ trợ ---"
sudo apt install -y fzf ripgrep
curl -sS https://starship.rs/install.sh | sh -s -- -y

# Hoàn tất
echo "--- Setup hoàn tất! Hãy khởi động lại máy hoặc terminal ---"
chsh -s $(which zsh)

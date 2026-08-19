# 🛠️ Cross-Platform Dotfiles & Dev Environment (Windows & Linux)

Bộ cấu hình (dotfiles) cá nhân hóa môi trường phát triển trên **Windows 11 / 10** và **Linux / WSL** với **PowerShell 7 / Bash / Zsh**, **WezTerm**, **Neovim (NvChad)** và script tự động hóa cài đặt 1 chạm.

---

## 📑 Mục lục

- [Tổng quan](#-tổng-quan)
- [Cấu trúc thư mục](#-cấu-trúc-thư-mục)
- [Hướng dẫn cài đặt](#-hướng-dẫn-cài-đặt)
  - [1. Dành cho Windows](#1-dành-cho-windows)
  - [2. Dành cho Linux / WSL / macOS](#2-dành-cho-linux--wsl--macos)
- [Các thành phần chính](#-các-thành-phần-chính)
- [Phím tắt & Lệnh tiện ích](#-phím-tắt--lệnh-tiện-ích)

---

## 🌟 Tổng quan

- **Terminal:** [WezTerm](https://wezfurlong.org/wezterm/) (GPU-accelerated, hiển thị RAM realtime mượt mà trên cả Windows & Linux, hỗ trợ chia pane nhanh).
- **Shell:** [PowerShell 7 (`pwsh`)](https://github.com/PowerShell/PowerShell) hoặc **Bash / Zsh** kết hợp với [Oh My Posh](https://ohmyposh.dev/) (theme `zash`), `PSReadLine`, `FZF`, `Terminal-Icons`.
- **Editor:** [Neovim](https://neovim.io/) với nền tảng [NvChad](https://nvchad.com/) v2.5 / v3.0, tích hợp LSP và Formatter (`conform.nvim`).
- **Package Manager:** [Scoop](https://scoop.sh/) (trên Windows) & `apt`/`pacman`/`dnf`/`brew` (trên Linux).

---

## 📂 Cấu trúc thư mục

```text
dotfiles/
├── install.ps1                 # Script cài đặt 1 lệnh cho Windows
├── install.sh                  # Script cài đặt 1 lệnh cho Linux / WSL / macOS
├── nvim/                       # Cấu hình Neovim (NvChad)
│   ├── init.lua
│   ├── lazy-lock.json
│   └── lua/
├── powershell/                 # Cấu hình PowerShell
│   ├── user_profile.ps1        # Profile chính ($PROFILE)
│   └── functions.ps1           # Các hàm & alias tiện ích
├── shell/                      # Cấu hình Bash / Zsh cho Linux
│   └── .bashrc
├── scoop/                      # Scoop config
│   └── config.json
├── wezterm/                    # Cấu hình WezTerm (Cross-platform)
│   ├── wezterm.lua             # Entry point
│   ├── core.lua                # Cấu hình font, phím tắt
│   ├── ui.lua                  # Giao diện, tab bar
│   └── status.lua              # Hiển thị RAM realtime (tương thích Windows & Linux)
└── README.md
```

---

## 🚀 Hướng dẫn cài đặt

### 1. Dành cho Windows

Mở **PowerShell** trên máy mới và dán lệnh duy nhất sau:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force; irm https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.ps1 | iex
```

> **Script tự động:** Cài Scoop, Git, Neovim, Font JetBrainsMono, WezTerm, NVM, Docker, WSL2, tạo Symlink và nạp Profile PowerShell.

---

### 2. Dành cho Linux / WSL / macOS

Mở **Terminal** và chạy lệnh duy nhất sau:

```bash
curl -fsSL https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.sh | bash
```

> **Script tự động:** Cài đặt các công cụ CLI (`neovim`, `ripgrep`, `fd`, `fzf`, `bat`, `eza`), tải Font JetBrainsMono NF, cài `oh-my-posh`, `nvm` (Node 22) và liên kết cấu hình `nvim`, `wezterm`, `bashrc`/`zshrc`.

---

### 3. Chạy trực tiếp từ repo (Nếu đã clone về máy)

- **Windows:** `.\install.ps1`
- **Linux:** `chmod +x ./install.sh && ./install.sh`

> [!IMPORTANT]
> Sau khi cài đặt trên Windows, hãy **khởi động lại máy tính (Restart)** để áp dụng kích hoạt Hyper-V, WSL và Font.
> Trên Linux, hãy chạy `source ~/.bashrc` hoặc mở tab terminal mới.

---

## ⌨️ Phím tắt & Lệnh tiện ích

### WezTerm

| Phím tắt | Thao tác |
| :--- | :--- |
| `Ctrl + Shift + \|` | Chia đôi màn hình theo chiều dọc (Split Horizontal) |
| `Ctrl + Shift + D` | Chia đôi màn hình theo chiều ngang (Split Vertical) |

### PowerShell & FZF

| Phím tắt / Lệnh | Mô tả |
| :--- | :--- |
| `Ctrl + R` | Tìm kiếm lịch sử dòng lệnh tương tác (FZF History) |
| `Ctrl + F` | Tìm kiếm đường dẫn file/thư mục tương tác (FZF Provider) |
| `Ctrl + D` | Xóa ký tự hiện tại (Emacs keybinding) |
| `Get-SystemSizeReport` | Xem bảng phân tích dung lượng ổ đĩa Windows |
| `Get-AppSizeReport` | Liệt kê dung lượng các ứng dụng đang chiếm dụng ổ cứng |
| `ll` / `la` | Liệt kê file với icon & thông tin chi tiết (`eza`) |
| `cd...` / `cd....` | Di chuyển lên 2 / 3 cấp thư mục |

---

## 📜 License

[MIT](LICENSE) © [kachitaro](https://github.com/kachitaro)
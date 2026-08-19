# 🛠️ Windows Dotfiles & Dev Environment

Bộ cấu hình (dotfiles) cá nhân hóa môi trường phát triển trên **Windows 11 / 10** với **PowerShell 7**, **WezTerm**, **Neovim (NvChad)** và script tự động hóa cài đặt bằng **Scoop**.

---

## 📑 Mục lục

- [Tổng quan](#-tổng-quan)
- [Cấu trúc thư mục](#-cấu-trúc-thư-mục)
- [Các thành phần chính](#-các-thành-phần-chính)
  - [1. PowerShell](#1-powershell-shell--utilities)
  - [2. WezTerm](#2-wezterm-terminal-emulator)
  - [3. Neovim](#3-neovim-nvchad)
  - [4. Scoop & Windows Setup](#4-scoop--windows-setup)
- [Hướng dẫn cài đặt](#-hướng-dẫn-cài-đặt)
- [Phím tắt & Lệnh tiện ích](#-phím-tắt--lệnh-tiện-ích)

---

## 🌟 Tổng quan

- **Terminal:** [WezTerm](https://wezfurlong.org/wezterm/) (GPU-accelerated, giao diện tối giản, hiển thị RAM realtime, hỗ trợ chia pane nhanh).
- **Shell:** [PowerShell 7 (`pwsh`)](https://github.com/PowerShell/PowerShell) kết hợp với [Oh My Posh](https://ohmyposh.dev/) (theme `zash`), `PSReadLine`, `PSFzf`, `Terminal-Icons`.
- **Editor:** [Neovim](https://neovim.io/) với nền tảng [NvChad](https://nvchad.com/) v2.5 / v3.0, tích hợp LSP và Formatter (`conform.nvim`).
- **Package Manager:** [Scoop](https://scoop.sh/) quản lý CLI, Dev Tools, Runtime (Node.js/NVM, Java, Python, Flutter, Docker, v.v.).

---

## 📂 Cấu trúc thư mục

```text
dotfiles/
├── nvim/                       # Cấu hình Neovim (NvChad)
│   ├── init.lua
│   ├── lazy-lock.json
│   └── lua/
│       ├── autocmds.lua
│       ├── chadrc.lua          # Tùy biến UI / Theme NvChad (OneDark)
│       ├── mappings.lua        # Key mappings
│       ├── options.lua         # Vim options
│       ├── configs/            # Config chi tiết cho plugins (LSP, Conform, Lazy)
│       └── plugins/            # Danh sách plugin cá nhân
├── powershell/                 # Cấu hình PowerShell
│   ├── set_up_windows.ps1      # Script tự động cài đặt toàn bộ môi trường
│   ├── user_profile.ps1        # Profile chính ($PROFILE)
│   └── functions.ps1           # Các hàm & alias tiện ích (Linux commands, Disk analyzer)
├── scoop/                      # Scoop config
│   └── config.json
├── tglow/                      # Cấu hình tglow (Telegram client CLI)
│   └── config.toml
├── wezterm/                    # Cấu hình WezTerm
│   ├── wezterm.lua             # Entry point
│   ├── core.lua                # Cấu hình font, phím tắt, độ mờ cửa sổ
│   ├── ui.lua                  # Tab bar, màu sắc, thanh cuộn
│   └── status.lua              # Hiển thị RAM status & định dạng tiêu đề tab
└── README.md
```

---

## ⚙️ Các thành phần chính

### 1. PowerShell (Shell & Utilities)

- **Giao diện & Tiện ích:**
  - Font: JetBrainsMono Nerd Font.
  - Theme prompt: Oh My Posh `zash`.
  - Autocomplete & Gợi ý lịch sử lệnh dạng danh sách (`ListView`).
  - Tìm kiếm lịch sử và file mượt mà với `PSFzf` (`Ctrl + R`, `Ctrl + F`).
  - Hỗ trợ đầy đủ UTF-8.

- **Alias quen thuộc từ Linux:**
  - `ls` ➔ `eza`
  - `cat` ➔ `bat`
  - `vim` / `vi` ➔ `nvim`
  - `g` ➔ `git`
  - `touch`, `which`, `grep`, `ll`, `la`, `cd...`, `cd....`

- **Công cụ kiểm tra dung lượng hệ thống:**
  - `Get-SystemSizeReport`: Báo cáo tổng quan dung lượng ổ `C:`, dung lượng Windows, Programs, Users.
  - `Get-AppSizeReport`: Quét và sắp xếp kích thước các ứng dụng cài đặt từ lớn đến nhỏ.

### 2. WezTerm (Terminal Emulator)

- **Modular Configuration:** Chia tách `core`, `ui`, và `status`.
- **Hiệu năng cao:** Tự động cache và cập nhật chỉ số RAM tiêu thụ mỗi 5s qua script tối ưu `pwsh -NoProfile`.
- **Tùy biến UI:**
  - Độ mờ (opacity) `0.75`.
  - Tab bar tùy chỉnh nằm ở cạnh dưới màn hình (`bottom`).
  - Hiển thị tên tiến trình đang chạy trên từng tab.

### 3. Neovim (NvChad)

- Thiết lập nhẹ, khởi động tức thì.
- Theme mặc định: `onedark`.
- Quản lý plugin qua `lazy.nvim`.
- Hỗ trợ format code tự động với `conform.nvim` và cấu hình LSP đa ngôn ngữ.

### 4. Scoop & Windows Setup

File script `powershell/set_up_windows.ps1` tự động hóa:
- Cài đặt **Scoop** và kích hoạt các bucket: `main`, `extras`, `nerd-fonts`, `java`, `nonportable`.
- Cài đặt trọn bộ công cụ:
  - **Dev Tools:** `pwsh`, `wezterm`, `vscode`, `nvm`, `yarn`, `python`, `temurin17-jdk`, `gradle`, `docker`.
  - **Mobile:** `flutter`, `android-studio`, `react-native-cli`, `react-native-windows-init`.
  - **Fonts & Libs:** `JetBrainsMono Nerd Font`, `vcredist-aio`.
- Kích hoạt tính năng ảo hóa: **Hyper-V**, **WSL2** (Ubuntu), **Containers**.

---

## 🚀 Hướng dẫn cài đặt

### Bước 1: Clone kho lưu trữ

Mở PowerShell và clone về thư mục cấu hình hoặc thư mục cá nhân:

```powershell
git clone https://github.com/kachitaro/dotfiles.git D:\work\dotfiles
```

### Bước 2: Cài đặt toàn bộ môi trường (Chạy lần đầu)

Mở PowerShell với quyền User thường và chạy:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
& "D:\work\dotfiles\powershell\set_up_windows.ps1"
```
> [!IMPORTANT]
> Sau khi script hoàn tất, hãy **khởi động lại máy tính (Restart)** để áp dụng kích hoạt Hyper-V, WSL và Docker.

---

### Bước 3: Áp dụng các cấu hình (Symlink / Copy)

#### 1. PowerShell Profile
Thêm dòng sau vào `$PROFILE` của bạn (hoặc tạo symlink):
```powershell
# Mở file profile
notepad $PROFILE

# Thêm nội dung nạp cấu hình từ dotfiles:
. "D:\work\dotfiles\powershell\user_profile.ps1"
```
*Lưu ý: Đảm bảo file `functions.ps1` được liên kết tới `~/.config/powershell/functions.ps1` hoặc đặt đúng đường dẫn.*

#### 2. WezTerm
Tạo symlink hoặc trỏ cấu hình WezTerm:
```powershell
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.wezterm.lua" -Target "D:\work\dotfiles\wezterm\wezterm.lua"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\wezterm" -Target "D:\work\dotfiles\wezterm"
```

#### 3. Neovim
Liên kết thư mục config Neovim:
```powershell
New-Item -ItemType SymbolicLink -Path "$env:LOCALAPPDATA\nvim" -Target "D:\work\dotfiles\nvim"
```

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
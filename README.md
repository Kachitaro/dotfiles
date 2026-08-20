# 🛠️ Cross-Platform Dotfiles & Dev Environment

![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)
![Neovim](https://img.shields.io/badge/Neovim-57A143?style=for-the-badge&logo=neovim&logoColor=white)
[![Ko-fi](https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/anhtai2k)
![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)

Bộ dotfiles cá nhân giúp dựng lại toàn bộ môi trường phát triển trên **Windows 11/10** và **Linux / WSL / macOS** chỉ với một lệnh duy nhất — gồm shell (PowerShell 7 / Bash / Zsh), terminal **WezTerm**, editor **Neovim (NvChad)**, và một CLI quản trị (`dot`) để cài đặt, đồng bộ và gỡ cấu hình an toàn.

---

## 📑 Mục lục

- [Tech Stack](#-tech-stack)
- [Cấu trúc thư mục](#-cấu-trúc-thư-mục)
- [Hướng dẫn cài đặt](#-hướng-dẫn-cài-đặt)
- [Quản lý bằng CLI `dot`](#-quản-lý-hệ-thống-bằng-cli-dot)
- [Theme Engine](#-theme-engine-đồng-bộ-màu-sắc-toàn-hệ-thống)
- [Phím tắt & tiện ích](#-phím-tắt--tiện-ích)
- [Đóng góp / Fork lại cho riêng bạn](#-đóng-góp--fork-lại-cho-riêng-bạn)
- [Ủng hộ / Donate](#-ủng-hộ--donate)
- [License](#-license)

---

## 🌊 Tech Stack

| Thành phần | Công cụ | Vai trò |
| :--- | :--- | :--- |
| Terminal | [WezTerm](https://wezfurlong.org/wezterm/) | Render bằng GPU, cấu hình Lua, hiển thị RAM realtime |
| Core Shell | [PowerShell 7](https://github.com/PowerShell/PowerShell) (Windows) / Bash, Zsh (Linux, macOS) | Shell chính |
| Prompt | [Starship](https://starship.rs/) | Prompt nhanh, viết bằng Rust, context-aware |
| Editor | [Neovim](https://neovim.io/) + [NvChad](https://nvchad.com/) | IDE nhẹ với LSP, Treesitter, format-on-save |
| JS Runtime | [FNM](https://github.com/Schniz/fnm) + [Bun](https://bun.sh/) | Quản lý version Node và chạy JS/TS tốc độ cao |
| CLI hiện đại | `eza`, `bat`, `fzf`, `ripgrep` | Thay thế `ls`, `cat` và tìm kiếm file siêu tốc |

---

## 📂 Cấu trúc thư mục

```text
dotfiles/
├── bin/                     # CLI quản trị `dot`
│   ├── dot                  # Bash entrypoint (Linux/macOS)
│   ├── dot.ps1              # PowerShell entrypoint (Windows)
│   └── dot.cmd              # Windows Batch wrapper
├── install.ps1              # One-liner installer entrypoint (Windows)
├── install.sh               # One-liner installer entrypoint (Linux/macOS)
├── nvim/                    # Cấu hình Neovim (NvChad v2.5)
│   ├── init.lua
│   ├── lazy-lock.json
│   └── lua/
├── powershell/              # Cấu hình PowerShell
│   ├── user_profile.ps1     # Profile chính ($PROFILE)
│   ├── functions.ps1        # Hàm & alias tiện ích
│   └── set_up_windows.ps1   # Thiết lập ban đầu cho Windows
├── scoop/                   # Cấu hình Scoop package manager
│   └── config.json
├── scripts/                 # Script cài đặt / gỡ cài đặt / tiện ích
│   ├── install.sh / install.ps1
│   ├── uninstall.sh / uninstall.ps1
│   ├── add.sh / add.ps1      # Thu nạp config mới vào kho
│   ├── eject.sh / eject.ps1  # Trả config về máy thật (bỏ symlink)
│   └── generate_theme.py     # Trình biên dịch theme
├── shell/                   # Cấu hình Bash cho Linux/macOS
│   └── .bashrc
├── starship/                # Cấu hình prompt
│   └── starship.toml
├── themes/                  # Theme Engine (nguồn sự thật: theme.json)
│   ├── theme.json
│   └── generated/           # File màu đã biên dịch (.lua/.sh/.ps1)
├── wezterm/                 # Cấu hình WezTerm
│   ├── wezterm.lua          # Entry point
│   ├── core.lua             # Font, phím tắt
│   ├── ui.lua                # Giao diện, tab bar
│   └── status.lua            # Hiển thị RAM realtime
└── README.md
```

---

## 🚀 Hướng dẫn cài đặt

### 1. Windows

Mở **PowerShell** và chạy:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
irm https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.ps1 | iex
```

> Script tự động cài Scoop, Git, Neovim, font JetBrainsMono NF, WezTerm, FNM (Node 22), Bun, tạo symlink và nạp profile PowerShell.
> Lệnh `dot` sẽ tự động khả dụng trên toàn hệ thống ngay sau khi cài đặt.

**Các tuỳ chọn cài đặt nâng cao:**
```powershell
# Cài đặt nhẹ (chỉ terminal & core CLI, bỏ qua VSCode và Android/Flutter/Docker)
irm https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.ps1 | iex -ArgumentList "-SkipEditor", "-SkipHeavyApps"
```

| Tham số | Ý nghĩa |
| :--- | :--- |
| `-SkipEditor` | Bỏ qua cài đặt GUI Editor (`VSCode`) |
| `-SkipHeavyApps` | Bỏ qua các stack nặng (`Java JDK 17`, `Gradle`, `Flutter`, `Android Studio`, `Docker`) |
| `-SkipFeatures` | Bỏ qua kích hoạt tính năng ảo hoá Windows (`Hyper-V`, `WSL2`, `Containers`) |
| `-ForceInstall` | Ép ghi đè các cấu hình hiện có, không tạo backup `.bak_*` |

### 2. Linux / WSL / macOS

Mở **Terminal** và chạy:

```bash
curl -fsSL https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.sh | bash
```

> Script tự động cài `neovim`, `ripgrep`, `fd`, `fzf`, `bat`, `eza`, font JetBrainsMono NF, `starship`, `fnm` (Node 22), Bun, và symlink cấu hình `nvim`, `wezterm`, `starship`, `bashrc`/`zshrc`.

### 3. Chạy trực tiếp từ repo đã clone

```bash
# Windows
.\install.ps1
# hoặc dùng dot CLI
.\bin\dot.ps1 install

# Linux/macOS
chmod +x ./install.sh && ./install.sh
```

> [!IMPORTANT]
> Sau khi cài trên Windows, **khởi động lại máy** để áp dụng Hyper-V, WSL và font. Trên Linux/macOS, chạy `source ~/.bashrc` hoặc mở tab terminal mới.

### 4. Cài đè & gỡ cài đặt

| Thao tác | Windows | Linux/macOS |
| :--- | :--- | :--- |
| Cài đè, bỏ qua sao lưu | `.\install.ps1 -ForceInstall` | `./install.sh --force` |
| Gỡ cài đặt (xoá symlink, khôi phục môi trường gốc) | `.\scripts\uninstall.ps1` | `./scripts\uninstall.sh` |

---

## 🧰 Quản lý hệ thống bằng CLI `dot`

Sau khi cài đặt, bạn có sẵn lệnh `dot` để quản lý toàn bộ dotfiles:

```bash
dot install                      # Chạy script cài đặt
dot install -SkipEditor          # Bỏ qua VSCode
dot install -SkipHeavyApps       # Bỏ qua Android/Flutter/Docker/JDK
dot install -ForceInstall        # Ép cài đè, không tạo file .bak
dot add <path>                   # Thu nạp một config mới vào kho (vd: dot add ~/.config/tmux)
dot eject                        # Gỡ symlink, trả file thật về máy (an toàn)
dot uninstall                    # Gỡ cài đặt hoàn toàn
dot theme reload                 # Biên dịch và áp dụng theme mới từ theme.json
dot update                       # Pull bản cập nhật mới nhất từ GitHub
dot help                         # Hiển thị menu trợ giúp
```

---

## 🎨 Theme Engine — đồng bộ màu sắc toàn hệ thống

Toàn bộ màu sắc của Neovim, WezTerm, Starship, Bash và PowerShell được đồng bộ từ **một nguồn sự thật duy nhất**: `themes/theme.json`.

1. Sửa màu trong `themes/theme.json`.
2. Chạy `dot theme reload`.
3. `scripts/generate_theme.py` biên dịch JSON ra `theme.lua`, `theme.sh`, `theme.ps1` trong `themes/generated/`.
4. WezTerm, Neovim và Shell tự động nhận diện vị trí dotfiles động (hỗ trợ mọi đường dẫn clone tuỳ chỉnh hoặc symlink) và áp dụng màu mới ngay lập tức.

Theme mặc định hiện tại: **Catppuccin Mocha**.

---

## ⌨️ Phím tắt & tiện ích

### WezTerm

| Phím tắt | Thao tác |
| :--- | :--- |
| `Ctrl + Shift + \|` | Chia màn hình theo chiều dọc |
| `Ctrl + Shift + D` | Chia màn hình theo chiều ngang |

### PowerShell & FZF

| Phím tắt / Lệnh | Mô tả |
| :--- | :--- |
| `Ctrl + R` | Tìm kiếm lịch sử dòng lệnh (FZF History) |
| `Ctrl + F` | Tìm kiếm đường dẫn file/thư mục (FZF Provider) |
| `Ctrl + D` | Xoá ký tự hiện tại (Emacs keybinding) |
| `Get-SystemSizeReport` | Xem báo cáo dung lượng ổ đĩa Windows |
| `Get-AppSizeReport` | Liệt kê dung lượng các ứng dụng đang chiếm ổ cứng |
| `ll` / `la` | Liệt kê file với icon & chi tiết (`eza`) |
| `cd...` / `cd....` | Di chuyển lên 2 / 3 cấp thư mục |

---

## ☕ Ủng hộ / Donate

Nếu bạn thấy bộ dotfiles này hữu ích, hãy ủng hộ mình một tách cà phê nhé!

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/anhtai2k)

👉 **Ko-fi:** [https://ko-fi.com/anhtai2k](https://ko-fi.com/anhtai2k)

---

## 📜 License

[MIT](LICENSE) © [kachitaro](https://github.com/kachitaro)

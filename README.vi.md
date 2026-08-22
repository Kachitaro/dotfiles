# 🛠️ Bộ Dotfiles & Môi trường phát triển Đa nền tảng

![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)
![Neovim](https://img.shields.io/badge/Neovim-57A143?style=for-the-badge&logo=neovim&logoColor=white)
[![Ko-fi](https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/anhtai2k)
![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)

🌐 **Ngôn ngữ**: [English](README.md) | **Tiếng Việt**

Bộ dotfiles cá nhân được tối ưu hoá cho **PowerShell 7**, **Bash / Zsh**, các công cụ dòng lệnh hiện đại, **WezTerm** GPU terminal emulator, và **Neovim (NvChad)** IDE, được quản lý toàn diện bởi công cụ CLI viết bằng Rust (`k-dot` / `dot`) & **Theme Engine**.

Thiết lập lại toàn bộ môi trường lập trình của bạn trên **Windows 11/10** và **Linux / WSL / macOS** chỉ bằng 1 dòng lệnh duy nhất.

---

## 📸 Hình ảnh giao diện

![Xem trước Terminal & Neovim](assets/showcase.png)

## 📑 Mục lục

- [📸 Hình ảnh giao diện](#-hình-ảnh-giao-diện)
- [🚀 Hướng dẫn cài đặt](#-hướng-dẫn-cài-đặt)
- [🧰 Quản lý bằng CLI `dot`](#-quản-lý-bằng-cli-dot-rust)
- [🎨 Theme Engine (Đồng bộ màu sắc)](#-theme-engine-đồng-bộ-màu-sắc)
- [⌨️ Phím tắt & Tiện ích](#️-phím-tắt--tiện-ích)
- [☕ Ủng hộ / Donate](#-ủng-hộ--donate)
- [📜 Giấy phép](#-giấy-phép)

---

## 🚀 Hướng dẫn cài đặt

### 1. Windows (PowerShell)

Mở **PowerShell** (Khuyến khích Run as Administrator nếu cài đặt toàn diện) và chạy:

```powershell
# ⚡ Cài đặt nhanh: Tự động tải binary dot release & gắn symlink cấu hình ngay lập tức
irm https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.ps1 | iex

# 🚀 Cài đặt máy mới toàn diện: Tự động cài Scoop, Neovim, WezTerm, Font, Node, Tools & ảo hoá
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.ps1))) -Full
```

### 2. Linux / macOS

Mở **Terminal** và chạy:

```bash
# ⚡ Cài đặt nhanh: Tự động tải binary dot release & gắn symlink cấu hình ngay lập tức
curl -fsSL https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.sh | bash

# 🚀 Cài đặt máy mới toàn diện: Tự động cài package hệ thống (apt/brew/pacman), Neovim, WezTerm, Font, Tools
curl -fsSL https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.sh | bash -s -- --full
```

### 3. Chạy trực tiếp từ repo đã clone

```bash
# Windows
.\install.ps1        # hoặc .\install.ps1 -Full

# Linux/macOS
./install.sh         # hoặc ./install.sh --full
```

> [!IMPORTANT]
> Sau khi cài trên Windows, **khởi động lại máy** để áp dụng Hyper-V, WSL và font. Trên Linux/macOS, chạy `source ~/.bashrc` hoặc mở tab terminal mới.

### 4. Cài đè & gỡ cài đặt

| Thao tác                                           | Windows                       | Linux/macOS              |
| :------------------------------------------------- | :---------------------------- | :----------------------- |
| Cài đè, bỏ qua sao lưu                             | `.\install.ps1 -ForceInstall` | `./install.sh --force`   |
| Gỡ cài đặt (xoá symlink, khôi phục môi trường gốc) | `dot uninstall`               | `dot uninstall`          |

---

## 🧰 Quản lý bằng CLI `dot` (Rust)

Công cụ dòng lệnh quản lý (`k-dot` / `dot`) được viết hoàn toàn bằng **Rust** cho tốc độ khởi động siêu nhanh, xử lý đường dẫn / symlink an toàn và không phụ thuộc runtime bên ngoài.

```bash
dot install                      # Chạy script cài đặt hệ thống (Tùy chọn: --force / -ForceInstall)
dot add <path>                   # Thu nạp một config từ ~/.config vào kho (vd: dot add ~/.config/alacritty)
dot eject                        # Gỡ symlink, trả file thực về máy (hoạt động độc lập)
dot inject                       # Đồng bộ / gắn lại symlink và nạp cấu hình dotfiles vào hệ thống (Tùy chọn: --force)
dot uninstall                    # Gỡ cài đặt hoàn toàn
dot theme reload                 # Biên dịch và áp dụng theme mới từ theme.json
dot theme path                   # In ra đường dẫn tuyệt đối của themes/generated (để script lấy path động)
dot --help                       # Hiển thị menu trợ giúp
```

### 🦀 Tự biên dịch CLI từ mã nguồn (Build from source)

Để tự biên dịch binary CLI:

```bash
cd cli
cargo build --release
```

#### Các lệnh build mẫu cho từng nền tảng (Cross-compilation):
- **Windows (MSVC)**: `cargo build --release --target x86_64-pc-windows-msvc`
- **Linux (x86_64)**: `cargo build --release --target x86_64-unknown-linux-gnu`
- **macOS (Apple Silicon)**: `cargo build --release --target aarch64-apple-darwin`

---

## 🎨 Theme Engine (Đồng bộ màu sắc)

Toàn bộ màu sắc của Neovim, WezTerm, Starship, Bash, Zsh và PowerShell được đồng bộ từ **một nguồn sự thật duy nhất**: `themes/theme.json`.

1. Sửa màu trong `themes/theme.json`.
2. Chạy `dot theme reload`.
3. Rust Theme Engine tự động biên dịch JSON trực tiếp ra:
   - `themes/generated/theme.lua` (WezTerm & Neovim)
   - `themes/generated/theme.sh` (Bash & Zsh)
   - `themes/generated/theme.ps1` (PowerShell)
   - `atuin/themes/theme.toml` (Atuin Shell History)
4. WezTerm, Neovim và Shell tự động nhận diện vị trí dotfiles động và áp dụng màu mới ngay lập tức.

Theme mặc định hiện tại: **Catppuccin Mocha**.

---

## ⌨️ Phím tắt & Tiện ích

### WezTerm

| Phím tắt            | Thao tác                       |
| :------------------ | :----------------------------- |
| `Ctrl + Shift + \|` | Chia màn hình theo chiều dọc   |
| `Ctrl + Shift + D`  | Chia màn hình theo chiều ngang |

### Core Shell & Shell Tools

| Phím tắt / Lệnh        | Mô tả                                                                            |
| :--------------------- | :------------------------------------------------------------------------------- |
| `Ctrl + R`             | **Atuin** tìm kiếm lịch sử lệnh tương tác (kèm thời lượng chạy, exit code, ngày) |
| `Ctrl + F`             | **PSFzf / FZF** tìm kiếm tệp và thư mục siêu nhanh                               |
| `Tab`                  | **Carapace** menu auto-complete trực quan đa shell                               |
| `z <thư_mục>`          | **Zoxide** nhảy nhanh đến thư mục thường xuyên sử dụng                           |
| `g`                    | Phím tắt nhanh cho `git`                                                         |
| `ls`, `ll`, `la`, `lt` | **Eza** liệt kê tệp hiện đại (kèm icon, trạng thái git, cây thư mục)             |
| `cat <tệp>`            | **Bat** xem nội dung tệp có highlight cú pháp và số dòng                         |
| `Get-SystemSizeReport` | *(PowerShell)* Báo cáo chi tiết dung lượng các thư mục dev, node_modules và cache |

---

## ☕ Ủng hộ / Donate

Nếu bạn thấy bộ dotfiles này hữu ích, hãy ủng hộ tác giả qua:

- **Ko-fi**: [ko-fi.com/anhtai2k](https://ko-fi.com/anhtai2k)
- **Star repo**: ⭐ Hãy thả 1 sao trên GitHub nhé!

---

## 📜 Giấy phép

Phát hành dưới **Giấy phép MIT**. Xem tệp `LICENSE` để biết thêm chi tiết.

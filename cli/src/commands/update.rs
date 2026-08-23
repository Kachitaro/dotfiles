use anyhow::{bail, Result};
use owo_colors::OwoColorize;
use std::env;
use std::fs;
use std::path::PathBuf;
use std::process::Command;

const CURRENT_VERSION: &str = env!("CARGO_PKG_VERSION");
const REPO: &str = "kachitaro/dotfiles";

pub fn execute() -> Result<()> {
    println!(
        "{}",
        format!("🔹 Đang kiểm tra và tải bản phát hành mới nhất từ GitHub ({}) ...", REPO).cyan()
    );
    println!("  Phiên bản hiện tại: {}", format!("v{}", CURRENT_VERSION).yellow());

    // 1. Xác định vị trí file thực thi hiện tại hoặc ~/.local/bin
    let current_exe = env::current_exe().ok();
    let home_bin = dirs::home_dir().map(|h| {
        #[cfg(windows)]
        { h.join(".local").join("bin").join("dot.exe") }
        #[cfg(unix)]
        { h.join(".local").join("bin").join("dot") }
    });

    let target_dest = if let Some(ref exe) = current_exe {
        if exe.exists() {
            exe.clone()
        } else if let Some(ref h_bin) = home_bin {
            h_bin.clone()
        } else {
            exe.clone()
        }
    } else if let Some(ref h_bin) = home_bin {
        h_bin.clone()
    } else {
        PathBuf::from(if cfg!(windows) { "dot.exe" } else { "dot" })
    };

    if let Some(parent) = target_dest.parent() {
        let _ = fs::create_dir_all(parent);
    }

    // 2. Tải và giải nén bản release tương ứng với OS/Arch
    #[cfg(windows)]
    {
        let url = format!(
            "https://github.com/{}/releases/latest/download/dot-x86_64-pc-windows-msvc.zip",
            REPO
        );
        let temp_dir = env::temp_dir().join("dot_update_extract");
        let temp_zip = env::temp_dir().join("dot_update.zip");

        if temp_dir.exists() {
            let _ = fs::remove_dir_all(&temp_dir);
        }
        if temp_zip.exists() {
            let _ = fs::remove_file(&temp_zip);
        }

        println!("  Đang tải: {}", url.dimmed());

        let ps_script = format!(
            r#"
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
            Invoke-WebRequest -Uri "{url}" -OutFile "{zip}" -UseBasicParsing -TimeoutSec 30
            Expand-Archive -Path "{zip}" -DestinationPath "{ext}" -Force
            "#,
            url = url,
            zip = temp_zip.display(),
            ext = temp_dir.display()
        );

        let status = Command::new("powershell")
            .args(["-NoProfile", "-Command", &ps_script])
            .status()?;

        if !status.success() || !temp_dir.exists() {
            bail!("Không thể tải hoặc giải nén release từ GitHub. Vui lòng kiểm tra kết nối mạng.");
        }

        // Tìm dot.exe đã giải nén
        let extracted_dot = find_extracted_binary(&temp_dir, "dot.exe")?;

        // Trên Windows, để ghi đè file .exe đang chạy, đổi tên file cũ trước
        let old_exe = target_dest.with_extension("exe.old");
        if target_dest.exists() {
            let _ = fs::remove_file(&old_exe);
            fs::rename(&target_dest, &old_exe).ok();
        }

        fs::copy(&extracted_dot, &target_dest)?;
        let _ = fs::remove_file(&old_exe);
        let _ = fs::remove_dir_all(&temp_dir);
        let _ = fs::remove_file(&temp_zip);

        // Đồng bộ thêm vào ~/.local/bin/dot.exe nếu target_dest nằm ở chỗ khác
        if let Some(ref h_bin) = home_bin {
            if h_bin != &target_dest {
                if let Some(p) = h_bin.parent() { let _ = fs::create_dir_all(p); }
                let _ = fs::copy(&target_dest, h_bin);
            }
        }
    }

    #[cfg(unix)]
    {
        let os = std::env::consts::OS;
        let arch = std::env::consts::ARCH;

        let target_triple = match (os, arch) {
            ("linux", "x86_64") => "x86_64-unknown-linux-gnu",
            ("linux", "aarch64") => "aarch64-unknown-linux-gnu",
            ("macos", "aarch64") => "aarch64-apple-darwin",
            ("macos", "x86_64") => "x86_64-apple-darwin",
            _ => bail!("Hệ điều hành hoặc kiến trúc chưa được hỗ trợ tự động: {}-{}", os, arch),
        };

        let url = format!(
            "https://github.com/{}/releases/latest/download/dot-{}.tar.gz",
            REPO, target_triple
        );
        let temp_dir = env::temp_dir().join("dot_update_extract");
        let _ = fs::create_dir_all(&temp_dir);

        println!("  Đang tải: {}", url.dimmed());

        let cmd = format!(
            "curl -fsSL \"{}\" | tar -xz -C \"{}\"",
            url,
            temp_dir.display()
        );

        let status = Command::new("sh").arg("-c").arg(&cmd).status()?;
        if !status.success() {
            bail!("Không thể tải hoặc giải nén release từ GitHub. Vui lòng kiểm tra kết nối mạng.");
        }

        let extracted_dot = find_extracted_binary(&temp_dir, "dot")?;

        fs::copy(&extracted_dot, &target_dest)?;
        let _ = Command::new("chmod").arg("+x").arg(&target_dest).status();
        let _ = fs::remove_dir_all(&temp_dir);

        if let Some(ref h_bin) = home_bin {
            if h_bin != &target_dest {
                if let Some(p) = h_bin.parent() { let _ = fs::create_dir_all(p); }
                let _ = fs::copy(&target_dest, h_bin);
                let _ = Command::new("chmod").arg("+x").arg(h_bin).status();
            }
        }
    }

    println!(
        "{}",
        format!("  ✅ Đã cập nhật binary 'dot' thành công tại: {}", target_dest.display()).green()
    );
    println!("\n{}", "🎉 Cập nhật CLI hoàn tất!".green().bold());

    Ok(())
}

fn find_extracted_binary(dir: &std::path::Path, bin_name: &str) -> Result<PathBuf> {
    if dir.is_dir() {
        for entry in fs::read_dir(dir)? {
            let entry = entry?;
            let path = entry.path();
            if path.is_file() && path.file_name().map(|n| n == bin_name).unwrap_or(false) {
                return Ok(path);
            }
            if path.is_dir() {
                if let Ok(found) = find_extracted_binary(&path, bin_name) {
                    return Ok(found);
                }
            }
        }
    }
    bail!("Không tìm thấy binary '{}' trong file nén release.", bin_name)
}

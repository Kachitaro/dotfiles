use anyhow::{bail, Context, Result};
use owo_colors::OwoColorize;
use std::process::Command;
use std::path::PathBuf;

use crate::paths;
use crate::theme_engine;

pub fn execute() -> Result<()> {
    let dotfiles_dir = paths::resolve_dotfiles_dir()?;

    println!(
        "{}",
        "🔹 Đang cập nhật Dotfiles từ GitHub (git pull)...".cyan()
    );

    let status = Command::new("git")
        .arg("-C")
        .arg(&dotfiles_dir)
        .arg("pull")
        .status()
        .with_context(|| "Không thể thực thi lệnh git pull")?;

    if !status.success() {
        bail!("git pull kết thúc với lỗi (exit code: {:?})", status.code());
    }

    println!("{}", "  ✅ Đã cập nhật mã nguồn dotfiles thành công.".green());

    // Cập nhật Theme
    println!("{}", "🔹 Đang đồng bộ lại Theme Engine...".cyan());
    if let Err(e) = theme_engine::generate_themes(&dotfiles_dir) {
        eprintln!("{}", format!("  ⚠️ Lỗi khi nạp theme: {}", e).yellow());
    } else {
        println!("{}", "  ✅ Đã đồng bộ Theme Engine thành công.".green());
    }

    // Nếu có Cargo, tự động biên dịch bản release mới
    let cargo_toml = dotfiles_dir.join("cli").join("Cargo.toml");
    if cargo_toml.exists() {
        if let Ok(output) = Command::new("cargo").arg("--version").output() {
            if output.status.success() {
                println!("{}", "🔹 Đang biên dịch bản cập nhật mới nhất của Dotfiles CLI...".cyan());
                let build_status = Command::new("cargo")
                    .arg("build")
                    .arg("--release")
                    .arg("--manifest-path")
                    .arg(&cargo_toml)
                    .status();

                if let Ok(st) = build_status {
                    if st.success() {
                        let home_dir = dirs::home_dir().unwrap_or_else(|| PathBuf::from("."));
                        #[cfg(windows)]
                        {
                            let bin_dest = home_dir.join(".local").join("bin").join("dot.exe");
                            let built_src = dotfiles_dir.join("cli").join("target").join("release").join("dot.exe");
                            if built_src.exists() && bin_dest.exists() {
                                let _ = std::fs::copy(&built_src, &bin_dest);
                            }
                        }
                        #[cfg(unix)]
                        {
                            let bin_dest = home_dir.join(".local").join("bin").join("dot");
                            let built_src = dotfiles_dir.join("cli").join("target").join("release").join("dot");
                            if built_src.exists() && bin_dest.exists() {
                                let _ = std::fs::copy(&built_src, &bin_dest);
                            }
                        }
                        println!("{}", "  ✅ Đã cập nhật Dotfiles CLI binary mới nhất.".green());
                    }
                }
            }
        }
    }

    println!("\n{}", "🎉 Quá trình cập nhật hoàn tất!".green());

    Ok(())
}

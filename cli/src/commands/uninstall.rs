use anyhow::Result;
use owo_colors::OwoColorize;
use std::fs;
use std::path::{Path, PathBuf};

use crate::linker::{is_symlink, remove_symlink};

pub fn execute() -> Result<()> {
    println!(
        "{}",
        "Bắt đầu gỡ cài đặt (Uninstall) Dotfiles...".red()
    );
    println!("{}", "Xóa các symlink cấu hình...".cyan());

    let home_dir = dirs::home_dir().unwrap_or_else(|| PathBuf::from("."));

    #[cfg(windows)]
    {
        let local_appdata = dirs::data_local_dir().unwrap_or_else(|| home_dir.join("AppData").join("Local"));
        let config_dir = home_dir.join(".config");

        let app_links = [
            (config_dir.join("wezterm"), true),
            (local_appdata.join("nvim"), true),
            (config_dir.join("nvim"), true),
            (config_dir.join("starship"), true),
            (config_dir.join("atuin"), true),
            (config_dir.join("carapace"), true),
            (config_dir.join("powershell"), true),
            (config_dir.join("scoop"), true),
            (home_dir.join(".wezterm.lua"), false),
        ];

        for (dest, is_dir) in app_links {
            if is_symlink(&dest) {
                let _ = remove_symlink(&dest, is_dir);
                println!(
                    "{}",
                    format!("  Đã xóa: {}", dest.display()).green()
                );
            }
        }

        // Clean PowerShell profile scripts
        clean_powershell_profiles(&home_dir)?;
    }

    #[cfg(unix)]
    {
        let config_dir = home_dir.join(".config");
        let app_links = [
            (config_dir.join("wezterm"), true),
            (config_dir.join("nvim"), true),
            (config_dir.join("starship"), true),
            (config_dir.join("atuin"), true),
            (config_dir.join("carapace"), true),
            (home_dir.join(".local").join("bin").join("dot"), false),
        ];

        for (dest, is_dir) in app_links {
            if is_symlink(&dest) {
                let _ = remove_symlink(&dest, is_dir);
                println!(
                    "{}",
                    format!("  Đã xóa: {}", dest.display()).green()
                );
            }
        }

        // Clean shell profiles
        clean_unix_shell_profiles(&home_dir)?;
    }

    println!(
        "\n{}",
        "Hoàn tất gỡ cài đặt! Các file gốc/backup (.bak_*) của bạn vẫn được giữ nguyên.".green()
    );

    Ok(())
}

#[cfg(windows)]
fn clean_powershell_profiles(home_dir: &Path) -> Result<()> {
    println!("{}", "Gỡ cấu hình khỏi PowerShell Profile...".cyan());

    let doc_dir = dirs::document_dir().unwrap_or_else(|| home_dir.join("Documents"));
    let candidate_profiles = [
        doc_dir.join("PowerShell").join("Microsoft.PowerShell_profile.ps1"),
        doc_dir.join("PowerShell").join("profile.ps1"),
        doc_dir.join("WindowsPowerShell").join("Microsoft.PowerShell_profile.ps1"),
        doc_dir.join("WindowsPowerShell").join("profile.ps1"),
        home_dir.join("Documents").join("PowerShell").join("Microsoft.PowerShell_profile.ps1"),
        home_dir.join("Documents").join("WindowsPowerShell").join("Microsoft.PowerShell_profile.ps1"),
    ];

    for profile in candidate_profiles {
        if profile.is_file() {
            if let Ok(content) = fs::read_to_string(&profile) {
                let cleaned_lines: Vec<&str> = content
                    .lines()
                    .filter(|line| {
                        !line.contains("# Load dotfiles user profile")
                            && !line.contains("user_profile.ps1")
                    })
                    .collect();
                let new_content = cleaned_lines.join("\r\n");
                if new_content != content {
                    fs::write(&profile, new_content)?;
                    println!(
                        "{}",
                        format!("  Đã gỡ cấu hình khỏi: {}", profile.display()).green()
                    );
                }
            }
        }
    }

    Ok(())
}

#[cfg(unix)]
fn clean_unix_shell_profiles(home_dir: &Path) -> Result<()> {
    println!("{}", "Gỡ bỏ cấu hình dotfiles khỏi shell profile...".cyan());

    let shell_profiles = [
        home_dir.join(".bashrc"),
        home_dir.join(".zshrc"),
        home_dir.join(".config").join("powershell").join("Microsoft.PowerShell_profile.ps1"),
    ];

    for profile in shell_profiles {
        if profile.is_file() {
            if let Ok(content) = fs::read_to_string(&profile) {
                let cleaned_lines: Vec<&str> = content
                    .lines()
                    .filter(|line| {
                        !line.contains("# Load dotfiles config")
                            && !line.contains("dotfiles/shell/.bashrc")
                            && !line.contains("dotfiles/shell/.zshrc")
                            && !line.contains("user_profile.ps1")
                    })
                    .collect();
                let new_content = cleaned_lines.join("\n");
                if new_content != content {
                    fs::write(&profile, new_content)?;
                    println!(
                        "{}",
                        format!("  Đã gỡ cấu hình khỏi: {}", profile.display()).green()
                    );
                }
            }
        }
    }

    Ok(())
}

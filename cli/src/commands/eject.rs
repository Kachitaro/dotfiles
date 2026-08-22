use anyhow::Result;
use owo_colors::OwoColorize;
use std::fs;
use std::path::{Path, PathBuf};

use crate::linker::{copy_dir_all, is_symlink, remove_symlink};
use crate::paths;

pub fn execute() -> Result<()> {
    let dotfiles_dir = paths::resolve_dotfiles_dir()?;
    println!(
        "{}",
        "🔹 Đang phục hồi (eject) cấu hình về máy thực...".cyan()
    );

    let home_dir = dirs::home_dir().unwrap_or_else(|| PathBuf::from("."));

    #[cfg(windows)]
    {
        let local_appdata = dirs::data_local_dir().unwrap_or_else(|| home_dir.join("AppData").join("Local"));
        let config_dir = home_dir.join(".config");

        let app_configs = [
            ("wezterm", config_dir.join("wezterm"), true),
            ("nvim", local_appdata.join("nvim"), true),
            ("starship", config_dir.join("starship"), true),
            ("atuin", config_dir.join("atuin"), true),
            ("carapace", config_dir.join("carapace"), true),
            ("powershell", config_dir.join("powershell"), true),
            ("scoop", config_dir.join("scoop"), true),
            ("nvim (config)", config_dir.join("nvim"), true),
        ];

        for (name, dest, is_dir) in app_configs {
            let src_name = if name == "nvim (config)" { "nvim" } else { name };
            let src = dotfiles_dir.join(src_name);
            restore_app_if_symlinked(&src, &dest, is_dir, name)?;
        }

        // Special: ~/.wezterm.lua file
        let wz_file_dest = home_dir.join(".wezterm.lua");
        let wz_file_src = dotfiles_dir.join("wezterm").join("wezterm.lua");
        restore_app_if_symlinked(&wz_file_src, &wz_file_dest, false, "wezterm.lua")?;

        // Clean PowerShell profile scripts
        clean_powershell_profiles(&home_dir)?;
    }

    #[cfg(unix)]
    {
        let config_dir = home_dir.join(".config");
        let app_configs = [
            ("wezterm", config_dir.join("wezterm"), true),
            ("nvim", config_dir.join("nvim"), true),
            ("starship", config_dir.join("starship"), true),
            ("atuin", config_dir.join("atuin"), true),
            ("carapace", config_dir.join("carapace"), true),
        ];

        for (name, dest, is_dir) in app_configs {
            let src = dotfiles_dir.join(name);
            restore_app_if_symlinked(&src, &dest, is_dir, name)?;
        }

        // Remove CLI symlink if present
        let cli_symlink = home_dir.join(".local").join("bin").join("dot");
        if is_symlink(&cli_symlink) {
            let _ = remove_symlink(&cli_symlink, false);
            println!(
                "{}",
                format!("  ✅ Đã gỡ symlink CLI: {}", cli_symlink.display()).green()
            );
        }

        // Clean bashrc, zshrc, pwsh
        clean_unix_shell_profiles(&home_dir)?;
    }

    println!(
        "\n{}",
        "🎉 Quá trình EJECT hoàn tất! Máy bạn đã độc lập.".green()
    );
    println!(
        "{}",
        format!(
            "Giờ bạn có thể xóa an toàn thư mục: {}",
            dotfiles_dir.display()
        )
        .yellow()
    );

    Ok(())
}

fn restore_app_if_symlinked(src: &Path, dest: &Path, is_dir: bool, name: &str) -> Result<()> {
    if is_symlink(dest) {
        remove_symlink(dest, is_dir)?;
        if src.exists() {
            if is_dir {
                copy_dir_all(src, dest)?;
            } else {
                fs::copy(src, dest)?;
            }
            println!(
                "{}",
                format!("  ✅ Đã phục hồi: {} -> {}", name, dest.display()).green()
            );
        }
    }
    Ok(())
}

#[cfg(windows)]
fn clean_powershell_profiles(home_dir: &Path) -> Result<()> {
    println!(
        "{}",
        "\n🔹 Gỡ cấu hình khỏi PowerShell Profile...".cyan()
    );

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
                        format!("  ✅ Đã gỡ cấu hình khỏi: {}", profile.display()).green()
                    );
                }
            }
        }
    }

    Ok(())
}

#[cfg(unix)]
fn clean_unix_shell_profiles(home_dir: &Path) -> Result<()> {
    println!(
        "{}",
        "\n🔹 Gỡ bỏ dòng load dotfiles khỏi shell profile...".cyan()
    );

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
                        format!("  ✅ Đã gỡ cấu hình khỏi: {}", profile.display()).green()
                    );
                }
            }
        }
    }

    Ok(())
}

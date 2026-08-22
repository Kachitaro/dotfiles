use anyhow::{bail, Context, Result};
use owo_colors::OwoColorize;
use std::process::Command;

use crate::paths;

pub fn execute() -> Result<()> {
    let dotfiles_dir = paths::resolve_dotfiles_dir()?;

    println!(
        "{}",
        "Đang cập nhật Dotfiles từ GitHub...".cyan()
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

    Ok(())
}

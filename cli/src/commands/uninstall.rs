use anyhow::{bail, Context, Result};
use std::process::Command;

use crate::paths;

pub fn execute() -> Result<()> {
    let dotfiles_dir = paths::resolve_dotfiles_dir()?;

    #[cfg(windows)]
    {
        let script_path = dotfiles_dir.join("scripts").join("uninstall.ps1");
        if !script_path.exists() {
            bail!("Không tìm thấy script gỡ cài đặt: {}", script_path.display());
        }

        let ps_cmd = if Command::new("pwsh").arg("-v").output().is_ok() {
            "pwsh"
        } else {
            "powershell"
        };

        let status = Command::new(ps_cmd)
            .arg("-ExecutionPolicy")
            .arg("Bypass")
            .arg("-File")
            .arg(&script_path)
            .status()
            .with_context(|| format!("Không thể thực thi script gỡ cài đặt bằng {}", ps_cmd))?;

        if !status.success() {
            bail!("Script gỡ cài đặt kết thúc với lỗi (exit code: {:?})", status.code());
        }
    }

    #[cfg(unix)]
    {
        let script_path = dotfiles_dir.join("scripts").join("uninstall.sh");
        if !script_path.exists() {
            bail!("Không tìm thấy script gỡ cài đặt: {}", script_path.display());
        }

        let status = Command::new("bash")
            .arg(&script_path)
            .status()
            .with_context(|| "Không thể thực thi script gỡ cài đặt bằng bash")?;

        if !status.success() {
            bail!("Script gỡ cài đặt kết thúc với lỗi (exit code: {:?})", status.code());
        }
    }

    Ok(())
}

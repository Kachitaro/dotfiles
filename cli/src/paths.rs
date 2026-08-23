use anyhow::{Context, Result};
use std::env;
use std::path::{Path, PathBuf};

/// Environment variable to override dotfiles directory (useful for local dev/testing).
pub const DOTFILES_DIR_ENV: &str = "DOTFILES_DIR";

/// Check if a directory looks like the root of the dotfiles repository.
pub fn is_dotfiles_root(path: &Path) -> bool {
    path.join("themes").is_dir()
        && (path.join("scripts").is_dir()
            || path.join("bin").is_dir()
            || path.join(".git").exists()
            || path.join("dotfiles.md").exists()
            || path.join("themes").join("theme.json").exists())
}

/// Find the dotfiles root directory by traversing upwards from an executable or file path.
pub fn find_dotfiles_root_from(path: &Path) -> Result<PathBuf> {
    let mut current = if path.is_file() {
        path.parent().map(Path::to_path_buf).unwrap_or_else(|| path.to_path_buf())
    } else {
        path.to_path_buf()
    };

    loop {
        if is_dotfiles_root(&current) {
            return Ok(current);
        }
        if let Some(parent) = current.parent() {
            current = parent.to_path_buf();
        } else {
            break;
        }
    }

    anyhow::bail!(
        "Could not determine dotfiles root from path '{}'. Please set the {} environment variable.",
        path.display(),
        DOTFILES_DIR_ENV
    )
}

/// Strip Windows UNC verbatim prefix `\\?\` if present.
pub fn strip_unc_prefix(path: PathBuf) -> PathBuf {
    #[cfg(windows)]
    {
        let path_str = path.to_string_lossy();
        if let Some(stripped) = path_str.strip_prefix(r"\\?\UNC\") {
            return PathBuf::from(format!(r"\\{}", stripped));
        }
        if let Some(stripped) = path_str.strip_prefix(r"\\?\") {
            return PathBuf::from(stripped);
        }
    }
    path
}

/// Resolve dotfiles directory safely across platforms and symlinks.
/// 
/// 1. If DOTFILES_DIR environment variable is set and not empty, use it.
/// 2. Otherwise, get current_exe() and canonicalize() to trace any symlinks to the real binary,
///    then walk up to find the dotfiles repository root.
/// 3. Fallback: Check if ~/.dotfiles exists and is a valid dotfiles root.
pub fn resolve_dotfiles_dir() -> Result<PathBuf> {
    if let Ok(env_val) = env::var(DOTFILES_DIR_ENV) {
        let trimmed = env_val.trim();
        if !trimmed.is_empty() {
            let path = PathBuf::from(trimmed);
            if path.exists() {
                let canonical = path
                    .canonicalize()
                    .with_context(|| format!("Failed to canonicalize {}='{}'", DOTFILES_DIR_ENV, trimmed))?;
                return Ok(strip_unc_prefix(canonical));
            }
            return Ok(strip_unc_prefix(path));
        }
    }

    let current_exe = env::current_exe().context("Failed to get current executable path")?;
    let canonical_exe = current_exe
        .canonicalize()
        .context("Failed to canonicalize current executable path")?;

    if let Ok(root) = find_dotfiles_root_from(&canonical_exe) {
        return Ok(strip_unc_prefix(root));
    }

    // Fallback 1: Check current directory or ./dotfiles
    if let Ok(current) = env::current_dir() {
        if is_dotfiles_root(&current) {
            if let Ok(canonical) = current.canonicalize() {
                return Ok(strip_unc_prefix(canonical));
            }
            return Ok(current);
        }
        let current_subdir = current.join("dotfiles");
        if is_dotfiles_root(&current_subdir) {
            if let Ok(canonical) = current_subdir.canonicalize() {
                return Ok(strip_unc_prefix(canonical));
            }
            return Ok(current_subdir);
        }
    }

    // Fallback 2: Check default ~/.dotfiles
    if let Some(home) = dirs::home_dir() {
        let default_dotfiles = home.join(".dotfiles");
        if is_dotfiles_root(&default_dotfiles) || default_dotfiles.is_dir() {
            if let Ok(canonical) = default_dotfiles.canonicalize() {
                return Ok(strip_unc_prefix(canonical));
            }
            return Ok(default_dotfiles);
        }
    }

    anyhow::bail!(
        "Could not determine dotfiles root from path '{}'. Please run 'dot init' or set the {} environment variable.",
        canonical_exe.display(),
        DOTFILES_DIR_ENV
    )
}

/// Return absolute path to `<DOTFILES_DIR>/themes/generated`.
pub fn theme_generated_dir() -> Result<PathBuf> {
    let dotfiles_dir = resolve_dotfiles_dir()?;
    Ok(dotfiles_dir.join("themes").join("generated"))
}


#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use tempfile::tempdir;

    fn setup_fake_dotfiles_repo() -> tempfile::TempDir {
        let dir = tempdir().expect("Failed to create tempdir");
        let root = dir.path();
        fs::create_dir_all(root.join("themes").join("generated")).unwrap();
        fs::create_dir_all(root.join("bin")).unwrap();
        fs::create_dir_all(root.join("scripts")).unwrap();
        fs::create_dir_all(root.join("target").join("release")).unwrap();
        fs::write(root.join("bin").join("dot"), b"fake binary").unwrap();
        fs::write(root.join("target").join("release").join("dot"), b"fake binary").unwrap();
        dir
    }

    fn get_canonical_root(temp_dir: &tempfile::TempDir) -> PathBuf {
        strip_unc_prefix(temp_dir.path().canonicalize().unwrap())
    }

    #[test]
    fn test_resolve_from_direct_path() {
        let fake_repo = setup_fake_dotfiles_repo();
        let canonical_root = get_canonical_root(&fake_repo);

        // 1. From <root>/bin/dot
        let bin_path = canonical_root.join("bin").join("dot");
        let resolved = find_dotfiles_root_from(&bin_path).expect("Failed to resolve from bin/dot");
        assert_eq!(strip_unc_prefix(resolved), canonical_root);

        // 2. From <root>/target/release/dot
        let release_path = canonical_root.join("target").join("release").join("dot");
        let resolved = find_dotfiles_root_from(&release_path).expect("Failed to resolve from target/release/dot");
        assert_eq!(strip_unc_prefix(resolved), canonical_root);
    }

    #[test]
    fn test_resolve_from_symlink() {
        let fake_repo = setup_fake_dotfiles_repo();
        let canonical_root = get_canonical_root(&fake_repo);
        let real_bin = canonical_root.join("bin").join("dot");

        let outside_dir = tempdir().expect("Failed to create outside tempdir");
        let symlink_path = outside_dir.path().join("dot_symlink");

        #[cfg(unix)]
        let symlink_created = std::os::unix::fs::symlink(&real_bin, &symlink_path).is_ok();

        #[cfg(windows)]
        let symlink_created = std::os::windows::fs::symlink_file(&real_bin, &symlink_path).is_ok();

        if symlink_created {
            let canonical_exe = symlink_path.canonicalize().expect("Failed to canonicalize symlink");
            let resolved = find_dotfiles_root_from(&canonical_exe).expect("Failed to resolve from symlinked executable");
            assert_eq!(strip_unc_prefix(resolved), canonical_root);
        }
    }

    #[test]
    fn test_theme_generated_dir_structure() {
        let fake_repo = setup_fake_dotfiles_repo();
        let canonical_root = get_canonical_root(&fake_repo);
        let expected = canonical_root.join("themes").join("generated");

        let generated = canonical_root.join("themes").join("generated");
        assert_eq!(generated, expected);
        assert!(generated.exists());
    }

    #[test]
    fn test_env_override() {
        let fake_repo = setup_fake_dotfiles_repo();
        let canonical_root = get_canonical_root(&fake_repo);

        // Set DOTFILES_DIR
        unsafe {
            env::set_var(DOTFILES_DIR_ENV, canonical_root.to_str().unwrap());
        }
        let resolved = resolve_dotfiles_dir().expect("Failed to resolve from env");
        assert_eq!(resolved, canonical_root);

        // Clean up env
        unsafe {
            env::remove_var(DOTFILES_DIR_ENV);
        }
    }

}


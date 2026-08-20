#!/usr/bin/env bash
# ==============================================================================
# 🚀 Linux / macOS Dotfiles & Dev Environment One-Command Installer
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/kachitaro/dotfiles/main/install.sh | bash
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/scripts/install.sh" ]; then
    exec bash "$SCRIPT_DIR/scripts/install.sh" "$@"
else
    exec bash -c "$(curl -fsSL https://raw.githubusercontent.com/kachitaro/dotfiles/main/scripts/install.sh)" -- "$@"
fi

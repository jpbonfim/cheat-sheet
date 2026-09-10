#!/usr/bin/env bash
# ==============================================================================
# cheat-sheet installer
# Installs cheat-sheet executable and starter cheatsheets
# ==============================================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_BIN_DIR="${INSTALL_BIN_DIR:-$HOME/.local/bin}"
CHEAT_SHEETS_DIR="${CHEAT_SHEETS_DIR:-$HOME/.cheat-sheet/sheets}"

info() {
    printf "\033[1;34m==>\033[0m %s\n" "$1"
}

success() {
    printf "\033[1;32m==>\033[0m %s\n" "$1"
}

warn() {
    printf "\033[1;33m==>\033[0m %s\n" "$1"
}

# 1. Install binary
info "Installing cheat-sheet binary to ${INSTALL_BIN_DIR}..."
mkdir -p "${INSTALL_BIN_DIR}"
ln -sf "${REPO_DIR}/bin/cheat-sheet" "${INSTALL_BIN_DIR}/cheat-sheet"
chmod +x "${REPO_DIR}/bin/cheat-sheet"
success "Symlinked ${INSTALL_BIN_DIR}/cheat-sheet -> ${REPO_DIR}/bin/cheat-sheet"

# Check if INSTALL_BIN_DIR is in PATH
if [[ ":$PATH:" != *":${INSTALL_BIN_DIR}:"* ]]; then
    warn "${INSTALL_BIN_DIR} is not currently in your PATH."
    warn "Add this to your ~/.bashrc or ~/.zshrc:"
    warn "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# 2. Copy starter sheets
info "Setting up custom cheatsheets directory in ${CHEAT_SHEETS_DIR}..."
mkdir -p "${CHEAT_SHEETS_DIR}"
if [[ -d "${REPO_DIR}/sheets" ]]; then
    for sheet in "${REPO_DIR}/sheets/"*.txt; do
        if [[ -f "$sheet" ]]; then
            dest="${CHEAT_SHEETS_DIR}/$(basename "$sheet")"
            if [[ ! -f "$dest" ]]; then
                cp "$sheet" "$dest"
                info "Installed starter cheatsheet: $(basename "$sheet")"
            else
                info "Existing sheet preserved: $(basename "$sheet")"
            fi
        fi
    done
fi
success "Cheatsheets ready at ${CHEAT_SHEETS_DIR}"

# 3. Print integration instructions
printf "\n"
success "Installation completed successfully!"
printf "\n"
info "Optional Shell & Tmux Integrations:"
printf "\n"
printf "  \033[1m1. Zsh Keybinding (Alt + /):\033[0m\n"
printf "     Add this to your ~/.zshrc:\n"
printf "       source \"%s/shell/cheat-sheet.zsh\"\n\n" "${REPO_DIR}"
printf "  \033[1m2. Bash Keybinding (Alt + /):\033[0m\n"
printf "     Add this to your ~/.bashrc:\n"
printf "       source \"%s/shell/cheat-sheet.bash\"\n\n" "${REPO_DIR}"
printf "  \033[1m3. Tmux Integration (optional sidebar):\033[0m\n"
printf "     Add this to your ~/.tmux.conf:\n"
printf "       bind-key i run-shell \"%s/tmux/toggle-cheat-sheet.sh\"\n\n" "${REPO_DIR}"
printf "Run 'cheat-sheet --help' or simply 'cheat-sheet' to get started!\n"

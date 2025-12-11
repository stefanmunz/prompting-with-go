#!/bin/bash
#
# bootstrap.sh
# Bootstrap script for prompting-with-go on a fresh Mac
#
# Prerequisites:
#   Xcode Command Line Tools must be installed first:
#   xcode-select --install
#
# This script:
# 1. Checks for Xcode CLT (exits with instructions if missing)
# 2. Installs Homebrew (if not present)
# 3. Installs git via Homebrew (if not present)
# 4. Clones the prompting-with-go repository
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/stefanmunz/prompting-with-go/main/bootstrap.sh | bash
#
# Exit codes:
#   0 - Success
#   1 - General error
#   2 - Homebrew installation failed
#   3 - Git installation failed
#   4 - Clone failed
#   5 - Xcode CLT not installed

set -e

# Configuration
REPO_URL="https://github.com/stefanmunz/prompting-with-go.git"
INSTALL_DIR="$HOME/prompting-with-go"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

error_exit() {
    log_error "$1"
    exit "${2:-1}"
}

# Check for Xcode Command Line Tools
check_xcode_clt() {
    if ! xcode-select -p &> /dev/null; then
        echo ""
        log_error "Xcode Command Line Tools are not installed."
        echo ""
        log_info "Please install them first by running:"
        echo ""
        echo "    xcode-select --install"
        echo ""
        log_info "Wait for the installation to complete, then run this script again."
        echo ""
        exit 5
    fi
    log_info "Xcode Command Line Tools found: $(xcode-select -p)"
}

# Install Homebrew
install_homebrew() {
    if command -v brew &> /dev/null; then
        log_info "Homebrew already installed: $(brew --version | head -1)"
        return 0
    fi

    log_info "Installing Homebrew..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        log_info "Homebrew installed successfully"

        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        if ! command -v brew &> /dev/null; then
            error_exit "Homebrew installed but not found in PATH. Please restart your terminal and run this script again." 2
        fi
    else
        error_exit "Failed to install Homebrew" 2
    fi
}

# Install git via Homebrew
install_git() {
    # Determine Homebrew prefix
    local brew_prefix
    if [[ -d /opt/homebrew ]]; then
        brew_prefix="/opt/homebrew"
    else
        brew_prefix="/usr/local"
    fi

    # Check if Homebrew git is already installed
    if [[ -x "$brew_prefix/bin/git" ]]; then
        log_info "Homebrew git already installed: $($brew_prefix/bin/git --version)"
        return 0
    fi

    # Install git via Homebrew (even if Xcode CLT git exists)
    log_info "Installing git via Homebrew..."
    if brew install git; then
        log_info "Git installed successfully: $($brew_prefix/bin/git --version)"
    else
        error_exit "Failed to install git" 3
    fi
}

# Clone the repository
clone_repo() {
    if [[ -d "$INSTALL_DIR" ]]; then
        log_warn "Directory $INSTALL_DIR already exists"
        log_info "Pulling latest changes..."
        if (cd "$INSTALL_DIR" && git pull); then
            log_info "Repository updated"
        else
            log_warn "Could not pull, directory may not be a git repo"
        fi
        return 0
    fi

    log_info "Cloning prompting-with-go to $INSTALL_DIR..."
    if git clone "$REPO_URL" "$INSTALL_DIR"; then
        log_info "Repository cloned successfully"
    else
        error_exit "Failed to clone repository" 4
    fi
}

# Main
main() {
    echo ""
    echo "========================================"
    echo "  prompting-with-go Bootstrap Script"
    echo "========================================"
    echo ""

    check_xcode_clt
    install_homebrew
    install_git
    clone_repo

    echo ""
    log_info "========================================="
    log_info "Bootstrap completed successfully!"
    log_info "========================================="
    echo ""
    log_info "Repository cloned to: $INSTALL_DIR"
    echo ""

    # Check if Homebrew PATH setup is needed
    local brew_prefix
    if [[ -d /opt/homebrew ]]; then
        brew_prefix="/opt/homebrew"
    else
        brew_prefix="/usr/local"
    fi

    # Remind user to add Homebrew to PATH if not in their shell config
    if ! grep -q 'brew shellenv' ~/.bash_profile 2>/dev/null && ! grep -q 'brew shellenv' ~/.zprofile 2>/dev/null && ! grep -q 'brew shellenv' ~/.zshrc 2>/dev/null; then
        log_warn "Add Homebrew to your PATH by running:"
        echo ""
        echo "    echo 'eval \"\$($brew_prefix/bin/brew shellenv)\"' >> ~/.bash_profile"
        echo "    eval \"\$($brew_prefix/bin/brew shellenv)\""
        echo ""
    fi

    log_info "Next steps:"
    log_info "  1. Install Claude Code: https://docs.anthropic.com/en/docs/claude-code"
    log_info "  2. Run the setup skill: cd $INSTALL_DIR && claude"
    log_info "     Then type: /setup-go-env"
    echo ""
}

main

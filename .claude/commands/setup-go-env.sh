#!/bin/bash
#
# setup-go-env.sh
# Accompanying script for the setup-go-env Claude skill
#
# This script:
# - Optionally installs mise (if --install-mise is passed)
# - Optionally installs Go globally via mise (if --install-go is passed)
# - Creates two example Go projects with different Go versions (1.24 and 1.25)
#
# Exit codes:
#   0 - Success
#   1 - General error
#   2 - mise installation failed
#   3 - Go installation failed
#   4 - Project setup failed

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Error handler
error_exit() {
    log_error "$1"
    exit "${2:-1}"
}

# Parse arguments
INSTALL_MISE=false
INSTALL_GO=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --install-mise)
            INSTALL_MISE=true
            shift
            ;;
        --install-go)
            INSTALL_GO=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --install-mise    Install mise if not present"
            echo "  --install-go      Install Go globally via mise"
            echo "  --help            Show this help message"
            exit 0
            ;;
        *)
            log_warn "Unknown option: $1"
            shift
            ;;
    esac
done

# Function to install mise
install_mise() {
    log_info "Installing mise..."

    if curl -fsSL https://mise.run | sh; then
        log_info "mise installed successfully"

        # Add mise to PATH for this session
        export PATH="$HOME/.local/bin:$PATH"

        # Activate mise for this shell session
        eval "$(~/.local/bin/mise activate bash 2>/dev/null || true)"

        # Verify installation
        if command -v mise &> /dev/null; then
            log_info "mise is now available: $(mise --version)"
        else
            # Try direct path
            if ~/.local/bin/mise --version &> /dev/null; then
                log_info "mise installed at ~/.local/bin/mise: $(~/.local/bin/mise --version)"
                alias mise="$HOME/.local/bin/mise"
            else
                error_exit "mise installation succeeded but binary not found in PATH" 2
            fi
        fi
    else
        error_exit "Failed to install mise" 2
    fi
}

# Function to install Go globally via mise
install_go() {
    log_info "Installing Go globally via mise..."

    # Determine mise command path
    local mise_cmd="mise"
    if ! command -v mise &> /dev/null; then
        if [ -x "$HOME/.local/bin/mise" ]; then
            mise_cmd="$HOME/.local/bin/mise"
        else
            error_exit "mise not found. Please install mise first with --install-mise" 3
        fi
    fi

    # Install Go 1.24 globally
    log_info "Installing Go 1.24 globally..."
    if ! $mise_cmd use --global go@1.24; then
        error_exit "Failed to install Go 1.24" 3
    fi

    # Install Go 1.25 globally (this makes both versions available)
    log_info "Installing Go 1.25 globally..."
    if ! $mise_cmd use --global go@1.25; then
        error_exit "Failed to install Go 1.25" 3
    fi

    log_info "Go versions installed successfully"
}

# Function to create a Go project
create_go_project() {
    local project_name="$1"
    local go_version="$2"
    local project_path="$PROJECT_DIR/$project_name"

    log_info "Creating project: $project_name with Go $go_version"

    # Create project directory
    if ! mkdir -p "$project_path"; then
        error_exit "Failed to create directory: $project_path" 4
    fi

    # Create .tool-versions file
    if ! echo "go $go_version" > "$project_path/.tool-versions"; then
        error_exit "Failed to create .tool-versions in $project_path" 4
    fi

    # Create main.go
    cat > "$project_path/main.go" << 'GOEOF'
package main

import (
	"fmt"
	"runtime"
)

func main() {
	fmt.Printf("I am built with Go %s\n", runtime.Version())
}
GOEOF

    if [ $? -ne 0 ]; then
        error_exit "Failed to create main.go in $project_path" 4
    fi

    # Determine mise command path
    local mise_cmd="mise"
    if ! command -v mise &> /dev/null; then
        if [ -x "$HOME/.local/bin/mise" ]; then
            mise_cmd="$HOME/.local/bin/mise"
        fi
    fi

    # Install the specific Go version for this project
    log_info "Ensuring Go $go_version is installed for $project_name..."
    (cd "$project_path" && $mise_cmd install)

    if [ $? -ne 0 ]; then
        log_warn "mise install in $project_path returned non-zero, but continuing..."
    fi

    log_info "Project $project_name created successfully"
}

# Main execution
main() {
    log_info "Starting Go environment setup..."
    log_info "Project directory: $PROJECT_DIR"

    # Install mise if requested
    if [ "$INSTALL_MISE" = true ]; then
        install_mise
    fi

    # Install Go if requested
    if [ "$INSTALL_GO" = true ]; then
        install_go
    fi

    # Create the two Go projects
    create_go_project "go124-project" "1.24"
    create_go_project "go125-project" "1.25"

    log_info "========================================="
    log_info "Setup completed successfully!"
    log_info "========================================="
    log_info ""
    log_info "Created projects:"
    log_info "  - $PROJECT_DIR/go124-project (Go 1.24)"
    log_info "  - $PROJECT_DIR/go125-project (Go 1.25)"
    log_info ""
    log_info "To verify, run:"
    log_info "  cd $PROJECT_DIR/go124-project && mise exec -- go run main.go"
    log_info "  cd $PROJECT_DIR/go125-project && mise exec -- go run main.go"

    exit 0
}

main

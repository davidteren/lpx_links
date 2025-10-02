#!/bin/bash
# aria2 Installation Script for macOS
# Installs bundled aria2 binary without requiring Homebrew
#
# Supports macOS 12+ (Monterey, Ventura, Sonoma, Sequoia)
# Currently supports Apple Silicon (ARM64) only
#
# MAINTENANCE NOTE: Binary is bundled in vendor/aria2/bin/aria2c
# When aria2 needs to be updated:
# 1. Install via Homebrew: brew install aria2
# 2. Copy binary: cp /opt/homebrew/Cellar/aria2/VERSION/bin/aria2c vendor/aria2/bin/
# 3. Update vendor/aria2/README.md with version info
#
# SECURITY NOTE: This script installs a pre-compiled binary bundled with lpx_links.
# The binary is sourced from official Homebrew bottles.
# Users who require maximum security should install via Homebrew directly: brew install aria2

set -e  # Exit on error

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print colored output
print_blue() { echo -e "${BLUE}$1${NC}"; }
print_green() { echo -e "${GREEN}✓ $1${NC}"; }
print_yellow() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_red() { echo -e "${RED}✗ $1${NC}"; }

# Print header
echo ""
print_blue "═══════════════════════════════════════════════════════"
print_blue "  aria2 Installation Script for macOS"
print_blue "═══════════════════════════════════════════════════════"
echo ""

# Check if aria2c is already installed
if command -v aria2c &> /dev/null; then
    CURRENT_VERSION=$(aria2c --version | head -n 1 | awk '{print $3}')
    print_yellow "aria2 is already installed (version $CURRENT_VERSION)"

    # Check if we can prompt for input (interactive environment)
    if [ -c /dev/tty ]; then
        read -p "Do you want to reinstall? (y/N): " -n 1 -r </dev/tty
        echo
    else
        # In non-interactive environments, default to 'No' (safe default)
        print_yellow "Non-interactive mode detected. Skipping reinstallation."
        REPLY="n"
    fi

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_blue "Installation cancelled."
        exit 0
    fi
fi

# Check if Homebrew is installed
HOMEBREW_INSTALLED=false
if command -v brew &> /dev/null; then
    HOMEBREW_INSTALLED=true
    print_blue "Homebrew detected on your system"
    echo ""
    print_blue "You have two installation options:"
    echo ""
    echo "  1. Install via Homebrew (recommended if you use Homebrew)"
    echo "     - Automatically updates with 'brew upgrade'"
    echo "     - Works on both Intel and Apple Silicon"
    echo "     - Managed by Homebrew"
    echo ""
    echo "  2. Install bundled binary (faster, no Homebrew needed)"
    echo "     - Instant installation from bundled binary"
    echo "     - Apple Silicon (ARM64) only"
    echo "     - No automatic updates"
    echo ""

    # Check if we can prompt for input (interactive environment)
    if ! [ -c /dev/tty ]; then
        print_red "Cannot prompt for installation method in a non-interactive environment."
        print_yellow "Please run this script in an interactive terminal, or"
        print_yellow "install aria2 directly using one of these methods:"
        print_yellow "  - Homebrew: brew install aria2"
        print_yellow "  - Clone repo and run: bash scripts/install_aria2.sh"
        exit 1
    fi

    read -p "Choose installation method (1=Homebrew, 2=Bundled): " -n 1 -r </dev/tty
    echo
    echo ""

    if [[ $REPLY =~ ^[1]$ ]]; then
        print_blue "Installing via Homebrew..."
        if brew install aria2; then
            print_green "aria2 successfully installed via Homebrew!"
            INSTALLED_VERSION=$(aria2c --version | head -n 1)
            echo ""
            print_blue "═══════════════════════════════════════════════════════"
            print_green "$INSTALLED_VERSION"
            print_blue "═══════════════════════════════════════════════════════"
            echo ""
            print_blue "You can now use aria2c to download Logic Pro content:"
            echo ""
            echo "  aria2c -c --auto-file-renaming=false -i ~/Desktop/lpx_download_links/mandatory_download_links.txt -d ~/Downloads/logic_content"
            echo ""
            exit 0
        else
            print_red "Homebrew installation failed"
            print_yellow "Falling back to bundled binary installation..."
            echo ""
        fi
    elif [[ $REPLY =~ ^[2]$ ]]; then
        print_blue "Proceeding with bundled binary installation..."
        echo ""
    else
        print_red "Invalid choice. Please run the script again and choose 1 or 2."
        exit 1
    fi
fi

# Detect architecture
ARCH=$(uname -m)
print_blue "Detecting system architecture..."
if [ "$ARCH" = "arm64" ]; then
    print_green "Apple Silicon (ARM64) detected"
elif [ "$ARCH" = "x86_64" ]; then
    print_red "Intel (x86_64) detected"
    print_yellow "This script currently only supports Apple Silicon (ARM64)"
    print_yellow "You can install aria2 using Homebrew instead:"
    print_yellow "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    print_yellow "  brew install aria2"
    exit 1
else
    print_red "Unsupported architecture: $ARCH"
    exit 1
fi

# Detect macOS version
print_blue "Detecting macOS version..."
MACOS_VERSION=$(sw_vers -productVersion | cut -d. -f1)
if [ "$MACOS_VERSION" -lt 12 ]; then
    print_red "macOS version $MACOS_VERSION detected"
    print_yellow "This script supports macOS 12+ (Monterey and later)"
    print_yellow "You can install aria2 using Homebrew instead:"
    print_yellow "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    print_yellow "  brew install aria2"
    exit 1
fi
print_green "macOS $(sw_vers -productVersion) detected"

# Determine if we're running from a local clone or via curl | bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" 2>/dev/null && pwd )"
BUNDLED_BINARY=""

# Try to find bundled binary in local repository first
if [ -n "$SCRIPT_DIR" ]; then
    REPO_ROOT="$( cd "$SCRIPT_DIR/.." 2>/dev/null && pwd )"
    if [ -f "$REPO_ROOT/vendor/aria2/bin/aria2c" ]; then
        BUNDLED_BINARY="$REPO_ROOT/vendor/aria2/bin/aria2c"
        print_blue "Found bundled aria2 binary in local repository"
    fi
fi

# If not found locally, download from GitHub
if [ -z "$BUNDLED_BINARY" ] || [ ! -f "$BUNDLED_BINARY" ]; then
    print_blue "Downloading aria2 binary from GitHub..."

    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT

    BUNDLED_BINARY="$TEMP_DIR/aria2c"
    BINARY_URL="https://raw.githubusercontent.com/davidteren/lpx_links/main/vendor/aria2/bin/aria2c"

    if ! curl -fsSL -o "$BUNDLED_BINARY" "$BINARY_URL"; then
        print_red "Failed to download aria2 binary from GitHub"
        print_yellow "Please check your internet connection and try again"
        print_yellow "Or clone the repository and run the script locally:"
        print_yellow "  git clone https://github.com/davidteren/lpx_links.git"
        print_yellow "  cd lpx_links"
        print_yellow "  bash scripts/install_aria2.sh"
        exit 1
    fi

    print_green "Download complete"
fi

# Verify binary integrity with SHA256 checksum
print_blue "Verifying binary integrity..."
EXPECTED_SHA="70cdce6d22c5208a8175e5906bf04220806850a4c97efa6676e66b0a9c1de751"
ACTUAL_SHA=$(shasum -a 256 "$BUNDLED_BINARY" | awk '{print $1}')

if [ "$ACTUAL_SHA" != "$EXPECTED_SHA" ]; then
    print_red "Binary integrity check failed!"
    print_red "Expected SHA256: $EXPECTED_SHA"
    print_red "Actual SHA256:   $ACTUAL_SHA"
    print_yellow "This may indicate a corrupted download or tampered binary"
    print_yellow "Please try again or report this issue at:"
    print_yellow "  https://github.com/davidteren/lpx_links/issues"
    exit 1
fi

print_green "Binary integrity verified"

# Make the binary executable
chmod +x "$BUNDLED_BINARY"

# Install to user's local bin directory (no sudo needed)
INSTALL_DIR="$HOME/.local/bin"
print_blue "Installing aria2c to $INSTALL_DIR..."
print_blue "(No administrator privileges required)"

# Create ~/.local/bin if it doesn't exist
if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p "$INSTALL_DIR"
fi

# Copy binary
if ! cp "$BUNDLED_BINARY" "$INSTALL_DIR/aria2c"; then
    print_red "Failed to install aria2c"
    exit 1
fi

# Make executable
chmod +x "$INSTALL_DIR/aria2c"

print_green "Installation complete"

# Add to PATH in .zshrc if not already there
ZSHRC="$HOME/.zshrc"
PATH_EXPORT="export PATH=\"\$HOME/.local/bin:\$PATH\""

if [ -f "$ZSHRC" ]; then
    if ! grep -q "\.local/bin" "$ZSHRC"; then
        print_blue "Adding $INSTALL_DIR to PATH in .zshrc..."
        echo "" >> "$ZSHRC"
        echo "# Added by lpx_links aria2 installer" >> "$ZSHRC"
        echo "$PATH_EXPORT" >> "$ZSHRC"
        print_green "PATH updated in .zshrc"
        print_yellow "Please restart your terminal or run: source ~/.zshrc"
    else
        print_blue ".local/bin already in PATH"
    fi
else
    print_yellow "Warning: .zshrc not found. Creating it..."
    echo "# Added by lpx_links aria2 installer" > "$ZSHRC"
    echo "$PATH_EXPORT" >> "$ZSHRC"
    print_green "Created .zshrc with PATH configuration"
    print_yellow "Please restart your terminal or run: source ~/.zshrc"
fi

# Add to current session PATH
export PATH="$HOME/.local/bin:$PATH"

# Verify installation
print_blue "Verifying installation..."
if [ -x "$INSTALL_DIR/aria2c" ]; then
    INSTALLED_VERSION=$("$INSTALL_DIR/aria2c" --version | head -n 1)
    print_green "aria2 successfully installed!"
    echo ""
    print_blue "═══════════════════════════════════════════════════════"
    print_green "$INSTALLED_VERSION"
    print_blue "═══════════════════════════════════════════════════════"
    echo ""
    print_green "Installation location: $INSTALL_DIR/aria2c"
    echo ""
    print_blue "You can now use aria2c to download Logic Pro content:"
    echo ""
    echo "  aria2c -c --auto-file-renaming=false -i ~/Desktop/lpx_download_links/mandatory_download_links.txt -d ~/Downloads/logic_content"
    echo ""

    # Test if aria2c is accessible in current session
    if command -v aria2c &> /dev/null; then
        print_green "✓ aria2c is ready to use in this terminal session"
    else
        print_yellow "Note: To use 'aria2c' command in this terminal:"
        print_yellow "  Run: source ~/.zshrc"
        print_yellow "  Or restart your terminal"
        print_yellow ""
        print_yellow "For now, you can use the full path:"
        print_yellow "  $INSTALL_DIR/aria2c"
    fi
else
    print_red "Installation verification failed"
    print_yellow "Could not find an executable aria2c at $INSTALL_DIR/aria2c"
    exit 1
fi


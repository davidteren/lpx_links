#!/bin/bash
# aria2 Installation Script for macOS
#
# Installs aria2 via Homebrew. If Homebrew isn't installed, offers to
# install it first. This avoids bundling GPL-licensed binaries.
#
# Supports macOS 12+ (Monterey, Ventura, Sonoma, Sequoia)
# Works on both Intel and Apple Silicon

set -e

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_blue() { echo -e "${BLUE}$1${NC}"; }
print_green() { echo -e "${GREEN}✓ $1${NC}"; }
print_yellow() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_red() { echo -e "${RED}✗ $1${NC}"; }

echo ""
print_blue "═══════════════════════════════════════════════════════"
print_blue "  aria2 Installation Script for macOS"
print_blue "═══════════════════════════════════════════════════════"
echo ""

# Check if aria2c is already installed
if command -v aria2c &> /dev/null; then
    CURRENT_VERSION=$(aria2c --version | head -n 1)
    print_green "aria2 is already installed!"
    echo ""
    print_blue "═══════════════════════════════════════════════════════"
    print_green "$CURRENT_VERSION"
    print_blue "═══════════════════════════════════════════════════════"
    echo ""
    exit 0
fi

# Check macOS version
MACOS_VERSION=$(sw_vers -productVersion | cut -d. -f1)
if [ "$MACOS_VERSION" -lt 12 ]; then
    print_red "macOS version $MACOS_VERSION detected"
    print_yellow "This script supports macOS 12+ (Monterey and later)"
    exit 1
fi

# --- Install via Homebrew ---
if command -v brew &> /dev/null; then
    print_blue "Homebrew detected. Installing aria2..."
    echo ""

    if brew install aria2; then
        INSTALLED_VERSION=$(aria2c --version | head -n 1)
        echo ""
        print_blue "═══════════════════════════════════════════════════════"
        print_green "$INSTALLED_VERSION"
        print_blue "═══════════════════════════════════════════════════════"
        echo ""
        print_green "Installation complete!"
        echo ""
        print_blue "You can now download Logic Pro content with:"
        echo ""
        echo "  aria2c -c --auto-file-renaming=false -i ~/Desktop/lpx_download_links/mandatory_download_links.txt -d ~/Downloads/logic_content"
        echo ""
        exit 0
    else
        print_red "Installation failed. Please try again or run: brew install aria2"
        exit 1
    fi
fi

# --- No Homebrew — offer to install it ---
print_blue "aria2 is installed via Homebrew, a free package manager for Mac."
print_blue "Homebrew is not currently installed on your system."
echo ""
print_blue "Homebrew is widely used by Mac users to install command-line tools."
print_blue "It installs to its own directory and won't interfere with your system."
echo ""

if [ -c /dev/tty ]; then
    echo "  1. Install Homebrew, then install aria2 (recommended)"
    echo "  2. Cancel"
    echo ""
    read -p "Choose an option (1/2): " -n 1 -r </dev/tty
    echo ""
    echo ""

    if [[ ! $REPLY =~ ^[1]$ ]]; then
        print_blue "Installation cancelled."
        echo ""
        print_blue "You can install Homebrew manually anytime:"
        echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        echo ""
        print_blue "Then install aria2:"
        echo "  brew install aria2"
        echo ""
        exit 0
    fi
else
    print_red "Cannot prompt for input in a non-interactive environment."
    print_yellow "Please install Homebrew and aria2 manually:"
    echo ""
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo "  brew install aria2"
    echo ""
    exit 1
fi

# Install Homebrew
print_blue "Installing Homebrew..."
print_blue "You may be asked for your Mac password during this step."
echo ""

if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    print_green "Homebrew installed!"
    echo ""
else
    print_red "Homebrew installation failed."
    print_yellow "Please visit https://brew.sh for manual installation instructions."
    exit 1
fi

# Add Homebrew to PATH for this session (Apple Silicon)
if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Add Homebrew to PATH for this session (Intel)
if [ -f /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Verify brew is available
if ! command -v brew &> /dev/null; then
    print_red "Homebrew installed but not found in PATH."
    print_yellow "Please restart your terminal and run:"
    echo "  brew install aria2"
    exit 1
fi

# Install aria2
print_blue "Installing aria2..."
echo ""

if brew install aria2; then
    INSTALLED_VERSION=$(aria2c --version | head -n 1)
    echo ""
    print_blue "═══════════════════════════════════════════════════════"
    print_green "$INSTALLED_VERSION"
    print_blue "═══════════════════════════════════════════════════════"
    echo ""
    print_green "Installation complete!"
    echo ""
    print_blue "You can now download Logic Pro content with:"
    echo ""
    echo "  aria2c -c --auto-file-renaming=false -i ~/Desktop/lpx_download_links/mandatory_download_links.txt -d ~/Downloads/logic_content"
    echo ""
else
    print_red "aria2 installation failed."
    print_yellow "Please try: brew install aria2"
    exit 1
fi

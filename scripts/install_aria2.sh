#!/bin/bash
# aria2 Installation Script for macOS
# Downloads and installs aria2 from Homebrew bottles without requiring Homebrew
#
# Supports macOS 12+ (Monterey, Ventura, Sonoma, Sequoia)
# Supports both Intel (x86_64) and Apple Silicon (ARM64)
#
# MAINTENANCE NOTE: SHA256 checksums are tied to aria2 v1.37.0
# When aria2 is updated, checksums must be refreshed from:
# https://formulae.brew.sh/api/formula/aria2.json
#
# SECURITY NOTE: This script downloads precompiled binaries from Homebrew's
# official infrastructure (ghcr.io) and verifies them with SHA256 checksums.
# While this provides reasonable security, users who require maximum security
# should install via Homebrew directly: brew install aria2

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
    read -p "Do you want to reinstall? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_blue "Installation cancelled."
        exit 0
    fi
fi

# Detect architecture
ARCH=$(uname -m)
print_blue "Detecting system architecture..."
if [ "$ARCH" = "arm64" ]; then
    print_green "Apple Silicon (ARM64) detected"
    ARCH_TYPE="arm64"
elif [ "$ARCH" = "x86_64" ]; then
    print_green "Intel (x86_64) detected"
    ARCH_TYPE="x86_64"
else
    print_red "Unsupported architecture: $ARCH"
    exit 1
fi

# Detect macOS version
print_blue "Detecting macOS version..."
MACOS_VERSION=$(sw_vers -productVersion | cut -d. -f1)
case $MACOS_VERSION in
    15)
        MACOS_NAME="sequoia"
        print_green "macOS Sequoia (15.x) detected"
        ;;
    14)
        MACOS_NAME="sonoma"
        print_green "macOS Sonoma (14.x) detected"
        ;;
    13)
        MACOS_NAME="ventura"
        print_green "macOS Ventura (13.x) detected"
        ;;
    12)
        MACOS_NAME="monterey"
        print_green "macOS Monterey (12.x) detected"
        ;;
    *)
        print_yellow "macOS version $MACOS_VERSION detected"
        print_yellow "This script supports macOS 12-15 (Monterey through Sequoia)"
        print_yellow "Attempting to use Monterey bottle as fallback..."
        MACOS_NAME="monterey"
        ;;
esac

# Homebrew bottle SHA256 checksums (aria2 1.37.0)
# Source: https://formulae.brew.sh/api/formula/aria2.json
declare -A BOTTLE_SHAS
BOTTLE_SHAS["arm64_sequoia"]="fa42d58d43ca08575c6df1b9c8b6141edc97fdeec4c60fc3e39c50fffc7a301e"
BOTTLE_SHAS["arm64_sonoma"]="89117256b91a5a87d4e31fb4054f7a0b45681a97627547b4db7498930486ff05"
BOTTLE_SHAS["arm64_ventura"]="fd06b5b187243559c5f286767ab8f7f7d5f16d361bbd3ff9faf0909643920849"
BOTTLE_SHAS["arm64_monterey"]="515cf8d197ec78753fa6b7462f775a3e625340e04f02207ae6dd1b6135afecdd"
BOTTLE_SHAS["x86_64_sonoma"]="7ad8b56e2edf9df28458b88cc88faec5e7ada3bd9b5652420aa6168325a10260"
BOTTLE_SHAS["x86_64_ventura"]="2821ec44b09994465d3bb8f8e4da6af8d2dd70cbdbf92f3b75d18ba65064e681"
BOTTLE_SHAS["x86_64_monterey"]="41ce19b788f94a35025e306afa0f90a85164243d18f7350340cf75b9edf18b6c"

# Determine bottle key
BOTTLE_KEY="${ARCH_TYPE}_${MACOS_NAME}"
BOTTLE_SHA="${BOTTLE_SHAS[$BOTTLE_KEY]}"

if [ -z "$BOTTLE_SHA" ]; then
    print_red "No precompiled binary available for $ARCH_TYPE on macOS $MACOS_NAME"
    print_yellow "You can install aria2 using Homebrew instead:"
    print_yellow "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    print_yellow "  brew install aria2"
    exit 1
fi

# Construct download URL
BOTTLE_URL="https://ghcr.io/v2/homebrew/core/aria2/blobs/sha256:${BOTTLE_SHA}"

# Create temporary directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

print_blue "Downloading aria2 1.37.0..."
BOTTLE_FILE="$TEMP_DIR/aria2.tar.gz"

if ! curl -fsSL -o "$BOTTLE_FILE" "$BOTTLE_URL"; then
    print_red "Failed to download aria2 bottle"
    print_yellow "Please check your internet connection and try again"
    exit 1
fi

print_green "Download complete"

# Verify checksum
print_blue "Verifying download integrity..."
DOWNLOADED_SHA=$(shasum -a 256 "$BOTTLE_FILE" | awk '{print $1}')
if [ "$DOWNLOADED_SHA" != "$BOTTLE_SHA" ]; then
    print_red "Checksum verification failed!"
    print_red "Expected: $BOTTLE_SHA"
    print_red "Got:      $DOWNLOADED_SHA"
    exit 1
fi
print_green "Checksum verified"

# Extract bottle
print_blue "Extracting aria2..."
cd "$TEMP_DIR"
if ! tar -xzf "$BOTTLE_FILE"; then
    print_red "Failed to extract aria2 bottle"
    exit 1
fi
print_green "Extraction complete"

# Find aria2c binary (look specifically in bin subdirectory for robustness)
ARIA2C_BINARY=$(find "$TEMP_DIR" -path "*/bin/aria2c" -type f | head -n 1)
if [ -z "$ARIA2C_BINARY" ]; then
    print_red "Could not find aria2c binary in extracted files"
    exit 1
fi

# Install to /usr/local/bin
print_blue "Installing aria2c to /usr/local/bin..."
print_yellow "This step requires administrator privileges (sudo)"

# Validate sudo privileges upfront to avoid multiple prompts
sudo -v

# Create /usr/local/bin if it doesn't exist
if [ ! -d "/usr/local/bin" ]; then
    sudo mkdir -p /usr/local/bin
fi

# Copy binary
if ! sudo cp "$ARIA2C_BINARY" /usr/local/bin/aria2c; then
    print_red "Failed to install aria2c"
    exit 1
fi

# Make executable
sudo chmod +x /usr/local/bin/aria2c

print_green "Installation complete"

# Verify installation
print_blue "Verifying installation..."
if [ -x "/usr/local/bin/aria2c" ]; then
    INSTALLED_VERSION=$(/usr/local/bin/aria2c --version | head -n 1)
    print_green "aria2 successfully installed!"
    echo ""
    print_blue "═══════════════════════════════════════════════════════"
    print_green "$INSTALLED_VERSION"
    print_blue "═══════════════════════════════════════════════════════"
    echo ""
    print_blue "You can now use aria2c to download Logic Pro content:"
    echo ""
    echo "  aria2c -c --auto-file-renaming=false -i ~/Desktop/lpx_download_links/mandatory_download_links.txt -d ~/Downloads/logic_content"
    echo ""

    # Check if aria2c is in PATH
    if ! command -v aria2c &> /dev/null; then
        print_yellow "Note: aria2c is not in your PATH. You may need to:"
        print_yellow "  - Restart your terminal, or"
        print_yellow "  - Add /usr/local/bin to your PATH"
        print_yellow "  - Use the full path: /usr/local/bin/aria2c"
    fi
else
    print_red "Installation verification failed"
    print_yellow "Could not find an executable aria2c at /usr/local/bin/aria2c"
    exit 1
fi


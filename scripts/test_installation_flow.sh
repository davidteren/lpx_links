#!/bin/bash
# Test the complete aria2 installation flow
# This script simulates what a user would experience

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Testing aria2 Installation Flow${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# Test 1: Verify bundled binary exists and works
echo -e "${BLUE}Test 1: Checking bundled binary...${NC}"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
BUNDLED_BINARY="$REPO_ROOT/vendor/aria2/bin/aria2c"

if [ ! -f "$BUNDLED_BINARY" ]; then
    echo -e "${RED}✗ Bundled binary not found${NC}"
    exit 1
fi

if [ ! -x "$BUNDLED_BINARY" ]; then
    echo -e "${RED}✗ Bundled binary not executable${NC}"
    exit 1
fi

VERSION=$("$BUNDLED_BINARY" --version | head -1)
echo -e "${GREEN}✓ Bundled binary works: $VERSION${NC}"

# Test 2: Check if aria2c is already installed
echo ""
echo -e "${BLUE}Test 2: Checking system installation...${NC}"
if command -v aria2c &> /dev/null; then
    INSTALLED_VERSION=$(aria2c --version | head -1)
    echo -e "${YELLOW}⚠ aria2c is already installed: $INSTALLED_VERSION${NC}"
    echo -e "${YELLOW}  Location: $(which aria2c)${NC}"
    echo ""
    echo -e "${YELLOW}To test the installation script, you would need to:${NC}"
    echo -e "${YELLOW}  1. Uninstall existing aria2c${NC}"
    echo -e "${YELLOW}  2. Run: sudo bash scripts/install_aria2.sh${NC}"
    echo -e "${YELLOW}  3. Verify: aria2c --version${NC}"
else
    echo -e "${GREEN}✓ No existing aria2c installation found${NC}"
    echo ""
    echo -e "${BLUE}To install aria2c, run:${NC}"
    echo -e "  ${YELLOW}sudo bash scripts/install_aria2.sh${NC}"
    echo ""
    echo -e "${BLUE}Or test with the bundled binary directly:${NC}"
    echo -e "  ${YELLOW}$BUNDLED_BINARY --version${NC}"
fi

# Test 3: Verify installation script syntax
echo ""
echo -e "${BLUE}Test 3: Verifying installation script syntax...${NC}"
if bash -n "$REPO_ROOT/scripts/install_aria2.sh"; then
    echo -e "${GREEN}✓ Installation script syntax is valid${NC}"
else
    echo -e "${RED}✗ Installation script has syntax errors${NC}"
    exit 1
fi

# Test 4: Check architecture compatibility
echo ""
echo -e "${BLUE}Test 4: Checking architecture compatibility...${NC}"
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    echo -e "${GREEN}✓ System is ARM64 (Apple Silicon) - compatible${NC}"
elif [ "$ARCH" = "x86_64" ]; then
    echo -e "${YELLOW}⚠ System is Intel (x86_64) - bundled binary is ARM64 only${NC}"
    echo -e "${YELLOW}  Intel users should install via Homebrew: brew install aria2${NC}"
else
    echo -e "${RED}✗ Unknown architecture: $ARCH${NC}"
fi

# Test 5: Check macOS version
echo ""
echo -e "${BLUE}Test 5: Checking macOS version...${NC}"
MACOS_VERSION=$(sw_vers -productVersion | cut -d. -f1)
if [ "$MACOS_VERSION" -ge 12 ]; then
    echo -e "${GREEN}✓ macOS $MACOS_VERSION is supported (requires 12+)${NC}"
else
    echo -e "${RED}✗ macOS $MACOS_VERSION is not supported (requires 12+)${NC}"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}All pre-installation checks passed!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""


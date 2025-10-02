#!/bin/bash
# Test Homebrew detection in installation script

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Testing Homebrew Detection${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# Test 1: Check if Homebrew is installed
echo -e "${BLUE}Test 1: Checking for Homebrew...${NC}"
if command -v brew &> /dev/null; then
    BREW_VERSION=$(brew --version | head -1)
    echo -e "${GREEN}✓ Homebrew is installed: $BREW_VERSION${NC}"
    HOMEBREW_PRESENT=true
else
    echo -e "${YELLOW}⚠ Homebrew is not installed${NC}"
    HOMEBREW_PRESENT=false
fi

# Test 2: Verify script detects Homebrew correctly
echo ""
echo -e "${BLUE}Test 2: Verifying script logic...${NC}"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Extract the Homebrew detection logic from the script
if grep -q "command -v brew" "$SCRIPT_DIR/install_aria2.sh"; then
    echo -e "${GREEN}✓ Script contains Homebrew detection logic${NC}"
else
    echo -e "${RED}✗ Script missing Homebrew detection logic${NC}"
    exit 1
fi

# Test 3: Check for installation options prompt
echo ""
echo -e "${BLUE}Test 3: Checking for user choice prompt...${NC}"
if grep -q "Choose installation method" "$SCRIPT_DIR/install_aria2.sh"; then
    echo -e "${GREEN}✓ Script prompts user for installation method${NC}"
else
    echo -e "${RED}✗ Script missing user choice prompt${NC}"
    exit 1
fi

# Test 4: Verify Homebrew installation path exists
echo ""
echo -e "${BLUE}Test 4: Checking Homebrew installation logic...${NC}"
if grep -q "brew install aria2" "$SCRIPT_DIR/install_aria2.sh"; then
    echo -e "${GREEN}✓ Script includes Homebrew installation option${NC}"
else
    echo -e "${RED}✗ Script missing Homebrew installation logic${NC}"
    exit 1
fi

# Test 5: Verify bundled binary fallback exists
echo ""
echo -e "${BLUE}Test 5: Checking bundled binary fallback...${NC}"
if grep -q "Proceeding with bundled binary installation" "$SCRIPT_DIR/install_aria2.sh"; then
    echo -e "${GREEN}✓ Script includes bundled binary option${NC}"
else
    echo -e "${RED}✗ Script missing bundled binary option${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}All Homebrew detection tests passed!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

if [ "$HOMEBREW_PRESENT" = true ]; then
    echo -e "${BLUE}User Experience Preview:${NC}"
    echo ""
    echo -e "${YELLOW}When you run the installation script, you will see:${NC}"
    echo ""
    echo "  Homebrew detected on your system"
    echo ""
    echo "  You have two installation options:"
    echo ""
    echo "    1. Install via Homebrew (recommended if you use Homebrew)"
    echo "       - Automatically updates with 'brew upgrade'"
    echo "       - Works on both Intel and Apple Silicon"
    echo "       - Managed by Homebrew"
    echo ""
    echo "    2. Install bundled binary (faster, no Homebrew needed)"
    echo "       - Instant installation from bundled binary"
    echo "       - Apple Silicon (ARM64) only"
    echo "       - No automatic updates"
    echo ""
    echo "  Choose installation method (1=Homebrew, 2=Bundled):"
    echo ""
else
    echo -e "${BLUE}User Experience Preview:${NC}"
    echo ""
    echo -e "${YELLOW}Since Homebrew is not installed, the script will:${NC}"
    echo "  - Skip the Homebrew option"
    echo "  - Proceed directly to bundled binary installation"
    echo "  - Check system architecture (ARM64 required)"
    echo ""
fi


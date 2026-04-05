#!/bin/bash
# Test the aria2 installation script logic
# Validates syntax, structure, and key paths

set -e

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
INSTALL_SCRIPT="$SCRIPT_DIR/install_aria2.sh"
PASSED=0
FAILED=0

pass() { echo -e "${GREEN}✓ $1${NC}"; PASSED=$((PASSED + 1)); }
fail() { echo -e "${RED}✗ $1${NC}"; FAILED=$((FAILED + 1)); }

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Testing install_aria2.sh${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# Test 1: Script syntax is valid
echo -e "${BLUE}Test 1: Script syntax check...${NC}"
if bash -n "$INSTALL_SCRIPT"; then
    pass "install_aria2.sh syntax is valid"
else
    fail "install_aria2.sh has syntax errors"
fi

# Test 2: Script uses Homebrew for installation
echo ""
echo -e "${BLUE}Test 2: Homebrew installation path...${NC}"
if grep -q "brew install aria2" "$INSTALL_SCRIPT"; then
    pass "Script installs aria2 via Homebrew"
else
    fail "Script missing Homebrew installation"
fi

# Test 3: Script detects existing Homebrew
echo ""
echo -e "${BLUE}Test 3: Homebrew detection...${NC}"
if grep -q "command -v brew" "$INSTALL_SCRIPT"; then
    pass "Script detects Homebrew"
else
    fail "Script missing Homebrew detection"
fi

# Test 4: Script offers to install Homebrew if missing
echo ""
echo -e "${BLUE}Test 4: Homebrew install offer...${NC}"
if grep -q "Homebrew/install/HEAD/install.sh" "$INSTALL_SCRIPT"; then
    pass "Script offers to install Homebrew"
else
    fail "Script missing Homebrew install offer"
fi

# Test 5: Script checks for existing aria2 installation
echo ""
echo -e "${BLUE}Test 5: Existing aria2 detection...${NC}"
if grep -q "command -v aria2c" "$INSTALL_SCRIPT"; then
    pass "Script checks for existing aria2"
else
    fail "Script missing existing aria2 check"
fi

# Test 6: Script handles non-interactive mode
echo ""
echo -e "${BLUE}Test 6: Non-interactive mode handling...${NC}"
if grep -q '/dev/tty' "$INSTALL_SCRIPT"; then
    pass "Script handles non-interactive environments"
else
    fail "Script missing non-interactive handling"
fi

# Test 7: No bundled binary references
echo ""
echo -e "${BLUE}Test 7: No bundled binary references...${NC}"
if grep -q "vendor/aria2" "$INSTALL_SCRIPT"; then
    fail "Script still references bundled binary"
else
    pass "No bundled binary references"
fi

# Test 8: Check current aria2 status on this machine
echo ""
echo -e "${BLUE}Test 8: Current system status...${NC}"
if command -v aria2c &> /dev/null; then
    VERSION=$(aria2c --version | head -1)
    pass "aria2 is installed: $VERSION"
else
    echo -e "${YELLOW}  aria2 is not installed (expected on clean systems)${NC}"
    pass "aria2 not installed (test still valid)"
fi

# --- Summary ---
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
TOTAL=$((PASSED + FAILED))
if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}All $TOTAL tests passed!${NC}"
else
    echo -e "${YELLOW}$PASSED of $TOTAL tests passed. $FAILED failed.${NC}"
fi
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

exit $FAILED

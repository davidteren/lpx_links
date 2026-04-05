#!/bin/bash
# Test the install.sh script logic
# Uses temporary directories with dummy .pkg files to validate behavior

set -e

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
INSTALL_SCRIPT="$SCRIPT_DIR/install.sh"
PASSED=0
FAILED=0

pass() { echo -e "${GREEN}✓ $1${NC}"; PASSED=$((PASSED + 1)); }
fail() { echo -e "${RED}✗ $1${NC}"; FAILED=$((FAILED + 1)); }

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Testing install.sh${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# Test 1: Script syntax is valid
echo -e "${BLUE}Test 1: Script syntax check...${NC}"
if bash -n "$INSTALL_SCRIPT"; then
    pass "install.sh syntax is valid"
else
    fail "install.sh has syntax errors"
fi

# Test 2: Missing argument shows usage
echo ""
echo -e "${BLUE}Test 2: Missing argument shows usage...${NC}"
OUTPUT=$(bash "$INSTALL_SCRIPT" 2>&1 || true)
if echo "$OUTPUT" | grep -q "Usage"; then
    pass "Shows usage when no argument provided"
else
    fail "Does not show usage when no argument provided"
fi

# Test 3: Non-existent directory shows error
echo ""
echo -e "${BLUE}Test 3: Non-existent directory...${NC}"
OUTPUT=$(bash "$INSTALL_SCRIPT" /tmp/nonexistent_pkg_dir_$$ 2>&1 || true)
if echo "$OUTPUT" | grep -q "Directory not found"; then
    pass "Shows error for non-existent directory"
else
    fail "Does not show error for non-existent directory"
fi

# Test 4: Empty directory (no .pkg files) shows error
echo ""
echo -e "${BLUE}Test 4: Empty directory (no .pkg files)...${NC}"
EMPTY_DIR=$(mktemp -d)
trap "rm -rf $EMPTY_DIR" EXIT
OUTPUT=$(bash "$INSTALL_SCRIPT" "$EMPTY_DIR" 2>&1 || true)
if echo "$OUTPUT" | grep -q "No .pkg files found"; then
    pass "Shows error when no .pkg files found"
else
    fail "Does not show error when no .pkg files found"
fi

# Test 5: Script detects .pkg files and shows disk space info
echo ""
echo -e "${BLUE}Test 5: Disk space reporting with .pkg files...${NC}"
TEST_DIR=$(mktemp -d)
trap "rm -rf $EMPTY_DIR $TEST_DIR" EXIT

# Create dummy .pkg files (small, just for testing detection)
dd if=/dev/zero of="$TEST_DIR/test1.pkg" bs=1024 count=100 2>/dev/null
dd if=/dev/zero of="$TEST_DIR/test2.pkg" bs=1024 count=200 2>/dev/null

# Run in non-interactive mode (no tty) so it doesn't block on prompt
# Redirect stdin from /dev/null to ensure non-interactive
OUTPUT=$(bash "$INSTALL_SCRIPT" "$TEST_DIR" </dev/null 2>&1 || true)

if echo "$OUTPUT" | grep -q "package(s) to install"; then
    pass "Reports package count"
else
    fail "Does not report package count"
fi

if echo "$OUTPUT" | grep -q "Package files size"; then
    pass "Reports package file size"
else
    fail "Does not report package file size"
fi

if echo "$OUTPUT" | grep -q "Available disk space"; then
    pass "Reports available disk space"
else
    fail "Does not report available disk space"
fi

# Test 6: Interactive or non-interactive path is chosen
echo ""
echo -e "${BLUE}Test 6: Interactive/non-interactive mode handling...${NC}"
if echo "$OUTPUT" | grep -q "Non-interactive mode"; then
    pass "Detects non-interactive mode (no tty)"
elif echo "$OUTPUT" | grep -q "Choose an option\|Will delete\|Will keep"; then
    pass "Detects interactive mode (tty available)"
else
    fail "Neither interactive nor non-interactive path triggered"
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

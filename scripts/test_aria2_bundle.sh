#!/bin/bash
# Test script for bundled aria2 binary
# This script tests that the bundled binary works without installing it

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Testing bundled aria2 binary..."

# Determine script location
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
BUNDLED_BINARY="$REPO_ROOT/vendor/aria2/bin/aria2c"

# Test 1: Check if binary exists
if [ ! -f "$BUNDLED_BINARY" ]; then
    echo -e "${RED}✗ Binary not found at: $BUNDLED_BINARY${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Binary exists${NC}"

# Test 2: Check if binary is executable
if [ ! -x "$BUNDLED_BINARY" ]; then
    echo -e "${RED}✗ Binary is not executable${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Binary is executable${NC}"

# Test 3: Check binary version
VERSION_INFO=$("$BUNDLED_BINARY" --version | head -1)
echo -e "${GREEN}✓ Binary version: $VERSION_INFO${NC}"

# Test 4: Verify it's ARM64
FILE_INFO=$(file "$BUNDLED_BINARY")
if [[ "$FILE_INFO" == *"arm64"* ]]; then
    echo -e "${GREEN}✓ Binary is ARM64${NC}"
else
    echo -e "${RED}✗ Binary is not ARM64: $FILE_INFO${NC}"
    exit 1
fi

# Test 5: Check file size (should be around 3-4MB)
SIZE=$(stat -f%z "$BUNDLED_BINARY")
SIZE_MB=$((SIZE / 1024 / 1024))
if [ "$SIZE_MB" -ge 2 ] && [ "$SIZE_MB" -le 10 ]; then
    echo -e "${GREEN}✓ Binary size is reasonable: ${SIZE_MB}MB${NC}"
else
    echo -e "${RED}✗ Binary size is unexpected: ${SIZE_MB}MB${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}All tests passed!${NC}"
echo "The bundled aria2 binary is ready for distribution."


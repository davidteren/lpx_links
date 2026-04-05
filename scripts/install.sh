#!/bin/bash

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_blue() { echo -e "${BLUE}$1${NC}"; }
print_green() { echo -e "${GREEN}✓ $1${NC}"; }
print_yellow() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_red() { echo -e "${RED}✗ $1${NC}"; }

# --- Validate input ---
PKG_DIR="$1"

if [ -z "$PKG_DIR" ]; then
    print_red "Usage: sudo $0 <folder-containing-pkg-files>"
    exit 1
fi

if [ ! -d "$PKG_DIR" ]; then
    print_red "Directory not found: $PKG_DIR"
    exit 1
fi

# Check for .pkg files
PKG_COUNT=$(ls "$PKG_DIR"/*.pkg 2>/dev/null | wc -l | tr -d ' ')
if [ "$PKG_COUNT" -eq 0 ]; then
    print_red "No .pkg files found in $PKG_DIR"
    exit 1
fi

# --- Disk space check ---
echo ""
print_blue "═══════════════════════════════════════════════════════"
print_blue "  Logic Pro Content Installer"
print_blue "═══════════════════════════════════════════════════════"
echo ""

# Calculate total size of .pkg files (in kilobytes, then convert)
TOTAL_PKG_KB=0
for pkg in "$PKG_DIR"/*.pkg; do
    PKG_SIZE_KB=$(du -k "$pkg" | cut -f1)
    TOTAL_PKG_KB=$((TOTAL_PKG_KB + PKG_SIZE_KB))
done
TOTAL_PKG_GB=$(echo "scale=1; $TOTAL_PKG_KB / 1048576" | bc)

# Get available disk space (in kilobytes)
AVAILABLE_KB=$(df -k / | tail -1 | awk '{print $4}')
AVAILABLE_GB=$(echo "scale=1; $AVAILABLE_KB / 1048576" | bc)

print_blue "Found $PKG_COUNT package(s) to install"
echo ""
echo "  Package files size:    ${TOTAL_PKG_GB} GB"
echo "  Available disk space:  ${AVAILABLE_GB} GB"
echo ""

# Determine if space is tight
# When keeping .pkg files, you only need space for the installed content (~same as .pkg size)
# When deleting, you reclaim space as you go, so peak usage is lower
NEEDED_IF_KEEP_KB=$TOTAL_PKG_KB
CLEANUP_RECOMMENDED=false

if [ "$AVAILABLE_KB" -lt "$NEEDED_IF_KEEP_KB" ]; then
    CLEANUP_RECOMMENDED=true
    print_yellow "Disk space is tight!"
    print_yellow "Deleting packages after install is recommended to free up space."
    echo ""
fi

# --- Ask user preference ---
if [ -c /dev/tty ]; then
    if [ "$CLEANUP_RECOMMENDED" = true ]; then
        echo "  1. Delete each .pkg after it installs (recommended - frees up ${TOTAL_PKG_GB} GB)"
        echo "  2. Keep .pkg files after install"
    else
        echo "  1. Delete each .pkg after it installs (frees up ${TOTAL_PKG_GB} GB)"
        echo "  2. Keep .pkg files after install"
    fi
    echo ""
    read -p "Choose an option (1/2): " -n 1 -r </dev/tty
    echo ""
    echo ""

    if [[ $REPLY =~ ^[1]$ ]]; then
        CLEANUP=true
        print_blue "Will delete each .pkg after successful installation."
    else
        CLEANUP=false
        print_blue "Will keep all .pkg files after installation."
    fi
else
    # Non-interactive: default to cleanup if space is tight, otherwise keep
    if [ "$CLEANUP_RECOMMENDED" = true ]; then
        CLEANUP=true
        print_yellow "Non-interactive mode: auto-deleting packages after install (low disk space)."
    else
        CLEANUP=false
        print_yellow "Non-interactive mode: keeping packages after install."
    fi
fi

echo ""

# --- Install packages ---
INSTALLED=0
FAILED=0

for pkg in "$PKG_DIR"/*.pkg; do
    PKG_NAME=$(basename "$pkg")
    INSTALLED=$((INSTALLED + 1))
    print_blue "[$INSTALLED/$PKG_COUNT] Installing $PKG_NAME..."

    if installer -pkg "$pkg" -target /; then
        print_green "$PKG_NAME installed"

        if [ "$CLEANUP" = true ]; then
            rm "$pkg"
            print_green "Deleted $PKG_NAME"
        fi
    else
        print_red "Failed to install $PKG_NAME"
        FAILED=$((FAILED + 1))
    fi
done

# --- Summary ---
echo ""
print_blue "═══════════════════════════════════════════════════════"
if [ "$FAILED" -eq 0 ]; then
    print_green "All $PKG_COUNT packages installed successfully!"
else
    print_yellow "$((PKG_COUNT - FAILED)) of $PKG_COUNT packages installed. $FAILED failed."
fi

if [ "$CLEANUP" = true ]; then
    print_green "Package files cleaned up to free disk space."
fi
print_blue "═══════════════════════════════════════════════════════"
echo ""

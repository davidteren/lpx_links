#!/bin/bash
# LPX Links Setup — Double-click to run
# Downloads and installs Logic Pro, MainStage, or GarageBand content
#
# This file is a .command file: macOS opens it in Terminal automatically
# when double-clicked. All user interaction happens via native macOS dialogs.

set -e

# --- Configuration ---
REPO_URL="https://github.com/davidteren/lpx_links"
DOWNLOAD_DIR="$HOME/Downloads/logic_content"
LINKS_DIR="$HOME/Desktop/lpx_download_links"
TOOL_DIR=$(mktemp -d)
trap "rm -rf $TOOL_DIR" EXIT

# --- Helpers ---
dialog() {
    osascript -e "display dialog \"$1\" buttons {\"OK\"} default button \"OK\" with title \"LPX Links\" with icon note" 2>/dev/null
}

dialog_error() {
    osascript -e "display dialog \"$1\" buttons {\"OK\"} default button \"OK\" with title \"LPX Links\" with icon stop" 2>/dev/null
}

choose() {
    osascript -e "choose from list {$1} with prompt \"$2\" with title \"LPX Links\" default items {$3}" 2>/dev/null
}

confirm() {
    osascript -e "display dialog \"$1\" buttons {\"Cancel\", \"$2\"} default button \"$2\" with title \"LPX Links\" with icon note" 2>/dev/null
}

notify() {
    osascript -e "display notification \"$1\" with title \"LPX Links\"" 2>/dev/null
}

# --- Preflight checks ---
echo "============================================"
echo "  LPX Links — Content Downloader & Installer"
echo "============================================"
echo ""

# Check for at least one supported app
HAS_LOGIC=false
HAS_MAINSTAGE=false
HAS_GARAGEBAND=false

for p in "/Applications/Logic Pro Creator Studio.app" "/Applications/Logic Pro.app" "/Applications/Logic Pro X.app"; do
    [ -d "$p" ] && HAS_LOGIC=true && break
done
for p in "/Applications/MainStage Creator Studio.app" "/Applications/MainStage 3.app" "/Applications/MainStage.app"; do
    [ -d "$p" ] && HAS_MAINSTAGE=true && break
done
[ -d "/Applications/GarageBand.app" ] && HAS_GARAGEBAND=true

if [ "$HAS_LOGIC" = false ] && [ "$HAS_MAINSTAGE" = false ] && [ "$HAS_GARAGEBAND" = false ]; then
    dialog_error "No supported apps found. Please install Logic Pro, MainStage, or GarageBand first."
    exit 1
fi

# Build the app list
APP_LIST=""
DEFAULT_APP=""
if [ "$HAS_LOGIC" = true ]; then
    APP_LIST="\"Logic Pro\""
    DEFAULT_APP="\"Logic Pro\""
fi
if [ "$HAS_MAINSTAGE" = true ]; then
    [ -n "$APP_LIST" ] && APP_LIST="$APP_LIST, "
    APP_LIST="${APP_LIST}\"MainStage\""
    [ -z "$DEFAULT_APP" ] && DEFAULT_APP="\"MainStage\""
fi
if [ "$HAS_GARAGEBAND" = true ]; then
    [ -n "$APP_LIST" ] && APP_LIST="$APP_LIST, "
    APP_LIST="${APP_LIST}\"GarageBand\""
    [ -z "$DEFAULT_APP" ] && DEFAULT_APP="\"GarageBand\""
fi

# --- Step 1: Choose app ---
CHOSEN_APP=$(choose "$APP_LIST" "Which app do you want to download content for?" "$DEFAULT_APP")

if [ "$CHOSEN_APP" = "false" ] || [ -z "$CHOSEN_APP" ]; then
    echo "Cancelled."
    exit 0
fi

echo "Selected: $CHOSEN_APP"

# Map display name to CLI argument
case "$CHOSEN_APP" in
    "Logic Pro") APP_ARG="Logic" ;;
    "MainStage") APP_ARG="Mainstage" ;;
    "GarageBand") APP_ARG="GarageBand" ;;
esac

# --- Step 2: Choose scope ---
SCOPE=$(choose "\"Essential packages only (recommended)\", \"Full content library\"" "What would you like to download?" "\"Essential packages only (recommended)\"")

if [ "$SCOPE" = "false" ] || [ -z "$SCOPE" ]; then
    echo "Cancelled."
    exit 0
fi

LINKS_FILE="mandatory_download_links.txt"
if [[ "$SCOPE" == *"Full"* ]]; then
    LINKS_FILE="all_download_links.txt"
fi

echo "Scope: $SCOPE"

# --- Step 3: Check disk space ---
AVAILABLE_GB=$(df -g / | tail -1 | awk '{print $4}')
if [[ "$SCOPE" == *"Full"* ]] && [ "$AVAILABLE_GB" -lt 80 ]; then
    confirm "You have ${AVAILABLE_GB} GB free. The full library needs about 80-100 GB. You may run out of space.\n\nContinue anyway, or cancel and choose essential packages instead?" "Continue Anyway"
    if [ $? -ne 0 ]; then
        echo "Cancelled."
        exit 0
    fi
fi

# --- Step 4: Download the tool and generate links ---
echo ""
echo "Downloading lpx_links tool..."
curl -sL "$REPO_URL/tarball/master" | tar -xz -C "$TOOL_DIR" --strip-components 1

echo "Generating download links for $CHOSEN_APP..."
cd "$TOOL_DIR"
ruby lpx_links.rb -n "$APP_ARG"

if [ ! -f "$LINKS_DIR/$LINKS_FILE" ]; then
    dialog_error "Failed to generate download links. Please report this issue at:\n$REPO_URL/issues"
    exit 1
fi

LINK_COUNT=$(wc -l < "$LINKS_DIR/$LINKS_FILE" | tr -d ' ')
echo "Generated $LINK_COUNT download links."

# --- Step 5: Download content ---
confirm "Ready to download $LINK_COUNT packages for $CHOSEN_APP.\n\nFiles will be saved to:\n$DOWNLOAD_DIR\n\nThis may take a while depending on your internet speed." "Start Download"

if [ $? -ne 0 ]; then
    echo "Cancelled."
    exit 0
fi

mkdir -p "$DOWNLOAD_DIR"

# Use aria2 if available, otherwise fall back to curl
if command -v aria2c &> /dev/null; then
    echo ""
    echo "Downloading with aria2 (fast, parallel downloads)..."
    echo ""
    aria2c -c --auto-file-renaming=false \
        -j 5 --summary-interval=10 \
        -i "$LINKS_DIR/$LINKS_FILE" \
        -d "$DOWNLOAD_DIR"
else
    echo ""
    echo "Downloading with curl (aria2 not installed — downloads will be sequential)..."
    echo "Tip: Install aria2 via Homebrew (brew install aria2) for much faster downloads."
    echo ""
    CURRENT=0
    while IFS= read -r url; do
        url=$(echo "$url" | tr -d '[:space:]')
        [ -z "$url" ] && continue
        CURRENT=$((CURRENT + 1))
        FILENAME=$(basename "$url")
        if [ -f "$DOWNLOAD_DIR/$FILENAME" ]; then
            echo "[$CURRENT/$LINK_COUNT] Skipping $FILENAME (already exists)"
            continue
        fi
        echo "[$CURRENT/$LINK_COUNT] Downloading $FILENAME..."
        curl -s -L -C - -o "$DOWNLOAD_DIR/$FILENAME" "$url"
    done < "$LINKS_DIR/$LINKS_FILE"
fi

echo ""
echo "All downloads complete!"

# --- Step 6: Install packages ---
confirm "Downloads complete! Ready to install $LINK_COUNT packages.\n\nThis will install the content into $CHOSEN_APP.\nYou'll be asked for your Mac password." "Install"

if [ $? -ne 0 ]; then
    dialog "Downloads saved to:\n$DOWNLOAD_DIR\n\nYou can install them later by running:\nsudo $TOOL_DIR/scripts/install.sh $DOWNLOAD_DIR"
    exit 0
fi

echo ""
echo "Installing packages (this may take a few minutes)..."
echo ""

# Run the install script — it handles disk space checks and cleanup prompts
# Use osascript to get admin privileges via a native dialog
osascript -e "do shell script \"bash '$TOOL_DIR/scripts/install.sh' '$DOWNLOAD_DIR'\" with administrator privileges" 2>/dev/null

echo ""
echo "============================================"
echo "  All done!"
echo "============================================"
echo ""
echo "Open $CHOSEN_APP — your new content is ready to use."
echo ""

notify "Installation complete! Open $CHOSEN_APP to find your new content."
dialog "All done!\n\nOpen $CHOSEN_APP — your new sounds, loops, and instruments are ready to use."

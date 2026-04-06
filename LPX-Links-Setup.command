#!/bin/bash
# LPX Links Setup — Double-click this file to run
#
# Downloads and installs Logic Pro, MainStage, or GarageBand content.
# All user interaction happens via native macOS dialogs — no typing required.
#
# This is a .command file: macOS opens it in Terminal automatically
# when you double-click it.

# --- Configuration ---
REPO_URL="https://github.com/davidteren/lpx_links"
DOWNLOAD_DIR="$HOME/Downloads/logic_content"
LINKS_DIR="$HOME/Desktop/lpx_download_links"
TOOL_DIR=$(mktemp -d)
PARALLEL_DOWNLOADS=5

cleanup() {
    rm -rf "$TOOL_DIR"
}
trap cleanup EXIT

# --- Dialog helpers (native macOS) ---
dialog_info() {
    osascript -e "display dialog \"$1\" buttons {\"OK\"} default button \"OK\" with title \"LPX Links\" with icon note" >/dev/null 2>&1
}

dialog_error() {
    osascript -e "display dialog \"$1\" buttons {\"OK\"} default button \"OK\" with title \"LPX Links\" with icon stop" >/dev/null 2>&1
}

dialog_choose() {
    osascript -e "choose from list {$1} with prompt \"$2\" with title \"LPX Links\" default items {$3}" 2>/dev/null
}

dialog_confirm() {
    osascript -e "display dialog \"$1\" buttons {\"Cancel\", \"$2\"} default button \"$2\" with title \"LPX Links\" with icon note" >/dev/null 2>&1
    return $?
}

dialog_notify() {
    osascript -e "display notification \"$1\" with title \"LPX Links\"" 2>/dev/null
}

# --- Terminal formatting ---
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo ""
}

print_step() { echo -e "${BLUE}▸ $1${NC}"; }
print_ok()   { echo -e "${GREEN}✓ $1${NC}"; }
print_warn() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_err()  { echo -e "${RED}✗ $1${NC}"; }

# =============================================
print_header "LPX Links — Content Downloader"
# =============================================

# --- Detect installed apps ---
print_step "Checking for installed apps..."

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

[ "$HAS_LOGIC" = true ]      && print_ok "Logic Pro"
[ "$HAS_MAINSTAGE" = true ]  && print_ok "MainStage"
[ "$HAS_GARAGEBAND" = true ] && print_ok "GarageBand"

if [ "$HAS_LOGIC" = false ] && [ "$HAS_MAINSTAGE" = false ] && [ "$HAS_GARAGEBAND" = false ]; then
    print_err "No supported apps found."
    dialog_error "No supported apps found.\n\nPlease install Logic Pro, MainStage, or GarageBand first."
    exit 1
fi
echo ""

# --- Build app list for dialog ---
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

# --- Choose app ---
CHOSEN_APP=$(dialog_choose "$APP_LIST" "Which app do you want to download content for?" "$DEFAULT_APP")

if [ "$CHOSEN_APP" = "false" ] || [ -z "$CHOSEN_APP" ]; then
    echo "Cancelled by user."
    exit 0
fi

case "$CHOSEN_APP" in
    "Logic Pro") APP_ARG="Logic" ;;
    "MainStage") APP_ARG="Mainstage" ;;
    "GarageBand") APP_ARG="GarageBand" ;;
esac

print_ok "Selected: $CHOSEN_APP"

# --- Choose scope ---
SCOPE=$(dialog_choose \
    "\"Essential packages only (recommended)\", \"Full content library\"" \
    "What would you like to download?\n\nEssential packages include everything $CHOSEN_APP needs to work. The full library adds extra loops, instruments, and sounds." \
    "\"Essential packages only (recommended)\"")

if [ "$SCOPE" = "false" ] || [ -z "$SCOPE" ]; then
    echo "Cancelled by user."
    exit 0
fi

LINKS_FILE="mandatory_download_links.txt"
SCOPE_LABEL="essential"
if [[ "$SCOPE" == *"Full"* ]]; then
    LINKS_FILE="all_download_links.txt"
    SCOPE_LABEL="full"
fi

print_ok "Scope: $SCOPE_LABEL packages"

# --- Disk space check for full library ---
AVAILABLE_GB=$(df -g / | tail -1 | awk '{print $4}')
if [ "$SCOPE_LABEL" = "full" ] && [ "$AVAILABLE_GB" -lt 80 ]; then
    if ! dialog_confirm "You have ${AVAILABLE_GB} GB free. The full library needs about 80–100 GB. You may run out of space.\n\nContinue anyway?" "Continue Anyway"; then
        echo "Cancelled by user."
        exit 0
    fi
fi

# --- Download the tool and generate links ---
print_header "Step 1 of 3 — Generating download links"

print_step "Downloading lpx_links tool..."
if ! curl -sL "$REPO_URL/tarball/master" | tar -xz -C "$TOOL_DIR" --strip-components 1; then
    print_err "Failed to download lpx_links tool."
    dialog_error "Failed to download the tool. Please check your internet connection and try again."
    exit 1
fi
print_ok "Tool downloaded"

print_step "Reading $CHOSEN_APP content list..."
cd "$TOOL_DIR"
if ! ruby lpx_links.rb -n "$APP_ARG" 2>/dev/null; then
    print_err "Failed to generate links."
    dialog_error "Failed to read $CHOSEN_APP content list.\n\nMake sure $CHOSEN_APP is installed in your Applications folder."
    exit 1
fi

if [ ! -f "$LINKS_DIR/$LINKS_FILE" ]; then
    print_err "Link file not found."
    dialog_error "Failed to generate download links.\n\nPlease report this at:\n$REPO_URL/issues"
    exit 1
fi

LINK_COUNT=$(wc -l < "$LINKS_DIR/$LINKS_FILE" | tr -d ' ')
print_ok "Found $LINK_COUNT packages to download"
echo ""

# --- Confirm and start download ---
if ! dialog_confirm "Ready to download $LINK_COUNT $SCOPE_LABEL packages for $CHOSEN_APP.\n\nFiles will be saved to:\n$DOWNLOAD_DIR\n\nThis may take a while depending on your internet speed." "Start Download"; then
    echo "Cancelled by user."
    dialog_info "Your download links have been saved to:\n$LINKS_DIR\n\nYou can download them manually anytime."
    exit 0
fi

print_header "Step 2 of 3 — Downloading content"

mkdir -p "$DOWNLOAD_DIR"

if command -v aria2c &> /dev/null; then
    # --- Fast path: aria2 (parallel downloads with resume) ---
    print_ok "Using aria2 for fast parallel downloads"
    echo ""
    aria2c -c --auto-file-renaming=false \
        -j "$PARALLEL_DOWNLOADS" \
        --summary-interval=10 \
        -i "$LINKS_DIR/$LINKS_FILE" \
        -d "$DOWNLOAD_DIR"
else
    # --- Fallback: curl with parallel batches ---
    print_warn "aria2 not installed — using curl (slower but works fine)"
    print_step "Downloading $PARALLEL_DOWNLOADS files at a time..."
    echo ""

    CURRENT=0
    BATCH_PIDS=()

    while IFS= read -r url; do
        url=$(echo "$url" | tr -d '[:space:]')
        [ -z "$url" ] && continue
        CURRENT=$((CURRENT + 1))
        FILENAME=$(basename "$url")

        if [ -f "$DOWNLOAD_DIR/$FILENAME" ]; then
            echo -e "  ${GREEN}[$CURRENT/$LINK_COUNT]${NC} $FILENAME (already exists, skipping)"
            continue
        fi

        echo -e "  ${BLUE}[$CURRENT/$LINK_COUNT]${NC} $FILENAME"

        # Download in background
        curl -s -L -C - -o "$DOWNLOAD_DIR/$FILENAME" "$url" &
        BATCH_PIDS+=($!)

        # Wait for batch to complete before starting next batch
        if [ ${#BATCH_PIDS[@]} -ge $PARALLEL_DOWNLOADS ]; then
            wait "${BATCH_PIDS[@]}" 2>/dev/null
            BATCH_PIDS=()
        fi
    done < "$LINKS_DIR/$LINKS_FILE"

    # Wait for any remaining downloads
    if [ ${#BATCH_PIDS[@]} -gt 0 ]; then
        wait "${BATCH_PIDS[@]}" 2>/dev/null
    fi
fi

echo ""
print_ok "All $LINK_COUNT packages downloaded"

# --- Install packages ---
if ! dialog_confirm "Downloads complete!\n\nReady to install $LINK_COUNT packages into $CHOSEN_APP.\n\nYou'll be asked for your Mac password." "Install"; then
    dialog_info "Downloads saved to:\n$DOWNLOAD_DIR\n\nYou can install them later by running:\nsudo bash scripts/install.sh $DOWNLOAD_DIR\nfrom the lpx_links folder."
    exit 0
fi

print_header "Step 3 of 3 — Installing packages"

print_step "Installing $LINK_COUNT packages (this may take a few minutes)..."
echo ""

# The install script handles disk space checks and cleanup.
# Running via osascript gives us a native password dialog.
# No tty means install.sh uses non-interactive mode (auto-cleanup if space is tight).
INSTALL_SCRIPT="$TOOL_DIR/scripts/install.sh"
if ! osascript -e "do shell script \"bash '$INSTALL_SCRIPT' '$DOWNLOAD_DIR'\" with administrator privileges" 2>/dev/null; then
    print_err "Installation failed or was cancelled."
    dialog_error "Installation was cancelled or failed.\n\nYour downloaded files are still in:\n$DOWNLOAD_DIR\n\nYou can try again by double-clicking this file."
    exit 1
fi

# =============================================
print_header "All done!"
# =============================================

echo "Open $CHOSEN_APP — your new sounds, loops, and instruments are ready."
echo ""

dialog_notify "Installation complete! Open $CHOSEN_APP to find your new content."
dialog_info "All done!\n\nOpen $CHOSEN_APP — your new sounds, loops, and instruments are ready to use."

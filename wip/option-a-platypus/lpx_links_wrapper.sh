#!/bin/bash
# Platypus wrapper script for LPX Links
# Platypus interprets PROGRESS markers to update its progress bar UI
# See: https://sveinbjornt.org/platypus/documentation/

BUNDLE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOWNLOAD_DIR="$HOME/Downloads/logic_content"
LINKS_DIR="$HOME/Desktop/lpx_download_links"

# --- Detect installed apps ---
echo "Checking for installed apps..."

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
    echo "No supported apps found."
    echo "Please install Logic Pro, MainStage, or GarageBand first."
    exit 1
fi

# --- Choose app via dialog ---
APP_LIST=""
if [ "$HAS_LOGIC" = true ]; then APP_LIST="\"Logic Pro\""; fi
if [ "$HAS_MAINSTAGE" = true ]; then
    [ -n "$APP_LIST" ] && APP_LIST="$APP_LIST, "
    APP_LIST="${APP_LIST}\"MainStage\""
fi
if [ "$HAS_GARAGEBAND" = true ]; then
    [ -n "$APP_LIST" ] && APP_LIST="$APP_LIST, "
    APP_LIST="${APP_LIST}\"GarageBand\""
fi

CHOSEN_APP=$(osascript -e "choose from list {$APP_LIST} with prompt \"Which app?\" with title \"LPX Links\"" 2>/dev/null)
[ "$CHOSEN_APP" = "false" ] || [ -z "$CHOSEN_APP" ] && exit 0

case "$CHOSEN_APP" in
    "Logic Pro") APP_ARG="Logic" ;;
    "MainStage") APP_ARG="Mainstage" ;;
    "GarageBand") APP_ARG="GarageBand" ;;
esac

# --- Choose scope ---
SCOPE=$(osascript -e 'choose from list {"Essential packages only", "Full content library"} with prompt "What to download?" with title "LPX Links" default items {"Essential packages only"}' 2>/dev/null)
[ "$SCOPE" = "false" ] || [ -z "$SCOPE" ] && exit 0

LINKS_FILE="mandatory_download_links.txt"
[[ "$SCOPE" == *"Full"* ]] && LINKS_FILE="all_download_links.txt"

# --- Generate links ---
echo "PROGRESS:10"
echo "Generating download links for $CHOSEN_APP..."

cd "$BUNDLE_DIR"
ruby lpx_links.rb -n "$APP_ARG"

LINK_COUNT=$(wc -l < "$LINKS_DIR/$LINKS_FILE" | tr -d ' ')
echo "Found $LINK_COUNT packages."

# --- Download ---
echo "PROGRESS:20"
mkdir -p "$DOWNLOAD_DIR"

echo "Downloading $LINK_COUNT packages..."
echo "(This may take a while depending on your internet speed)"
echo ""

CURRENT=0
while IFS= read -r url; do
    url=$(echo "$url" | tr -d '[:space:]')
    [ -z "$url" ] && continue
    CURRENT=$((CURRENT + 1))
    PROGRESS=$((20 + (CURRENT * 60 / LINK_COUNT)))
    echo "PROGRESS:$PROGRESS"
    FILENAME=$(basename "$url")
    if [ -f "$DOWNLOAD_DIR/$FILENAME" ]; then
        echo "[$CURRENT/$LINK_COUNT] Skipping $FILENAME (exists)"
        continue
    fi
    echo "[$CURRENT/$LINK_COUNT] $FILENAME"
    curl -s -L -C - -o "$DOWNLOAD_DIR/$FILENAME" "$url"
done < "$LINKS_DIR/$LINKS_FILE"

# --- Install ---
echo "PROGRESS:85"
echo ""
echo "Installing packages..."

osascript -e "do shell script \"bash '$BUNDLE_DIR/scripts/install.sh' '$DOWNLOAD_DIR'\" with administrator privileges" 2>/dev/null

echo "PROGRESS:100"
echo ""
echo "All done! Open $CHOSEN_APP — your new content is ready."

osascript -e "display notification \"Installation complete!\" with title \"LPX Links\"" 2>/dev/null

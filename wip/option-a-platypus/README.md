# Option A: Platypus .app Bundle

## What is Platypus?

[Platypus](https://sveinbjornt.org/platypus/) creates native macOS `.app` bundles from scripts. The app shows a window with script output, handles admin privileges, and can be distributed as a `.dmg`.

## Setup

1. Install Platypus: `brew install --cask platypus`
2. Install the CLI tool: open Platypus.app → Preferences → Install Command Line Tool
3. Build the app:

```bash
platypus \
    --name "LPX Links" \
    --interface-type "Progress Bar" \
    --interpreter "/bin/bash" \
    --app-icon icon.icns \
    --author "David Teren" \
    --app-version "1.0.0" \
    --bundle-identifier "com.davidteren.lpx-links" \
    --optimize-nib \
    --overwrite \
    --bundled-file ../../lpx_links.rb \
    --bundled-file ../../lib \
    --bundled-file ../../scripts/install.sh \
    lpx_links_wrapper.sh \
    "LPX Links.app"
```

4. Create a DMG:

```bash
hdiutil create -volname "LPX Links" -srcfolder "LPX Links.app" -ov -format UDZO "LPX-Links-1.0.0.dmg"
```

## Files

- `lpx_links_wrapper.sh` — The script Platypus wraps. Uses PROGRESS markers that Platypus displays as a progress bar.
- `icon.icns` — App icon (TODO: create a music-themed icon)

## Notes

- Platypus apps are unsigned by default. Users will need to right-click → Open the first time.
- For proper distribution, sign with an Apple Developer certificate ($99/year).
- The app bundles our Ruby scripts inside the .app — no network access needed for the tool itself, only for downloading content from Apple's servers.

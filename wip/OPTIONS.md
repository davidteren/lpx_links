# Self-Contained Distribution Options

Research into making lpx_links a painless, self-contained experience for non-technical musicians.

## Current state

Users must: open Terminal → paste a `curl | tar | ruby` command → install aria2 via Homebrew → paste aria2 commands → paste a sudo install command. That's 4-5 Terminal interactions across 3 tools. The audience is musicians, not developers.

## The goal

One download, one action. A musician should be able to download something, open it, and have their Logic Pro content downloaded and installed — with clear progress and no Terminal knowledge required.

---

## Option A: macOS .app with Platypus (Recommended)

**What**: A native `.app` bundle the user double-clicks. It wraps our shell/Ruby scripts with a macOS GUI window showing progress output.

**How it works**: [Platypus](https://github.com/sveinbjornt/Platypus) (3.4k stars, actively maintained, v5.5.0 released Dec 2025) creates macOS `.app` bundles from scripts. It provides a native window that shows script output, handles drag-and-drop, and can request admin privileges.

**User experience**:
1. Download `LPX Links.app` from GitHub Releases
2. Double-click to open
3. App shows a friendly window, detects Logic Pro/MainStage/GarageBand
4. User picks which app and whether essential or full library
5. Downloads happen with progress shown in the window
6. Installs packages automatically
7. Done — open Logic Pro

**Effort**: Medium. Need to write a wrapper script that orchestrates the full flow (generate links → download via curl/aria2 → install), then package with Platypus.

**Pros**:
- Feels like a real Mac app — no Terminal
- Can be distributed as a `.dmg` with drag-to-Applications
- macOS system Ruby is sufficient (our script uses only stdlib)
- Platypus is well-maintained and open source (BSD license)
- Supports both Intel and Apple Silicon
- Can request admin password via native macOS dialog (for the install step)

**Cons**:
- Platypus is a build tool, not a runtime dependency — but we need it in our build pipeline
- macOS Gatekeeper: unsigned app will show "unidentified developer" warning (user must right-click → Open the first time). Signing requires Apple Developer Program ($99/year)
- aria2 still needs to be installed (or we fall back to curl for downloads, which is slower but works)

**Prototype**: See `wip/option-a-platypus/` — wrapper script ready for Platypus packaging.

---

## Option B: All-in-one shell script with GUI prompts

**What**: A single self-contained shell script that uses `osascript` (AppleScript) for GUI dialogs instead of Terminal prompts. User downloads and double-clicks a `.command` file.

**User experience**:
1. Download `LPX-Links-Setup.command` from GitHub Releases
2. Double-click to open (Terminal opens automatically but the script drives GUI dialogs)
3. macOS dialog: "Which app? Logic Pro / MainStage / GarageBand"
4. macOS dialog: "Essential packages only, or full library?"
5. Terminal shows download progress
6. macOS dialog asks for admin password (for install)
7. macOS notification: "Done! Open Logic Pro to find your new content."

**Effort**: Low-medium. The `.command` file extension tells macOS to run it in Terminal on double-click. We use `osascript` for the interactive parts so users don't type anything.

**Pros**:
- Zero dependencies — ships as a single file
- Uses macOS system Ruby (available on all supported macOS versions)
- `.command` files open Terminal automatically on double-click
- `osascript` dialogs feel native
- No code signing needed (it's just a script)
- No Gatekeeper issues (scripts aren't subject to the same checks as .app bundles)

**Cons**:
- Terminal window is visible (even though user doesn't type in it)
- Less polished than a real .app
- aria2 needs Homebrew, or we fall back to sequential `curl` downloads (slower)
- No app icon, no drag-to-Applications experience

**Prototype**: See `wip/option-b-command/` — working `.command` script.

---

## Option C: Homebrew tap

**What**: Users install via `brew install davidteren/tap/lpx-links`, which installs the Ruby script, aria2, and a `lpx-links` command.

**User experience**:
1. Open Terminal
2. Run: `brew install davidteren/tap/lpx-links`
3. Run: `lpx-links` (interactive — picks app, downloads, installs)

**Effort**: Low. Create a Homebrew tap repo (`homebrew-tap`) with a formula.

**Pros**:
- Standard macOS developer distribution channel
- Handles aria2 as a dependency automatically
- One install command, one run command
- Auto-updates via `brew upgrade`
- Works on Intel and Apple Silicon

**Cons**:
- Requires Homebrew (non-technical users likely don't have it)
- Still requires Terminal
- Two commands instead of one action
- The audience is musicians, not developers — Homebrew is foreign to them

**Prototype**: See `wip/option-c-homebrew/` — formula definition.

---

## Option D: Swift native app (long-term)

**What**: Rewrite the core logic in Swift with a native SwiftUI interface. Distribute as a signed `.app`.

**User experience**:
1. Download from Mac App Store or GitHub
2. Open the app
3. Beautiful native UI: pick your app, pick essential/full, click "Download"
4. Progress bars, estimated time, disk space indicator
5. Click "Install" when done
6. Done

**Effort**: High. Rewrite the Ruby logic in Swift, build a SwiftUI interface, handle `plutil`/JSON parsing natively, implement download manager (URLSession supports concurrent downloads natively), handle package installation.

**Pros**:
- Best possible user experience — fully native macOS app
- Can be distributed on the Mac App Store
- No Terminal, no Ruby, no Homebrew, no dependencies
- Proper code signing, no Gatekeeper warnings
- Native progress bars, notifications, dock icon
- Could add features like download scheduling, content browser

**Cons**:
- Significant development effort (weeks, not hours)
- Need Apple Developer Program for signing/notarization ($99/year)
- Must maintain two codebases (or deprecate the Ruby version)
- Swift/SwiftUI learning curve if not already familiar

**Prototype**: See `wip/option-d-swift/` — minimal Swift CLI proof-of-concept.

---

## Recommendation

**Start with Option B** (`.command` file with GUI dialogs) — it's the fastest to ship, requires zero dependencies, and dramatically improves the experience over the current multi-step Terminal workflow. A musician downloads one file, double-clicks it, answers two dialog boxes, and waits.

**Then build toward Option A** (Platypus `.app`) for a more polished experience. This can reuse the same wrapper script from Option B.

**Option C** (Homebrew tap) is worth doing in parallel — it's low effort and serves the developer/power-user audience who already have Homebrew.

**Option D** (Swift native) is the long-term dream but is a separate project.

## Download strategy without aria2

For Options A and B, we don't want to require Homebrew/aria2 for first-time users. macOS ships with `curl`, which supports:
- Resume (`-C -`)
- Parallel downloads (multiple background processes)
- Progress bars (`--progress-bar`)

A shell function that downloads files in parallel batches using `curl` (e.g., 5 at a time) with resume support would eliminate the aria2 dependency entirely for most users. Power users can still use aria2 if they have it.

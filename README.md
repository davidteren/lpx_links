# LPX Links

[![Ruby CI](https://github.com/davidteren/lpx_links/actions/workflows/ruby-ci.yml/badge.svg)](https://github.com/davidteren/lpx_links/actions/workflows/ruby-ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Download all your Logic Pro, MainStage, and GarageBand sounds, loops, and instruments — faster and more reliably than the built-in downloader.**

If you've ever sat waiting for the in-app downloader to crawl through hundreds of packages (or watched it fail halfway through), this tool is for you. It gives you direct download links so you can grab everything at full speed.

## Easiest way: one-click setup

If you've never used Terminal and just want everything done for you:

1. **[Download LPX-Links-Setup.command](https://github.com/davidteren/lpx_links/releases/latest/download/LPX-Links-Setup.command)**
2. **Double-click** the downloaded file
3. Follow the dialog boxes — pick your app, pick essential or full library, and wait

That's it. The tool detects your installed apps, downloads the content, and installs it. No Terminal knowledge needed.

> **First time?** macOS may say the file is from an unidentified developer. Right-click the file and choose **Open** instead of double-clicking, then click **Open** in the dialog.

---

## Manual setup (step by step)

If you prefer to run things yourself, or the one-click setup doesn't work for your situation, follow the steps below.

### What you'll need

- **Logic Pro**, **MainStage**, or **GarageBand** installed on your Mac
- **An internet connection** (the downloads are large)
- **Free disk space** — see [How much space do I need?](#how-much-space-do-i-need) below

### How to open Terminal

Every step below happens in **Terminal**, a built-in app on your Mac. If you've never used it:

1. Press **Cmd + Space** to open Spotlight search
2. Type **Terminal**
3. Press **Enter**

A window will appear with a text cursor — that's where you'll paste the commands from each step. To paste, press **Cmd + V**.

### Step 1: Generate your download links

**What this does:** Downloads a small tool to your Mac, reads your app installation to find all available content, and creates text files listing every download link. By default it generates links for Logic Pro. For MainStage or GarageBand, see the [quick reference](#quick-reference-for-experienced-users) below.

**How long it takes:** A few seconds.

Open Terminal and paste this command:

```bash
cd ~/Downloads && mkdir -p lpx_links/app && cd lpx_links/app && curl -#L https://github.com/davidteren/lpx_links/tarball/master | tar -xzv --strip-components 1 && ./lpx_links.rb
```

**What you'll see:** Some text will scroll in the Terminal window. When it finishes, a Finder window will open showing a folder called `lpx_download_links` on your Desktop with two files:

- **`mandatory_download_links.txt`** — the essential packages your app needs to function (28-38 depending on the app)
- **`all_download_links.txt`** — the complete content library (707-917 packages depending on the app)

### Step 2: Install the download tool (aria2)

**What this does:** Installs a small download manager called aria2 that can download many files at once, resume if your internet drops, and skip files you already have. You only need to do this once.

**How long it takes:** Under a minute.

```bash
curl -fsSL https://raw.githubusercontent.com/davidteren/lpx_links/main/scripts/install_aria2.sh | bash
```

**What you'll see:** The installer will ask you a couple of questions (just follow the prompts). When it's done, you'll see a green checkmark and a success message.

> If you already have [Homebrew](https://brew.sh) installed, you can also run `brew install aria2` instead.

### Step 3: Download your content

**What this does:** Downloads the actual sound files from Apple's servers to a folder on your Mac.

**How long it takes:** This depends on your internet speed. The essential packages take a few minutes. The full library can take 30 minutes to several hours.

**For the essential packages only** (recommended if you're short on space):
```bash
aria2c -c --auto-file-renaming=false -i ~/Desktop/lpx_download_links/mandatory_download_links.txt -d ~/Downloads/logic_content
```

**For everything** (the complete sound library):
```bash
aria2c -c --auto-file-renaming=false -i ~/Desktop/lpx_download_links/all_download_links.txt -d ~/Downloads/logic_content
```

**What you'll see:** Progress bars for each file being downloaded. You can close the Terminal and come back later — just run the same command again and it will pick up where it left off.

> **Tip:** If a download gets interrupted (laptop goes to sleep, internet drops), just run the same command again. It won't re-download files you already have.

### Step 4: Install the packages

**What this does:** Takes all the downloaded files and installs them into Logic Pro so your sounds, loops, and instruments are ready to use.

**How long it takes:** A few minutes, depending on how many packages you downloaded.

```bash
sudo ~/Downloads/lpx_links/app/scripts/install.sh ~/Downloads/logic_content
```

**What you'll see:** First, a summary showing how many packages were found and how much disk space you have. Then you'll be asked:

- **Option 1: Delete each package after it installs** — choose this if you're low on disk space (recommended)
- **Option 2: Keep the packages** — choose this if you want to keep the files for installing on another Mac

> **"It's asking for my password"** — The `sudo` command needs your Mac login password to install the packages. When you type your password, you won't see any characters appear on screen — that's normal. Just type it and press Enter.

After installation, open Logic Pro — all your new content will be there.

## How much space do I need?

| App | Packages | Essential download | Essential installed | Full download | Full installed |
|---|---|---|---|---|---|
| **Logic Pro** | 915 (28 essential) | ~1.3 GB | ~1.6 GB | ~78 GB | ~101 GB |
| **MainStage** | 917 (32 essential) | ~1.4 GB | ~1.8 GB | ~77 GB | ~100 GB |
| **GarageBand** | 707 (38 essential) | ~2.2 GB | ~2.7 GB | ~43 GB | ~56 GB |

If your Mac is low on space, start with the **essential packages** — they're only 1-3 GB and include everything the app needs to function fully. The rest is additional loops, instruments, and sound packs you can always add later.

> **Tip:** When installing, choose Option 1 ("delete after install") to avoid needing double the disk space.

## Troubleshooting

**"Command not found" when running lpx_links.rb**
Your Mac needs Ruby installed. All recent versions of macOS include it. If you've removed it, install Ruby via [Homebrew](https://brew.sh): `brew install ruby`

**"Logic Pro not found" / "MainStage not found" / "GarageBand not found"**
The tool reads your app installation to find the content list. Make sure the app is installed in your Applications folder before running Step 1. The tool supports all versions including the newer "Creator Studio" editions.

**Downloads are very slow**
Make sure you're using aria2 (Step 2). Without it, downloads go through your browser one at a time instead of in parallel.

**A download was interrupted**
Just run the same aria2 command again (Step 3). It automatically resumes where it left off and skips files you already have.

**"It's asking for my password" and nothing happens when I type**
That's normal — Terminal hides your password for security. Just type your Mac login password and press Enter.

**My disk filled up during installation**
See issue [#75](https://github.com/davidteren/lpx_links/issues/75). The latest version of the install script now checks disk space and lets you delete packages as they install. Re-download the tool (Step 1) and re-run the installer (Step 4).

**Something else went wrong?**
[Open an issue](https://github.com/davidteren/lpx_links/issues) on GitHub and we'll help you out.

## Quick reference (for experienced users)

```bash
# Generate links (Logic Pro is the default)
cd ~/Downloads && mkdir -p lpx_links/app && cd lpx_links/app && curl -#L https://github.com/davidteren/lpx_links/tarball/master | tar -xzv --strip-components 1 && ./lpx_links.rb

# For MainStage or GarageBand, use the -n flag:
./lpx_links.rb -n Mainstage
./lpx_links.rb -n GarageBand

# Install aria2
curl -fsSL https://raw.githubusercontent.com/davidteren/lpx_links/main/scripts/install_aria2.sh | bash

# Download (essential only)
aria2c -c --auto-file-renaming=false -i ~/Desktop/lpx_download_links/mandatory_download_links.txt -d ~/Downloads/logic_content

# Download (everything)
aria2c -c --auto-file-renaming=false -i ~/Desktop/lpx_download_links/all_download_links.txt -d ~/Downloads/logic_content

# Install
sudo ~/Downloads/lpx_links/app/scripts/install.sh ~/Downloads/logic_content
```

## Compatibility

- Logic Pro 11 / Logic Pro Creator Studio (current)
- Logic Pro X 10.x
- MainStage 3 / MainStage Creator Studio
- GarageBand 10.4+
- macOS Monterey (12) and later

## Version

**Current Version**: 1.0.0

See [CHANGELOG.md](CHANGELOG.md) for version history.

## For developers

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for development setup, testing, and contribution guidelines.

## Credits

Special thanks to [Matteo Ceruti (Matatata)](https://github.com/matatata) for the mandatory package list feature idea.

## License

MIT License — free to use, modify, and distribute. See [LICENSE](docs/LICENSE).

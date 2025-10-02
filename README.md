# lpx_links

[![Ruby CI](https://github.com/davidteren/lpx_links/actions/workflows/ruby-ci.yml/badge.svg)](https://github.com/davidteren/lpx_links/actions/workflows/ruby-ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Get direct download links for all Logic Pro and MainStage additional content. Download faster and more reliably than using the in-app downloader.

## What It Does

This tool creates text files with direct download links for all Logic Pro and MainStage sounds, loops, and instruments. Perfect for:
- Fresh Logic Pro installations
- Downloading content faster with a download manager
- Managing content across multiple machines
- Avoiding the slow in-app downloader

## Compatibility

✅ **Logic Pro 11** (current version)
✅ **Logic Pro X 10.x**
✅ **MainStage 3**
✅ **macOS** (requires Logic Pro or MainStage installed)

## Quick Start

### 1. Run the Tool

Open Terminal and paste one of these commands:

**For Logic Pro**:
```bash
cd ~/Downloads; mkdir -p lpx_links/app ; cd lpx_links/app ; curl -#L https://github.com/davidteren/lpx_links/tarball/master | tar -xzv --strip-components 1 ; ./lpx_links.rb -n Logic
```

**For MainStage**:
```bash
cd ~/Downloads; mkdir -p lpx_links/app ; cd lpx_links/app ; curl -#L https://github.com/davidteren/lpx_links/tarball/master | tar -xzv --strip-components 1 ; ./lpx_links.rb -n Mainstage
```

### 2. Find Your Links

The tool creates a folder on your Desktop called `lpx_download_links` with two files:
- **`mandatory_download_links.txt`** - Essential packages only (28 items)
- **`all_download_links.txt`** - Complete library (900+ items)

### 3. Download Content

You can download the content using any download manager or your browser.

## Recommended: Download with aria2

For faster, resumable downloads, use **aria2** (a download manager):

### Install aria2

Download and install: [aria2 v1.33.0 installer](https://github.com/aria2/aria2/releases/download/release-1.33.0/aria2-1.33.0-osx-darwin.dmg)

### Download Content

**Essential packages only** (28 items):
```bash
aria2c -c --auto-file-renaming=false -i ~/Desktop/lpx_download_links/mandatory_download_links.txt -d ~/Downloads/logic_content
```

**All packages** (900+ items):
```bash
aria2c -c --auto-file-renaming=false -i ~/Desktop/lpx_download_links/all_download_links.txt -d ~/Downloads/logic_content
```

**What these options do**:
- `-c` - Resume interrupted downloads
- `--auto-file-renaming=false` - Skip files that already exist (never re-download)
- `-i` - Path to the file with download links
- `-d` - Where to save the downloaded files

![aria2 download example](https://github.com/davidteren/lpx_links/blob/master/images/aria2_example.png?raw=true)

## Install Downloaded Packages

After downloading, install all packages with this command:

```bash
sudo ~/Downloads/lpx_links/app/install.sh ~/Downloads/logic_content
```

> **Note**: The install script needs a folder containing `.pkg` files, not the text file with links.

## Troubleshooting

**"Command not found" error**
Make sure you have Ruby installed. macOS includes Ruby by default.

**"Logic Pro not found" error**
The tool needs Logic Pro or MainStage installed to find the content list.

**Downloads are slow**
Use aria2 (see above) for much faster downloads with resume capability.

**Need help?**
[Open an issue](https://github.com/davidteren/lpx_links/issues) on GitHub.

## Version

**Current Version**: 0.0.10

See [CHANGELOG.md](CHANGELOG.md) for version history and release notes.

## For Developers

Want to contribute or modify the code? See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Development setup instructions
- Testing guidelines
- Code quality standards
- Pull request process

Technical documentation:
- [CONTRIBUTING.md](CONTRIBUTING.md) - Developer guide
- [BEST_PRACTICES.md](BEST_PRACTICES.md) - Code standards and architecture
- [TEST_WORKFLOW.md](TEST_WORKFLOW.md) - Testing documentation

## Credits

Special thanks to [Matteo Ceruti (Matatata)](https://github.com/matatata) for the mandatory package list feature idea.

## License

MIT License - Free to use, modify, and distribute. See [LICENSE](LICENSE) for details.


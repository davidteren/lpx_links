# aria2 Binary Distribution

This directory contains a pre-compiled aria2 binary for macOS to simplify installation for lpx_links users.

## Version Information

- **aria2 version**: 1.37.0
- **Architecture**: ARM64 (Apple Silicon)
- **Source**: Official Homebrew bottle
- **License**: GPL-2.0-or-later

## Why Bundle the Binary?

We bundle the aria2 binary to provide a seamless installation experience:

1. **No Homebrew Required**: Users don't need to install Homebrew
2. **No Authentication Issues**: Avoids GitHub Container Registry authentication complexities
3. **Faster Installation**: No need to download from external sources during installation
4. **Guaranteed Compatibility**: We control the exact version users receive

## Installation Script

The `scripts/install_aria2.sh` script installs this bundled binary to `/usr/local/bin/aria2c`.

## Updating the Binary

To update the aria2 binary in the future:

1. Install aria2 via Homebrew: `brew install aria2`
2. Copy the binary: `cp /opt/homebrew/Cellar/aria2/VERSION/bin/aria2c vendor/aria2/bin/`
3. Update this README with the new version information
4. Test the installation script

## License

aria2 is licensed under GPL-2.0-or-later. See https://github.com/aria2/aria2 for more information.


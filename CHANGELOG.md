# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-04-05

### Added
- **Disk space check in install script** - Checks available space before installing, warns when tight, lets users choose to delete packages after install to save space (#75)
- **Install script test suite** (`scripts/test_install_pkg.sh`) - 8 tests covering validation, disk reporting, and mode detection
- **CI test matrix** - Tests across Ruby 3.2, 3.3, 3.4, and 4.0 (all currently maintained versions)
- **macOS shell test job** in CI - Validates install scripts on the target platform
- **GitHub Pages site redesign** - Replaced marketing-style landing page with a practical, musician-friendly guide
- **aria2 installation script** (`scripts/install_aria2.sh`) - One-command installation of aria2 without requiring Homebrew
  - Automatic detection of macOS version and architecture (Intel/Apple Silicon)
  - Installs to `~/.local/bin/aria2c` (user directory, no sudo required)
  - Automatic shell detection and PATH configuration (supports zsh, bash, and other shells)
  - Homebrew detection with user choice between Homebrew or bundled binary
- CONTRIBUTING.md with comprehensive developer documentation
- **Bundled aria2 binary** - Pre-compiled aria2 v1.37.0 ARM64 binary for offline installation
- **Test scripts** for aria2 installation verification
- COPYRIGHT file documenting all contributors and license change rationale
- Minitest test framework with 90%+ coverage (34 tests, 65 assertions)
- Rakefile for running tests with `bundle exec rake test`

### Changed
- **README completely rewritten for musicians** - Plain language, step-by-step guide with explanations of what each command does, Terminal introduction for beginners, disk space guidance, and expanded troubleshooting
- **Install script overhauled** - Input validation, progress tracking (`[1/N]`), disk space summary, cleanup prompts, non-interactive mode support
- Updated minitest to 5.27.0 for Ruby 4.0 compatibility
- Migrated test suite from RSpec to Minitest
- Updated CI from single Ruby 3.3.1 to matrix of 3.2, 3.3, 3.4, 4.0
- Simplified aria2 installation from manual DMG to single command (v1.33.0 → v1.37.0)

### Fixed
- **Disk filling up during package installation** - Packages and installed content no longer coexist by default (#75)
- Fixed input handling where `upcase!` returned `nil` for already-uppercase input
- Fixed aria2 installer: 401 errors, `curl | bash` mode, checksum verification, non-interactive fallbacks
- All RuboCop linting issues resolved

## [0.0.11] - 2025-10-01

### Added
- Local workflow testing script (`test_local_workflow.sh`) for validating changes before pushing to GitHub
- Comprehensive testing documentation (`TEST_WORKFLOW.md`)
- RuboCop configuration file (`.rubocop.yml`) with reasonable metric limits
- RuboCop lint check to GitHub Actions CI workflow
- `.ruby-version` file specifying Ruby 3.3.1
- MIT License file

### Changed
- **License changed from GPL-3.0 to MIT** for better compatibility and community alignment
- Replaced global variable `$app_name` with module-level accessor pattern
- Refactored `app_path` method to reduce complexity by extracting logic into separate methods
- Converted `download_links` method to use keyword arguments (`only_mandatory:`)
- Standardized string quotes (double → single) throughout codebase
- Updated all tests to match new method signatures
- Changed `ENV['HOME']` to `Dir.home` for better Ruby idioms
- Updated README license badge and section with MIT license rationale

### Fixed
- All RuboCop linting issues (115 offenses → 0 offenses)
- Indentation and trailing whitespace issues
- Method complexity violations
- Line length violations in spec files

## [0.0.10] - 2023-07-01

### Added
- Support for MainStage application to get direct download links for sample/sound content
- Command-line argument `-n` / `--name` to specify application (Logic or MainStage)

### Changed
- Updated README with MainStage usage instructions

## [0.0.9] - 2023-04-15

### Fixed
- Install script no longer attempts to re-download pkg files

## [0.0.8] - 2023-03-03

### Added
- Logic to resolve relative parents in download URLs (fixes `../` path issues)

### Changed
- Updated README with improved instructions and examples

## [0.0.7] - 2023-04-02

### Added
- Mandatory file list feature (thanks to Matteo Ceruti aka [Matatata](https://github.com/matatata))
- Separate download links file for mandatory packages only

### Changed
- Refactored code structure for better maintainability

## [0.0.6] - 2023-03-03

### Added
- Version detection for Logic Pro X
- Support for both "Logic Pro X" and "Logic Pro" application names

### Changed
- Any version of Logic Pro X should now work

## Earlier Versions

Earlier version history was not tracked in a formal changelog.

---

## Types of Changes

- **Added** for new features
- **Changed** for changes in existing functionality
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Fixed** for any bug fixes
- **Security** in case of vulnerabilities

[Unreleased]: https://github.com/davidteren/lpx_links/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/davidteren/lpx_links/compare/v0.0.11...v1.0.0
[0.0.11]: https://github.com/davidteren/lpx_links/compare/v0.0.10...v0.0.11
[0.0.10]: https://github.com/davidteren/lpx_links/compare/v0.0.9...v0.0.10
[0.0.9]: https://github.com/davidteren/lpx_links/compare/v0.0.8...v0.0.9
[0.0.8]: https://github.com/davidteren/lpx_links/compare/v0.0.7...v0.0.8
[0.0.7]: https://github.com/davidteren/lpx_links/compare/v0.0.6...v0.0.7
[0.0.6]: https://github.com/davidteren/lpx_links/releases/tag/v0.0.6


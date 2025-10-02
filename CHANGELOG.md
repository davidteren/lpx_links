# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **aria2 installation script** (`scripts/install_aria2.sh`) - One-command installation of aria2 without requiring Homebrew
  - Automatic detection of macOS version and architecture (Intel/Apple Silicon)
  - Downloads official Homebrew bottles (aria2 v1.37.0)
  - Installs to `/usr/local/bin/aria2c` with verification
  - Color-coded output and error handling
  - **Homebrew detection** - Automatically detects if Homebrew is installed and offers user choice between Homebrew or bundled binary installation
- CONTRIBUTING.md with comprehensive developer documentation (setup, testing, code quality, PR process)
- **Bundled aria2 binary** - Pre-compiled aria2 v1.37.0 ARM64 binary in `vendor/aria2/bin/` for offline installation
- **Test scripts** for aria2 installation verification (`test_aria2_bundle.sh`, `test_installation_flow.sh`, `test_homebrew_detection.sh`)

### Changed
- **README.md aria2 installation instructions** - Replaced outdated v1.33.0 DMG installer with new one-command installation script
  - Updated from aria2 v1.33.0 (2017) to v1.37.0 (2023)
  - Simplified installation from manual DMG to single command
  - Added Homebrew as alternative installation method
- Improved file handling robustness in `print_file` method by using block form of `File.open` to ensure automatic file closure even if exceptions occur
- **aria2 installation approach** - Changed from downloading Homebrew bottles to bundling pre-compiled binary
  - Bundled aria2 v1.37.0 ARM64 binary in `vendor/aria2/bin/` directory
  - Eliminates GitHub Container Registry authentication issues
  - Provides faster, more reliable installation experience
  - Currently supports Apple Silicon (ARM64) only

### Fixed
- Fixed input handling logic in option parser where `upcase!` returned `nil` for already-uppercase input (e.g., 'LOGIC'), causing valid input to be rejected
- **aria2 installation script** - Fixed 401 Unauthorized error by bundling aria2 binary instead of downloading from GitHub Container Registry

### Changed
- **README.md rewritten for musicians** - User-focused content with plain language, clear steps, and no technical jargon
- Moved all developer/technical content from README.md to CONTRIBUTING.md
- Simplified installation and usage instructions for non-technical users
- Updated Logic Pro version references to Logic Pro 11 (current version)
- Reorganized documentation structure with clear separation between user and developer content

### Added
- COPYRIGHT file documenting all contributors and license change rationale
- Reference to COPYRIGHT file in README license section
- Minitest test framework with minitest-reporters for better output
- Rakefile for running tests with `bundle exec rake test`
- test/ directory structure following Rails conventions
- Comprehensive test coverage for edge cases and error handling (22 new tests)
- Tests for relative path resolution in download URLs
- Tests for error handling (invalid JSON, missing files, runtime errors)
- Tests for file system operations (directory creation, file writing)
- Tests for command execution (plutil, open commands)

### Changed
- **Migrated test suite from RSpec to Minitest** for better Rails alignment and TDD practices
- Updated GitHub Actions CI to run Minitest instead of RSpec
- Updated test_local_workflow.sh to run Minitest tests
- Updated all documentation (README.md, TEST_WORKFLOW.md) to reference Minitest
- Enabled warnings in Rakefile test configuration to catch potential code issues early
- **Restored test coverage threshold to 90%** in CI workflow (from 60%)
- Increased test coverage from 62.89% to 91.75% (89/97 lines covered)
- Updated .rubocop.yml to exclude test files from metrics cops

### Removed
- RSpec gem and all RSpec-related dependencies
- spec/ directory and all RSpec test files
- RSpec configuration files (.rspec, spec_helper.rb)

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

[Unreleased]: https://github.com/davidteren/lpx_links/compare/v0.0.10...HEAD
[0.0.10]: https://github.com/davidteren/lpx_links/compare/v0.0.9...v0.0.10
[0.0.9]: https://github.com/davidteren/lpx_links/compare/v0.0.8...v0.0.9
[0.0.8]: https://github.com/davidteren/lpx_links/compare/v0.0.7...v0.0.8
[0.0.7]: https://github.com/davidteren/lpx_links/compare/v0.0.6...v0.0.7
[0.0.6]: https://github.com/davidteren/lpx_links/releases/tag/v0.0.6


# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Local workflow testing script (`test_local_workflow.sh`) for validating changes before pushing to GitHub
- Comprehensive testing documentation (`TEST_WORKFLOW.md`)
- RuboCop configuration file (`.rubocop.yml`) with reasonable metric limits
- RuboCop lint check to GitHub Actions CI workflow
- `.ruby-version` file specifying Ruby 3.3.1

### Changed
- Replaced global variable `$app_name` with module-level accessor pattern
- Refactored `app_path` method to reduce complexity by extracting logic into separate methods
- Converted `download_links` method to use keyword arguments (`only_mandatory:`)
- Standardized string quotes (double → single) throughout codebase
- Updated all tests to match new method signatures
- Changed `ENV['HOME']` to `Dir.home` for better Ruby idioms

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


# AGENTS.md

Source of truth for AI coding agents working on this project. If you are an AI agent (Claude Code, Cursor, Copilot, Windsurf, etc.), read this file first.

## Project

Ruby CLI that generates direct download links for Logic Pro, MainStage, and GarageBand content. Users paste a single Terminal command, the tool reads Apple's content manifest from the installed app, and produces text files of download URLs. A companion install script handles bulk `.pkg` installation with disk space checks.

The audience is **musicians and producers**, many of whom have never used Terminal. All user-facing text must be plain language.

## Structure

```
lpx_links.rb                 # CLI entry point — arg parsing, orchestration, output
lib/file_helpers.rb           # App discovery, path resolution, URL helpers
scripts/install.sh            # Bulk .pkg installer with disk space check
scripts/install_aria2.sh      # aria2 download manager installer
scripts/test_install_pkg.sh   # Shell tests for install.sh
test/                         # Minitest suite (mirrors lib/ structure)
gh-pages/                     # GitHub Pages site source
docs/                         # LICENSE, COPYRIGHT
```

## How it works

1. `file_helpers.rb` locates the app (Logic Pro / MainStage / GarageBand) by checking known paths in order — including the newer "Creator Studio" app names
2. `plist_file_name` finds the content plist inside the app bundle (e.g. `logicpro1120.plist`, `garageband10412.plist`)
3. `plutil` converts the plist to JSON
4. `download_links` iterates packages, resolves relative paths, builds download URLs
5. Output is written to `~/Desktop/lpx_download_links/`

**Important**: The tool reads the plist from the user's installed app at runtime. We do not bundle, redistribute, or expose any plist data. The download links point to Apple's public content servers.

## Commands

```bash
# Run tests
bundle exec rake test

# Lint
rubocop

# Generate links (test end-to-end)
ruby lpx_links.rb                  # Logic Pro (default)
ruby lpx_links.rb -n Mainstage     # MainStage
ruby lpx_links.rb -n GarageBand    # GarageBand

# Shell tests
bash scripts/test_install_pkg.sh
```

## Tests

- Framework: Minitest + minitest-reporters + SimpleCov
- Coverage threshold: 90%+
- Tests use `stub` to isolate filesystem, shell calls, and environment — no installed apps required
- Shell tests in `scripts/test_install_pkg.sh` cover install.sh validation, disk reporting, and mode detection

## CI

GitHub Actions (`.github/workflows/ruby-ci.yml`):

| Job | Runner | What |
|-----|--------|------|
| lint | ubuntu | RuboCop, 0 offenses |
| test | ubuntu | Ruby 3.2, 3.3, 3.4, 4.0 matrix |
| shell-test | macOS | install.sh syntax + tests, install_aria2.sh syntax |

## Conventions

- Ruby target: 3.2 (`.rubocop.yml`)
- `frozen_string_literal: true` in all Ruby files
- `module_function` for stateless helper modules
- `File.join` for paths, `URI` + `Pathname#cleanpath` for URLs
- Memoize expensive reads (`@packages ||= ...`)
- snake_case files/methods, CamelCase modules
- Raise descriptive errors in helpers, rescue at top-level `run` with user-friendly messages

## App detection paths

Logic Pro checks in order:
1. `/Applications/Logic Pro Creator Studio.app/Contents/Resources`
2. `/Applications/Logic Pro.app/Contents/Resources`
3. `/Applications/Logic Pro X.app/Contents/Resources`

MainStage:
1. `/Applications/MainStage Creator Studio.app/Contents/Resources`
2. `/Applications/MainStage 3.app/Contents/Resources`
3. `/Applications/MainStage.app/Contents/Resources`

GarageBand:
1. `/Applications/GarageBand.app/Contents/Resources`

## Content sizes (measured April 2026)

| App | Total pkgs | Essential | Essential DL | Full DL | Full installed |
|-----|-----------|-----------|-------------|---------|---------------|
| Logic Pro | 915 | 28 | ~1.3 GB | ~78 GB | ~101 GB |
| MainStage | 917 | 32 | ~1.4 GB | ~77 GB | ~100 GB |
| GarageBand | 707 | 38 | ~2.2 GB | ~43 GB | ~56 GB |

## Workflow rules

- **Always work on a new branch** — never commit directly to `main`. Branch from `main` using `feature/`, `fix/`, `docs/`, `refactor/`, or `test/` prefix.
- Write tests for new behaviour, maintain 90%+ coverage
- Pass RuboCop with 0 offenses
- Run `bundle exec rake test` locally before pushing
- CI must be green before merge
- After merging, check out `main`, pull, and delete the merged local branch
- User-opened issues stay open until the user acknowledges — only close issues opened by `davidteren`

# 📘 Project Best Practices

## 1. Project Purpose
A small Ruby utility that extracts direct download URLs for Logic Pro X and MainStage additional content by parsing Apple-provided package metadata (plist converted to JSON). It generates organized text files with all links and mandatory-only links and opens the destination folder for user convenience. The project emphasizes reliability, clear CLI behavior, and a robust automated test suite.

## 2. Project Structure
- Root
  - `lpx_links.rb` — Main entry point executable (CLI). Handles argument parsing, orchestrates workflow, writes outputs, and opens the links directory.
  - `lib/file_helpers.rb` — Paths and URL helpers. Encapsulates application resource discovery and output locations.
  - `Rakefile` — Test task wiring for Minitest via `rake test`.
  - `Gemfile` — Development/test dependencies (Minitest, reporters, SimpleCov, Rake).
  - `.rubocop.yml` — Style and metrics configuration (Ruby 2.7 target).
  - Scripts/docs: `install.sh`, `test_local_workflow.sh`, `TEST_WORKFLOW.md`, `README.md`.
  - Meta/config: `.qodo_merge.toml` (PR review/quality automation), CI in `.github/`.
- `lib/` — Library code (non-executable code, helpers, utilities).
- `test/` — Minitest test suite
  - `test_helper.rb` — Test bootstrap (SimpleCov, reporters, requires app code).
  - `lib/file_helpers_test.rb`, `lpx_links_test.rb` — Unit tests.
- `images/` — Documentation assets.

Conventions
- Source files use `# frozen_string_literal: true` and idiomatic Ruby 2.7.
- File names are snake_case; modules/classes are CamelCase; methods are snake_case.
- Output artifacts are written to the user’s Desktop under `~/Desktop/lpx_download_links`.

## 3. Test Strategy
- Frameworks: Minitest + minitest-reporters (Spec reporter) + SimpleCov for coverage.
- Organization: Tests reside under `test/`, mirroring code locations (e.g., `test/lib/..._test.rb`). Files end with `_test.rb`.
- Execution:
  - Unit tests: `bundle exec rake test` or `rake test` if environment is set up.
  - Local end-to-end workflow: `./test_local_workflow.sh` (runs RuboCop, test suite, and simulates user flow).
- Mocking/Stubbing: Prefer Minitest’s built-in `stub` to isolate filesystem, environment, and shell calls:
  - Stub `File.read`, `File.exist?`, `Dir.home`, backticks (`` `cmd` ``), and helpers in `FileHelpers` as needed.
  - Keep tests deterministic and independent of host macOS setup.
- Coverage Expectations: Target 90%+ line coverage; cover success paths, edge cases, and error branches.
- Unit vs Integration:
  - Unit: Validate pure logic (path building, sorting, filtering, memoization, error propagation).
  - Integration/E2E: Use `test_local_workflow.sh` to simulate the full CLI pipeline and verify generated files where possible.

## 4. Code Style
- Ruby Version: Target Ruby 2.7 (see `.rubocop.yml`).
- Linting: Must pass RuboCop with project rules.
- Idioms:
  - Use `module_function` for modules with stateless helpers.
  - Prefer `File.join`, `URI`, and `Pathname#cleanpath` for robust path/URL handling.
  - Use memoization for cached computations (e.g., `@packages`). Clear/reset in tests when required.
  - Keep methods small and cohesive; respect configured metrics in `.rubocop.yml`.
- Naming:
  - Modules/Classes: CamelCase (`LpxLinks`, `FileHelpers`).
  - Methods/Variables: snake_case (`download_links`, `json_dir`).
  - Files: snake_case matching the primary class/module where applicable.
- Comments/Docs:
  - Use concise comments where non-obvious behavior exists (shelling out, side effects, OS assumptions).
  - Keep README/TEST_WORKFLOW.md up to date when user-facing behavior changes.
- Error Handling:
  - Raise clear errors in helpers (e.g., when app resources are missing) and handle at the top-level (`run`) with user-friendly messages and non-zero exit.
  - Avoid rescuing overly-broad exceptions unless necessary; allow JSON parsing errors to surface in tests when appropriate.
  - When shelling out, ensure quoting and safe input handling.

## 5. Common Patterns
- CLI Orchestration: `OptionParser` for flags (`-n/--name`, `-h/--help`).
- Shell Interactions: Backticks (`` `plutil ...` ``, `` `open ...` ``) for converting plist to JSON and opening directories. Inputs are derived from known paths to reduce risk.
- Path/URL Safety: `File.join` and `URI` to avoid malformed separators; `Pathname.cleanpath` to normalize relative segments like `../../`.
- Output Files: `print_file` writes arrays of lines; ensure newline semantics are preserved.
- Memoization: Cache expensive reads (e.g., packages) and reset between tests.
- Testing Practices: Heavy use of `stub` to isolate side effects; verify error messages, sorting, and edge cases.

## 6. Do's and Don'ts
- Do
  - Run `./test_local_workflow.sh` before pushing changes; it enforces RuboCop, tests, and basic workflow.
  - Keep code RuboCop-clean; adjust `.rubocop.yml` sparingly and with justification.
  - Add unit tests for new logic, including error branches and edge cases (nil/missing keys, empty structures).
  - Use `File.join`, `URI`, `Pathname.cleanpath` for all paths/URLs; avoid manual string concatenation.
  - Prefer non-bang methods for comparisons (e.g., `n.upcase == 'LOGIC'`) to avoid `nil` surprises from bang methods’ return values.
  - Keep user messaging clear and actionable on failures.
  - Stub external effects in tests (filesystem, environment, shell commands) to keep tests deterministic.
- Don't
  - Don’t introduce global state or hidden side effects; keep helpers pure where possible.
  - Don’t hardcode OS-specific assumptions beyond documented macOS tooling; always guard with checks and clear errors.
  - Don’t rescue and swallow exceptions that should fail fast or be validated by tests.
  - Don’t depend on network or actual installed apps in unit tests; use stubs.
  - Don’t change output file locations or formats without updating docs and tests.

## 7. Tools & Dependencies
- Runtime
  - Ruby (2.7 compatible environment)
  - macOS tools: `plutil` (for plist→JSON), `open` (to open output directory)
- Development/Test Gems (Gemfile)
  - `minitest` — Unit testing framework
  - `minitest-reporters` — Spec-style test output
  - `simplecov` — Code coverage
  - `rake` — Test task runner
- Linting
  - RuboCop with `.rubocop.yml` project rules
- Setup
  - Install Ruby dependencies: `bundle install`
  - Run tests: `bundle exec rake test`
  - Local workflow validation: `./test_local_workflow.sh`

## 8. Other Notes
- Platform Assumptions: macOS with Logic Pro or MainStage installed for the full workflow; unit tests do not require installed apps.
- File Outputs: Generated under `~/Desktop/lpx_download_links/` with `all_download_links.txt`, `mandatory_download_links.txt`, and `json/logicpro_content.json`.
- Safety & Reliability:
  - Avoid command injection by keeping shell inputs constrained to known paths and quoting arguments.
  - Ensure directory creation precedes any writes (`create_dirs`).
- Extensibility:
  - When adding new CLI options, extend `OptionParser`, keep defaults explicit, and document in README.
  - Add tests for new flags and behaviors; maintain 90%+ coverage.
- CI & Reviews:
  - GitHub Actions (in `.github/`) runs linting/tests on PRs.
  - `.qodo_merge.toml` enforces high-quality PR review standards; keep tests and coverage strong to pass automated checks.

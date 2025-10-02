# Contributing to lpx_links

Thank you for your interest in contributing to lpx_links! This guide will help you get started with development, testing, and submitting contributions.

## Table of Contents

- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Testing](#testing)
- [Code Quality Standards](#code-quality-standards)
- [Making Changes](#making-changes)
- [Submitting Pull Requests](#submitting-pull-requests)
- [CI/CD Pipeline](#cicd-pipeline)

## Development Setup

### Prerequisites

- **Ruby 2.7 or higher** (Ruby 3.3+ recommended)
- **Bundler** gem installed
- **Logic Pro** or **MainStage** installed (for full workflow testing)
- **Git** for version control

### Installation

1. **Fork and clone the repository**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/lpx_links.git
   cd lpx_links
   ```

2. **Install dependencies**:
   ```bash
   bundle install
   ```

3. **Verify installation**:
   ```bash
   bundle exec rake test
   ```

## Project Structure

```
lpx_links/
├── lpx_links.rb              # Main CLI entry point
├── lib/
│   └── file_helpers.rb       # Path and URL helper utilities
├── test/
│   ├── test_helper.rb        # Test configuration and setup
│   ├── lpx_links_test.rb     # Main application tests
│   └── lib/
│       └── file_helpers_test.rb  # Helper module tests
├── scripts/
│   ├── test_local_workflow.sh    # Local validation script
│   └── install.sh                # Package installation script
├── docs/
│   ├── CONTRIBUTING.md       # Developer guide
│   ├── BEST_PRACTICES.md     # Code standards
│   └── TEST_WORKFLOW.md      # Testing documentation
├── Rakefile                  # Test task definitions
├── Gemfile                   # Dependency management
└── .rubocop.yml              # RuboCop linting configuration
```

### Key Files

- **`lpx_links.rb`**: Main executable that handles CLI argument parsing, orchestrates the workflow, and generates output files
- **`lib/file_helpers.rb`**: Module containing path resolution, URL construction, and application discovery logic
- **`scripts/test_local_workflow.sh`**: Comprehensive local testing script that validates RuboCop compliance, runs tests, and simulates end-user workflow

## Testing

### Test Framework

This project uses **Minitest** with the following tools:
- **minitest-reporters**: Enhanced test output formatting
- **SimpleCov**: Code coverage tracking (90%+ required)
- **Rake**: Test task automation

### Running Tests

**Run the full test suite**:
```bash
bundle exec rake test
```

**Run with verbose output**:
```bash
ruby -Ilib:test test/lpx_links_test.rb -v
```

**Check code coverage**:
After running tests, open `coverage/index.html` in your browser to view the coverage report.

### Local Workflow Testing

**Always run the local workflow script before submitting a PR**:
```bash
./scripts/test_local_workflow.sh
```

This script:
1. ✅ Runs RuboCop linting (must have 0 offenses)
2. ✅ Executes the full test suite (all tests must pass)
3. ✅ Simulates end-user workflow in an isolated test directory
4. ✅ Validates generated output files
5. ✅ Verifies Logic Pro integration

See [TEST_WORKFLOW.md](TEST_WORKFLOW.md) for detailed documentation.

### Writing Tests

**Test Organization**:
- Tests mirror the source code structure
- Test files end with `_test.rb`
- Use descriptive test names: `test_method_name_does_something`

**Example Test**:
```ruby
def test_download_links_returns_sorted_results
  # Setup
  packages = [
    { 'DownloadName' => 'Package_B.pkg', 'IsMandatory' => false },
    { 'DownloadName' => 'Package_A.pkg', 'IsMandatory' => false }
  ]
  
  # Execute
  result = LpxLinks.download_links(packages, mandatory: false)
  
  # Assert
  assert_equal 2, result.size
  assert result[0].include?('Package_A.pkg')
  assert result[1].include?('Package_B.pkg')
end
```

**Mocking and Stubbing**:
Use Minitest's built-in `stub` method to isolate tests:
```ruby
def test_app_path_returns_correct_path
  FileHelpers.stub :find_logic_pro_path, '/Applications/Logic Pro.app' do
    result = FileHelpers.app_path('LOGIC')
    assert_equal '/Applications/Logic Pro.app', result
  end
end
```

## Code Quality Standards

### RuboCop Linting

**All code must pass RuboCop with 0 offenses**:
```bash
bundle exec rubocop
```

**Auto-fix safe offenses**:
```bash
bundle exec rubocop -a
```

**Configuration**: See `.rubocop.yml` for project-specific rules
- Target Ruby version: 2.7
- Custom metrics for test files
- Style preferences aligned with Ruby community standards

### Code Style Guidelines

**Ruby Idioms**:
- Use `frozen_string_literal: true` at the top of all files
- Prefer `File.join` for path construction
- Use `module_function` for stateless helper modules
- Keep methods small and focused (follow RuboCop metrics)

**Naming Conventions**:
- **Modules/Classes**: CamelCase (`LpxLinks`, `FileHelpers`)
- **Methods/Variables**: snake_case (`download_links`, `json_dir`)
- **Files**: snake_case (`file_helpers.rb`, `lpx_links_test.rb`)

**Best Practices**:
- Memoize expensive computations (e.g., `@packages ||= ...`)
- Handle errors gracefully with descriptive messages
- Use `Pathname#cleanpath` for path normalization
- Validate inputs and provide clear error messages

See [BEST_PRACTICES.md](BEST_PRACTICES.md) for comprehensive guidelines.

## Making Changes

### Branch Naming Convention

Use descriptive branch names with prefixes:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test improvements

**Examples**:
- `feature/add-logic-pro-11-support`
- `fix/issue-46-input-handling-logic`
- `docs/update-readme-installation`

### Commit Messages

Write clear, descriptive commit messages:

**Format**:
```
type: brief description (50 chars or less)

Detailed explanation if needed (wrap at 72 chars).
Include context, reasoning, and any breaking changes.

Resolves #123
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Test additions or modifications
- `chore`: Maintenance tasks

**Example**:
```
fix: correct input handling logic in option parser

- Replace mutating upcase! with non-mutating upcase
- Use Array#include? for cleaner multiple comparison
- Fixes issue where 'LOGIC' input was incorrectly rejected

Resolves #46
```

### Updating CHANGELOG

**Always update CHANGELOG.md** in the `[Unreleased]` section:

```markdown
## [Unreleased]

### Added
- New feature description

### Changed
- Modified behavior description

### Fixed
- Bug fix description
```

Follow [Keep a Changelog](https://keepachangelog.com/) format.

## Submitting Pull Requests

### Before Submitting

1. ✅ Run `./scripts/test_local_workflow.sh` - all checks must pass
2. ✅ Update CHANGELOG.md in the `[Unreleased]` section
3. ✅ Ensure RuboCop has 0 offenses
4. ✅ Verify all tests pass with 90%+ coverage
5. ✅ Write clear commit messages
6. ✅ Update documentation if needed

### Creating a Pull Request

1. **Push your branch**:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create PR using GitHub CLI** (recommended):
   ```bash
   gh pr create --title "Brief description" --body "Detailed description"
   ```

   Or use the GitHub web interface.

3. **PR Description Template**:
   ```markdown
   ## Summary
   Brief description of changes
   
   ## Problem
   What issue does this solve?
   
   ## Solution
   How does this PR address the problem?
   
   ## Testing
   - [ ] RuboCop: 0 offenses
   - [ ] All tests passing
   - [ ] Coverage: XX%
   - [ ] Local workflow test passed
   
   ## Changes
   - File 1: Description
   - File 2: Description
   
   Closes #XX
   ```

### PR Review Process

- **Automated Checks**: GitHub Actions CI runs RuboCop and tests
- **Qodo Merge**: Automated code review provides feedback
- **Manual Review**: Maintainers review code quality and design
- **Address Feedback**: Either fix issues immediately or create GitHub issues for backlog items

**Important**: Never leave automated review comments unaddressed. Either:
1. Fix the issue in the PR, or
2. Create a GitHub issue to track it as a backlog item

## CI/CD Pipeline

### GitHub Actions

The project uses GitHub Actions for continuous integration:

**Workflow**: `.github/workflows/ruby-ci.yml`

**Checks**:
1. **RuboCop Linting**: Must pass with 0 offenses
2. **Test Suite**: All tests must pass
3. **Code Coverage**: Must maintain 90%+ coverage
4. **Ruby Versions**: Tests run on multiple Ruby versions

**Viewing Results**:
- Check the "Actions" tab in GitHub
- PR status checks show pass/fail status
- Click "Details" to view full logs

### Qodo Merge Integration

Automated PR review tool configured in `.qodo_merge.toml`:
- Provides code quality feedback
- Suggests improvements
- Checks for common issues
- Reviews test coverage

## Getting Help

- **Issues**: Check [existing issues](https://github.com/davidteren/lpx_links/issues) or create a new one
- **Discussions**: Use GitHub Discussions for questions
- **Documentation**: See [README.md](../README.md), [BEST_PRACTICES.md](BEST_PRACTICES.md), and [TEST_WORKFLOW.md](TEST_WORKFLOW.md)

## Additional Resources

- [Ruby Style Guide](https://rubystyle.guide/)
- [Minitest Documentation](https://github.com/minitest/minitest)
- [RuboCop Documentation](https://docs.rubocop.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [Semantic Versioning](https://semver.org/)

---

Thank you for contributing to lpx_links! Your efforts help make this tool better for the Logic Pro and MainStage community. 🎹


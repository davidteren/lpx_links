# Local Workflow Testing Guide

This document explains how to use the `test_local_workflow.sh` script to validate changes before pushing to GitHub.

## Purpose

The `test_local_workflow.sh` script simulates the complete end-user workflow using your local code changes, allowing you to:

- Test changes without pushing to GitHub
- Validate that the workflow works end-to-end
- Ensure RuboCop linting passes
- Verify all tests pass
- Generate actual download links files for inspection

## Prerequisites

- Ruby installed (the version specified in `.ruby-version`)
- Logic Pro or Logic Pro X installed (for full workflow testing)
- RuboCop installed: `gem install rubocop`
- Bundler installed: `gem install bundler`
- Dependencies installed: `bundle install`

## Usage

### Basic Usage

Simply run the script from the repository root:

```bash
./test_local_workflow.sh
```

### What the Script Does

1. **Cleanup**: Removes any previous test runs
   - Deletes `~/Desktop/lpx_links_test/`
   - Deletes `~/Desktop/lpx_download_links/`
   - Removes temporary files

2. **Setup**: Creates a fresh test environment
   - Creates test directories on Desktop
   - Copies local code (not from GitHub)
   - Makes scripts executable
   - Shows current branch and last commit

3. **Prerequisites Check**: Verifies system requirements
   - Checks Ruby installation
   - Checks for Logic Pro / Logic Pro X
   - Checks for MainStage

4. **RuboCop Lint Check**: Runs linting
   - Executes `rubocop` on the codebase
   - Fails if any offenses are found

5. **Test Suite**: Runs Minitest tests
   - Executes `bundle exec rake test`
   - Fails if any tests fail

6. **Workflow Test**: Simulates user workflow
   - Runs `lpx_links.rb -n Logic`
   - Generates download links files
   - Verifies all expected files are created

7. **Results**: Displays summary
   - Shows generated files
   - Displays sample links
   - Provides next steps

## Output

The script provides color-coded output:

- 🔵 **Blue**: Step information
- ✅ **Green**: Success messages
- ⚠️ **Yellow**: Warnings (non-fatal)
- ❌ **Red**: Errors (fatal)

## Generated Files

After a successful run, you'll find:

- **Test Directory**: `~/Desktop/lpx_links_test/`
  - Contains a copy of your local code
  - Isolated from your working directory

- **Generated Links**: `~/Desktop/lpx_download_links/`
  - `all_download_links.txt` - All available packages
  - `mandatory_download_links.txt` - Essential packages only
  - `json/logicpro_content.json` - Full package metadata

## Testing Different Scenarios

### Test Current Branch

```bash
./test_local_workflow.sh
```

### Test After Making Changes

1. Make your code changes
2. Run the script again:
   ```bash
   ./test_local_workflow.sh
   ```
3. The script automatically cleans up and re-tests

### Test Different Branches

```bash
# Switch to the branch you want to test
git checkout feature/my-branch

# Run the test script
./test_local_workflow.sh
```

## Troubleshooting

### "Logic Pro not found" Warning

If you don't have Logic Pro installed, the workflow test will fail. This is expected. The script will still:
- Run RuboCop checks
- Run the test suite
- Validate code quality

### RuboCop Failures

If RuboCop fails:
1. Review the offenses listed
2. Fix the issues in your code
3. Run the script again

### Test Failures

If tests fail:
1. Review the failing test output
2. Fix the code or tests
3. Run the script again

### Script Permissions

If you get a "Permission denied" error:
```bash
chmod +x test_local_workflow.sh
```

## Integration with Development Workflow

### Recommended Workflow

1. **Make changes** to your code
2. **Run the test script**:
   ```bash
   ./test_local_workflow.sh
   ```
3. **Review generated files** in `~/Desktop/lpx_download_links/`
4. **If tests pass**, commit your changes:
   ```bash
   git add .
   git commit -m "Your commit message"
   ```
5. **Push to GitHub**:
   ```bash
   git push origin your-branch-name
   ```

### Before Creating a PR

Always run this script before creating or updating a pull request:

```bash
# Ensure you're on the right branch
git checkout fix/rubocop-linting

# Run the test script
./test_local_workflow.sh

# If all tests pass, push
git push origin fix/rubocop-linting
```

## What Gets Tested

### Code Quality
- ✅ RuboCop linting (0 offenses)
- ✅ All Minitest tests passing
- ✅ Code coverage maintained

### Functionality
- ✅ Script execution without errors
- ✅ File generation (all_download_links.txt)
- ✅ File generation (mandatory_download_links.txt)
- ✅ JSON generation (json/logicpro_content.json)
- ✅ Correct number of links generated

### User Experience
- ✅ Clean execution output
- ✅ Proper error handling
- ✅ Files created in expected locations

## Cleanup

The script automatically cleans up before each run. If you want to manually clean up:

```bash
rm -rf ~/Desktop/lpx_links_test
rm -rf ~/Desktop/lpx_download_links
```

## Notes

- The script uses **local code only** - it never pulls from GitHub
- Each run starts with a **clean slate** - previous test files are removed
- The script is **reusable** - run it as many times as needed
- Generated files are left for **manual inspection**
- The script **exits on first failure** to help identify issues quickly

## Example Output

```
========================================
  Local Workflow Testing Script
========================================

Repository: /Users/davidteren/Projects/LogicLinks/lpx_links
Test Directory: /Users/davidteren/Desktop/lpx_links_test

========================================
  Cleaning Up Previous Test Runs
========================================

==> Removing previous test directory: /Users/davidteren/Desktop/lpx_links_test
✓ Test directory removed
✓ Cleanup complete

========================================
  Setting Up Test Environment
========================================

==> Creating test directories
✓ Test directories created
==> Copying local code from: /Users/davidteren/Projects/LogicLinks/lpx_links
==>                      to: /Users/davidteren/Desktop/lpx_links_test/app
✓ Local code copied successfully
==> Testing code from branch: test/local-workflow-validation
==> Last commit: abc1234 Add local testing script

[... more output ...]

========================================
  All Tests Passed! ✓
========================================

✓ Local changes are working correctly
✓ You can now safely push your changes
```

## Contributing

If you find issues with the test script or have suggestions for improvements, please open an issue or submit a PR.


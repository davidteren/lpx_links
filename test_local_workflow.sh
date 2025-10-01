#!/bin/bash
# frozen_string_literal: true

# Local Workflow Testing Script for lpx_links
# This script simulates the end-user workflow using local code changes
# without pulling from GitHub, allowing validation before pushing to PR.

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$HOME/Desktop/lpx_links_test"
TEST_APP_DIR="$TEST_DIR/app"
TEST_DOWNLOAD_DIR="$TEST_DIR/downloads"
TEST_LINKS_DIR="$HOME/Desktop/lpx_download_links"

# Function to print colored output
print_step() {
    echo -e "${BLUE}==>${NC} ${1}"
}

print_success() {
    echo -e "${GREEN}✓${NC} ${1}"
}

print_error() {
    echo -e "${RED}✗${NC} ${1}"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} ${1}"
}

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  ${1}${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

# Function to clean up previous test runs
cleanup_previous_runs() {
    print_header "Cleaning Up Previous Test Runs"
    
    # Remove test directory
    if [ -d "$TEST_DIR" ]; then
        print_step "Removing previous test directory: $TEST_DIR"
        rm -rf "$TEST_DIR"
        print_success "Test directory removed"
    else
        print_success "No previous test directory found"
    fi
    
    # Remove generated links directory
    if [ -d "$TEST_LINKS_DIR" ]; then
        print_step "Removing previous links directory: $TEST_LINKS_DIR"
        rm -rf "$TEST_LINKS_DIR"
        print_success "Links directory removed"
    else
        print_success "No previous links directory found"
    fi
    
    # Remove temporary JSON file
    if [ -f "/tmp/lgp_content.json" ]; then
        print_step "Removing temporary JSON file"
        rm -f "/tmp/lgp_content.json"
        print_success "Temporary JSON file removed"
    fi
    
    print_success "Cleanup complete"
}

# Function to setup test environment
setup_test_environment() {
    print_header "Setting Up Test Environment"
    
    # Create test directories
    print_step "Creating test directories"
    mkdir -p "$TEST_APP_DIR"
    mkdir -p "$TEST_DOWNLOAD_DIR"
    print_success "Test directories created"
    
    # Copy local repository code to test directory
    print_step "Copying local code from: $REPO_ROOT"
    print_step "                     to: $TEST_APP_DIR"
    
    # Copy all necessary files
    cp -r "$REPO_ROOT/lib" "$TEST_APP_DIR/"
    cp "$REPO_ROOT/lpx_links.rb" "$TEST_APP_DIR/"
    cp "$REPO_ROOT/.rubocop.yml" "$TEST_APP_DIR/" 2>/dev/null || true
    
    # Make the script executable
    chmod +x "$TEST_APP_DIR/lpx_links.rb"
    
    print_success "Local code copied successfully"
    
    # Display current branch info
    cd "$REPO_ROOT"
    CURRENT_BRANCH=$(git branch --show-current)
    LAST_COMMIT=$(git log -1 --oneline)
    print_step "Testing code from branch: ${GREEN}$CURRENT_BRANCH${NC}"
    print_step "Last commit: $LAST_COMMIT"
}

# Function to check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check if Ruby is installed
    if command -v ruby &> /dev/null; then
        RUBY_VERSION=$(ruby --version)
        print_success "Ruby is installed: $RUBY_VERSION"
    else
        print_error "Ruby is not installed"
        exit 1
    fi
    
    # Check if Logic Pro or Logic Pro X is installed
    LOGIC_FOUND=false
    if [ -d "/Applications/Logic Pro X.app" ]; then
        print_success "Logic Pro X found at: /Applications/Logic Pro X.app"
        LOGIC_FOUND=true
    elif [ -d "/Applications/Logic Pro.app" ]; then
        print_success "Logic Pro found at: /Applications/Logic Pro.app"
        LOGIC_FOUND=true
    else
        print_warning "Logic Pro not found - script will fail when trying to read plist"
        print_warning "This is expected if you don't have Logic Pro installed"
    fi
    
    # Check if MainStage is installed
    if [ -d "/Applications/MainStage 3.app" ]; then
        print_success "MainStage 3 found at: /Applications/MainStage 3.app"
    else
        print_warning "MainStage 3 not found"
    fi
}

# Function to run RuboCop
run_rubocop() {
    print_header "Running RuboCop Lint Check"
    
    cd "$REPO_ROOT"
    
    if command -v rubocop &> /dev/null; then
        print_step "Running RuboCop..."
        if rubocop; then
            print_success "RuboCop passed - no offenses detected"
        else
            print_error "RuboCop found offenses"
            return 1
        fi
    else
        print_warning "RuboCop not installed - skipping lint check"
        print_warning "Install with: gem install rubocop"
    fi
}

# Function to run tests
run_tests() {
    print_header "Running Test Suite"

    cd "$REPO_ROOT"

    if [ -f "Gemfile" ] && command -v bundle &> /dev/null; then
        print_step "Running Minitest tests..."
        if bundle exec rake test; then
            print_success "All tests passed"
        else
            print_error "Tests failed"
            return 1
        fi
    else
        print_warning "Bundler not available or Gemfile not found - skipping tests"
    fi
}

# Function to test Logic Pro workflow
test_logic_workflow() {
    print_header "Testing Logic Pro Workflow"
    
    cd "$TEST_APP_DIR"
    
    print_step "Running: ./lpx_links.rb -n Logic"
    
    if ./lpx_links.rb -n Logic; then
        print_success "Logic Pro workflow completed successfully"
        
        # Check if files were created
        print_step "Verifying generated files..."
        
        if [ -f "$TEST_LINKS_DIR/all_download_links.txt" ]; then
            LINE_COUNT=$(wc -l < "$TEST_LINKS_DIR/all_download_links.txt")
            print_success "all_download_links.txt created ($LINE_COUNT links)"
        else
            print_error "all_download_links.txt not found"
            return 1
        fi
        
        if [ -f "$TEST_LINKS_DIR/mandatory_download_links.txt" ]; then
            LINE_COUNT=$(wc -l < "$TEST_LINKS_DIR/mandatory_download_links.txt")
            print_success "mandatory_download_links.txt created ($LINE_COUNT links)"
        else
            print_error "mandatory_download_links.txt not found"
            return 1
        fi
        
        if [ -f "$TEST_LINKS_DIR/json/logicpro_content.json" ]; then
            print_success "logicpro_content.json created"
        else
            print_error "logicpro_content.json not found"
            return 1
        fi
        
    else
        print_error "Logic Pro workflow failed"
        return 1
    fi
}

# Function to display test results
display_results() {
    print_header "Test Results Summary"
    
    echo "Test directory: $TEST_DIR"
    echo "Generated files location: $TEST_LINKS_DIR"
    echo ""
    
    if [ -d "$TEST_LINKS_DIR" ]; then
        print_step "Generated files:"
        ls -lh "$TEST_LINKS_DIR"
        echo ""
        
        # Show sample of links
        if [ -f "$TEST_LINKS_DIR/mandatory_download_links.txt" ]; then
            print_step "Sample from mandatory_download_links.txt (first 5 lines):"
            head -5 "$TEST_LINKS_DIR/mandatory_download_links.txt"
            echo ""
        fi
    fi
    
    print_success "Test files are available for inspection at: $TEST_LINKS_DIR"
}

# Main execution
main() {
    print_header "Local Workflow Testing Script"
    echo "Repository: $REPO_ROOT"
    echo "Test Directory: $TEST_DIR"
    echo ""
    
    # Run all steps
    cleanup_previous_runs
    setup_test_environment
    check_prerequisites
    
    # Run linting and tests
    if ! run_rubocop; then
        print_error "RuboCop check failed - fix linting issues before continuing"
        exit 1
    fi
    
    if ! run_tests; then
        print_error "Test suite failed - fix failing tests before continuing"
        exit 1
    fi
    
    # Test the actual workflow
    if ! test_logic_workflow; then
        print_error "Workflow test failed"
        exit 1
    fi
    
    # Display results
    display_results
    
    print_header "All Tests Passed! ✓"
    print_success "Local changes are working correctly"
    print_success "You can now safely push your changes"
    
    echo ""
    print_step "Next steps:"
    echo "  1. Review generated files in: $TEST_LINKS_DIR"
    echo "  2. If everything looks good, commit and push your changes"
    echo "  3. Run this script again after making new changes"
    echo ""
}

# Run main function
main


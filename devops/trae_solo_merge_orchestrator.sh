#!/bin/bash
################################################################################
# TRAE SOLO CODER - PR Merge Orchestrator
# Purpose: Execute individual PR merges with full verification
# PRs: 173, 174, 175, 177
# 
# Usage: ./trae_solo_merge_orchestrator.sh [--pr PR_NUMBER] [--all] [--verify-only]
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_OWNER="BobbyBlanco400"
REPO_NAME="nexus-cos"
BASE_BRANCH="main"
LOG_DIR="$(pwd)/logs/merge_orchestration"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="${LOG_DIR}/merge_${TIMESTAMP}.log"

# PR Configuration
declare -A PR_BRANCHES
PR_BRANCHES[173]="copilot/enhance-readme-nexcoin-section"
PR_BRANCHES[174]="copilot/fix-nexus-cos-platform-pf"
PR_BRANCHES[175]="copilot/create-canonical-execution-script"
PR_BRANCHES[177]="copilot/nation-by-nation-launch-orchestration"

declare -A PR_TITLES
PR_TITLES[173]="NexCoin wallet clarifications and founder beta purchase tiers"
PR_TITLES[174]="Nexus COS Expansion Layer: Jurisdiction toggle, marketplace, AI dealers"
PR_TITLES[175]="Feature-flag overlay system and canonical NexCoin documentation"
PR_TITLES[177]="Global Launch & Onboarding PF with nation-specific rollout"

# Create log directory
mkdir -p "${LOG_DIR}"

################################################################################
# Logging Functions
################################################################################

log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "${timestamp} [${level}] ${message}" | tee -a "${LOG_FILE}"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $@" | tee -a "${LOG_FILE}"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $@" | tee -a "${LOG_FILE}"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $@" | tee -a "${LOG_FILE}"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $@" | tee -a "${LOG_FILE}"
}

################################################################################
# Banner
################################################################################

print_banner() {
    echo -e "${GREEN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║          TRAE SOLO CODER - PR MERGE ORCHESTRATOR            ║
║                                                              ║
║    Safe, Individual PR Merging with Full Verification       ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

################################################################################
# Pre-Flight Checks
################################################################################

check_prerequisites() {
    log_info "Running pre-flight checks..."
    
    # Check if we're in a git repository
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        log_error "Not in a git repository!"
        exit 1
    fi
    
    # Check for required commands
    local required_commands=("git" "curl" "jq")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            log_error "Required command not found: $cmd"
            log_info "Please install: $cmd"
            exit 1
        fi
    done
    
    # Check git configuration
    if ! git config user.name > /dev/null 2>&1; then
        log_error "Git user.name not configured"
        exit 1
    fi
    
    if ! git config user.email > /dev/null 2>&1; then
        log_error "Git user.email not configured"
        exit 1
    fi
    
    log_success "Pre-flight checks passed"
}

################################################################################
# Repository State Check
################################################################################

check_repository_state() {
    log_info "Checking repository state..."
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        log_error "Uncommitted changes detected!"
        log_info "Please commit or stash changes before running merge orchestrator"
        git status --short
        exit 1
    fi
    
    # Check current branch
    local current_branch=$(git branch --show-current)
    log_info "Current branch: ${current_branch}"
    
    # Fetch latest from origin
    log_info "Fetching latest changes from origin..."
    git fetch origin --prune || {
        log_error "Failed to fetch from origin"
        exit 1
    }
    
    log_success "Repository state check complete"
}

################################################################################
# PR Status Check
################################################################################

check_pr_status() {
    local pr_number=$1
    log_info "Checking status of PR #${pr_number}..."
    
    # Use GitHub API to check PR status
    local api_url="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/pulls/${pr_number}"
    local pr_data=$(curl -s "${api_url}")
    
    local state=$(echo "${pr_data}" | jq -r '.state')
    local merged=$(echo "${pr_data}" | jq -r '.merged')
    local mergeable=$(echo "${pr_data}" | jq -r '.mergeable')
    local draft=$(echo "${pr_data}" | jq -r '.draft')
    
    log_info "PR #${pr_number} Status:"
    log_info "  State: ${state}"
    log_info "  Merged: ${merged}"
    log_info "  Mergeable: ${mergeable}"
    log_info "  Draft: ${draft}"
    
    if [ "${merged}" = "true" ]; then
        log_warning "PR #${pr_number} is already merged"
        return 2
    fi
    
    if [ "${state}" != "open" ]; then
        log_warning "PR #${pr_number} is not open (state: ${state})"
        return 3
    fi
    
    if [ "${draft}" = "true" ]; then
        log_warning "PR #${pr_number} is still in draft mode"
        return 4
    fi
    
    if [ "${mergeable}" = "false" ]; then
        log_error "PR #${pr_number} has merge conflicts"
        return 1
    fi
    
    log_success "PR #${pr_number} is ready to merge"
    return 0
}

################################################################################
# Branch Verification
################################################################################

verify_branch_exists() {
    local branch_name=$1
    local pr_number=$2
    
    log_info "Verifying branch exists: ${branch_name}"
    
    # Try to fetch the specific branch
    if git fetch origin "${branch_name}:refs/remotes/origin/${branch_name}" 2>/dev/null; then
        log_success "Branch ${branch_name} exists and fetched"
        return 0
    else
        log_error "Branch ${branch_name} for PR #${pr_number} not found"
        log_info "This branch may have been deleted after merge"
        return 1
    fi
}

################################################################################
# Pre-Merge Validation
################################################################################

pre_merge_validation() {
    local pr_number=$1
    local branch_name=$2
    
    log_info "Running pre-merge validation for PR #${pr_number}..."
    
    # Create a temporary branch for testing
    local test_branch="test-merge-pr-${pr_number}-${TIMESTAMP}"
    
    log_info "Creating test merge branch: ${test_branch}"
    git checkout -b "${test_branch}" "${BASE_BRANCH}" || {
        log_error "Failed to create test branch"
        return 1
    }
    
    # Attempt test merge
    log_info "Attempting test merge..."
    if git merge --no-commit --no-ff "origin/${branch_name}" 2>&1 | tee -a "${LOG_FILE}"; then
        log_success "Test merge successful - no conflicts"
        
        # Abort the test merge
        git merge --abort 2>/dev/null || true
        
        # Clean up test branch
        git checkout "${BASE_BRANCH}"
        git branch -D "${test_branch}"
        
        return 0
    else
        log_error "Test merge failed - conflicts detected"
        
        # Show conflict files
        log_info "Conflicted files:"
        git diff --name-only --diff-filter=U | tee -a "${LOG_FILE}"
        
        # Abort the test merge
        git merge --abort 2>/dev/null || true
        
        # Clean up test branch
        git checkout "${BASE_BRANCH}" 2>/dev/null
        git branch -D "${test_branch}" 2>/dev/null
        
        return 1
    fi
}

################################################################################
# Merge PR
################################################################################

merge_pr() {
    local pr_number=$1
    local branch_name=$2
    local pr_title="${PR_TITLES[$pr_number]}"
    
    log_info "============================================"
    log_info "Merging PR #${pr_number}: ${pr_title}"
    log_info "Branch: ${branch_name}"
    log_info "============================================"
    
    # Ensure we're on the base branch
    log_info "Switching to ${BASE_BRANCH} branch..."
    git checkout "${BASE_BRANCH}" || {
        log_error "Failed to checkout ${BASE_BRANCH}"
        return 1
    }
    
    # Pull latest changes
    log_info "Pulling latest changes from ${BASE_BRANCH}..."
    git pull origin "${BASE_BRANCH}" || {
        log_warning "Failed to pull from ${BASE_BRANCH} - it may not exist yet"
        # This is okay for initial setup
    }
    
    # Fetch the PR branch
    log_info "Fetching PR branch: ${branch_name}..."
    if ! git fetch origin "${branch_name}"; then
        log_error "Failed to fetch branch ${branch_name}"
        return 1
    fi
    
    # Perform the merge
    local merge_message="Merge pull request #${pr_number} from ${REPO_OWNER}/${branch_name}

${pr_title}

Merged individually via TRAE SOLO CODER Merge Orchestrator
Timestamp: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
"
    
    log_info "Performing merge..."
    if git merge --no-ff -m "${merge_message}" "origin/${branch_name}"; then
        log_success "Merge completed successfully"
        
        # Show merge summary
        log_info "Merge summary:"
        git show --stat HEAD | tee -a "${LOG_FILE}"
        
        return 0
    else
        log_error "Merge failed!"
        log_info "Merge conflicts detected. Manual resolution required."
        
        # Show conflicted files
        log_info "Conflicted files:"
        git diff --name-only --diff-filter=U | tee -a "${LOG_FILE}"
        
        # Provide instructions
        log_info ""
        log_info "To resolve conflicts:"
        log_info "  1. Edit conflicted files"
        log_info "  2. Run: git add <resolved-files>"
        log_info "  3. Run: git commit"
        log_info "  4. Re-run this script to continue"
        log_info ""
        log_info "To abort merge:"
        log_info "  git merge --abort"
        
        return 1
    fi
}

################################################################################
# Post-Merge Verification
################################################################################

post_merge_verification() {
    local pr_number=$1
    
    log_info "Running post-merge verification for PR #${pr_number}..."
    
    # Verify merge commit exists
    local latest_commit=$(git rev-parse HEAD)
    log_info "Latest commit: ${latest_commit}"
    
    # Check if it's a merge commit
    local parent_count=$(git cat-file -p HEAD | grep "^parent" | wc -l)
    if [ "$parent_count" -ge 2 ]; then
        log_success "Merge commit verified (${parent_count} parents)"
    else
        log_warning "This doesn't appear to be a merge commit"
    fi
    
    # Show changed files
    log_info "Files changed in this merge:"
    git diff-tree --no-commit-id --name-status -r HEAD | head -20 | tee -a "${LOG_FILE}"
    
    # Check for common issues
    log_info "Checking for potential issues..."
    
    # Check for merge conflict markers
    if git grep -n "<<<<<<< HEAD" || git grep -n ">>>>>>> " || git grep -n "=======" ; then
        log_error "Merge conflict markers still present in files!"
        return 1
    fi
    
    log_success "Post-merge verification complete"
    return 0
}

################################################################################
# Push Changes
################################################################################

push_changes() {
    log_info "Pushing changes to origin..."
    
    # Ask for confirmation in interactive mode
    if [ -t 0 ]; then
        read -p "Push changes to origin/${BASE_BRANCH}? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_warning "Push cancelled by user"
            return 1
        fi
    fi
    
    if git push origin "${BASE_BRANCH}"; then
        log_success "Changes pushed successfully"
        return 0
    else
        log_error "Failed to push changes"
        log_info "You may need to push manually: git push origin ${BASE_BRANCH}"
        return 1
    fi
}

################################################################################
# Process Single PR
################################################################################

process_pr() {
    local pr_number=$1
    local branch_name="${PR_BRANCHES[$pr_number]}"
    
    if [ -z "${branch_name}" ]; then
        log_error "Unknown PR number: ${pr_number}"
        log_info "Valid PR numbers: ${!PR_BRANCHES[@]}"
        return 1
    fi
    
    log_info ""
    log_info "╔════════════════════════════════════════╗"
    log_info "║  Processing PR #${pr_number}                    ║"
    log_info "╚════════════════════════════════════════╝"
    log_info ""
    
    # Check PR status via API
    check_pr_status "${pr_number}"
    local pr_status=$?
    
    case $pr_status in
        2)
            log_warning "Skipping PR #${pr_number} - already merged"
            return 0
            ;;
        3)
            log_warning "Skipping PR #${pr_number} - not open"
            return 0
            ;;
        4)
            log_warning "Skipping PR #${pr_number} - still in draft"
            return 0
            ;;
        1)
            log_error "PR #${pr_number} has conflicts and cannot be merged"
            return 1
            ;;
    esac
    
    # Verify branch exists
    if ! verify_branch_exists "${branch_name}" "${pr_number}"; then
        log_warning "Skipping PR #${pr_number} - branch not available"
        return 0
    fi
    
    # Run pre-merge validation
    if ! pre_merge_validation "${pr_number}" "${branch_name}"; then
        log_error "Pre-merge validation failed for PR #${pr_number}"
        return 1
    fi
    
    # Perform the merge
    if ! merge_pr "${pr_number}" "${branch_name}"; then
        log_error "Merge failed for PR #${pr_number}"
        return 1
    fi
    
    # Run post-merge verification
    if ! post_merge_verification "${pr_number}"; then
        log_error "Post-merge verification failed for PR #${pr_number}"
        return 1
    fi
    
    # Push changes
    if ! push_changes; then
        log_warning "Changes not pushed - you may need to push manually"
    fi
    
    log_success "PR #${pr_number} processed successfully!"
    return 0
}

################################################################################
# Process All PRs
################################################################################

process_all_prs() {
    log_info "Processing all PRs in sequence: 173, 174, 175, 177"
    
    local prs_to_process=(173 174 175 177)
    local failed_prs=()
    local success_count=0
    
    for pr in "${prs_to_process[@]}"; do
        log_info ""
        log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        log_info "Starting PR #${pr}"
        log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        if process_pr "${pr}"; then
            ((success_count++))
            log_success "PR #${pr} completed successfully"
        else
            failed_prs+=("${pr}")
            log_error "PR #${pr} failed"
            
            # Ask whether to continue
            if [ -t 0 ]; then
                read -p "Continue with remaining PRs? (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    log_warning "Stopping at user request"
                    break
                fi
            else
                log_warning "Stopping due to failure in non-interactive mode"
                break
            fi
        fi
        
        # Wait between PRs
        log_info "Waiting 5 seconds before next PR..."
        sleep 5
    done
    
    # Final summary
    log_info ""
    log_info "════════════════════════════════════════"
    log_info "  MERGE ORCHESTRATION SUMMARY"
    log_info "════════════════════════════════════════"
    log_info "Successfully processed: ${success_count}/4 PRs"
    
    if [ ${#failed_prs[@]} -gt 0 ]; then
        log_error "Failed PRs: ${failed_prs[*]}"
        return 1
    else
        log_success "All PRs processed successfully!"
        return 0
    fi
}

################################################################################
# Verify Only Mode
################################################################################

verify_only_mode() {
    log_info "Running in verification-only mode"
    log_info "No merges will be performed"
    
    local prs_to_check=(173 174 175 177)
    
    for pr in "${prs_to_check[@]}"; do
        local branch_name="${PR_BRANCHES[$pr]}"
        
        log_info ""
        log_info "Checking PR #${pr}..."
        
        check_pr_status "${pr}"
        verify_branch_exists "${branch_name}" "${pr}"
    done
    
    log_success "Verification complete"
}

################################################################################
# Main Function
################################################################################

main() {
    print_banner
    
    # Parse arguments
    local pr_number=""
    local process_all=false
    local verify_only=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --pr)
                pr_number="$2"
                shift 2
                ;;
            --all)
                process_all=true
                shift
                ;;
            --verify-only)
                verify_only=true
                shift
                ;;
            --help|-h)
                cat << EOF
Usage: $0 [OPTIONS]

Options:
    --pr PR_NUMBER      Merge a specific PR (173, 174, 175, or 177)
    --all               Merge all PRs in sequence
    --verify-only       Check PR status without merging
    --help, -h          Show this help message

Examples:
    $0 --pr 173         # Merge PR #173 only
    $0 --all            # Merge all PRs in sequence
    $0 --verify-only    # Check status of all PRs

EOF
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                log_info "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    # Run checks
    check_prerequisites
    check_repository_state
    
    # Execute requested action
    if [ "${verify_only}" = true ]; then
        verify_only_mode
    elif [ "${process_all}" = true ]; then
        process_all_prs
    elif [ -n "${pr_number}" ]; then
        process_pr "${pr_number}"
    else
        log_error "No action specified"
        log_info "Use --pr, --all, or --verify-only"
        log_info "Use --help for more information"
        exit 1
    fi
    
    log_info ""
    log_success "Merge orchestrator complete!"
    log_info "Log file: ${LOG_FILE}"
}

# Run main function
main "$@"

# TRAE SOLO CODER - Merge Orchestration Guide

## 🎯 Purpose

This document provides complete instructions for **TRAE SOLO CODER** to execute individual PR merges flawlessly for PRs **173, 174, 175, and 177** in the nexus-cos repository.

## 📋 Overview

### PRs to Process

| PR # | Status | Branch | Title |
|------|--------|--------|-------|
| 173 | ✅ Merged | `copilot/enhance-readme-nexcoin-section` | NexCoin wallet clarifications and founder beta purchase tiers |
| 174 | 🔄 Open/Draft | `copilot/fix-nexus-cos-platform-pf` | Nexus COS Expansion Layer: Jurisdiction toggle, marketplace, AI dealers |
| 175 | ✅ Merged | `copilot/create-canonical-execution-script` | Feature-flag overlay system and canonical NexCoin documentation |
| 177 | ✅ Merged | `copilot/nation-by-nation-launch-orchestration` | Global Launch & Onboarding PF with nation-specific rollout |

### Why Individual Merging?

The merge orchestrator processes PRs individually to:
- ✅ Prevent cascading merge conflicts
- ✅ Allow proper verification after each merge
- ✅ Enable rollback of specific changes if needed
- ✅ Maintain clean git history
- ✅ Ensure each feature layer is properly integrated

## 🚀 Quick Start

### Option 1: Verify Status First (Recommended)

```bash
cd /home/runner/work/nexus-cos/nexus-cos
chmod +x devops/trae_solo_merge_orchestrator.sh
./devops/trae_solo_merge_orchestrator.sh --verify-only
```

### Option 2: Merge Single PR

```bash
./devops/trae_solo_merge_orchestrator.sh --pr 174
```

### Option 3: Merge All PRs in Sequence

```bash
./devops/trae_solo_merge_orchestrator.sh --all
```

## 📖 Detailed Instructions

### Prerequisites

The script automatically checks for:
- ✅ Git repository
- ✅ Required commands: `git`, `curl`, `jq`
- ✅ Git user configuration
- ✅ Clean working directory (no uncommitted changes)

### Step-by-Step Execution

#### Step 1: Navigate to Repository

```bash
cd /home/runner/work/nexus-cos/nexus-cos
```

#### Step 2: Make Script Executable

```bash
chmod +x devops/trae_solo_merge_orchestrator.sh
```

#### Step 3: Verify PR Status

Check all PRs without making changes:

```bash
./devops/trae_solo_merge_orchestrator.sh --verify-only
```

This will show:
- Current PR status (open, merged, draft)
- Branch availability
- Merge readiness

#### Step 4: Process PRs Individually

For PR that needs attention (likely PR #174):

```bash
./devops/trae_solo_merge_orchestrator.sh --pr 174
```

The script will:
1. ✅ Check PR status via GitHub API
2. ✅ Verify branch exists
3. ✅ Run pre-merge validation (test merge for conflicts)
4. ✅ Perform actual merge
5. ✅ Run post-merge verification
6. ✅ Push changes (with confirmation)

#### Step 5: Alternative - Process All PRs

To process all PRs in sequence (173, 174, 175, 177):

```bash
./devops/trae_solo_merge_orchestrator.sh --all
```

**Note**: This will:
- Skip already-merged PRs automatically
- Stop on first failure (in non-interactive mode)
- Ask for confirmation to continue (in interactive mode)
- Wait 5 seconds between PRs

## 🔍 Understanding the Output

### Success Messages

```
[SUCCESS] Pre-flight checks passed
[SUCCESS] Repository state check complete
[SUCCESS] PR #174 is ready to merge
[SUCCESS] Test merge successful - no conflicts
[SUCCESS] Merge completed successfully
[SUCCESS] Post-merge verification complete
[SUCCESS] Changes pushed successfully
[SUCCESS] PR #174 processed successfully!
```

### Warning Messages

```
[WARNING] PR #173 is already merged
[WARNING] Skipping PR #173 - already merged
```

These are normal for already-merged PRs.

### Error Messages

```
[ERROR] PR #174 has merge conflicts
[ERROR] Pre-merge validation failed
[ERROR] Merge failed!
```

If you see errors, see **Troubleshooting** section below.

## 🛠️ Troubleshooting

### Merge Conflicts

If the script reports merge conflicts:

```bash
# View conflicted files
git status

# Edit each conflicted file
# Look for:
#   <<<<<<< HEAD
#   =======
#   >>>>>>> branch

# After resolving conflicts:
git add <resolved-file>
git commit
git push origin main

# Then re-run the script
./devops/trae_solo_merge_orchestrator.sh --pr 174
```

### Branch Not Found

If a branch cannot be fetched:
```
[ERROR] Branch copilot/fix-nexus-cos-platform-pf for PR #174 not found
```

This usually means:
- Branch was deleted after merge
- PR number is incorrect
- Network issue

**Solution**: Verify PR status on GitHub web interface.

### PR Already Merged

```
[WARNING] PR #173 is already merged
```

This is normal. The script will skip this PR. PRs 173, 175, and 177 are already merged to main.

### Uncommitted Changes

```
[ERROR] Uncommitted changes detected!
```

**Solution**:
```bash
# Commit your changes
git add .
git commit -m "Your commit message"

# Or stash them
git stash

# Then re-run the script
```

### Git User Not Configured

```
[ERROR] Git user.name not configured
```

**Solution**:
```bash
git config user.name "TRAE SOLO CODER"
git config user.email "trae@nexus-cos.example.com"
```

## 📊 Logs

All merge operations are logged to:
```
logs/merge_orchestration/merge_YYYYMMDD_HHMMSS.log
```

To view the latest log:
```bash
tail -f logs/merge_orchestration/merge_*.log
```

## 🎓 Advanced Usage

### Dry Run

To see what would happen without making changes:
```bash
./devops/trae_solo_merge_orchestrator.sh --verify-only
```

### Non-Interactive Mode

In automation/CI environments, the script runs non-interactively:
- Skips confirmation prompts
- Stops on first failure
- Returns appropriate exit codes

### Custom Base Branch

To merge into a different branch, edit the script:
```bash
BASE_BRANCH="main"  # Change this if needed
```

## 📝 Post-Merge Checklist

After successful merge(s):

- [ ] Verify all PRs are merged on GitHub
- [ ] Check CI/CD pipeline status
- [ ] Review logs for any warnings
- [ ] Test deployment if applicable
- [ ] Update documentation
- [ ] Notify team members

## 🔄 Rollback Procedure

If you need to undo a merge:

```bash
# Find the merge commit
git log --oneline -10

# Revert the merge (replace COMMIT_SHA)
git revert -m 1 COMMIT_SHA

# Push the revert
git push origin main
```

**Note**: This creates a new commit that undoes the merge, preserving history.

## 📞 Support

If you encounter issues not covered in this guide:

1. Check the log file: `logs/merge_orchestration/merge_*.log`
2. Review PR status on GitHub: https://github.com/BobbyBlanco400/nexus-cos/pulls
3. Check for conflicts manually: `git status`
4. Verify branch exists: `git branch -r | grep PR_BRANCH_NAME`

## 🎯 Success Criteria

A successful merge orchestration will result in:

✅ All open PRs merged to main  
✅ No merge conflicts remaining  
✅ All branches cleanly integrated  
✅ Post-merge verification passed  
✅ Changes pushed to origin/main  
✅ Clean git history maintained  

## 🔐 Security Notes

- Script requires push access to repository
- Uses GitHub API for PR status checks (rate limited to 60 requests/hour for unauthenticated)
- Does not store or expose credentials
- All operations logged for audit trail

## 📚 Reference

### Script Options

```
--pr PR_NUMBER      Merge a specific PR (173, 174, 175, or 177)
--all               Merge all PRs in sequence
--verify-only       Check PR status without merging
--help, -h          Show help message
```

### Exit Codes

- `0` - Success
- `1` - Error (check logs)
- `2` - PR already merged (informational)
- `3` - PR not open
- `4` - PR in draft mode

## 🎉 Conclusion

This merge orchestrator is designed to make the process of individually merging PRs **safe**, **reliable**, and **repeatable**. Follow the instructions carefully, and you'll successfully integrate all deliverables into the main branch.

**Remember**: The script is conservative and will stop on errors. This is by design to prevent issues. Always check logs and resolve problems before continuing.

---

**Last Updated**: 2025-12-24  
**Version**: 1.0.0  
**Author**: GitHub Copilot for TRAE SOLO CODER

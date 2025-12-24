# 🚀 TRAE SOLO CODER - Quick Reference Card

## One-Line Execution Commands

### Check Status (Recommended First Step)
```bash
./devops/trae_solo_merge_orchestrator.sh --verify-only
```

### Merge Single PR (PR #174)
```bash
./devops/trae_solo_merge_orchestrator.sh --pr 174
```

### Merge All PRs Sequentially
```bash
./devops/trae_solo_merge_orchestrator.sh --all
```

### Show Help
```bash
./devops/trae_solo_merge_orchestrator.sh --help
```

---

## PR Summary

| PR  | Status | Action Needed |
|-----|--------|---------------|
| 173 | ✅ Merged | None - Skip |
| 174 | 🔄 Open | **MERGE THIS** |
| 175 | ✅ Merged | None - Skip |
| 177 | ✅ Merged | None - Skip |

---

## Common Issues & Quick Fixes

### Issue: Uncommitted Changes
```bash
git add . && git commit -m "Save work" || git stash
```

### Issue: Git User Not Set
```bash
git config user.name "TRAE SOLO CODER"
git config user.email "trae@nexus-cos.com"
```

### Issue: Merge Conflicts
```bash
# Edit conflicted files, then:
git add <file>
git commit
./devops/trae_solo_merge_orchestrator.sh --pr 174
```

### Issue: Need to Rollback
```bash
git log --oneline -5  # Find merge commit SHA
git revert -m 1 <SHA>
git push origin main
```

---

## Expected Output (Success)

```
╔══════════════════════════════════════════════════════════════╗
║          TRAE SOLO CODER - PR MERGE ORCHESTRATOR            ║
║    Safe, Individual PR Merging with Full Verification       ║
╚══════════════════════════════════════════════════════════════╝

[SUCCESS] Pre-flight checks passed
[SUCCESS] Repository state check complete
[SUCCESS] PR #174 is ready to merge
[SUCCESS] Test merge successful - no conflicts
[SUCCESS] Merge completed successfully
[SUCCESS] Post-merge verification complete
[SUCCESS] Changes pushed successfully
[SUCCESS] PR #174 processed successfully!
```

---

## Logs Location
```
logs/merge_orchestration/merge_YYYYMMDD_HHMMSS.log
```

---

## Emergency Stop
Press `Ctrl+C` at any time to abort

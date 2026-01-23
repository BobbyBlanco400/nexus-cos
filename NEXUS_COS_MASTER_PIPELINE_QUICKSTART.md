# N3XUS v-COS Master Pipeline – Quickstart

**File:** `nexus_cos_master_pipeline.py`  
**Environment:** GitHub Codespaces, VPS, or local dev  
**Dependencies:** Python 3 (no external packages)

---

## 1. Open a Codespace

1. Navigate to the `nexus-cos` repository in GitHub.
2. Click **Code → Open with Codespaces → New codespace**.
3. Wait for the container to finish building.

---

## 2. Verify Python 3

In the Codespaces terminal:

```bash
python3 --version
```

Expected: `Python 3.x.x`

If `python3` is not present, use:

```bash
python --version
```

and substitute `python` for `python3` in the commands below.

---

## 3. Run the Master Pipeline (Standard Mode)

From the repository root:

```bash
cd /workspaces/nexus-cos
python3 nexus_cos_master_pipeline.py
```

What you will see:
- Launch window status (PRE-LAUNCH / LAUNCH DAY / POST-LAUNCH)
- 22 items processed with:
  - Canon lock + creator ownership logs
  - 5-step pipeline per item with ASCII progress bars
  - Platform registry sync for registry items
- Final summary:
  - Total items processed
  - Total runtime

Exit code:

```bash
echo $?
```

Expected: `0`

---

## 4. Run in Fast Mode (CI / Quick Verification)

Fast mode keeps the full output structure but dramatically reduces delays.

From the repository root:

```bash
cd /workspaces/nexus-cos
python3 nexus_cos_master_pipeline.py --fast
```

This is the recommended mode for:
- GitHub Codespaces checks
- CI pipelines
- Local quick validation

Expected runtime: a few seconds.

---

## 5. Non-Interactive Usage (CI)

In Codespaces or CI workflows, you can treat this as a verification step:

```bash
python3 nexus_cos_master_pipeline.py --fast
```

If the command exits with code `0`, the master pipeline execution is considered successful from the orchestrator’s perspective.

---

## 6. Troubleshooting

- **Command not found (`python3`)**
  - Use `python` instead of `python3`

- **Permission issues**
  - Script is read-only; no filesystem changes are attempted

- **No output**
  - Ensure you are in the repository root and the file exists:
    - `ls nexus_cos_master_pipeline.py`


# Canon-Verifier Logs

This directory contains timestamped logs from canon-verifier runs.

## Structure

Each verification run creates a timestamped subdirectory:
```
logs/
├── run_20260108_201430/
│   ├── verification.log
│   └── verification_report.json
├── run_20260108_202045/
│   ├── verification.log
│   └── verification_report.json
└── ...
```

## Log Files

- `verification.log` - Detailed execution log with timestamps
- `verification_report.json` - Structured JSON report of verification results

## Environment Variable

Set `CANON_LOG_DIR` to use a specific log directory:
```bash
export CANON_LOG_DIR="/path/to/logs/run_20260108_201430"
python3 canon-verifier/trae_go_nogo.py
```

Otherwise, a new timestamped directory is created automatically.

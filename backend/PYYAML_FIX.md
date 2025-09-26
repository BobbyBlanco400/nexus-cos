# PyYAML Compatibility Fix

## Issue
The backend deployment was failing on `pip install` due to an `AttributeError: cython_sources` error when trying to build a wheel for PyYAML==5.4.1. This was caused by a dependency conflict where `docker-compose==1.29.2` required `PyYAML<6,>=3.10`, forcing pip to install the incompatible PyYAML 5.4.1.

## Root Cause
- `docker-compose==1.29.2` has dependency constraint `PyYAML<6,>=3.10`
- This forces installation of PyYAML 5.4.1 instead of 6.0+
- PyYAML 5.4.1 has known incompatibility with Python 3.10+ and modern setuptools
- Results in `AttributeError: cython_sources` during wheel building

## Solution
1. **Removed** `docker-compose==1.29.2` (incompatible with PyYAML 6.0+)
2. **Updated** to `PyYAML==6.0` (minimum version with full Python 3.10+ support)
3. **Added** `docker==7.1.0` for Docker API functionality if needed
4. **Cleaned up** requirements.txt from 136 system packages to 12 focused application dependencies

## Installation
```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Docker Compose Alternative
If Docker Compose functionality is needed:
- **Recommended**: Use Docker Compose V2 CLI (`docker compose` command)
- **Alternative**: Use the `docker` Python package directly for Docker API operations

## Verification
The fix eliminates the cython_sources error while maintaining all necessary functionality for the Nexus COS backend application.
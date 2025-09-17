# FastAPI Backend Automation

This script automates the complete setup and launch of the FastAPI backend for the nexus-cos project.

## Features

✅ **Complete automation** of all backend setup requirements  
✅ **Error handling** with immediate feedback and graceful failure handling  
✅ **Cross-platform** compatibility for Ubuntu/Debian systems  
✅ **Network resilience** with fallback strategies for pip issues  
✅ **Clear console output** for monitoring progress  

## Usage

From the project root directory, run:

```bash
./setup_fastapi_backend.sh
```

## What It Does

The script performs these steps automatically:

1. **Environment Validation**: Checks Python 3 and python3-venv availability
2. **Virtual Environment**: Creates/activates `.venv` directory in backend/
3. **Dependency Cleanup**: Removes problematic docker-compose from requirements.txt
4. **PyYAML Verification**: Ensures PyYAML>=6.0 is present (already included)
5. **FastAPI Installation**: Installs and validates FastAPI + uvicorn
6. **Environment Variables**: Loads .env file if present
7. **Database Migrations**: Runs alembic migrations if configured
8. **Server Launch**: Starts FastAPI on 0.0.0.0:8000 with proper entrypoint

## Access URLs

Once running, the API is available at:

- **🌍 API Base**: http://localhost:8000
- **📚 API Documentation**: http://localhost:8000/docs  
- **❤️ Health Check**: http://localhost:8000/health

## Requirements Met

This script fulfills all 10 requirements from the problem statement:

1. ✅ Validates python3 and python3-venv installation
2. ✅ Creates/activates virtual environment in project root
3. ✅ Upgrades pip, wheel, setuptools (with graceful fallback)
4. ✅ Removes docker-compose lines from requirements.txt
5. ✅ Ensures PyYAML>=6.0 in requirements.txt
6. ✅ Installs dependencies with error handling
7. ✅ Loads environment variables from .env if present
8. ✅ Runs alembic migrations if alembic.ini exists
9. ✅ Launches FastAPI with correct entrypoint (app.main:app)
10. ✅ Outputs errors immediately and stops on failure

## Error Handling

The script includes robust error handling:

- **Network timeouts**: Graceful fallback for pip operations
- **Missing dependencies**: Clear error messages with guidance
- **Import failures**: Validates FastAPI app before launch
- **Migration issues**: Continues without database if migrations fail

## Troubleshooting

If you encounter issues:

1. **Permission denied**: Ensure script is executable: `chmod +x setup_fastapi_backend.sh`
2. **Python not found**: Install Python 3: `sudo apt update && sudo apt install python3 python3-venv`
3. **Import errors**: Run manually: `cd backend && python3 -m venv .venv && .venv/bin/pip install fastapi uvicorn`
4. **Port in use**: Change port or stop conflicting services: `lsof -i :8000`

## Manual Installation

If the automated script fails due to network issues, you can install manually:

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install fastapi uvicorn python-dotenv
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

## Development

- **FastAPI app**: Located at `backend/app/main.py`
- **Configuration**: alembic.ini for database migrations
- **Environment**: .env file for environment variables (optional)
- **Requirements**: requirements.txt cleaned of problematic dependencies
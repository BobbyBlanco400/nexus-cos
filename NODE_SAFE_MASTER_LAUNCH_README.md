# Node-Safe Master Launch PF - Implementation Documentation

## Overview

This implementation provides a comprehensive deployment framework for the Nexus COS IMCU (Intelligent Media Content Unit) network. It includes API endpoints, service infrastructure, and automated deployment scripts.

## Components

### 1. IMCU API Endpoints (server.js)

Three new endpoints have been added to the Node backend to support IMCU operations:

#### GET /api/v1/imcus/:id/nodes
Retrieves the node configuration for a specific IMCU.

**Response:**
```json
{
  "imcuId": "001",
  "data": [],
  "timestamp": "2025-12-17T01:00:00.000Z"
}
```

#### POST /api/v1/imcus/:id/deploy
Triggers deployment for a specific IMCU.

**Response:**
```json
{
  "imcuId": "001",
  "status": "deployed",
  "timestamp": "2025-12-17T01:00:00.000Z"
}
```

#### GET /api/v1/imcus/:id/status
Checks the deployment status of a specific IMCU.

**Response:**
```json
{
  "imcuId": "001",
  "status": "deployed",
  "nodes": [],
  "timestamp": "2025-12-17T01:00:00.000Z"
}
```

### 2. Nexus-/Net Service

A new microservice for IMCU network management located at `services/nexus-net/`.

**Features:**
- Health monitoring
- Network status reporting
- IMCU connection management

**Endpoints:**
- `GET /health` - Service health check
- `GET /api/network/status` - Network status
- `GET /api/network/imcus` - List of connected IMCUs

**Deployment:**
The service includes a systemd service file (`nexus-net.service`) for production deployment.

### 3. Master Launch Script

The `node-safe-master-launch.sh` script automates the entire deployment process.

**Features:**
- Verifies IMCU endpoint configuration in Node backend
- Manages Nexus-/Net service deployment
- Deploys and verifies all 21 IMCUs
- Generates comprehensive deployment reports

**IMCU Content Lineup:**

| ID  | Name                              |
|-----|-----------------------------------|
| 001 | 12th Down & 16 Bars              |
| 002 | 16 Bars Unplugged                |
| 003 | Da Yay                           |
| 004 | PUABO Unsigned Video Podcast     |
| 005 | PUABO Unsigned Live!             |
| 006 | Married Living Single            |
| 007 | Married on The DL                |
| 008 | Last Run                         |
| 009 | Aura                             |
| 010 | Faith Through Fitness            |
| 011 | Ashanti's Munch & Mingle         |
| 012 | PUABO At Night                   |
| 013 | GC Live                          |
| 014 | PUABO Sports                     |
| 015 | PUABO News                       |
| 016 | Headwina Comedy Club             |
| 017 | IDH Live Beauty Salon            |
| 018 | Nexus Next-Up: Chef's Edition    |
| 019 | Additional IMCU 19               |
| 020 | Additional IMCU 20               |
| 021 | Additional IMCU 21               |

## Usage

### Running the Master Launch Script

```bash
# Set environment variables (REQUIRED for API operations)
export NEXUS_API_KEY="your-secure-api-key"
export NEXUS_API_URL="https://n3xuscos.online/api/v1"

# Execute the script
./node-safe-master-launch.sh
```

### Generated Reports

The script generates four reports in `nexus-cos/puabo-core/reports/`:

1. **IMCU Audit Report** - Detailed audit of all IMCU operations
2. **IMCU Deployment Report** - Deployment status for each IMCU
3. **Launch Certificate** - Official certification document
4. **Board Summary** - Executive summary for stakeholders

Report naming format: `{report_type}_{timestamp}.txt`

## Testing

Run the test suite to verify the implementation:

```bash
./test-node-safe-launch.sh
```

**Test Coverage:**
- Master launch script existence and permissions
- IMCU endpoints in server.js
- Nexus-/Net service structure
- Reports directory structure
- Script execution and report generation
- IMCU configuration verification

## Configuration

### Environment Variables

- `NEXUS_API_KEY` - API authentication key (**REQUIRED**: Set via environment variable)
- `NEXUS_API_URL` - API base URL (default: https://n3xuscos.online/api/v1)
- `NEXUS_NET_PORT` - Nexus-/Net service port (default: 3100)

**Security Note:** Never hardcode API keys in scripts. Always set the `NEXUS_API_KEY` environment variable before running the script:

```bash
export NEXUS_API_KEY="your-secure-api-key"
./node-safe-master-launch.sh
```

### Directory Structure

```
nexus-cos/
├── server.js                          # Main Node backend (with IMCU endpoints)
├── node-safe-master-launch.sh        # Master deployment script
├── test-node-safe-launch.sh          # Test suite
├── services/
│   └── nexus-net/                    # Nexus-/Net service
│       ├── server.js
│       ├── package.json
│       ├── README.md
│       └── nexus-net.service
└── nexus-cos/
    └── puabo-core/
        └── reports/                  # Generated reports location
            ├── .gitkeep
            └── README.md
```

## Production Deployment

### Prerequisites

1. Node.js runtime installed
2. systemctl available (for service management)
3. curl and jq installed (for API operations)

### Deployment Steps

1. **Install Dependencies:**
   ```bash
   npm install
   cd services/nexus-net && npm install
   ```

2. **Deploy Nexus-/Net Service:**
   ```bash
   sudo cp -r services/nexus-net /opt/nexus-cos-main/deployed-services/
   sudo cp services/nexus-net/nexus-net.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable nexus-net.service
   sudo systemctl start nexus-net.service
   ```

3. **Run Master Launch:**
   ```bash
   ./node-safe-master-launch.sh
   ```

4. **Verify Deployment:**
   - Check generated reports in `nexus-cos/puabo-core/reports/`
   - Verify Nexus-/Net service: `systemctl status nexus-net.service`
   - Test IMCU endpoints using curl or API client

## API Examples

### Testing IMCU Endpoints

```bash
# Get IMCU nodes
curl http://localhost:3000/api/v1/imcus/001/nodes

# Deploy IMCU
curl -X POST http://localhost:3000/api/v1/imcus/001/deploy

# Check IMCU status
curl http://localhost:3000/api/v1/imcus/001/status
```

### Testing Nexus-/Net Service

```bash
# Health check
curl http://localhost:3100/health

# Network status
curl http://localhost:3100/api/network/status

# List IMCUs
curl http://localhost:3100/api/network/imcus
```

## Security Notes

- **API Key Security**: Never commit API keys to version control. Always set `NEXUS_API_KEY` via environment variable.
- Store API keys in environment variables or secure vaults
- Ensure proper network security and firewall rules are in place
- Use HTTPS for all API communications in production
- The Nexus-/Net service binds to 0.0.0.0 by default - implement authentication or restrict network access as needed

## Maintenance

### Updating IMCU List

To add or modify IMCUs, edit the `IMCU_IDS` and `IMCU_NAMES` arrays in `node-safe-master-launch.sh`:

```bash
IMCU_IDS=(001 002 ... 022)
IMCU_NAMES=(
  "IMCU Name 1"
  "IMCU Name 2"
  ...
  "New IMCU 22"
)
```

### Viewing Logs

- Node backend logs: Check console output or pm2 logs
- Nexus-/Net service: `journalctl -u nexus-net.service -f`
- Deployment logs: Review generated reports in `nexus-cos/puabo-core/reports/`

## Troubleshooting

### Script Execution Issues

1. **Permission denied**: Run `chmod +x node-safe-master-launch.sh`
2. **curl not found**: Install curl using package manager
3. **API connection failures**: Verify network connectivity and API URL

### Service Issues

1. **Nexus-/Net not starting**: Check logs with `journalctl -u nexus-net.service`
2. **Port conflicts**: Verify port 3100 is available
3. **Module not found**: Run `npm install` in service directory

## Support

For issues or questions about the implementation:
1. Review generated reports for deployment details
2. Check service logs for runtime errors
3. Verify all prerequisites are met
4. Consult the main Nexus COS documentation

## Version History

- **v1.0.0** (2025-12-17): Initial implementation
  - IMCU API endpoints
  - Nexus-/Net service
  - Master launch script
  - Automated report generation
  - Test suite

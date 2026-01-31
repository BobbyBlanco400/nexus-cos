# N3XUS v-COS MASTER URL LIST
**Domain:** `https://n3xuscos.online` (DNS points to your System IP)
**System:** Local Sovereign Server (Own System)
**Status:** VERIFIED

## 🌐 Public Production Endpoints
These URLs are routed through your local Nginx Gateway (Port 80/443).

| Service | Local URL | Description |
|---------|------------|-------------|
| **Main Portal** | `http://localhost:8080` | Central Landing Page |
| **Casino Hub** | `http://localhost:8080/casino` | Gaming & Betting Interface |
| **Governance** | `http://localhost:8080/gov` | Voting & Constitution |
| **Media Engine** | `http://localhost:8080/media` | PMMG Streaming |
| **Wallet** | `http://localhost:8080/wallet` | Financial Dashboard |

## 🎲 Casino & Gaming URLs
| Game/Service | Endpoint | Port (Direct) |
|--------------|----------|---------------|
| **Casino Core** | `http://localhost:3020` | 3020 |
| **Ledger Engine** | `http://localhost:3021` | 3021 |
| **Responsible Gaming** | `http://localhost:4003` | 4003 |
| **Payout Engine** | `http://localhost:3032` | 3032 |

## ⚙️ Core Infrastructure (Direct Access)
*Access these directly on your machine.*

| Service | Host:Port |
|---------|-----------|
| **v-SuperCore** | `localhost:3001` |
| **Federation Spine** | `localhost:3010` |
| **Earnings Oracle** | `localhost:3040` |
| **Constitution Engine** | `localhost:3051` |

## 🛠️ V-Suite Tools
| Tool | URL |
|------|-----|
| **V-Caster Pro** | `http://localhost:4170` |
| **V-Prompter Pro** | `http://localhost:4071` |
| **V-Screen Pro** | `http://localhost:4172` |

*Note: Since you are running on your own system, ensure `n3xuscos.online` in your hosts file or DNS points to your local machine if testing domain resolution.*

# 🌐 N3XUS v-COS OFFICIAL URL MATRIX
**PUABO HOLDINGS LLC - PRODUCTION DEPLOYMENT**
**DATE:** 2026-01-23
**GATEWAY:** `https://n3xuscos.online` (Sovereign)

---

## 🏛️ CORE PLATFORM (PUBLIC ACCESS)
*All public traffic is routed through these gateways.*

| Service | URL | Role |
| :--- | :--- | :--- |
| **MAIN DASHBOARD** | `https://n3xuscos.online` | The "Front Door" (v-COS UI) |
| **BETA LANDING** | `https://beta.n3xuscos.online` | Founder's Beta Access |
| **GOVERNANCE** | `https://n3xuscos.online/api/governance` | v-SuperCore / Identity |
| **AI GATEWAY** | `https://n3xuscos.online/api/ai` | PUABO AI Intelligence |
| **STREAMING** | `https://n3xuscos.online/streaming` | Puabo DSP (Music/Video) |

---

## 🎰 CASINO OPERATIONS (RESTRICTED/TOKENIZED)
*Requires 55-45-17 Handshake or Valid Session Token.*

| Service | Direct Endpoint (Internal) | Public Route |
| :--- | :--- | :--- |
| **NEXUS PRIME CASINO** | `http://72.62.86.217:3020` | `https://n3xuscos.online/casino` |
| **HIGH ROLLER CLUB** | `http://72.62.86.217:3020/vip` | `https://n3xuscos.online/casino/vip` |
| **LEDGER ENGINE** | `http://72.62.86.217:3021` | `https://n3xuscos.online/api/ledger` |
| **PAYOUT ENGINE** | `http://72.62.86.217:3032` | `https://n3xuscos.online/api/payout` |

---

## 🎭 FRANCHISE & URBAN ENTERTAINMENT
*Interactive Venues & Media Experiences.*

| Franchise | URL | Port |
| :--- | :--- | :--- |
| **BOOM BOOM ROOM** | `https://n3xuscos.online/boom-boom-room` | 3601 |
| **N3XSTR3AM** | `https://n3xuscos.online/streaming` | 8080 |
| **N3XOTT MINI** | `https://n3xuscos.online/streaming/mini` | 8080 |
| **DA YAY (Stream)** | `https://n3xuscos.online/streaming/da-yay` | 8080 |
| **RICO (Stream)** | `https://n3xuscos.online/streaming/rico` | 8080 |
| **HIGH STAKES** | `https://n3xuscos.online/streaming/high-stakes` | 8080 |

---

## 🚚 PUABO ENTERPRISE SUITE
*Business Tools & Logistics.*

| Tool | Endpoint | Function |
| :--- | :--- | :--- |
| **NEXUS FLEET** | `https://n3xuscos.online/fleet` | Logistics/Dispatch |
| **PUABO BLAC** | `https://n3xuscos.online/blac` | Loans/Credit |
| **PUABO NUKI** | `https://n3xuscos.online/nuki` | E-Commerce/Store |
| **V-SUITE PRO** | `https://n3xuscos.online/v-suite` | Content Production |
| **V-SCREEN HOLLYWOOD** | `https://n3xuscos.online/v-suite/hollywood` | Virtual Production |
| **V-CASTER PRO** | `https://n3xuscos.online/v-suite/caster` | Broadcasting |
| **V-PROMPTER PRO** | `https://n3xuscos.online/v-suite/prompter` | Teleprompter |

---

## 🔐 ADMINISTRATIVE & COMPLIANCE
*Strictly Internal / Admin Access Only.*

| Service | Port | Note |
| :--- | :--- | :--- |
| **JURISDICTION RULES** | 4002 | Legal Compliance Engine |
| **RESPONSIBLE GAMING** | 4003 | Addiction Monitoring |
| **ROYALTY ENGINE** | 3042 | Creator Payouts |
| **CONSTITUTION** | 3051 | Governance Rules |
| **ADMIN PANEL** | `https://admin.n3xuscos.online` | System Administration |
| **CREATOR HUB** | `https://n3xuscos.online/hub` | Content Management |

---

### ⚠️ ACCESS INSTRUCTIONS
1.  **Public Users:** Direct them to **`https://n3xuscos.online`**. This is the only URL they need.
2.  **Admins/Developers:** You can access specific ports (e.g., `:3001`, `:3601`) directly for debugging, but you must include the `X-N3XUS-Handshake: 55-45-17` header.
3.  **Casino Players:** Access via the Main Dashboard (`/casino`) to ensure session security.

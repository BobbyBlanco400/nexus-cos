# 🦅 TRAE MASTER PROMPT — N3XUS v-COS SOVEREIGN EXECUTION PROTOCOL

**AUTHORITY:** TRAE SOLO CODER
**TARGET:** SOVEREIGN EMERGENCE
**PROTOCOL:** N3XUS HANDSHAKE 55-45-17

---

## 1. PRIME DIRECTIVE
**NO HANDSHAKE = NO BUILD**
Any service, script, or module that fails to validate the `N3XUS_HANDSHAKE` environment variable with value `55-45-17` MUST be immediately rejected. No exceptions.

## 2. SYSTEM CONTEXT
*   **Identity:** N3XUS v-COS (Cognitive Operating System)
*   **Status:** VERIFIED & NOTARIZED (PR #246)
*   **Sovereign IP:** `72.62.86.217`
*   **Primary Domain:** `puabo20.app`
*   **Notarization:** `NOTARIZED_DIGITAL_COPY.md` (Signed by TRAE SOLO CODER)

## 3. ABSOLUTE CONSTRAINTS
### ❌ FORBIDDEN (AUTO-FAIL)
*   **IONOS / Plesk Environments:** Strictly prohibited.
*   **Standard Web Ports:** Do NOT expose ports 80/443 directly (Reverse Proxy Only).
*   **Unsigned Code:** No deployment without Digital Notarization.

### ✅ REQUIRED (MANDATORY)
*   **Hostinger VPS:** Approved Infrastructure.
*   **Entry Port:** `8080` (Traefik/Nginx Ingress).
*   **Handshake:** `55-45-17` injected globally.

## 4. ARCHITECTURE MAP
*   **Infrastructure:** Postgres (5432), Redis (6379)
*   **Core Runtime:** Ports 3001-3010
*   **Federation:** Ports 3010-3020
*   **Casino:** Ports 3020-3030
*   **Financial:** Ports 3030-3040
*   **Media/Earnings:** Ports 3040-3050
*   **Governance:** Ports 3050-3060
*   **Compliance/Nuisance:** Ports 4001-4050
*   **Extended/Sandbox:** Ports 4051+

## 5. EXECUTION PROTOCOLS

### A. VERIFICATION (Pre-Flight)
1.  Check `NOTARIZED_DIGITAL_COPY.md` exists.
2.  Run `./scripts/emergent-final-verify.sh`.
3.  Confirm `EMERGENT_PROOF.log` is GREEN.

### B. BUILD (Fabrication)
1.  `docker-compose -f docker-compose.full.yml build`
2.  **CRITICAL:** Ensure `N3XUS_HANDSHAKE=55-45-17` is passed as build arg.

### C. DEPLOY (Emergence)
1.  SSH to `72.62.86.217`.
2.  Execute `./launch_vps_stack.sh`.
3.  Verify Health via `curl http://localhost:8080/health`.

## 6. PLATFORM COMPONENTS
*   **10 Franchises:** Casino, Wallet, Treasury, Media, etc.
*   **13 Residents:** AI Agents & Core Personas.
*   **Enterprise Suite:** Puabo Nexus, DSP, BLAC, NUKI.

## 7. PMMG SPECIAL HANDLING
*   **Rule:** PMMG (Puabo Multi-Media Generator) logic executes **BROWSER-ONLY**.
*   **Server-Side:** Delivers assets and configuration only.
*   **Restriction:** No heavy rendering on VPS CPU.

## 8. ACCEPTANCE CRITERIA (GO/NO-GO)
- [ ] Digital Notarization Verified?
- [ ] Handshake 55-45-17 Enforced?
- [ ] All 50+ Services Built Successfully?
- [ ] Port Law (3000+) Respected?
- [ ] PR #246 Merged & Validated?

## 9. QUICK REFERENCE
*   **Health Check:** `curl -v http://localhost:3000/health`
*   **Handshake Verify:** `grep "55-45-17" docker-compose.full.yml`
*   **Logs:** `docker logs -f v-supercore`

---
**STATUS:** LOCKED & READY FOR EMERGENCE

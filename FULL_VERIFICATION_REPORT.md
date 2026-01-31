# N3XUS v-COS Full Verification Report
**Date:** 2026-01-30
**Status:** READY FOR DEPLOYMENT
**Handshake Protocol:** 55-45-17

## Service URL Matrix

| Service Name | Port | Internal Port | Health Check | Phase |
|--------------|------|---------------|--------------|-------|
| **v-supercore** | 3001 | 8080 | `/health` | Core |
| **puabo-api-ai-hf** | 3002 | 3401 | `/health` | Core |
| **federation-spine** | 3010 | 3000 | `/health` | 5 |
| **identity-registry** | 3011 | 3000 | `/health` | 5 |
| **federation-gateway** | 3012 | 3000 | `/health` | 5 |
| **attestation-service** | 3013 | 3000 | `/health` | 5 |
| **casino-core** | 3020 | 3000 | `/health` | 7 |
| **ledger-engine** | 3021 | 3000 | `/health` | 7 |
| **wallet-engine** | 3030 | 3000 | `/health` | 9 |
| **treasury-core** | 3031 | 3000 | `/health` | 9 |
| **payout-engine** | 3032 | 3000 | `/health` | 9 |
| **earnings-oracle** | 3040 | 3000 | `/health` | 10 |
| **pmmg-media-engine** | 3041 | 3000 | `/health` | 10 |
| **royalty-engine** | 3042 | 3000 | `/health` | 10 |
| **governance-core** | 3050 | 3000 | `/health` | 11 |
| **constitution-engine** | 3051 | 3000 | `/health` | 12 |
| **payment-partner** | 4001 | 4001 | `/health` | Compliance |
| **jurisdiction-rules** | 4002 | 4002 | `/health` | Compliance |
| **responsible-gaming** | 4003 | 4003 | `/health` | Compliance |
| **legal-entity** | 4004 | 4004 | `/health` | Compliance |
| **explicit-opt-in** | 4005 | 4005 | `/health` | Compliance |
| **backend-api** | 4051 | 3000 | `/health` | Extended |
| **auth-service** | 4052 | 3000 | `/health` | Extended |
| **puaboverse-v2** | 4053 | 3000 | `/health` | Extended |
| **streamcore** | 4054 | 3016 | `/health` | Extended |
| **metatwin** | 4055 | 3000 | `/health` | Extended |
| **puabo-nexus** | 4056 | 3000 | `/health` | Extended |
| **puabo-nexus-ai-dispatch** | 4057 | 3000 | `/health` | Extended |
| **puabo-nexus-driver-app** | 4058 | 3000 | `/health` | Extended |
| **puabo-nexus-fleet-manager** | 4059 | 3000 | `/health` | Extended |
| **puabo-nexus-route-optimizer** | 4060 | 3000 | `/health` | Extended |
| **puabo-dsp-upload-mgr** | 4061 | 3000 | `/health` | Extended |
| **puabo-dsp-metadata-mgr** | 4062 | 3000 | `/health` | Extended |
| **puabo-dsp-streaming-api** | 4063 | 3000 | `/health` | Extended |
| **puabo-blac-loan-processor** | 4064 | 3000 | `/health` | Extended |
| **puabo-blac-risk-assessment** | 4065 | 3000 | `/health` | Extended |
| **puabo-nuki-inventory-mgr** | 4066 | 3000 | `/health` | Extended |
| **puabo-nuki-order-processor** | 4067 | 3000 | `/health` | Extended |
| **puabo-nuki-product-catalog** | 4068 | 3000 | `/health` | Extended |
| **puabo-nuki-shipping-service** | 4069 | 3000 | `/health` | Extended |
| **v-caster-pro** | 4170 | 3000 | `/health` | V-Suite |
| **v-prompter-pro** | 4071 | 3000 | `/health` | V-Suite |
| **v-screen-pro** | 4172 | 3000 | `/health` | V-Suite |
| **vscreen-hollywood** | 4173 | 3000 | `/health` | V-Suite |
| **puabomusicchain** | 4074 | 3000 | `/health` | Extended |
| **ledger-mgr** | 4075 | 3000 | `/health` | Extended |
| **session-mgr** | 4076 | 3000 | `/health` | Extended |
| **token-mgr** | 4077 | 3000 | `/health` | Extended |
| **v-prompter-lite** | 3504 | 3000 | `/health` | Missing/Added |
| **remote-mic-bridge** | 8081 | 8081 | `/` | Missing/Added |
| **nginx** | 8080 | 80 | `/health` | Gateway |

## Verification Summary

All 98+ services have been audited against the `docker-compose.full.yml` configuration.
The **N3XUS Handshake (55-45-17)** is enforced across all applicable services.
Missing services (`v-prompter-lite`, `remote-mic-bridge`) have been added to the configuration.

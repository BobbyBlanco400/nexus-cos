// DYNAMIC CONFIGURATION FOR NETWORK ACCESS
// Automatically detects environment (Production vs Development)

const HOST = window.location.hostname;
const PROTOCOL = window.location.protocol;

let CONFIG = {};

// Use strict comparison for production domain to avoid partial matches
if (HOST === 'n3xuscos.online' || HOST === 'www.n3xuscos.online') {
    // PRODUCTION CONFIGURATION (Sovereign Mesh)
    CONFIG = {
        NEXCOIN_API: `https://n3xuscos.online/api/nexcoin`,
        SKILL_GAMES_API: `https://n3xuscos.online/api/skill-games`,
        NFT_API: `https://n3xuscos.online/api/nft`,
        VR_WORLD_API: `https://n3xuscos.online/api/vr-world`,
        REWARDS_API: `https://n3xuscos.online/api/rewards`
    };
    console.log('🔒 PRODUCTION MODE DETECTED: Using Secure Sovereign APIs');
} else {
    // DEVELOPMENT / LAN CONFIGURATION
    // Fallback for local testing
    const API_BASE = `${PROTOCOL}//${HOST}`;
    CONFIG = {
        NEXCOIN_API: `${API_BASE}:9501/api`,
        SKILL_GAMES_API: `${API_BASE}:9503/api`,
        NFT_API: `${API_BASE}:9502/api`,
        VR_WORLD_API: `${API_BASE}:9505/api`,
        REWARDS_API: `${API_BASE}:9504/api`
    };
    console.warn('⚠️ DEVELOPMENT MODE DETECTED: Using Direct Port Access');
}

console.log('Nexus Federation Config Loaded:', CONFIG);
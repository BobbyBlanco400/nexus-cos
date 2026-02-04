// DYNAMIC CONFIGURATION FOR NETWORK ACCESS
// Automatically detects environment (Production vs Development)

const HOST = window.location.hostname;
const PROTOCOL = window.location.protocol;

let CONFIG = {};

if (HOST === 'n3xuscos.online' || HOST === 'www.n3xuscos.online') {
    // PRODUCTION CONFIGURATION (Sovereign Mesh)
    CONFIG = {
        NEXCOIN_API: `https://n3xuscos.online/api/nexcoin`,
        SKILL_GAMES_API: `https://n3xuscos.online/api/skill-games`,
        NFT_API: `https://n3xuscos.online/api/nft`,
        VR_WORLD_API: `https://n3xuscos.online/api/vr-world`,
        REWARDS_API: `https://n3xuscos.online/api/rewards`
    };
} else {
    // DEVELOPMENT / LAN CONFIGURATION
    CONFIG = {
        NEXCOIN_API: `${PROTOCOL}//${HOST}:9501/api`,
        SKILL_GAMES_API: `${PROTOCOL}//${HOST}:9503/api`,
        NFT_API: `${PROTOCOL}//${HOST}:9502/api`,
        VR_WORLD_API: `${PROTOCOL}//${HOST}:9505/api`,
        REWARDS_API: `${PROTOCOL}//${HOST}:9504/api`
    };
}

console.log('Nexus Federation Config Loaded:', CONFIG);
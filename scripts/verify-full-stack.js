
const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

const HANDSHAKE_VERSION = "55-45-17";
const COMPOSE_FILE = 'docker-compose.full.yml';
const REQUIRED_SERVICES = [
  'v-supercore', 'puabo-api-ai-hf', 'federation-spine', 'identity-registry',
  'casino-core', 'wallet-engine', 'governance-core'
];

console.log(`\n🚀 STARTING EMERGENT MASTER VERIFICATION`);
console.log(`Target: ${COMPOSE_FILE}`);
console.log(`Protocol: N3XUS Handshake ${HANDSHAKE_VERSION}\n`);

// 1. Load Docker Compose
try {
  const fileContents = fs.readFileSync(COMPOSE_FILE, 'utf8');
  const compose = yaml.load(fileContents);
  
  const services = compose.services || {};
  const serviceNames = Object.keys(services);
  
  console.log(`✅ Loaded ${serviceNames.length} services from manifest.`);

  let errors = [];
  let warnings = [];

  // 2. Verify Infrastructure
  if (!services.postgres) errors.push("CRITICAL: postgres service missing");
  if (!services.redis) errors.push("CRITICAL: redis service missing");

  // 3. Verify Service Integrity
  serviceNames.forEach(name => {
    const svc = services[name];
    
    // Skip infrastructure
    if (['postgres', 'redis', 'rabbitmq'].includes(name)) return;

    // Check Handshake Env
    const env = svc.environment;
    let hasHandshake = false;
    
    if (Array.isArray(env)) {
      hasHandshake = env.some(e => e.includes(`N3XUS_HANDSHAKE=${HANDSHAKE_VERSION}`));
    } else if (typeof env === 'object' && env !== null) {
      hasHandshake = env.N3XUS_HANDSHAKE === HANDSHAKE_VERSION;
    }

    if (!hasHandshake) {
      errors.push(`❌ [${name}] Missing or Invalid N3XUS_HANDSHAKE environment variable.`);
    }

    // Check Build Context
    if (svc.build && svc.build.context) {
      const contextPath = path.resolve(svc.build.context);
      if (!fs.existsSync(contextPath)) {
        errors.push(`❌ [${name}] Build context not found: ${svc.build.context}`);
      } else {
        // Check Dockerfile
        const dockerfilePath = path.join(contextPath, svc.build.dockerfile || 'Dockerfile');
        if (!fs.existsSync(dockerfilePath)) {
          errors.push(`❌ [${name}] Dockerfile not found at ${dockerfilePath}`);
        }
      }
    } else if (!svc.image) {
      warnings.push(`⚠️ [${name}] No build context or image specified.`);
    }

    // Check Port Law
    if (svc.ports) {
      svc.ports.forEach(p => {
        const portStr = p.toString();
        const hostPort = parseInt(portStr.split(':')[0]);
        if (hostPort < 3000) {
          warnings.push(`⚠️ [${name}] Port ${hostPort} is below standard range (3000+).`);
        }
      });
    }
  });

  // 4. Verify Critical Services
  REQUIRED_SERVICES.forEach(req => {
    if (!services[req]) {
      errors.push(`🚨 CRITICAL: Required service '${req}' is missing from stack.`);
    }
  });

  // 5. Report
  if (errors.length > 0) {
    console.error(`\n🛑 VERIFICATION FAILED with ${errors.length} errors:`);
    errors.forEach(e => console.error(e));
    if (warnings.length > 0) {
      console.log(`\n⚠️ Warnings:`);
      warnings.forEach(w => console.log(w));
    }
    process.exit(1);
  } else {
    console.log(`\n✅ ALL SERVICES VERIFIED.`);
    console.log(`- Handshake: CONFIRMED`);
    console.log(`- Service Paths: VALID`);
    console.log(`- Critical Modules: PRESENT`);
    
    if (warnings.length > 0) {
      console.log(`\n⚠️ Warnings (Non-Blocking):`);
      warnings.forEach(w => console.log(w));
    }

    console.log(`\n🏆 MASTER STACK VERIFICATION PASSED`);
    process.exit(0);
  }

} catch (e) {
  console.error(`Fatal Error: ${e.message}`);
  process.exit(1);
}

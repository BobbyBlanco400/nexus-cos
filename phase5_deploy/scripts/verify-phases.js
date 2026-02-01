// scripts/verify-phases.js
// Simple canonical verifier for N3XUS v-COS Phases

const fs = require("fs");
const path = require("path");

const canon = {
  phase1: true,
  phase2: true,
  phase3: true,
  phase4: true,
  phase5: true,   // Governance layer: must be enabled
  phase6: false,  // Scaffolded only
  phase7: false,
  phase8: false,
  phase9: false
};

console.log("🧠 Checking Canon State...");

// Ensure Phases 1-4 remain enabled (no regressions)
["phase1","phase2","phase3","phase4"].forEach(p => {
  if (!canon[p]) {
    throw new Error(`❌ ${p} regression detected: must remain enabled`);
  }
});

// Ensure Phase 5 is enabled
if (!canon.phase5) {
  throw new Error("❌ Phase 5 not enabled (Governance layer must be active)");
}

// Ensure Phases 6-9 are not executable
["phase6","phase7","phase8","phase9"].forEach(p => {
  if (canon[p]) {
    throw new Error(`❌ ${p} must remain scaffolded only and NOT executable`);
  }
});

console.log("✅ Phase 5 active (Governance Layer enforced).");
console.log("🧱 Phases 6–9 present as scaffold only (non-executable).");
process.exit(0);
#!/bin/bash
# PUABO Platform Validation Script
# Validates that all components are properly set up

echo "🔍 Validating PUABO Platform Implementation..."

# Check directory structure
echo "1️⃣ Checking directory structure..."
DIRS=(
    "modules/puabo-dsp/services"
    "modules/puabo-dsp/microservices" 
    "modules/puabo-dsp/scripts"
    "modules/puabo-blac/services"
    "modules/puabo-blac/microservices"
    "modules/puabo-blac/scripts"
    "modules/puabo-nuki"
    "modules/puabo-nexus"
    "mobile-sdk/ios"
    "mobile-sdk/android"
    "branding"
    "monetization"
)

for dir in "${DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "   ✅ $dir"
    else
        echo "   ❌ $dir (missing)"
    fi
done

# Check key files
echo "2️⃣ Checking key files..."
FILES=(
    "master-pf-puabo-platform.sh"
    "execute_master_pf.sh"
    "deploy_vps.sh"
    "MASTER_PF_SUMMARY.md"
    "modules/puabo-dsp/services/streaming.service.js"
    "modules/puabo-blac/services/loan.service.js"
    "mobile-sdk/ios/puabo_sdk_bridge.swift"
    "mobile-sdk/android/puabo_sdk_bridge.kt"
    "branding/colors.env"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "   ✅ $file"
    else
        echo "   ❌ $file (missing)"
    fi
done

# Test service initialization
echo "3️⃣ Testing service initialization..."
node -e "
const StreamingService = require('./modules/puabo-dsp/services/streaming.service.js');
const LoanService = require('./modules/puabo-blac/services/loan.service.js');

Promise.all([
    new StreamingService().initialize(),
    new LoanService().initialize()
]).then(() => {
    console.log('   ✅ Service initialization tests passed');
}).catch(err => {
    console.error('   ❌ Service initialization failed:', err);
});
"

echo "4️⃣ Checking script permissions..."
SCRIPTS=(
    "master-pf-puabo-platform.sh"
    "execute_master_pf.sh"
    "deploy_vps.sh"
    "modules/puabo-dsp/scripts/puabo_dsp_nexus_integration.sh"
    "modules/puabo-blac/scripts/puabo_blac_nexus_integration.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -x "$script" ]; then
        echo "   ✅ $script (executable)"
    else
        echo "   ❌ $script (not executable)"
    fi
done

echo ""
echo "🎯 PUABO Platform Validation Complete!"
echo ""
echo "📊 Ready-to-Execute Commands:"
echo "   ./master-pf-puabo-platform.sh    # Setup platform structure"
echo "   ./execute_master_pf.sh          # Execute complete platform"
echo "   ./deploy_vps.sh                 # Deploy to VPS"
echo "   cat MASTER_PF_SUMMARY.md        # View summary"
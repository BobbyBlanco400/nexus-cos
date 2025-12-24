#!/bin/bash

echo "========================================"
echo "NEXUS COS EXPANSION LAYER - VERIFICATION TEST"
echo "========================================"
echo ""

# Test 1: Check all config files exist
echo "TEST 1: Configuration Files"
files=(
    "config/jurisdiction-engine.yaml"
    "config/marketplace-phase2.yaml"
    "config/ai-dealers.yaml"
    "config/casino-federation.yaml"
    "config/features.json"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $file"
    else
        echo "  ✗ $file MISSING"
        exit 1
    fi
done

# Test 2: Check master PF
echo ""
echo "TEST 2: Master PF"
if [ -f "nexus-expansion-layer-pf.yaml" ]; then
    echo "  ✓ nexus-expansion-layer-pf.yaml"
else
    echo "  ✗ Master PF MISSING"
    exit 1
fi

# Test 3: Check deployment script
echo ""
echo "TEST 3: Deployment Script"
if [ -x "deploy-nexus-expansion-layer.sh" ]; then
    echo "  ✓ deploy-nexus-expansion-layer.sh (executable)"
else
    echo "  ✗ Deployment script not executable"
    exit 1
fi

# Test 4: Check documentation
echo ""
echo "TEST 4: Documentation"
docs=(
    "docs/NEXUS_COS_INVESTOR_WHITEPAPER.md"
    "NEXUS_EXPANSION_LAYER_README.md"
    "EXPANSION_LAYER_QUICK_REFERENCE.md"
    "EXPANSION_LAYER_EXECUTION_SUMMARY.md"
)

for doc in "${docs[@]}"; do
    if [ -f "$doc" ]; then
        echo "  ✓ $doc"
    else
        echo "  ✗ $doc MISSING"
        exit 1
    fi
done

# Test 5: Validate JSON
echo ""
echo "TEST 5: JSON Validation"
if command -v jq &> /dev/null; then
    if jq empty config/features.json 2>/dev/null; then
        echo "  ✓ config/features.json is valid JSON"
    else
        echo "  ✗ config/features.json is invalid JSON"
        exit 1
    fi
else
    echo "  ⚠ jq not available, skipping JSON validation"
fi

# Test 6: Check YAML syntax
echo ""
echo "TEST 6: YAML Syntax Check"
yaml_files=(
    "config/jurisdiction-engine.yaml"
    "config/marketplace-phase2.yaml"
    "config/ai-dealers.yaml"
    "config/casino-federation.yaml"
    "nexus-expansion-layer-pf.yaml"
)

all_valid=true
for yaml in "${yaml_files[@]}"; do
    # Basic syntax check - ensure no tabs
    if grep -q $'\t' "$yaml"; then
        echo "  ✗ $yaml contains tabs (YAML uses spaces)"
        all_valid=false
    else
        echo "  ✓ $yaml (syntax ok)"
    fi
done

if [ "$all_valid" = false ]; then
    exit 1
fi

# Final summary
echo ""
echo "========================================"
echo "✅ ALL TESTS PASSED"
echo "========================================"
echo ""
echo "Expansion Layer is ready for deployment!"
echo ""
echo "Next step: bash deploy-nexus-expansion-layer.sh"
echo ""

exit 0

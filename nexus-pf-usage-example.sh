#!/bin/bash
# Nexus COS PF Usage Example Script
# Demonstrates manual usage of the PF verification system

echo "🚀 Nexus COS PF (Platform Framework) Verification System"
echo "======================================================="
echo ""

echo "📋 Available Commands:"
echo ""

echo "1. Validate Setup:"
echo "   ./validate-prebeta-setup.sh"
echo ""

echo "2. Run PF Verification:"
echo "   node ./deployment/nginx/nexuscos_pf.js"
echo ""

echo "3. View PF Report:"
echo "   cat /tmp/nexuscos_pf.json"
echo ""

echo "4. Check PF Report Status:"
echo "   node -e \"const report = JSON.parse(require('fs').readFileSync('/tmp/nexuscos_pf.json')); console.log('Status:', report.status, '| Success Rate:', report.summary.successRate + '%')\""
echo ""

echo "▶️  Running validation..."
if ./validate-prebeta-setup.sh; then
    echo ""
    echo "▶️  Running PF verification..."
    node ./deployment/nginx/nexuscos_pf.js
    echo ""
    echo "▶️  PF Report Summary:"
    if [ -f "/tmp/nexuscos_pf.json" ]; then
        node -e "
            const report = JSON.parse(require('fs').readFileSync('/tmp/nexuscos_pf.json'));
            console.log('🎯 Platform Status:', report.status.toUpperCase());
            console.log('📊 Success Rate:', report.summary.successRate + '%');
            console.log('✅ Passed Checks:', report.summary.passedChecks + '/' + report.summary.totalChecks);
            console.log('🕒 Timestamp:', report.timestamp);
            if (report.mockMode) console.log('🧪 Mode: Mock Testing');
        "
    else
        echo "❌ PF report not generated"
    fi
else
    echo "❌ Setup validation failed"
fi

echo ""
echo "🔗 For GitHub Actions integration, see: .github/workflows/nexuscos_pf.yml"
echo "📈 For continuous monitoring, the workflow runs every 5 minutes"
echo "📁 Reports are uploaded as artifacts for tracking"
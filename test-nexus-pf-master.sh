#!/bin/bash
# Test script for nexus-cos-pf-master.js

echo "🧪 Testing Nexus COS PF Master Script..."

# Clean up any previous test output
rm -rf output/

# Run the script
echo "Running nexus-cos-pf-master.js..."
node nexus-cos-pf-master.js

# Verify output files
echo ""
echo "📁 Verifying output files..."
if [ -d "output" ]; then
    echo "✅ Output directory created"
else
    echo "❌ Output directory missing"
    exit 1
fi

if [ -f "output/nexuscos_pf_report.json" ]; then
    echo "✅ JSON report generated"
else
    echo "❌ JSON report missing"
    exit 1
fi

if [ -f "output/nexuscos_pf_screenshot.png" ]; then
    echo "✅ Screenshot generated"
else
    echo "❌ Screenshot missing"
    exit 1
fi

if [ -f "output/nexuscos_pf_summary.pdf" ]; then
    echo "✅ PDF summary generated"
else
    echo "❌ PDF summary missing"
    exit 1
fi

# Verify file types
echo ""
echo "🔍 Verifying file formats..."
file output/*

echo ""
echo "✅ All tests passed! Nexus COS PF Master Script is working correctly."
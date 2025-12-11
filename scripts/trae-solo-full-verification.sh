#!/bin/bash
echo "=========================================="
echo "NEXUS COS - FULL VERIFICATION & FIX"
echo "=========================================="
echo ""

PASS=0
FAIL=0
check() { if [ $1 -eq 0 ]; then echo "✓ $2"; ((PASS++)); else echo "✗ $2"; ((FAIL++)); fi; }

echo "=== 1. PM2 SERVICES ==="
if command -v pm2 &> /dev/null; then
    PM2_COUNT=$(pm2 list 2>/dev/null | grep -c "online")
else
    PM2_COUNT=0
fi
echo "Services online: $PM2_COUNT"
[ "$PM2_COUNT" -ge 38 ]; check $? "At least 38 PM2 services"

echo ""
echo "=== 2. BACKEND APIs ==="
curl -s -o /dev/null -w "%{http_code}" http://localhost:4000 2>/dev/null | grep -q "200"; check $? "PUABO AI (4000)"
curl -s -o /dev/null -w "%{http_code}" http://localhost:8088 2>/dev/null | grep -q "200"; check $? "V-Screen (8088)"
curl -s -o /dev/null -w "%{http_code}" http://localhost:5315 2>/dev/null | grep -q "200"; check $? "Creator Studio (5315)"

echo ""
echo "=== 3. BLACK SCREEN DIAGNOSIS ==="
if [ -d /var/www/vhosts/nexuscos.online/httpdocs ]; then
    cd /var/www/vhosts/nexuscos.online/httpdocs
    CONTENT=$(curl -s https://nexuscos.online/vscreen-app/ 2>/dev/null || echo "")
    if echo "$CONTENT" | grep -q '<div id="root"></div>' && ! echo "$CONTENT" | grep -q '<div id="root">[^<]'; then
        echo "✗ React NOT mounting - root div is empty"
        ((FAIL++))
    else
        echo "✓ React content detected"
        ((PASS++))
    fi
else
    echo "⚠ Cannot access /var/www/vhosts/nexuscos.online/httpdocs - skipping web check"
fi

echo ""
echo "=== 4. CREATING DIAGNOSTIC PAGE ==="
if [ -d /var/www/vhosts/nexuscos.online/httpdocs/vscreen-app ]; then
    cat > /var/www/vhosts/nexuscos.online/httpdocs/vscreen-app/diagnostic.html << 'DIAGNOSTIC_EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>V-Screen Diagnostic</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: #1a1a1a;
            color: #fff;
        }
        h1 { color: #4CAF50; }
        .test { 
            padding: 10px;
            margin: 10px 0;
            background: #2a2a2a;
            border-left: 4px solid #4CAF50;
        }
        .error { border-left-color: #f44336; }
        pre {
            background: #000;
            padding: 10px;
            overflow-x: auto;
        }
    </style>
</head>
<body>
    <h1>V-Screen Diagnostic Page</h1>
    <div class="test">
        <strong>Test 1:</strong> Basic HTML rendering
        <p>✓ If you can see this, HTML is working</p>
    </div>
    <div class="test error" id="js-test">
        <strong>Test 2:</strong> JavaScript execution
        <p>✗ JavaScript NOT running</p>
    </div>
    <div class="test">
        <strong>Test 3:</strong> API Connectivity
        <p id="api-test">⏳ Testing...</p>
    </div>
    <div class="test">
        <strong>Test 4:</strong> React Detection
        <p id="react-test">⏳ Testing...</p>
    </div>
    <h2>Console Errors</h2>
    <pre id="console-errors">Check browser console (F12) for errors</pre>
    
    <script>
        // Test JavaScript
        document.getElementById('js-test').className = 'test';
        document.getElementById('js-test').innerHTML = '<strong>Test 2:</strong> JavaScript execution<p>✓ JavaScript is working</p>';
        
        // Test API
        fetch('/api/health')
            .then(r => r.json())
            .then(data => {
                document.getElementById('api-test').innerHTML = '✓ API responding: ' + JSON.stringify(data);
            })
            .catch(err => {
                document.getElementById('api-test').innerHTML = '✗ API error: ' + err.message;
            });
        
        // Test React
        if (window.React) {
            document.getElementById('react-test').innerHTML = '✓ React is loaded (version ' + React.version + ')';
        } else {
            document.getElementById('react-test').innerHTML = '✗ React NOT loaded';
        }
        
        // Capture console errors
        const errors = [];
        const originalError = console.error;
        console.error = function(...args) {
            errors.push(args.join(' '));
            originalError.apply(console, args);
        };
        
        setTimeout(() => {
            if (errors.length > 0) {
                document.getElementById('console-errors').textContent = errors.join('\n');
            } else {
                document.getElementById('console-errors').textContent = 'No errors detected';
            }
        }, 2000);
    </script>
</body>
</html>
DIAGNOSTIC_EOF
    echo "Created: https://nexuscos.online/vscreen-app/diagnostic.html"
    ((PASS++))
else
    echo "⚠ Cannot create diagnostic page - directory not accessible"
fi

echo ""
echo "=== SUMMARY ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

echo ""
echo "NEXT STEPS:"
echo "1. Visit: https://nexuscos.online/vscreen-app/diagnostic.html"
echo "2. Open browser console (F12) on black screen page"
echo "3. Share console errors here"

# Exit with error if any checks failed
if [ $FAIL -gt 0 ]; then
    exit 1
fi

exit 0

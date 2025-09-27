#!/bin/bash
echo "Validating Nexus COS PF setup..."
if [ -f "./deployment/nginx/nexuscos_pf.js" ]; then
  echo "Verification script found."
else
  echo "Error: nexuscos_pf.js missing!"
  exit 1
fi

if node -v > /dev/null 2>&1; then
  echo "Node.js installed."
else
  echo "Error: Node.js not found!"
  exit 1
fi

echo "All setup validated."
exit 0
#!/bin/bash

MODULES=("studio" "metavision" "puaboverse")
REPORT="/opt/nexus-cos/SERVICES_MODULE_CHECK.md"
echo "# Nexus COS Services Module Check" > $REPORT
echo "Generated: $(date)" >> $REPORT
echo "" >> $REPORT

for MOD in "${MODULES[@]}"; do
  MOD_PATH="/opt/nexus-cos/services/$MOD"
  if [ -d "$MOD_PATH" ]; then
    echo "- ✅ $MOD directory exists at $MOD_PATH" >> $REPORT
    if [ -f "$MOD_PATH/package.json" ]; then
      echo "  - 📦 package.json found" >> $REPORT
      echo "  - Contents preview:" >> $REPORT
      head -n 10 "$MOD_PATH/package.json" >> $REPORT
      echo "  ..." >> $REPORT
    else
      echo "  - ⚠️ No package.json found" >> $REPORT
    fi
  else
    echo "- ❌ $MOD directory is missing at $MOD_PATH" >> $REPORT
  fi
done

echo "" >> $REPORT
echo "📄 Report saved to $REPORT"
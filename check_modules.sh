MODULES=("studio" "metavision" "puaboverse") 
REPORT="/opt/nexus-cos/MODULE_SOURCE_CHECK.md" 
echo "# Nexus COS Module Source Check" > $REPORT 
echo "Generated: $(date)" >> $REPORT 
echo "" >> $REPORT 

for MOD in "${MODULES[@]}"; do 
  MOD_PATH="/opt/nexus-cos/$MOD" 
  if [ -d "$MOD_PATH" ]; then 
    echo "- ✅ $MOD exists at $MOD_PATH" >> $REPORT 
    if [ -f "$MOD_PATH/package.json" ]; then 
      echo "  - 📦 package.json found (ready to build)" >> $REPORT 
    else 
      echo "  - ⚠️ No package.json found (not buildable)" >> $REPORT 
    fi 
  else 
    echo "- ❌ $MOD is missing (no directory at $MOD_PATH)" >> $REPORT 
  fi 
done 

echo "" >> $REPORT 
echo "📄 Report saved to $REPORT"
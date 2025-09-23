#!/bin/bash

# Sync Assets
echo "🔄 Syncing Nexus COS global assets..."
mkdir -p /opt/nexus-cos/shared/assets
cp -r /opt/nexus-cos/assets/* /opt/nexus-cos/shared/assets/
echo "✅ Global assets centralized"

# Apply Branding Across Modules
echo "🎨 Applying Nexus COS branding to all modules..."
for module in studio metavision streamcore api dashboard; do
  MODULE_PATH="/opt/nexus-cos/services/$module/public"
  mkdir -p $MODULE_PATH/assets
  cp -r /opt/nexus-cos/shared/assets/* $MODULE_PATH/assets/

  # Inject favicon + logo into head and navbar
  if [ -f "$MODULE_PATH/index.html" ]; then
    sed -i '/<head>/a \
<link rel="icon" href="/assets/favicon.svg" type="image/svg+xml"> \
<link rel="apple-touch-icon" href="/assets/favicon.svg"> \
<link rel="stylesheet" href="/assets/branding.css">' $MODULE_PATH/index.html

    sed -i '/<nav>/a \
<img src="/assets/logo.svg" alt="Nexus COS Logo" class="logo-navbar">' $MODULE_PATH/index.html
  fi
done
echo "✅ Branding applied to all modules"

# Branding Stylesheet
echo "🎨 Creating global branding stylesheet..."
cat <<EOF > /opt/nexus-cos/shared/assets/branding.css
body {
  font-family: 'Inter', sans-serif;
  background-color: #f9fafb;
}
.logo-navbar {
  height: 42px;
  margin-right: 12px;
}
.btn-primary {
  background-color: #1D4ED8;
  color: #fff;
  border-radius: 8px;
}
.btn-primary:hover {
  background-color: #6D28D9;
}
EOF
echo "✅ Branding stylesheet created"

# Update Nginx Config
echo "⚙️ Updating Nginx to serve shared branding..."
sed -i '/location \/ {/,/}/{s|root .*|root /opt/nexus-cos/shared;|}' /etc/nginx/sites-available/nexuscos.conf
nginx -t && systemctl reload nginx
echo "✅ Nginx updated and reloaded"

# Restart Services
echo "🔄 Restarting services to apply branding..."
docker compose -f /opt/nexus-cos/docker-compose.yml restart
echo "✅ Services restarted with new branding"

# Generate Branding Report
REPORT=/opt/nexus-cos/BRANDING-REPORT.md
echo "# Nexus COS Global Branding Report" > $REPORT
echo "Generated: $(date)" >> $REPORT
echo "" >> $REPORT
echo "## Applied Branding" >> $REPORT
echo "- Logo + Favicon applied globally" >> $REPORT
echo "- Navbar + Landing pages updated" >> $REPORT
echo "- Branding stylesheet injected" >> $REPORT
echo "" >> $REPORT
echo "✅ Nexus COS is now globally branded!" >> $REPORT
echo "📄 Report saved at $REPORT"
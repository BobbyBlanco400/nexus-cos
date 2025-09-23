#!/bin/bash

echo "⚙️ Updating Nginx reverse proxy..."

/opt/nexus-cos/scripts/generate-nginx-from-yml.sh /opt/nexus-cos/nginx-routes.yml > /etc/nginx/sites-enabled/nexuscos.conf

nginx -t && systemctl restart nginx

echo "✅ Nginx updated with all Nexus COS routes"
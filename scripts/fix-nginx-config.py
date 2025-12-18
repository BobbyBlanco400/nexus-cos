#!/usr/bin/env python3
"""
Nexus COS - Nginx Configuration Generator
Integrates TRAE's routing updates with platform fixes
Generates nginx.conf with streaming as front-facing entrypoint
"""

import os
import sys

def generate_nginx_config():
    """Generate complete nginx.conf with all platform routes"""
    
    config = """events {}

http {
    # PF Service Upstreams - Exact container names from docker-compose.pf.yml
    upstream pf_gateway {
        server puabo-api:4000;
    }

    upstream pf_puaboai_sdk {
        server nexus-cos-puaboai-sdk:3002;
    }

    upstream pf_pv_keys {
        server nexus-cos-pv-keys:3041;
    }

    # HTTP to HTTPS redirect - All PF domains
    server {
        listen 80;
        server_name nexuscos.online www.nexuscos.online beta.nexuscos.online;
        return 301 https://$server_name$request_uri;
    }

    # Main HTTPS server for nexuscos.online
    server {
        listen 443 ssl http2;
        server_name nexuscos.online www.nexuscos.online;

        # IONOS SSL Configuration
        ssl_certificate /etc/ssl/ionos/fullchain.pem;
        ssl_certificate_key /etc/ssl/ionos/privkey.pem;
        ssl_trusted_certificate /etc/ssl/ionos/chain.pem;

        # SSL Security Settings
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;
        ssl_session_tickets off;
        ssl_stapling on;
        ssl_stapling_verify on;

        # Security Headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;
        add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

        # Domain-specific logging
        access_log /var/log/nginx/nexuscos.online_access.log;
        error_log /var/log/nginx/nexuscos.online_error.log;

        # PF Gateway Health Check
        location /health {
            proxy_pass http://pf_gateway/health;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # PF Service Health Checks
        location /health/puaboai-sdk {
            proxy_pass http://pf_puaboai_sdk/health;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location /health/pv-keys {
            proxy_pass http://pf_pv_keys/health;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # PF Frontend Routes - Admin Panel
        location /admin {
            proxy_pass http://pf_gateway/admin;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        # PF Frontend Routes - Creator Hub
        location /hub {
            proxy_pass http://pf_gateway/hub;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        # PF Frontend Routes - Studio
        location /studio {
            proxy_pass http://pf_gateway/studio;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        # PF V-Suite Routes - Stage
        location /v-suite/stage {
            proxy_pass http://pf_gateway/v-suite/stage;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        # PF V-Screen Route
        location /v-screen {
            proxy_pass http://pf_gateway/v-screen;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        # PF V-Suite Routes - Caster
        location /v-suite/caster {
            proxy_pass http://pf_gateway/v-suite/caster;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        # PF V-Suite Routes - Hollywood
        location /v-suite/hollywood {
            proxy_pass http://pf_gateway/v-suite/hollywood;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        # PF Frontend Routes - Streaming (v-caster-pro)
        location /streaming {
            proxy_pass http://pf_gateway/streaming;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        # PF V-Suite Routes - Prompter (v-prompter-pro)
        location /v-suite/prompter {
            proxy_pass http://pf_puaboai_sdk/v-suite/prompter;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        # PF API Gateway
        location /api {
            proxy_pass http://pf_gateway/api;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        # SPA Routes - Apex
        location /apex/ {
            alias /usr/share/nginx/html/apex/;
            index index.html;
            try_files $uri $uri/ /apex/index.html;
            
            # Cache static assets
            location ~* \\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
                expires 1y;
                add_header Cache-Control "public, immutable";
            }
        }

        # SPA Routes - Beta Landing
        location /beta/ {
            alias /usr/share/nginx/html/beta/;
            index index.html;
            try_files $uri $uri/ /beta/index.html;
            
            # Cache static assets
            location ~* \\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
                expires 1y;
                add_header Cache-Control "public, immutable";
            }
        }

        # SPA Routes - Drops
        location /drops/ {
            alias /usr/share/nginx/html/drops/;
            index index.html;
            try_files $uri $uri/ /drops/index.html;
            
            # Cache static assets
            location ~* \\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
                expires 1y;
                add_header Cache-Control "public, immutable";
            }
        }

        # SPA Routes - Docs
        location /docs/ {
            alias /usr/share/nginx/html/docs/;
            index index.html;
            try_files $uri $uri/ /docs/index.html;
            
            # Cache static assets
            location ~* \\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
                expires 1y;
                add_header Cache-Control "public, immutable";
            }
        }

        # Hashed assets
        location /assets/ {
            alias /usr/share/nginx/html/assets/;
            expires 1y;
            add_header Cache-Control "public, immutable";
        }

        # Root - Redirect to Streaming (legal front-facing entrypoint)
        location = / {
            return 301 /streaming;
        }

        # Root - Main Frontend (fallback for other paths)
        location / {
            proxy_pass http://pf_gateway/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
    }

    # Monitoring subdomain
    server {
        listen 443 ssl http2;
        server_name monitoring.nexuscos.online;

        # IONOS SSL Configuration
        ssl_certificate /etc/ssl/ionos/fullchain.pem;
        ssl_certificate_key /etc/ssl/ionos/privkey.pem;
        ssl_trusted_certificate /etc/ssl/ionos/chain.pem;

        # SSL Security Settings
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;
        ssl_session_tickets off;
        ssl_stapling on;
        ssl_stapling_verify on;

        # Security Headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;
        add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

        # Domain-specific logging
        access_log /var/log/nginx/monitoring.nexuscos.online_access.log;
        error_log /var/log/nginx/monitoring.nexuscos.online_error.log;

        # Monitoring (Grafana)
        location / {
            proxy_pass http://localhost:3000/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }

    # Beta subdomain - beta.nexuscos.online
    server {
        listen 443 ssl http2;
        server_name beta.nexuscos.online;

        # IONOS SSL Configuration for beta
        ssl_certificate /etc/ssl/ionos/beta.nexuscos.online/fullchain.pem;
        ssl_certificate_key /etc/ssl/ionos/beta.nexuscos.online/privkey.pem;

        # SSL Security Settings
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;
        ssl_session_tickets off;
        ssl_stapling on;
        ssl_stapling_verify on;

        # Security Headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;
        add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        add_header X-Environment "beta" always;

        # Domain-specific logging
        access_log /var/log/nginx/beta.nexuscos.online_access.log;
        error_log /var/log/nginx/beta.nexuscos.online_error.log;

        # Beta Health Check
        location /health {
            proxy_pass http://pf_gateway/health;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Beta API Gateway
        location /api {
            proxy_pass http://pf_gateway/api;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        # Beta Streaming via PF gateway
        location /streaming {
            proxy_pass http://pf_gateway/streaming;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        # Beta VR modules via PF gateway
        location /v-screen {
            proxy_pass http://pf_gateway/v-screen;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        location /v-suite/stage {
            proxy_pass http://pf_gateway/v-suite/stage;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        location /v-suite/caster {
            proxy_pass http://pf_gateway/v-suite/caster;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        location /v-suite/hollywood {
            proxy_pass http://pf_gateway/v-suite/hollywood;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        # Beta SPA Routes
        location /apex/ {
            alias /usr/share/nginx/html/apex/;
            index index.html;
            try_files $uri $uri/ /apex/index.html;
        }

        location /beta/ {
            alias /usr/share/nginx/html/beta/;
            index index.html;
            try_files $uri $uri/ /beta/index.html;
        }

        location /drops/ {
            alias /usr/share/nginx/html/drops/;
            index index.html;
            try_files $uri $uri/ /drops/index.html;
        }

        location /docs/ {
            alias /usr/share/nginx/html/docs/;
            index index.html;
            try_files $uri $uri/ /docs/index.html;
        }

        location /assets/ {
            alias /usr/share/nginx/html/assets/;
            expires 1y;
            add_header Cache-Control "public, immutable";
        }

        # Beta root - redirect to streaming
        location = / {
            return 301 /streaming;
        }

        # Beta Frontend (fallback)
        location / {
            proxy_pass http://pf_gateway/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
    }

    # Networks
    networks:
      cos-net:
        driver: bridge
      nexus-network:
        driver: bridge

    # Volumes
    volumes:
      postgres_data:
      redis_data:
      nginx_logs:
}
"""
    
    return config

def main():
    """Main execution"""
    print("🔧 Nexus COS - Nginx Configuration Generator")
    print("=" * 60)
    
    # Generate config
    config = generate_nginx_config()
    
    # Write to nginx.conf
    output_path = "/opt/nexus-cos/nginx.conf"
    
    # Try current directory if /opt/nexus-cos doesn't exist
    if not os.path.exists("/opt/nexus-cos"):
        output_path = "./nginx.conf"
    
    print(f"📝 Writing configuration to: {output_path}")
    
    try:
        with open(output_path, 'w') as f:
            f.write(config)
        print(f"✅ Configuration written successfully!")
        print(f"\nNext steps:")
        print(f"1. Validate: sudo nginx -t")
        print(f"2. Reload: sudo systemctl reload nginx")
        print(f"3. Or Docker: cd /opt/nexus-cos && docker-compose restart nginx")
        return 0
    except Exception as e:
        print(f"❌ Error writing configuration: {e}")
        return 1

if __name__ == "__main__":
    sys.exit(main())

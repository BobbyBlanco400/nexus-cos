#!/usr/bin/env python3

import yaml
import sys
from typing import Dict, List

# Templates for Nginx configuration
MAIN_TEMPLATE = """
# Nginx configuration for Nexus COS Backend Services
# Generated automatically - DO NOT EDIT MANUALLY

user www-data;
worker_processes auto;
pid /run/nginx.pid;

events {{
    worker_connections 1024;
    multi_accept on;
}}

http {{
    # Basic Settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;

    # MIME Types
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Logging
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    # Gzip Settings
    gzip {gzip_setting};
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    # SSL Settings
    {ssl_config}

    # Security Headers
    {security_headers}

    # Client Upload Size
    client_max_body_size {client_max_body_size};
    
    # Timeouts
    proxy_connect_timeout {proxy_timeout};
    proxy_send_timeout {proxy_timeout};
    proxy_read_timeout {proxy_timeout};

    # Static Asset Caching
    {static_asset_config}

    # Service Proxies
    {service_proxies}
}}
"""

SSL_CONFIG_TEMPLATE = """
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 8.8.8.8 8.8.4.4 valid=300s;
    resolver_timeout 5s;
    add_header Strict-Transport-Security "max-age=63072000" always;
"""

STATIC_ASSET_TEMPLATE = """
    location /static/ {{
        alias {static_path};
        expires {cache_time};
        add_header Cache-Control "public, no-transform";
    }}
"""

SERVICE_PROXY_TEMPLATE = """
    # {service_name} Service
    location {location} {{
        proxy_pass http://localhost:{port};
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }}
"""

def load_config(config_file: str) -> Dict:
    """Load and parse YAML configuration file."""
    try:
        with open(config_file, 'r') as f:
            return yaml.safe_load(f)
    except Exception as e:
        print(f"Error loading configuration: {str(e)}", file=sys.stderr)
        sys.exit(1)

def generate_security_headers(headers: Dict[str, str]) -> str:
    """Generate Nginx security header configuration."""
    if not headers:
        return ""
    
    header_config = []
    for header, value in headers.items():
        header_config.append(f'    add_header {header} "{value}" always;')
    return "\n".join(header_config)

def generate_service_proxies(services: Dict) -> str:
    """Generate Nginx proxy configurations for services."""
    proxies = []
    for service_name, config in services.items():
        location = f"/api/{service_name}"
        if service_name == "nexus-backend":
            location = "/api"
        
        proxy = SERVICE_PROXY_TEMPLATE.format(
            service_name=service_name,
            location=location,
            port=config['port']
        )
        proxies.append(proxy)
    return "\n".join(proxies)

def generate_nginx_config(config: Dict) -> str:
    """Generate complete Nginx configuration."""
    nginx_config = config.get('nginx', {})
    services = config.get('services', {})
    
    # SSL Configuration
    ssl_config = ""
    if nginx_config.get('ssl', {}).get('enabled', False):
        ssl_config = SSL_CONFIG_TEMPLATE
    
    # Static Asset Configuration
    static_assets = nginx_config.get('static_assets', {})
    static_asset_config = STATIC_ASSET_TEMPLATE.format(
        static_path=static_assets.get('path', '/var/www/nexus-cos/static/'),
        cache_time=static_assets.get('cache_time', '7d')
    ) if static_assets else ""
    
    # Security Headers
    security_headers = generate_security_headers(
        nginx_config.get('security_headers', {})
    )
    
    return MAIN_TEMPLATE.format(
        gzip_setting="on" if nginx_config.get('gzip', True) else "off",
        ssl_config=ssl_config,
        security_headers=security_headers,
        client_max_body_size=nginx_config.get('client_max_body_size', '100M'),
        proxy_timeout=nginx_config.get('proxy_timeout', '300s'),
        static_asset_config=static_asset_config,
        service_proxies=generate_service_proxies(services)
    )

def main():
    if len(sys.argv) != 2:
        print("Usage: generate-nginx-config.py <config_file>", file=sys.stderr)
        sys.exit(1)
    
    config = load_config(sys.argv[1])
    nginx_config = generate_nginx_config(config)
    print(nginx_config)

if __name__ == "__main__":
    main()
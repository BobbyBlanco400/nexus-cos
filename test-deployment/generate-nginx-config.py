#!/usr/bin/env python3

import yaml
import sys
import os
from typing import Dict, Any

NGINX_TEMPLATE = """
# Nginx configuration for Nexus COS
# Generated automatically - DO NOT EDIT MANUALLY

user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 1024;
    multi_accept on;
}

http {
    ##
    # Basic Settings
    ##
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;

    # MIME
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    ##
    # SSL Settings
    ##
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets off;
    ssl_stapling on;
    ssl_stapling_verify on;

    ##
    # Logging Settings
    ##
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    ##
    # Gzip Settings
    ##
    gzip {gzip_setting};
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    ##
    # Virtual Host Configs
    ##
    server {
        listen 80;
        listen [::]:80;
        server_name _;

        {ssl_redirect}

        location / {
            return 404;
        }
    }

    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name _;

        # SSL configuration
        ssl_certificate {ssl_cert};
        ssl_certificate_key {ssl_key};

        # Security headers
        {security_headers}

        # Client body size
        client_max_body_size {client_max_body_size};

        # Root directory for static files
        root {static_path};

        # Static asset caching
        location /static/ {
            expires {static_cache_time};
            add_header Cache-Control "public, no-transform";
        }

        # Service proxies
        {service_proxies}

        # Default location
        location / {
            try_files $uri $uri/ /index.html;
        }
    }
}
"""

SERVICE_PROXY_TEMPLATE = """
        # {service_name} API proxy
        location /api/{service_path}/ {
            proxy_pass http://localhost:{port}/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_cache_bypass $http_upgrade;
            proxy_read_timeout {proxy_timeout};
        }
"""

def load_config(config_file: str) -> Dict[str, Any]:
    """Load and parse the YAML configuration file."""
    try:
        with open(config_file, 'r') as f:
            return yaml.safe_load(f)
    except Exception as e:
        print(f"Error loading configuration: {str(e)}", file=sys.stderr)
        sys.exit(1)

def generate_security_headers(headers: Dict[str, str]) -> str:
    """Generate Nginx security header configuration."""
    return '\n        '.join(f'add_header {name} "{value}";' for name, value in headers.items())

def generate_service_proxies(services: Dict[str, Any], proxy_timeout: str) -> str:
    """Generate Nginx proxy configurations for all services."""
    proxies = []
    for service_name, config in services.items():
        service_path = service_name.replace('_', '-')
        proxies.append(SERVICE_PROXY_TEMPLATE.format(
            service_name=service_name,
            service_path=service_path,
            port=config['port'],
            proxy_timeout=proxy_timeout
        ))
    return ''.join(proxies)

def generate_nginx_config(config: Dict[str, Any]) -> str:
    """Generate the complete Nginx configuration."""
    nginx_config = config.get('nginx', {})
    ssl_config = nginx_config.get('ssl', {})
    
    # SSL redirect configuration
    ssl_redirect = """
        # Redirect all HTTP traffic to HTTPS
        return 301 https://$host$request_uri;
    """ if ssl_config.get('enabled', True) else ""

    # Generate the configuration
    return NGINX_TEMPLATE.format(
        gzip_setting='on' if nginx_config.get('gzip', True) else 'off',
        ssl_redirect=ssl_redirect,
        ssl_cert=ssl_config.get('cert_path', '/etc/ssl/certs/nexus-cos.crt'),
        ssl_key=ssl_config.get('key_path', '/etc/ssl/private/nexus-cos.key'),
        security_headers=generate_security_headers(nginx_config.get('security_headers', {})),
        client_max_body_size=nginx_config.get('client_max_body_size', '100M'),
        static_path=nginx_config.get('static_assets', {}).get('path', '/var/www/nexus-cos/static'),
        static_cache_time=nginx_config.get('static_assets', {}).get('cache_time', '7d'),
        service_proxies=generate_service_proxies(
            config.get('services', {}),
            nginx_config.get('proxy_timeout', '300s')
        )
    )

def main():
    """Main execution function."""
    if len(sys.argv) != 2:
        print("Usage: generate-nginx-config.py <config_file>", file=sys.stderr)
        sys.exit(1)

    config_file = sys.argv[1]
    if not os.path.exists(config_file):
        print(f"Configuration file {config_file} not found", file=sys.stderr)
        sys.exit(1)

    config = load_config(config_file)
    nginx_config = generate_nginx_config(config)
    print(nginx_config)

if __name__ == '__main__':
    main()
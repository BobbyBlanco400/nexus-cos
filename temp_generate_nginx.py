import yaml
import sys
from urllib.parse import urlparse

input_file = sys.argv[1]

with open(input_file, 'r') as f:
    data = yaml.safe_load(f)

def generate_locations(data):
    locations = ''
    for key, value in data.items():
        if isinstance(value, dict):
            if 'path' in value and 'proxy' in value:
                path = value['path']
                proxy = value['proxy']
                parsed = urlparse(proxy)
                new_proxy = f'{parsed.scheme}://127.0.0.1:{parsed.port}'
                locations += f'    location {path} {{\n        proxy_pass {new_proxy};\n        proxy_set_header Host $host;\n        proxy_set_header X-Real-IP $remote_addr;\n        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n        proxy_set_header X-Forwarded-Proto $scheme;\n    }}\n'
            else:
                locations += generate_locations(value)
    return locations

locations = generate_locations(data)

config = f'server {{\n    listen 80;\n    server_name nexuscos.online;\n    location / {{\n        return 301 https://$host$request_uri;\n    }}\n}}\n\nserver {{\n    listen 443 ssl;\n    server_name nexuscos.online;\n    ssl_certificate /etc/letsencrypt/live/nexuscos.online/fullchain.pem;\n    ssl_certificate_key /etc/letsencrypt/live/nexuscos.online/privkey.pem;\n    ssl_protocols TLSv1.2 TLSv1.3;\n    ssl_prefer_server_ciphers on;\n{locations}}}\n'

print(config)
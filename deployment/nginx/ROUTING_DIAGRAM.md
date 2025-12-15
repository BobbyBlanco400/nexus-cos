# Nginx Routing Diagram for nexuscos.online

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         CLIENT REQUEST                                   │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    HTTP (Port 80) or HTTPS (Port 443)                   │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │  Is request using HTTP?       │
                    └───────────────────────────────┘
                                    │
                    ┌───────────────┴───────────────┐
                   YES                             NO
                    │                               │
                    ▼                               ▼
        ┌───────────────────────┐       ┌──────────────────────┐
        │  Redirect to HTTPS    │       │  Continue to HTTPS   │
        │  (301 Permanent)      │       │  Server Block        │
        └───────────────────────┘       └──────────────────────┘
                    │                               │
                    └───────────────┬───────────────┘
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         HTTPS SERVER BLOCK                               │
│                    (nexuscos.online / www.nexuscos.online)              │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │      Match Request Path       │
                    └───────────────────────────────┘
                                    │
        ┌───────────┬───────────┬──┴──┬───────────┬───────────┬──────────┐
        │           │           │     │           │           │          │
        ▼           ▼           ▼     ▼           ▼           ▼          ▼
    ┌─────┐   ┌──────┐   ┌──────┐ ┌─────┐  ┌────────┐  ┌──────┐  ┌────────┐
    │  /  │   │/apex/│   │/beta/│ │/core│  │  /api/ │  │/stream│  │ /hls/  │
    └─────┘   └──────┘   └──────┘ └─────┘  └────────┘  └──────┘  └────────┘
        │           │           │       │          │          │          │
        ▼           ▼           ▼       ▼          ▼          ▼          ▼
┌──────────┐ ┌──────────┐ ┌──────────┐ ┌─────┐ ┌──────┐ ┌────────┐ ┌────────┐
│  Serve   │ │  Serve   │ │  Serve   │ │Serve│ │Proxy │ │ Proxy  │ │ Proxy  │
│  Static  │ │   SPA    │ │   SPA    │ │Asset│ │  to  │ │   to   │ │   to   │
│   HTML   │ │  (Apex)  │ │  (Beta)  │ │CORS │ │ 3000 │ │  3043  │ │  3043  │
└──────────┘ └──────────┘ └──────────┘ └─────┘ └──────┘ └────────┘ └────────┘
     │            │            │          │         │         │          │
     │            │            │          │         │         │          │
     │            │            │          │         │         │          │
     ▼            ▼            ▼          ▼         ▼         ▼          ▼
/var/www/    /var/www/    /var/www/   /var/www/  Backend  Streaming  Streaming
nexus-cos/   nexus-cos/   nexus-cos/  nexus-cos/  API     Service    Service
index.html   apex/        beta/       core/      (Node.js) (WebRTC/  (HLS)
                                                            Socket.IO)

     │            │            │          │         │         │          │
     │            ▼            ▼          │         │         ▼          ▼
     │      try_files     try_files       │         │    WebSocket  WebSocket
     │      fallback      fallback        │         │     Support   Support
     │      to index      to index        │         │    Extended   Standard
     │                                    │         │    Timeout    Headers
     │                                    │         │    (86400s)
     │                                    │         │
     │                                    │         ▼
     │                                    │    ┌──────────────┐
     │                                    │    │ WebSocket    │
     │                                    │    │ Headers:     │
     │                                    │    │ - Upgrade    │
     │                                    │    │ - Connection │
     │                                    │    │ - Host       │
     │                                    │    │ - X-Real-IP  │
     │                                    │    └──────────────┘
     │                                    │
     ▼                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         RESPONSE TO CLIENT                               │
│                                                                          │
│  Security Headers:                                                       │
│  ✓ Strict-Transport-Security (HSTS)                                    │
│  ✓ X-Content-Type-Options: nosniff                                     │
│  ✓ X-Frame-Options: SAMEORIGIN                                         │
│  ✓ X-XSS-Protection: 1; mode=block                                     │
│  ✓ Referrer-Policy                                                     │
│                                                                          │
│  Caching:                                                                │
│  ✓ Static assets (JS/CSS/images): 1 year                               │
│  ✓ HTML/API responses: no-cache                                        │
└─────────────────────────────────────────────────────────────────────────┘
```

## Special Endpoints

```
┌──────────┐
│ /health  │  → Returns "ok" (200) - Nginx health check
└──────────┘

┌──────────────┐
│ Hidden files │  → Blocked (403) - Security filter
│ (.git, .env) │
└──────────────┘
```

## Port Mapping

```
External                           Internal
────────                          ────────
https://nexuscos.online/api/   →  http://127.0.0.1:3000/
https://nexuscos.online/stream/→  http://127.0.0.1:3043/stream/
https://nexuscos.online/hls/   →  http://127.0.0.1:3043/hls/
```

## Request Flow Example

### Example 1: API Request
```
1. Client → https://nexuscos.online/api/users
2. Nginx → Proxy to http://127.0.0.1:3000/users
3. Backend processes request
4. Backend → Response with data
5. Nginx → Add security headers
6. Client ← HTTPS response with data
```

### Example 2: SPA Navigation
```
1. Client → https://nexuscos.online/apex/dashboard
2. Nginx → try_files checks for /apex/dashboard file
3. File not found
4. Nginx → Fallback to /apex/index.html
5. Client ← Receives index.html
6. React Router handles /dashboard route client-side
```

### Example 3: Streaming Connection
```
1. Client → https://nexuscos.online/stream/ (WebSocket upgrade)
2. Nginx → Detects Upgrade header
3. Nginx → Proxy to http://127.0.0.1:3043/stream/
4. Nginx → Forward Upgrade and Connection headers
5. Streaming service accepts WebSocket
6. Nginx ← Maintains connection (timeout: 86400s)
7. Client ↔ Persistent WebSocket connection
```

## File System Layout

### Vanilla Nginx
```
/var/www/nexus-cos/
├── index.html           ← / (root)
├── apex/
│   └── index.html       ← /apex/* (SPA)
├── beta/
│   └── index.html       ← /beta/* (SPA)
└── core/                ← /core/* (assets with CORS)
```

### Plesk
```
/var/www/vhosts/nexuscos.online/httpdocs/
├── index.html           ← / (root)
├── apex/
│   └── index.html       ← /apex/* (SPA)
├── beta/
│   └── index.html       ← /beta/* (SPA)
└── core/                ← /core/* (assets with CORS)
```

## SSL/TLS Flow

```
Client Request (HTTPS)
        │
        ▼
┌────────────────────┐
│ TLS Handshake      │
│ - Verify cert      │
│ - Negotiate cipher │
└────────────────────┘
        │
        ▼
┌────────────────────┐
│ SSL Termination    │
│ at Nginx           │
│                    │
│ Certificates:      │
│ - fullchain.pem    │
│ - privkey.pem      │
└────────────────────┘
        │
        ▼
┌────────────────────┐
│ Decrypt Request    │
│ Process in Nginx   │
└────────────────────┘
        │
        ▼
┌────────────────────┐
│ Proxy to Backend   │
│ (Plain HTTP)       │
│ via 127.0.0.1      │
└────────────────────┘
        │
        ▼
┌────────────────────┐
│ Backend Response   │
└────────────────────┘
        │
        ▼
┌────────────────────┐
│ Encrypt Response   │
│ Add Headers        │
│ Send to Client     │
└────────────────────┘
```

## Load Balancing (Future Enhancement)

Currently, each service has one upstream. For scaling, you can add multiple upstreams:

```nginx
upstream backend_api {
    server 127.0.0.1:3000;
    server 127.0.0.1:3001;
    server 127.0.0.1:3002;
    keepalive 32;
}
```

## Monitoring Points

```
┌─────────────────────────────────────┐
│ Nginx Access Log                     │
│ /var/log/nginx/access.log           │
│ - Track all requests                │
│ - Monitor response times            │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ Nginx Error Log                      │
│ /var/log/nginx/error.log            │
│ - Track configuration errors        │
│ - Monitor upstream failures         │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ Health Endpoint                      │
│ GET https://nexuscos.online/health  │
│ - Returns: "ok"                     │
│ - Status: 200                       │
└─────────────────────────────────────┘
```

## Error Handling

```
Error Code         │ Source          │ Meaning
───────────────────┼─────────────────┼────────────────────────────
404 Not Found      │ Nginx/Backend   │ Path/resource doesn't exist
502 Bad Gateway    │ Nginx           │ Backend service is down
503 Service Unavail│ Nginx           │ Backend is overwhelmed
504 Gateway Timeout│ Nginx           │ Backend took too long
```

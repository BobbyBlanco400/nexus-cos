# Clocking T With Ta Gurl P — Virtual Gossip Column

Gossip/tea module for Nexus COS with Live, VOD, and PPV wiring.

## Endpoints
- `GET /health`
- `GET /live`
- `GET /vod/list`
- `GET /ppv/events`
- `GET /events`

## Ports
- Module: `CLOCKING_T_PORT` (default `8230`)
- Service: `CLOCKING_T_SERVICE_PORT` (default `8330`)

## Start
```sh
node modules/ClockingTWithTaGurlP/server.js
node services/ClockingTWithTaGurlPService/service.js
```
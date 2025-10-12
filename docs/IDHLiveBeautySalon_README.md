# IDH Live! (I Define Hair) Virtual Urban Beauty Salon

Beauty salon module for Nexus COS with Live, VOD, and PPV.

## Endpoints
- `GET /health`
- `GET /live`
- `GET /vod/list`
- `GET /ppv/events`
- `GET /events`

## Ports
- Module: `IDH_PORT` (default `8220`)
- Service: `IDH_SERVICE_PORT` (default `8320`)

## Start
```sh
node modules/IDHLiveBeautySalon/server.js
node services/IDHLiveBeautySalonService/service.js
```
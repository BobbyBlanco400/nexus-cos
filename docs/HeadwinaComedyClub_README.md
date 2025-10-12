# Headwina’s Virtual Comedy Club

Urban comedy module for Nexus COS with Live, VOD, and PPV wiring.

## Endpoints
- `GET /health` — service health
- `GET /live` — live stream status
- `GET /vod/list` — VOD catalog
- `GET /ppv/events` — PPV events
- `GET /events` — calendar

## Ports
- Module: `HEADWINA_PORT` (default `8210`)
- Service: `HEADWINA_SERVICE_PORT` (default `8310`)

## Start
```sh
node modules/HeadwinaComedyClub/server.js
node services/HeadwinaComedyClubService/service.js
```
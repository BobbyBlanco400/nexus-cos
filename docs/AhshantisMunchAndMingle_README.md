# Ahshanti's Munch & Mingle — Flagship Module (TRAE Solo)

Purpose: Premium ASMR cooking, live streaming, VOD, social/commerce. Healthy Air Fryer focus. All proceeds to Ahshanti (minus 20% Nexus COS platform fee).

## Features
- Live ASMR Cooking Shows: HD/4K streaming, multi‑angle, audio controls, chat, tips, reactions.
- VOD Recipe Library: On‑demand videos, guides, nutrition, ingredients, bookmarks/shares.
- Healthy Cooking Hub: Weekly tips, guides, user recipes, Q&A and guest nutritionists.
- Premium Monetization: PPV, subscriptions, recipe unlocks, integrated payments, revenue dashboard.
- Community & Social: Private club, forums, contests, profiles, follows, messages.
- Branding: Custom logo and palette, uplifting health‑focused UI design.

## Service
- Path: `services/AhshantisMunchAndMingleService/server.js`
- Port: `8410` (configurable via `PORT` env)
- Health: `GET /health` (permanently green branding, returns `{ status: 'healthy' }`)
- Endpoints: `/live`, `/vod`, `/hub`, `/payments`, `/social` (placeholders)

## PM2
- Config: `ecosystem.ahshantis-munch-and-mingle.config.js`
- Start: `pm2 start ecosystem.ahshantis-munch-and-mingle.config.js`

## Frontend
- Page: `/ahshanti/munch-and-mingle` — tabs for Live, VOD, Hub, Monetization, Social.
- Health chips default green per branding.

## PF Install Command
```sh
nexus-cos install AhshantisMunchAndMingle
```
Triggers setup, config, branding assets, payments wiring, and integration into ModularStack.

## Notes
- Flagship module: prioritize stability and premium UX.
- Proceeds flow directly to Ahshanti, minus platform fee.
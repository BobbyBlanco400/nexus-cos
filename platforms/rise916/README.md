# Rise Sacramento: VoicesOfThe916

World's first browser-based platform dedicated to showcasing Sacramento's music artists with global virtual reach and community impact.

## Platform Overview

- **Platform ID**: rise_sacramento_voices916
- **Version**: 1.0.0
- **Type**: Browser Virtual Music Platform

## Features

- Virtual Artist Showcases
- 3D Browser-Based Performance Portals
- Spotlight Artist Cycles
- 916 Sound Map
- Community Pulse & Story Hub
- Global Discovery Engine
- Impact Metrics & Awards

## Technology Stack

### Frontend
- React 18.x
- Three.js (3D graphics)
- @react-three/fiber (React renderer for Three.js)
- TailwindCSS (styling)

### Backend
- Node.js
- Express
- CORS
- Body Parser

## Directory Structure

```
rise916/
├── frontend/           # React + Three.js + TailwindCSS frontend
│   ├── src/
│   │   ├── components/
│   │   │   ├── NavBar.js
│   │   │   ├── VirtualStage.js
│   │   │   ├── ArtistShowcase.js
│   │   │   └── CommunityHub.js
│   │   ├── App.js
│   │   ├── index.js
│   │   ├── App.css
│   │   └── index.css
│   ├── public/
│   ├── package.json
│   ├── tailwind.config.js
│   └── postcss.config.js
├── backend/            # Node.js + Express backend
│   ├── server.js
│   └── package.json
├── config/             # Platform configuration
│   └── platform.json
├── modules/            # Platform modules
├── db/                 # Database files
└── assets/             # Platform assets
```

## Getting Started

### Backend Setup

```bash
cd backend
npm install
npm start
```

The backend server will start on port 3001 by default.

### Frontend Setup

```bash
cd frontend
npm install
npm start
```

The frontend will start on port 3000 by default.

## API Endpoints

- `GET /api/artists` - Get list of featured artists
- `GET /api/health` - Health check endpoint

## Modules

This platform includes the following modules:
- artist_showcase_module
- virtual_stage_3d
- community_story_hub
- global_discovery_engine
- impact_metrics_tracker
- events_calendar_module
- user_profile_and_fan_interaction

## Branding

- **Primary Color**: #FF6F61 (Coral/Orange)
- **Secondary Color**: #1B1B1B (Dark Gray/Black)
- **Accent Color**: #FFD700 (Gold)
- **Font Family**: Montserrat, sans-serif

## Social Links

- Instagram: https://www.instagram.com/risesacramento/

## Deployment

See `config/platform.json` for deployment configuration and instructions.

## Creator Focus

Artists making an impact in Sacramento and globally.

## License

MIT

# Process Management

This document outlines how to manage local development processes and Windows services for Nexus COS modules.

## PM2 (Node.js)

Install PM2 globally or use `npx`:

```
npm i -g pm2
# or
npx pm2 -v
```

Start processes:

```
pm2 start ecosystem.config.js
pm2 restart <name>
pm2 stop <name>
pm2 delete <name>
pm2 list
pm2 logs <name>
```

### Family Modules (PM2 ecosystem)

For the four family-focused modules, a dedicated PM2 ecosystem file is provided:

```
pm2 start ecosystem.family.config.js
pm2 status
pm2 logs tyshawns-vdance-service
pm2 logs fayeloni-kreation-service
pm2 logs sassie-lashes-service
pm2 logs nee-nee-kids-service
```

Default ports:
- `TyshawnsVDanceStudioService` → `8401`
- `FayeloniKreationService` → `8402`
- `SassieLashesService` → `8403`
- `NeeNeeAndKidsShowService` → `8404`

Each service exposes `/health` returning `status`, `service`, `port`, and `time`.

## NSSM (Windows)

Install NSSM and register services:

```
nssm install gateway-backend "C:\\Program Files\\nodejs\\node.exe" "C:\\path\\to\\repo\\backend\\src\\server.js"
nssm install v-prompter-pro "C:\\Program Files\\nodejs\\node.exe" "C:\\path\\to\\repo\\modules\\v-suite\\v-prompter-pro\\server.js"
```

### Family Modules (NSSM examples)

Adjust paths as needed:

```
nssm install tyshawns-vdance-service "C:\\Program Files\\nodejs\\node.exe" "C:\\path\\to\\repo\\services\\TyshawnsVDanceStudioService\\server.js"
nssm set tyshawns-vdance-service AppParameters ""
nssm set tyshawns-vdance-service AppEnvironmentExtra "PORT=8401;SERVICE_NAME=TyshawnsVDanceStudioService"

nssm install fayeloni-kreation-service "C:\\Program Files\\nodejs\\node.exe" "C:\\path\\to\\repo\\services\\FayeloniKreationService\\server.js"
nssm set fayeloni-kreation-service AppEnvironmentExtra "PORT=8402;SERVICE_NAME=FayeloniKreationService"

nssm install sassie-lashes-service "C:\\Program Files\\nodejs\\node.exe" "C:\\path\\to\\repo\\services\\SassieLashesService\\server.js"
nssm set sassie-lashes-service AppEnvironmentExtra "PORT=8403;SERVICE_NAME=SassieLashesService"

nssm install nee-nee-kids-service "C:\\Program Files\\nodejs\\node.exe" "C:\\path\\to\\repo\\services\\NeeNeeAndKidsShowService\\server.js"
nssm set nee-nee-kids-service AppEnvironmentExtra "PORT=8404;SERVICE_NAME=NeeNeeAndKidsShowService"
```
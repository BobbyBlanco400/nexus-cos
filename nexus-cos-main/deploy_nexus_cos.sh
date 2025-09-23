name: Deploy Nexus COS

on:
  workflow_dispatch: # Manual trigger
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    defaults:
      run:
        shell: bash

    steps:
      # 1. Checkout the repo
      - name: Checkout code
        uses: actions/checkout@v3

      # 2. Set up Node.js
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: 20

      # 3. Cache Node modules for speed
      - name: Cache Node modules
        uses: actions/cache@v3
        with:
          path: |
            ~/.npm
            node_modules
          key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
          restore-keys: |
            ${{ runner.os }}-node-

      # 4. Install dependencies (backend first)
      - name: Install backend dependencies
        run: |
          cd backend
          npm ci --omit=dev
          cd ..

      # 5. Install frontend dependencies
      - name: Install frontend dependencies
        run: |
          cd web
          npm ci --omit=dev
          cd ..

      # 6. Install mobile dependencies
      - name: Install mobile dependencies
        run: |
          cd mobile
          npm ci --omit=dev
          cd ..

      # 7. Run your deployment script
      - name: Deploy Nexus COS
        run: |
          chmod +x deploy_nexus_cos.sh
          ./deploy_nexus_cos.sh

      # 8. Optional: List PM2 processes for confirmation
      - name: Check PM2 processes
        run: pm2 list


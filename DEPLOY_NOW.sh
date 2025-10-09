#!/bin/bash

# ==============================================================================
# NEXUS COS PHASE 2.5 - ULTIMATE ONE-LINER DEPLOYMENT
# ==============================================================================
# This is the absolute simplest deployment command for VPS
# Run this one command and everything deploys automatically
# ==============================================================================

cd /opt/nexus-cos && \
chmod +x scripts/deploy-phase-2.5-architecture.sh scripts/validate-phase-2.5-deployment.sh && \
sudo ./scripts/deploy-phase-2.5-architecture.sh && \
sudo ./scripts/validate-phase-2.5-deployment.sh

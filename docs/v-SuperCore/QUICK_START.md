# v-SuperCore Quick Start Guide

## Overview

v-SuperCore is the world's first fully virtualized Super PC, providing on-demand cloud computing resources accessible from any device.

## Quick Start

### Local Development

1. **Start services:**
   ```bash
   docker-compose -f docker-compose.v-supercore.yml up -d
   ```

2. **Verify services:**
   ```bash
   # Check health
   curl http://localhost:8080/health
   
   # View logs
   docker-compose -f docker-compose.v-supercore.yml logs -f
   ```

3. **Access dashboards:**
   - API: http://localhost:8080
   - Metrics: http://localhost:9091/metrics
   - Prometheus: http://localhost:9092
   - Grafana: http://localhost:3005 (admin/admin)

### Production Deployment

1. **Deploy to Kubernetes:**
   ```bash
   ./scripts/deploy-v-supercore.sh
   ```

2. **Verify deployment:**
   ```bash
   kubectl get pods -n v-supercore
   kubectl get services -n v-supercore
   ```

3. **Access production:**
   - Dashboard: https://n3xuscos.online/v-supercore
   - API: https://api.n3xuscos.online/v1/supercore

## API Usage

### Authentication

All API requests require:
- `X-N3XUS-Handshake: 55-45-17` header
- `Authorization: Bearer <token>` header

### Create Session

```bash
curl -X POST https://api.n3xuscos.online/v1/supercore/sessions/create \
  -H "X-N3XUS-Handshake: 55-45-17" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "tier": "standard"
  }'
```

### List Sessions

```bash
curl https://api.n3xuscos.online/v1/supercore/sessions \
  -H "X-N3XUS-Handshake: 55-45-17" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Connect to Session

```bash
curl https://api.n3xuscos.online/v1/supercore/stream/{sessionId}/connect \
  -H "X-N3XUS-Handshake: 55-45-17" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Resource Tiers

| Tier | CPU | RAM | GPU | Storage | Price/Hour |
|------|-----|-----|-----|---------|------------|
| Basic | 2 vCPU | 4 GB | - | 20 GB | 100 NexCoin |
| Standard | 4 vCPU | 8 GB | - | 50 GB | 200 NexCoin |
| Performance | 8 vCPU | 16 GB | - | 100 GB | 400 NexCoin |
| GPU Basic | 4 vCPU | 16 GB | T4 | 100 GB | 800 NexCoin |
| GPU Pro | 8 vCPU | 32 GB | A100 | 200 GB | 1600 NexCoin |

## Network Requirements

**Minimum:**
- 5 Mbps download / 1 Mbps upload
- <200ms latency

**Recommended:**
- 25 Mbps download / 5 Mbps upload
- <100ms latency

**Optimal:**
- 100+ Mbps download / 20+ Mbps upload
- <50ms latency

## Troubleshooting

### Service Won't Start

```bash
# Check logs
docker-compose -f docker-compose.v-supercore.yml logs v-supercore-orchestrator

# Restart service
docker-compose -f docker-compose.v-supercore.yml restart v-supercore-orchestrator
```

### Cannot Connect to Session

1. Verify session status is "active"
2. Check network connectivity
3. Ensure WebRTC ports are not blocked
4. Try different network (e.g., disable VPN)

### High Latency

1. Check your internet connection speed
2. Try selecting a closer geographic region
3. Lower streaming quality in settings
4. Close bandwidth-intensive applications

## Monitoring

### Metrics

View system metrics:
- Prometheus: http://localhost:9092
- Grafana: http://localhost:3005

### Key Metrics

- `v_supercore_active_sessions` - Active sessions count
- `v_supercore_resource_allocation` - Resource usage
- `http_request_duration_seconds` - API latency

### Alerts

Configure alerts in Prometheus for:
- High CPU/memory usage
- Session creation failures
- API errors
- Latency spikes

## Support

- Documentation: https://docs.n3xuscos.online/v-supercore
- Issues: https://github.com/BobbyBlanco400/nexus-cos/issues
- Support: support@n3xuscos.online

## Next Steps

1. Read the [full documentation](../docs/v-SuperCore/README.md)
2. Explore the [API reference](../docs/v-SuperCore/API.md)
3. Join the community on Discord
4. Check the [roadmap](../docs/v-SuperCore/ROADMAP.md)

---

**Status**: Phase 3.0 MVP  
**Version**: 1.0.0-alpha  
**Last Updated**: January 12, 2026

# Nexus COS - Core Platform Services

This directory contains the core platform services that provide foundational functionality for the entire Nexus COS ecosystem.

## Service Architecture Overview

Each service follows a microservice architecture pattern with:
- **Microservices**: Individual components within each service
- **Dependencies**: Clear mapping of service-to-service dependencies
- **APIs**: RESTful endpoints for inter-service communication
- **Health Checks**: Monitoring and health verification endpoints

## Services Structure

### Core Services
- `auth-service/` - Authentication and authorization
- `billing-service/` - Payment processing and financial operations
- `user-profile-service/` - User management and profiles
- `media-encoding-service/` - Media processing and encoding
- `streaming-service/` - Content delivery and streaming
- `recommendation-engine/` - ML-powered content recommendations
- `chat-service/` - Communication and messaging
- `notification-service/` - Multi-channel notifications
- `analytics-service/` - Data collection and reporting

## Dependency Management

Each service includes a `deps.yaml` file that defines:
- Required services for operation
- API endpoints consumed
- Event bus topics subscribed to
- Database dependencies

## Getting Started

1. Each service has its own `README.md` with specific setup instructions
2. Use the deployment scripts to start services in the correct order
3. Check `deps.yaml` files to understand inter-service relationships
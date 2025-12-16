# TCP Relay Detection Implementation

## Overview

This implementation adds TCP relay detection capabilities to the Pixel Streaming application. When WebRTC connections are forced to relay over TCP due to network restrictions (such as firewalls or NAT traversal issues), the system now logs a warning to alert operators about potential stream quality degradation.

## What is TCP Relay?

In WebRTC connections, UDP is the preferred protocol for real-time media streaming due to its low latency characteristics. However, when UDP is blocked or unavailable, WebRTC falls back to relaying data over TCP. This fallback can result in:

- Increased latency
- Reduced stream quality
- Potential buffering issues
- Higher bandwidth overhead

## Implementation Details

### Files Added/Modified

1. **PixelStreamingInfrastructure/Frontend/ui-library/src/Application/Application.ts** (NEW)
   - Main Application class with stream event listener management
   - Logger utility for structured logging
   - Stream class for event handling

2. **PixelStreamingInfrastructure/Frontend/ui-library/src/index.ts** (MODIFIED)
   - Exports Application class and Logger utility

3. **PixelStreamingInfrastructure/Frontend/implementations/react/src/App.tsx** (MODIFIED)
   - Enhanced React demo to showcase TCP relay detection

### Key Features

#### Application Class
```typescript
export class Application {
    private stream: Stream;
    
    constructor() {
        this.stream = new Stream();
        this.setupEventListeners();
    }
    
    private setupEventListeners(): void {
        // Player count listener
        this.stream.addEventListener('playerCount', ...);
        
        // TCP relay detection listener
        this.stream.addEventListener('webRtcTCPRelayDetected', ...);
    }
}
```

#### Logger Utility
```typescript
export class Logger {
    static Warning(stackTrace: string, message: string): void
    static Info(message: string): void
    static Error(stackTrace: string, message: string): void
    static GetStackTrace(): string
}
```

### Event Types

1. **playerCount** - Triggered when player count changes
   - Payload: `{ data: { count: number } }`

2. **webRtcTCPRelayDetected** - Triggered when TCP relay is detected
   - Logs warning: "Stream quality degraded due to network environment, stream is relayed over TCP."

## Usage Example

### Basic Usage
```typescript
import { Application, Logger } from '@epicgames-ps/lib-pixelstreamingfrontend-ui';

const app = new Application();

// The Application automatically listens for events
// TCP relay warnings will be logged when detected
```

### React Integration
```typescript
import { Application } from '@epicgames-ps/lib-pixelstreamingfrontend-ui';

const MyComponent = () => {
    const [application] = useState(() => new Application());
    
    // Application handles events automatically
    return <div>Pixel Streaming App</div>;
};
```

### Testing/Simulation
```typescript
// For testing purposes, you can trigger events manually
app.triggerTCPRelayEvent(); // Simulates TCP relay detection
app.triggerPlayerCountEvent(5); // Simulates player count update
```

## Testing

The implementation has been tested with:

1. **Unit Tests**: Node.js test script verifying all event listeners
2. **Build Tests**: Successfully builds with TypeScript and webpack
3. **Integration Tests**: React application successfully integrates and builds
4. **Security Scan**: CodeQL scan passed with 0 vulnerabilities

### Running Tests

```bash
# Build the ui-library
cd PixelStreamingInfrastructure/Frontend/ui-library
npm install
npm run build

# Build the React demo
cd ../implementations/react
npm install
npm run build
```

## Monitoring TCP Relay Issues

When TCP relay is detected, the following warning will appear in the console:

```
[WARNING] Stream quality degraded due to network environment, stream is relayed over TCP.
```

### Troubleshooting TCP Relay

If you see this warning frequently, consider:

1. **Network Configuration**
   - Ensure UDP ports are not blocked by firewalls
   - Check NAT configuration
   - Verify STUN/TURN server configuration

2. **Infrastructure**
   - Review network policies
   - Check for restrictive firewalls
   - Consider implementing TURN servers for relay

3. **Client Environment**
   - Corporate networks may block UDP
   - VPNs can interfere with WebRTC
   - Some ISPs restrict UDP traffic

## Future Enhancements

Potential improvements for this feature:

1. Metrics collection for TCP relay frequency
2. Automatic quality adjustment when TCP relay is detected
3. User notifications when stream quality is degraded
4. Integration with monitoring systems (e.g., Prometheus, DataDog)
5. Automatic fallback to lower bitrates when using TCP relay

## References

- WebRTC RFC: https://www.w3.org/TR/webrtc/
- ICE (Interactive Connectivity Establishment): RFC 8445
- TURN (Traversal Using Relays around NAT): RFC 8656

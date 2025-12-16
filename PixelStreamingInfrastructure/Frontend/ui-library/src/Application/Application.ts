/**
 * Application - Main application class for Pixel Streaming
 */

// Logger utility for application logging
export class Logger {
    static Warning(stackTrace: string, message: string): void {
        console.warn(`[WARNING] ${message}`);
        if (stackTrace) {
            console.warn(`Stack trace: ${stackTrace}`);
        }
    }

    static GetStackTrace(): string {
        const error = new Error();
        return error.stack || '';
    }

    static Info(message: string): void {
        console.info(`[INFO] ${message}`);
    }

    static Error(stackTrace: string, message: string): void {
        console.error(`[ERROR] ${message}`);
        if (stackTrace) {
            console.error(`Stack trace: ${stackTrace}`);
        }
    }
}

// Stream event interface
interface StreamEvent {
    data?: any;
    [key: string]: any;
}

// Stream class with event listening capabilities
class Stream {
    private eventListeners: Map<string, Array<(event: StreamEvent) => void>> = new Map();

    addEventListener(eventType: string, callback: (event: StreamEvent) => void): void {
        if (!this.eventListeners.has(eventType)) {
            this.eventListeners.set(eventType, []);
        }
        this.eventListeners.get(eventType)?.push(callback);
    }

    removeEventListener(eventType: string, callback: (event: StreamEvent) => void): void {
        const listeners = this.eventListeners.get(eventType);
        if (listeners) {
            const index = listeners.indexOf(callback);
            if (index > -1) {
                listeners.splice(index, 1);
            }
        }
    }

    dispatchEvent(eventType: string, event: StreamEvent): void {
        const listeners = this.eventListeners.get(eventType);
        if (listeners) {
            listeners.forEach(callback => callback(event));
        }
    }
}

export class Application {
    private stream: Stream;

    constructor() {
        this.stream = new Stream();
        this.setupEventListeners();
    }

    /**
     * Setup event listeners for the stream
     */
    private setupEventListeners(): void {
        // Add player count listener
        this.stream.addEventListener(
            'playerCount',
            ({ data: { count }}) =>
                this.onPlayerCount(count)
        );
        
        // Add TCP relay detected listener
        this.stream.addEventListener(
            'webRtcTCPRelayDetected' as any,
            (event: any) => {
                Logger.Warning(
                    Logger.GetStackTrace(),
                    `Stream quality degraded due to network environment, stream is relayed over TCP.`
                );
            }
        );
    }

    /**
     * Handle player count updates
     */
    private onPlayerCount(count: number): void {
        Logger.Info(`Player count updated: ${count}`);
    }

    /**
     * Get the stream instance
     */
    public getStream(): Stream {
        return this.stream;
    }

    /**
     * Trigger a player count event (for testing)
     */
    public triggerPlayerCountEvent(count: number): void {
        this.stream.dispatchEvent('playerCount', { data: { count } });
    }

    /**
     * Trigger a TCP relay detected event (for testing)
     */
    public triggerTCPRelayEvent(): void {
        this.stream.dispatchEvent('webRtcTCPRelayDetected', {});
    }
}

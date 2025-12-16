import React, { useEffect, useState } from 'react';
import { StatsPanel, AggregatedStats, VideoStats, AudioStats, CandidatePair, Application } from '@epicgames-ps/lib-pixelstreamingfrontend-ui';

const App: React.FC = () => {
  const [statsPanel] = useState(() => new StatsPanel());
  const [application] = useState(() => new Application());
  const [stats, setStats] = useState<AggregatedStats | null>(null);

  useEffect(() => {
    // Initialize stats with proper types
    const initialStats: AggregatedStats = {
      inboundVideoStats: {
        bytesReceived: 0,
        framesDecoded: 0,
        frameWidth: 1920,
        frameHeight: 1080
      } as VideoStats,
      inboundAudioStats: {
        bytesReceived: 0,
        packetsReceived: 0,
        packetsLost: 0
      } as AudioStats,
      candidatePair: {
        id: 'default',
        state: 'connected'
      } as CandidatePair
    };
    statsPanel.updateStats(initialStats);
    setStats(statsPanel.getStats());
  }, [statsPanel]);

  const handleGetActivePair = () => {
    const activePair = statsPanel.getActiveCandidatePair();
    console.log('Active Candidate Pair:', activePair);
    alert('Check console for active candidate pair');
  };

  const handleSimulateTCPRelay = () => {
    console.log('Simulating TCP relay detection...');
    application.triggerTCPRelayEvent();
    alert('TCP relay event triggered - check console for warning message');
  };

  const handleSimulatePlayerCount = () => {
    const randomCount = Math.floor(Math.random() * 10) + 1;
    console.log(`Simulating player count: ${randomCount}`);
    application.triggerPlayerCountEvent(randomCount);
    alert(`Player count event triggered with count: ${randomCount} - check console`);
  };

  return (
    <div style={{ padding: '20px', fontFamily: 'Arial, sans-serif' }}>
      <h1>Nexus Stream - Pixel Streaming React Frontend</h1>
      <div style={{ marginTop: '20px' }}>
        <h2>Stats Panel</h2>
        <button 
          onClick={handleGetActivePair}
          style={{
            padding: '10px 20px',
            fontSize: '16px',
            cursor: 'pointer',
            backgroundColor: '#007bff',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            marginRight: '10px'
          }}
        >
          Get Active Candidate Pair
        </button>
      </div>
      <div style={{ marginTop: '20px' }}>
        <h2>Application Events (TCP Relay Detection)</h2>
        <button 
          onClick={handleSimulateTCPRelay}
          style={{
            padding: '10px 20px',
            fontSize: '16px',
            cursor: 'pointer',
            backgroundColor: '#dc3545',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            marginRight: '10px'
          }}
        >
          Simulate TCP Relay Detection
        </button>
        <button 
          onClick={handleSimulatePlayerCount}
          style={{
            padding: '10px 20px',
            fontSize: '16px',
            cursor: 'pointer',
            backgroundColor: '#28a745',
            color: 'white',
            border: 'none',
            borderRadius: '4px'
          }}
        >
          Simulate Player Count Event
        </button>
      </div>
      <div style={{ marginTop: '20px' }}>
        <h3>Current Stats:</h3>
        <pre style={{ 
          backgroundColor: '#f4f4f4', 
          padding: '10px', 
          borderRadius: '4px',
          overflow: 'auto'
        }}>
          {JSON.stringify(stats, null, 2)}
        </pre>
      </div>
    </div>
  );
};

export default App;

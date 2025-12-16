import React, { useEffect, useState } from 'react';
import { StatsPanel, AggregatedStats, VideoStats, AudioStats, CandidatePair } from '@epicgames-ps/lib-pixelstreamingfrontend-ui';

const App: React.FC = () => {
  const [statsPanel] = useState(() => new StatsPanel());
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
            borderRadius: '4px'
          }}
        >
          Get Active Candidate Pair
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

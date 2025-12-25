/**
 * N.E.X.U.S AI Control Panel - World Map Component
 * 
 * Displays casino world map with active status indicators
 * 
 * @module control-panel/ui/WorldMap
 */

import React, { useEffect, useState } from 'react';

interface Casino {
  casinoId: string;
  name: string;
  status: 'online' | 'offline' | 'maintenance';
  playersOnline: number;
}

interface Federation {
  federationId: string;
  name: string;
  status: 'active' | 'inactive';
  totalPlayers: number;
  sharedPots: number;
}

const WorldMap: React.FC = () => {
  const [casinos, setCasinos] = useState<Casino[]>([]);
  const [federations, setFederations] = useState<Federation[]>([]);

  useEffect(() => {
    fetchData();
    const interval = setInterval(fetchData, 5000);
    return () => clearInterval(interval);
  }, []);

  const fetchData = async () => {
    try {
      const [casinosRes, federationsRes] = await Promise.all([
        fetch('/api/state/casinos'),
        fetch('/api/state/federations')
      ]);
      
      const casinosData = await casinosRes.json();
      const federationsData = await federationsRes.json();
      
      setCasinos(casinosData);
      setFederations(federationsData);
    } catch (error) {
      console.error('Failed to fetch world map data:', error);
    }
  };

  const handleCasinoClick = (casinoId: string) => {
    console.log(`Navigate to casino: ${casinoId}`);
    // In production, navigate to casino detail view
  };

  return (
    <div style={styles.container}>
      <div style={styles.section}>
        <h3 style={styles.sectionTitle}>WORLD MAP</h3>
        <div style={styles.casinoGrid}>
          {casinos.slice(0, 9).map((casino) => (
            <div
              key={casino.casinoId}
              style={styles.casinoCard}
              onClick={() => handleCasinoClick(casino.casinoId)}
            >
              <span style={{ color: getStatusColor(casino.status) }}>
                {getStatusIcon(casino.status)}
              </span>
              <span style={styles.casinoName}>{casino.name}</span>
            </div>
          ))}
          {/* Fill remaining slots */}
          {Array.from({ length: Math.max(0, 9 - casinos.length) }).map((_, i) => (
            <div key={`empty-${i}`} style={styles.emptySlot}>
              <span style={{ color: '#333' }}>○</span>
              <span style={{ color: '#555' }}>Empty Slot</span>
            </div>
          ))}
        </div>
        <p style={styles.subtitle}>Click = Enter Casino</p>
      </div>

      <div style={styles.section}>
        <h3 style={styles.sectionTitle}>ACTIVE CASINOS</h3>
        <div style={styles.casinoList}>
          {casinos.map((casino) => (
            <div key={casino.casinoId} style={styles.casinoListItem}>
              <span style={{ color: getStatusColor(casino.status) }}>
                {getStatusIcon(casino.status)}
              </span>
              <span style={styles.casinoListName}>{casino.name}</span>
              <span style={styles.playerCount}>
                {casino.playersOnline.toLocaleString()} players
              </span>
            </div>
          ))}
        </div>
        <p style={styles.subtitle}>Click = Control</p>
      </div>

      <div style={styles.section}>
        <h3 style={styles.sectionTitle}>FEDERATIONS</h3>
        <div style={styles.federationList}>
          {federations.map((fed) => (
            <div key={fed.federationId} style={styles.federationItem}>
              <span style={{ color: fed.status === 'active' ? '#00ff00' : '#555' }}>
                {fed.status === 'active' ? '●' : '○'}
              </span>
              <span style={styles.federationName}>{fed.federationId}</span>
              <span style={styles.federationDetail}>
                {fed.sharedPots} shared pots
              </span>
            </div>
          ))}
        </div>
        <p style={styles.subtitle}>Shared Pots</p>
      </div>
    </div>
  );
};

const getStatusIcon = (status: string): string => {
  switch (status) {
    case 'online': return '●';
    case 'offline': return '○';
    case 'maintenance': return '◐';
    default: return '○';
  }
};

const getStatusColor = (status: string): string => {
  switch (status) {
    case 'online': return '#00ff00';
    case 'offline': return '#555';
    case 'maintenance': return '#ffaa00';
    default: return '#555';
  }
};

const styles: Record<string, React.CSSProperties> = {
  container: {
    display: 'grid',
    gridTemplateColumns: '1fr 1fr 1fr',
    gap: '20px',
    border: '1px solid #00ff00',
    padding: '20px',
    backgroundColor: '#111'
  },
  section: {
    display: 'flex',
    flexDirection: 'column',
    gap: '10px'
  },
  sectionTitle: {
    margin: 0,
    fontSize: '14px',
    borderBottom: '1px solid #00ff00',
    paddingBottom: '5px'
  },
  casinoGrid: {
    display: 'grid',
    gridTemplateColumns: 'repeat(3, 1fr)',
    gap: '10px'
  },
  casinoCard: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    padding: '10px',
    border: '1px solid #333',
    cursor: 'pointer',
    transition: 'all 0.2s'
  },
  emptySlot: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    padding: '10px',
    border: '1px dashed #333'
  },
  casinoName: {
    fontSize: '10px',
    marginTop: '5px',
    textAlign: 'center'
  },
  casinoList: {
    display: 'flex',
    flexDirection: 'column',
    gap: '8px'
  },
  casinoListItem: {
    display: 'flex',
    alignItems: 'center',
    gap: '10px',
    padding: '8px',
    border: '1px solid #333',
    cursor: 'pointer'
  },
  casinoListName: {
    flex: 1,
    fontSize: '12px'
  },
  playerCount: {
    fontSize: '10px',
    color: '#888'
  },
  federationList: {
    display: 'flex',
    flexDirection: 'column',
    gap: '8px'
  },
  federationItem: {
    display: 'flex',
    alignItems: 'center',
    gap: '10px',
    padding: '8px',
    border: '1px solid #333'
  },
  federationName: {
    flex: 1,
    fontSize: '12px'
  },
  federationDetail: {
    fontSize: '10px',
    color: '#888'
  },
  subtitle: {
    margin: 0,
    marginTop: '10px',
    fontSize: '10px',
    color: '#888',
    fontStyle: 'italic'
  }
};

export default WorldMap;

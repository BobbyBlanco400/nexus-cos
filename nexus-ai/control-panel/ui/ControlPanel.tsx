/**
 * N.E.X.U.S AI Control Panel - Main UI Component
 * 
 * @module control-panel/ui/ControlPanel
 */

import React, { useEffect, useState } from 'react';
import WorldMap from './WorldMap';
import ComplianceStatus from './ComplianceStatus';
import NexCoinLedger from './NexCoinLedger';
import KillSwitch from './KillSwitch';

interface SystemState {
  handshakeValid: boolean;
  handshakeVersion: string;
  riskLevel: 'LOW' | 'MEDIUM' | 'HIGH';
}

const ControlPanel: React.FC = () => {
  const [systemState, setSystemState] = useState<SystemState | null>(null);
  const [isLive, setIsLive] = useState(true);

  useEffect(() => {
    // Fetch initial system state
    fetchSystemState();

    // Poll for updates every 5 seconds
    const interval = setInterval(fetchSystemState, 5000);

    return () => clearInterval(interval);
  }, []);

  const fetchSystemState = async () => {
    try {
      const response = await fetch('/api/state/system');
      const data = await response.json();
      setSystemState(data);
      setIsLive(true);
    } catch (error) {
      console.error('Failed to fetch system state:', error);
      setIsLive(false);
    }
  };

  if (!systemState) {
    return (
      <div style={styles.loading}>
        <div style={styles.spinner}>⟳</div>
        <p>Initializing N.E.X.U.S AI Control Panel...</p>
      </div>
    );
  }

  return (
    <div style={styles.container}>
      {/* Header */}
      <header style={styles.header}>
        <div style={styles.headerContent}>
          <h1 style={styles.title}>N.E.X.U.S AI CONTROL PANEL</h1>
          <div style={styles.statusBar}>
            <span style={styles.statusItem}>
              Status: <span style={{ color: isLive ? '#00ff00' : '#ff0000' }}>
                ● {isLive ? 'LIVE' : 'OFFLINE'}
              </span>
            </span>
            <span style={styles.statusItem}>
              Handshake: {systemState.handshakeVersion} ✔
            </span>
            <span style={styles.statusItem}>
              Risk: <span style={{ color: getRiskColor(systemState.riskLevel) }}>
                {systemState.riskLevel}
              </span>
            </span>
          </div>
        </div>
      </header>

      {/* Main Grid Layout */}
      <div style={styles.mainGrid}>
        {/* Top Row - World Map, Casinos, Federations */}
        <div style={styles.topRow}>
          <WorldMap />
        </div>

        {/* Middle Row - Compliance Status */}
        <div style={styles.middleRow}>
          <ComplianceStatus systemState={systemState} />
        </div>

        {/* Bottom Row - Treasury and Metrics */}
        <div style={styles.bottomRow}>
          <NexCoinLedger />
        </div>

        {/* Emergency Controls */}
        <div style={styles.emergencyRow}>
          <KillSwitch />
        </div>
      </div>
    </div>
  );
};

const getRiskColor = (level: string): string => {
  switch (level) {
    case 'LOW': return '#00ff00';
    case 'MEDIUM': return '#ffaa00';
    case 'HIGH': return '#ff0000';
    default: return '#ffffff';
  }
};

const styles: Record<string, React.CSSProperties> = {
  container: {
    backgroundColor: '#0a0a0a',
    color: '#00ff00',
    minHeight: '100vh',
    fontFamily: 'monospace',
    padding: '20px'
  },
  loading: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    height: '100vh',
    backgroundColor: '#0a0a0a',
    color: '#00ff00',
    fontFamily: 'monospace'
  },
  spinner: {
    fontSize: '48px',
    animation: 'spin 2s linear infinite'
  },
  header: {
    borderBottom: '2px solid #00ff00',
    paddingBottom: '15px',
    marginBottom: '20px'
  },
  headerContent: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center'
  },
  title: {
    margin: 0,
    fontSize: '24px',
    letterSpacing: '2px'
  },
  statusBar: {
    display: 'flex',
    gap: '30px'
  },
  statusItem: {
    fontSize: '14px'
  },
  mainGrid: {
    display: 'flex',
    flexDirection: 'column',
    gap: '20px'
  },
  topRow: {
    display: 'grid',
    gridTemplateColumns: '1fr',
    gap: '20px'
  },
  middleRow: {
    display: 'grid',
    gridTemplateColumns: '1fr',
    gap: '20px'
  },
  bottomRow: {
    display: 'grid',
    gridTemplateColumns: '1fr',
    gap: '20px'
  },
  emergencyRow: {
    marginTop: '20px'
  }
};

export default ControlPanel;

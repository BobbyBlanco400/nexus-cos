/**
 * N.E.X.U.S AI Control Panel - NexCoin Ledger Component
 * 
 * Displays NexCoin treasury and live metrics
 * 
 * @module control-panel/ui/NexCoinLedger
 */

import React, { useEffect, useState } from 'react';

interface Treasury {
  totalSupply: number;
  inCirculation: number;
  locked: number;
}

interface Metrics {
  totalPlayers: number;
  totalBetsPerMinute: number;
  activeJackpotPools: number;
}

const NexCoinLedger: React.FC = () => {
  const [treasury, setTreasury] = useState<Treasury | null>(null);
  const [metrics, setMetrics] = useState<Metrics | null>(null);

  useEffect(() => {
    fetchData();
    const interval = setInterval(fetchData, 5000);
    return () => clearInterval(interval);
  }, []);

  const fetchData = async () => {
    try {
      const [treasuryRes, metricsRes] = await Promise.all([
        fetch('/api/state/treasury'),
        fetch('/api/state/metrics')
      ]);
      
      const treasuryData = await treasuryRes.json();
      const metricsData = await metricsRes.json();
      
      setTreasury(treasuryData);
      setMetrics(metricsData);
    } catch (error) {
      console.error('Failed to fetch ledger data:', error);
    }
  };

  if (!treasury || !metrics) {
    return <div style={styles.loading}>Loading...</div>;
  }

  const circulationPercent = (treasury.inCirculation / treasury.totalSupply) * 100;
  const lockedPercent = (treasury.locked / treasury.totalSupply) * 100;

  return (
    <div style={styles.container}>
      <div style={styles.section}>
        <h3 style={styles.title}>NEXCOIN TREASURY</h3>
        <div style={styles.treasuryStats}>
          <div style={styles.statRow}>
            <span style={styles.statLabel}>Total Supply:</span>
            <div style={styles.progressBar}>
              <div style={{ ...styles.progressFill, width: '100%' }}></div>
            </div>
            <span style={styles.statValue}>
              {treasury.totalSupply.toLocaleString()}
            </span>
          </div>
          <div style={styles.statRow}>
            <span style={styles.statLabel}>In Circulation:</span>
            <div style={styles.progressBar}>
              <div style={{ ...styles.progressFill, width: `${circulationPercent}%` }}></div>
            </div>
            <span style={styles.statValue}>
              {treasury.inCirculation.toLocaleString()}
            </span>
          </div>
          <div style={styles.statRow}>
            <span style={styles.statLabel}>Locked:</span>
            <div style={styles.progressBar}>
              <div style={{ 
                ...styles.progressFill, 
                width: `${lockedPercent}%`,
                backgroundColor: '#ff8800'
              }}></div>
            </div>
            <span style={styles.statValue}>
              {treasury.locked.toLocaleString()}
            </span>
          </div>
        </div>
      </div>

      <div style={styles.section}>
        <h3 style={styles.title}>LIVE METRICS</h3>
        <div style={styles.metricsGrid}>
          <div style={styles.metricCard}>
            <span style={styles.metricLabel}>Players Online:</span>
            <span style={styles.metricValue}>
              {metrics.totalPlayers.toLocaleString()}
            </span>
          </div>
          <div style={styles.metricCard}>
            <span style={styles.metricLabel}>Bets / Min:</span>
            <span style={styles.metricValue}>
              {metrics.totalBetsPerMinute.toLocaleString()}
            </span>
          </div>
          <div style={styles.metricCard}>
            <span style={styles.metricLabel}>Jackpot Pools:</span>
            <span style={styles.metricValue}>
              {metrics.activeJackpotPools}
            </span>
          </div>
        </div>
      </div>
    </div>
  );
};

const styles: Record<string, React.CSSProperties> = {
  container: {
    display: 'grid',
    gridTemplateColumns: '1fr 1fr',
    gap: '20px',
    border: '1px solid #00ff00',
    padding: '20px',
    backgroundColor: '#111'
  },
  loading: {
    padding: '20px',
    textAlign: 'center',
    color: '#888'
  },
  section: {
    display: 'flex',
    flexDirection: 'column',
    gap: '15px'
  },
  title: {
    margin: 0,
    fontSize: '14px',
    borderBottom: '1px solid #00ff00',
    paddingBottom: '5px'
  },
  treasuryStats: {
    display: 'flex',
    flexDirection: 'column',
    gap: '15px'
  },
  statRow: {
    display: 'flex',
    flexDirection: 'column',
    gap: '5px'
  },
  statLabel: {
    fontSize: '12px',
    color: '#888'
  },
  progressBar: {
    width: '100%',
    height: '20px',
    backgroundColor: '#222',
    border: '1px solid #333',
    position: 'relative',
    overflow: 'hidden'
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#00ff00',
    transition: 'width 0.3s ease'
  },
  statValue: {
    fontSize: '12px',
    color: '#00ff00',
    marginTop: '2px'
  },
  metricsGrid: {
    display: 'grid',
    gridTemplateColumns: '1fr',
    gap: '10px'
  },
  metricCard: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: '15px',
    border: '1px solid #333',
    backgroundColor: '#0a0a0a'
  },
  metricLabel: {
    fontSize: '12px',
    color: '#888'
  },
  metricValue: {
    fontSize: '18px',
    color: '#00ff00',
    fontWeight: 'bold'
  }
};

export default NexCoinLedger;

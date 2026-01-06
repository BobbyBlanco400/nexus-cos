/**
 * Nexus OACP - Admin Control Panel App
 * Centralized management for all Nexus COS platforms and modules
 */

import React, { useState, useEffect } from 'react';

interface Platform {
  id: string;
  name: string;
  status: 'active' | 'inactive' | 'maintenance';
  url: string;
  module: string;
}

const App: React.FC = () => {
  const [platforms] = useState<Platform[]>([
    { id: '1', name: 'Beta Environment', status: 'active', url: 'https://beta.n3xuscos.online', module: 'Beta' },
    { id: '2', name: 'CIM-B Module', status: 'active', url: '/cim-b', module: 'CIM-B' },
    { id: '3', name: 'PWA Service', status: 'active', url: '/pwa', module: 'PWA' },
    { id: '4', name: 'NexusVision', status: 'active', url: '/nexusvision', module: 'NexusVision' },
    { id: '5', name: 'HoloCore', status: 'active', url: '/holocore', module: 'HoloCore' },
    { id: '6', name: 'PUABO Nexus Fleet', status: 'active', url: '/puabo-nexus', module: 'PUABO' },
    { id: '7', name: 'PUABO DSP', status: 'active', url: '/puabo-dsp', module: 'PUABO' },
    { id: '8', name: 'PUABO BLAC', status: 'active', url: '/puabo-blac', module: 'PUABO' },
    { id: '9', name: 'PUABO NUKI', status: 'active', url: '/puabo-nuki', module: 'PUABO' },
    { id: '10', name: 'V-Suite', status: 'active', url: '/v-suite', module: 'V-Suite' },
    { id: '11', name: 'StreamCore', status: 'active', url: '/streamcore', module: 'Core' },
    { id: '12', name: 'GameCore', status: 'active', url: '/gamecore', module: 'Core' },
    { id: '13', name: 'MusicChain', status: 'active', url: '/musicchain', module: 'Blockchain' },
    { id: '14', name: 'Nexus Studio AI', status: 'active', url: '/studio-ai', module: 'AI' },
    { id: '15', name: 'Casino-Nexus', status: 'active', url: '/casino-nexus', module: 'Gaming' },
    { id: '16', name: 'Club Saditty', status: 'active', url: '/club-saditty', module: 'Premium' },
    { id: '17', name: 'PUABOverse', status: 'active', url: '/puaboverse', module: 'Social' },
    { id: '18', name: 'Creator Hub', status: 'active', url: '/creator-hub', module: 'Creator' },
    { id: '19', name: 'PUABO OTT TV', status: 'active', url: '/ott-tv', module: 'Streaming' },
  ]);

  const [stats, setStats] = useState({
    totalPlatforms: 19,
    activePlatforms: 19,
    totalModules: 17,
    uptime: '99.9%'
  });

  return (
    <div style={styles.container}>
      <header style={styles.header}>
        <h1 style={styles.title}>🎛️ Nexus OACP</h1>
        <p style={styles.subtitle}>Owner/Admin Control Panel</p>
      </header>

      <div style={styles.statsBar}>
        <div style={styles.statCard}>
          <div style={styles.statLabel}>Total Platforms</div>
          <div style={styles.statValue}>{stats.totalPlatforms}</div>
        </div>
        <div style={styles.statCard}>
          <div style={styles.statLabel}>Active</div>
          <div style={styles.statValue}>{stats.activePlatforms}</div>
        </div>
        <div style={styles.statCard}>
          <div style={styles.statLabel}>Modules</div>
          <div style={styles.statValue}>{stats.totalModules}</div>
        </div>
        <div style={styles.statCard}>
          <div style={styles.statLabel}>Uptime</div>
          <div style={styles.statValue}>{stats.uptime}</div>
        </div>
      </div>

      <main style={styles.main}>
        <h2 style={styles.sectionTitle}>Platform Management</h2>
        <div style={styles.platformGrid}>
          {platforms.map((platform) => (
            <div key={platform.id} style={styles.platformCard}>
              <div style={styles.platformHeader}>
                <h3 style={styles.platformName}>{platform.name}</h3>
                <span style={{
                  ...styles.statusBadge,
                  backgroundColor: platform.status === 'active' ? '#10b981' : '#ef4444'
                }}>
                  {platform.status}
                </span>
              </div>
              <div style={styles.platformModule}>Module: {platform.module}</div>
              <div style={styles.platformUrl}>{platform.url}</div>
              <div style={styles.platformActions}>
                <button style={styles.actionButton}>Monitor</button>
                <button style={styles.actionButton}>Configure</button>
                <button style={styles.actionButton}>Logs</button>
              </div>
            </div>
          ))}
        </div>
      </main>
    </div>
  );
};

const styles: { [key: string]: React.CSSProperties } = {
  container: {
    minHeight: '100vh',
    background: 'linear-gradient(135deg, #0c0a1f 0%, #1e1b3c 100%)',
    color: '#ffffff',
    fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
  },
  header: {
    padding: '2rem',
    background: 'rgba(37, 99, 235, 0.1)',
    borderBottom: '2px solid #2563eb',
    textAlign: 'center',
  },
  title: {
    fontSize: '2.5rem',
    margin: '0 0 0.5rem 0',
    color: '#60a5fa',
  },
  subtitle: {
    fontSize: '1.1rem',
    margin: 0,
    color: '#94a3b8',
  },
  statsBar: {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))',
    gap: '1rem',
    padding: '2rem',
    background: 'rgba(0, 0, 0, 0.2)',
  },
  statCard: {
    background: 'rgba(37, 99, 235, 0.1)',
    padding: '1.5rem',
    borderRadius: '8px',
    textAlign: 'center',
    border: '1px solid rgba(59, 130, 246, 0.3)',
  },
  statLabel: {
    fontSize: '0.9rem',
    color: '#94a3b8',
    marginBottom: '0.5rem',
    textTransform: 'uppercase',
  },
  statValue: {
    fontSize: '2rem',
    fontWeight: 'bold',
    color: '#60a5fa',
  },
  main: {
    padding: '2rem',
    maxWidth: '1600px',
    margin: '0 auto',
  },
  sectionTitle: {
    fontSize: '1.8rem',
    margin: '0 0 1.5rem 0',
    color: '#60a5fa',
    borderBottom: '2px solid #2563eb',
    paddingBottom: '0.5rem',
  },
  platformGrid: {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))',
    gap: '1.5rem',
  },
  platformCard: {
    background: 'rgba(255, 255, 255, 0.05)',
    border: '1px solid rgba(59, 130, 246, 0.3)',
    borderRadius: '8px',
    padding: '1.5rem',
    transition: 'transform 0.2s, box-shadow 0.2s',
    cursor: 'pointer',
  },
  platformHeader: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: '1rem',
  },
  platformName: {
    margin: 0,
    fontSize: '1.2rem',
    color: '#93c5fd',
  },
  statusBadge: {
    padding: '0.25rem 0.75rem',
    borderRadius: '12px',
    fontSize: '0.75rem',
    fontWeight: 'bold',
    textTransform: 'uppercase',
  },
  platformModule: {
    fontSize: '0.9rem',
    color: '#94a3b8',
    marginBottom: '0.5rem',
  },
  platformUrl: {
    fontSize: '0.85rem',
    color: '#64748b',
    marginBottom: '1rem',
    fontFamily: 'monospace',
  },
  platformActions: {
    display: 'flex',
    gap: '0.5rem',
  },
  actionButton: {
    flex: 1,
    padding: '0.5rem',
    background: 'rgba(37, 99, 235, 0.3)',
    border: '1px solid rgba(59, 130, 246, 0.5)',
    borderRadius: '4px',
    color: '#60a5fa',
    cursor: 'pointer',
    fontSize: '0.85rem',
    transition: 'background 0.2s',
  },
};

export default App;

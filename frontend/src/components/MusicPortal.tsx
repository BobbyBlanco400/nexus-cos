import { useState } from 'react';

interface MusicPortalProps {
  className?: string;
}

export const MusicPortal = ({ className = '' }: MusicPortalProps) => {
  const [activeTab, setActiveTab] = useState<'library' | 'studio' | 'chain'>('library');

  return (
    <div className={`music-portal ${className}`} style={{
      padding: '2rem',
      backgroundColor: '#0f172a',
      borderRadius: '0.5rem',
      color: '#fff'
    }}>
      <header style={{ marginBottom: '2rem' }}>
        <h2 style={{ fontSize: '2rem', fontWeight: 'bold', marginBottom: '0.5rem' }}>
          🎵 PMMG Music Platform
        </h2>
        <p style={{ color: '#94a3b8' }}>
          Professional Music Production, Distribution, and Blockchain Rights Management
        </p>
      </header>

      <nav style={{ 
        display: 'flex', 
        gap: '1rem', 
        marginBottom: '2rem',
        borderBottom: '1px solid #334155',
        paddingBottom: '1rem'
      }}>
        <button
          onClick={() => setActiveTab('library')}
          style={{
            padding: '0.5rem 1rem',
            background: activeTab === 'library' ? '#8b5cf6' : 'transparent',
            border: 'none',
            borderRadius: '0.25rem',
            color: '#fff',
            cursor: 'pointer',
            fontSize: '0.875rem',
            fontWeight: '500'
          }}
        >
          Music Library
        </button>
        <button
          onClick={() => setActiveTab('studio')}
          style={{
            padding: '0.5rem 1rem',
            background: activeTab === 'studio' ? '#8b5cf6' : 'transparent',
            border: 'none',
            borderRadius: '0.25rem',
            color: '#fff',
            cursor: 'pointer',
            fontSize: '0.875rem',
            fontWeight: '500'
          }}
        >
          Studio Pro
        </button>
        <button
          onClick={() => setActiveTab('chain')}
          style={{
            padding: '0.5rem 1rem',
            background: activeTab === 'chain' ? '#8b5cf6' : 'transparent',
            border: 'none',
            borderRadius: '0.25rem',
            color: '#fff',
            cursor: 'pointer',
            fontSize: '0.875rem',
            fontWeight: '500'
          }}
        >
          MusicChain
        </button>
      </nav>

      <div className="portal-content">
        {activeTab === 'library' && (
          <div className="library-section">
            <h3 style={{ fontSize: '1.5rem', marginBottom: '1rem' }}>Music Library</h3>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: '1rem' }}>
              <div className="track-card" style={{ 
                padding: '1.5rem', 
                backgroundColor: '#1e293b',
                borderRadius: '0.5rem',
                border: '1px solid #334155'
              }}>
                <div style={{ marginBottom: '1rem', fontSize: '3rem' }}>🎸</div>
                <h4 style={{ marginBottom: '0.5rem' }}>Rock Collection</h4>
                <p style={{ color: '#94a3b8', fontSize: '0.875rem', marginBottom: '0.5rem' }}>
                  2,345 tracks
                </p>
                <div style={{ display: 'flex', gap: '0.5rem', marginTop: '1rem' }}>
                  <span style={{ 
                    padding: '0.25rem 0.5rem', 
                    backgroundColor: '#8b5cf6',
                    borderRadius: '0.25rem',
                    fontSize: '0.75rem'
                  }}>Licensed</span>
                  <span style={{ 
                    padding: '0.25rem 0.5rem', 
                    backgroundColor: '#10b981',
                    borderRadius: '0.25rem',
                    fontSize: '0.75rem'
                  }}>High Quality</span>
                </div>
              </div>
              <div className="track-card" style={{ 
                padding: '1.5rem', 
                backgroundColor: '#1e293b',
                borderRadius: '0.5rem',
                border: '1px solid #334155'
              }}>
                <div style={{ marginBottom: '1rem', fontSize: '3rem' }}>🎹</div>
                <h4 style={{ marginBottom: '0.5rem' }}>Electronic & EDM</h4>
                <p style={{ color: '#94a3b8', fontSize: '0.875rem', marginBottom: '0.5rem' }}>
                  1,876 tracks
                </p>
                <div style={{ display: 'flex', gap: '0.5rem', marginTop: '1rem' }}>
                  <span style={{ 
                    padding: '0.25rem 0.5rem', 
                    backgroundColor: '#8b5cf6',
                    borderRadius: '0.25rem',
                    fontSize: '0.75rem'
                  }}>Licensed</span>
                  <span style={{ 
                    padding: '0.25rem 0.5rem', 
                    backgroundColor: '#3b82f6',
                    borderRadius: '0.25rem',
                    fontSize: '0.75rem'
                  }}>Trending</span>
                </div>
              </div>
              <div className="track-card" style={{ 
                padding: '1.5rem', 
                backgroundColor: '#1e293b',
                borderRadius: '0.5rem',
                border: '1px solid #334155'
              }}>
                <div style={{ marginBottom: '1rem', fontSize: '3rem' }}>🎤</div>
                <h4 style={{ marginBottom: '0.5rem' }}>Hip Hop & Rap</h4>
                <p style={{ color: '#94a3b8', fontSize: '0.875rem', marginBottom: '0.5rem' }}>
                  3,201 tracks
                </p>
                <div style={{ display: 'flex', gap: '0.5rem', marginTop: '1rem' }}>
                  <span style={{ 
                    padding: '0.25rem 0.5rem', 
                    backgroundColor: '#8b5cf6',
                    borderRadius: '0.25rem',
                    fontSize: '0.75rem'
                  }}>Licensed</span>
                  <span style={{ 
                    padding: '0.25rem 0.5rem', 
                    backgroundColor: '#f59e0b',
                    borderRadius: '0.25rem',
                    fontSize: '0.75rem'
                  }}>Featured</span>
                </div>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'studio' && (
          <div className="studio-section">
            <h3 style={{ fontSize: '1.5rem', marginBottom: '1rem' }}>PUABO Studio Pro</h3>
            <div style={{ 
              padding: '2rem', 
              backgroundColor: '#1e293b',
              borderRadius: '0.5rem',
              border: '1px solid #334155'
            }}>
              <p style={{ marginBottom: '1rem', color: '#94a3b8' }}>
                Professional-grade music production tools with cloud collaboration.
              </p>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1.5rem', marginTop: '1.5rem' }}>
                <div>
                  <h4 style={{ marginBottom: '0.75rem', color: '#a78bfa' }}>🎚️ Mixer Engine</h4>
                  <ul style={{ listStyle: 'none', padding: 0, color: '#94a3b8', fontSize: '0.875rem' }}>
                    <li>• 64-track mixing</li>
                    <li>• Real-time collaboration</li>
                    <li>• Professional effects suite</li>
                    <li>• Automation lanes</li>
                  </ul>
                </div>
                <div>
                  <h4 style={{ marginBottom: '0.75rem', color: '#a78bfa' }}>🎼 Mastering Suite</h4>
                  <ul style={{ listStyle: 'none', padding: 0, color: '#94a3b8', fontSize: '0.875rem' }}>
                    <li>• AI-powered mastering</li>
                    <li>• Industry-standard quality</li>
                    <li>• Multi-format export</li>
                    <li>• Stem separation</li>
                  </ul>
                </div>
              </div>
              <button style={{
                marginTop: '2rem',
                padding: '0.75rem 1.5rem',
                backgroundColor: '#8b5cf6',
                border: 'none',
                borderRadius: '0.25rem',
                color: '#fff',
                cursor: 'pointer',
                fontSize: '1rem',
                fontWeight: '600'
              }}>
                Launch Studio
              </button>
            </div>
          </div>
        )}

        {activeTab === 'chain' && (
          <div className="chain-section">
            <h3 style={{ fontSize: '1.5rem', marginBottom: '1rem' }}>MusicChain™ Rights Management</h3>
            <div style={{ 
              padding: '2rem', 
              backgroundColor: '#1e293b',
              borderRadius: '0.5rem',
              border: '1px solid #334155'
            }}>
              <p style={{ marginBottom: '1rem', color: '#94a3b8' }}>
                Blockchain-based music rights management and royalty distribution.
              </p>
              <div style={{ 
                display: 'grid', 
                gridTemplateColumns: 'repeat(3, 1fr)', 
                gap: '1rem', 
                marginTop: '1.5rem' 
              }}>
                <div style={{ textAlign: 'center' }}>
                  <div style={{ fontSize: '2rem', marginBottom: '0.5rem' }}>🔐</div>
                  <h4 style={{ fontSize: '0.875rem', color: '#94a3b8', marginBottom: '0.25rem' }}>
                    Smart Contracts
                  </h4>
                  <p style={{ color: '#8b5cf6', fontWeight: 'bold' }}>Automated</p>
                </div>
                <div style={{ textAlign: 'center' }}>
                  <div style={{ fontSize: '2rem', marginBottom: '0.5rem' }}>💰</div>
                  <h4 style={{ fontSize: '0.875rem', color: '#94a3b8', marginBottom: '0.25rem' }}>
                    Instant Royalties
                  </h4>
                  <p style={{ color: '#10b981', fontWeight: 'bold' }}>Real-time</p>
                </div>
                <div style={{ textAlign: 'center' }}>
                  <div style={{ fontSize: '2rem', marginBottom: '0.5rem' }}>📊</div>
                  <h4 style={{ fontSize: '0.875rem', color: '#94a3b8', marginBottom: '0.25rem' }}>
                    Transparent Tracking
                  </h4>
                  <p style={{ color: '#3b82f6', fontWeight: 'bold' }}>Immutable</p>
                </div>
              </div>
              <div style={{ 
                marginTop: '2rem', 
                padding: '1rem', 
                backgroundColor: '#0f172a',
                borderRadius: '0.25rem',
                border: '1px solid #8b5cf6'
              }}>
                <p style={{ fontSize: '0.875rem', color: '#a78bfa' }}>
                  ✨ Protect your music with blockchain technology. Track every play, every sale, every distribution.
                </p>
              </div>
            </div>
          </div>
        )}
      </div>

      <footer style={{ 
        marginTop: '2rem', 
        paddingTop: '1rem', 
        borderTop: '1px solid #334155',
        fontSize: '0.75rem',
        color: '#64748b'
      }}>
        <p>🔒 55-45-17 Compliance Enforced | Rights Protected | DMCA Compliant</p>
      </footer>
    </div>
  );
};

export default MusicPortal;

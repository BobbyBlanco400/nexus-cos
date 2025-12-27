import { useState } from 'react';

interface CasinoPortalProps {
  className?: string;
}

export const CasinoPortal = ({ className = '' }: CasinoPortalProps) => {
  const [activeTab, setActiveTab] = useState<'games' | 'vr' | 'highroller'>('games');

  return (
    <div className={`casino-portal ${className}`} style={{
      padding: '2rem',
      backgroundColor: '#0f172a',
      borderRadius: '0.5rem',
      color: '#fff'
    }}>
      <header style={{ marginBottom: '2rem' }}>
        <h2 style={{ fontSize: '2rem', fontWeight: 'bold', marginBottom: '0.5rem' }}>
          🎰 Casino N3XUS
        </h2>
        <p style={{ color: '#94a3b8' }}>
          Premium gaming experience with VR Lounge and Progressive Jackpots
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
          onClick={() => setActiveTab('games')}
          style={{
            padding: '0.5rem 1rem',
            background: activeTab === 'games' ? '#2563eb' : 'transparent',
            border: 'none',
            borderRadius: '0.25rem',
            color: '#fff',
            cursor: 'pointer',
            fontSize: '0.875rem',
            fontWeight: '500'
          }}
        >
          Skill Games
        </button>
        <button
          onClick={() => setActiveTab('vr')}
          style={{
            padding: '0.5rem 1rem',
            background: activeTab === 'vr' ? '#2563eb' : 'transparent',
            border: 'none',
            borderRadius: '0.25rem',
            color: '#fff',
            cursor: 'pointer',
            fontSize: '0.875rem',
            fontWeight: '500'
          }}
        >
          VR Lounge
        </button>
        <button
          onClick={() => setActiveTab('highroller')}
          style={{
            padding: '0.5rem 1rem',
            background: activeTab === 'highroller' ? '#2563eb' : 'transparent',
            border: 'none',
            borderRadius: '0.25rem',
            color: '#fff',
            cursor: 'pointer',
            fontSize: '0.875rem',
            fontWeight: '500'
          }}
        >
          High Roller Suite
        </button>
      </nav>

      <div className="portal-content">
        {activeTab === 'games' && (
          <div className="games-section">
            <h3 style={{ fontSize: '1.5rem', marginBottom: '1rem' }}>Skill-Based Games</h3>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(250px, 1fr))', gap: '1rem' }}>
              <div className="game-card" style={{ 
                padding: '1.5rem', 
                backgroundColor: '#1e293b',
                borderRadius: '0.5rem',
                border: '1px solid #334155'
              }}>
                <h4 style={{ marginBottom: '0.5rem' }}>🎯 Progressive Poker</h4>
                <p style={{ color: '#94a3b8', fontSize: '0.875rem' }}>
                  Test your skills with our progressive jackpot system
                </p>
                <div style={{ marginTop: '1rem', color: '#10b981', fontWeight: 'bold' }}>
                  Jackpot: $125,430
                </div>
              </div>
              <div className="game-card" style={{ 
                padding: '1.5rem', 
                backgroundColor: '#1e293b',
                borderRadius: '0.5rem',
                border: '1px solid #334155'
              }}>
                <h4 style={{ marginBottom: '0.5rem' }}>🎲 Strategy Dice</h4>
                <p style={{ color: '#94a3b8', fontSize: '0.875rem' }}>
                  Compete with players worldwide
                </p>
                <div style={{ marginTop: '1rem', color: '#3b82f6' }}>
                  Live Players: 2,347
                </div>
              </div>
              <div className="game-card" style={{ 
                padding: '1.5rem', 
                backgroundColor: '#1e293b',
                borderRadius: '0.5rem',
                border: '1px solid #334155'
              }}>
                <h4 style={{ marginBottom: '0.5rem' }}>🃏 Dealer AI Challenge</h4>
                <p style={{ color: '#94a3b8', fontSize: '0.875rem' }}>
                  Face our advanced AI dealer system
                </p>
                <div style={{ marginTop: '1rem', color: '#f59e0b' }}>
                  Difficulty: Adaptive
                </div>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'vr' && (
          <div className="vr-section">
            <h3 style={{ fontSize: '1.5rem', marginBottom: '1rem' }}>VR Lounge Experience</h3>
            <div style={{ 
              padding: '2rem', 
              backgroundColor: '#1e293b',
              borderRadius: '0.5rem',
              border: '1px solid #334155'
            }}>
              <p style={{ marginBottom: '1rem', color: '#94a3b8' }}>
                Immerse yourself in our premium VR casino environment. Play with friends in virtual reality.
              </p>
              <ul style={{ listStyle: 'none', padding: 0 }}>
                <li style={{ marginBottom: '0.5rem' }}>✓ Realistic 3D casino environment</li>
                <li style={{ marginBottom: '0.5rem' }}>✓ Social interaction with other players</li>
                <li style={{ marginBottom: '0.5rem' }}>✓ Premium table reservations</li>
                <li style={{ marginBottom: '0.5rem' }}>✓ VR tournaments and events</li>
              </ul>
              <button style={{
                marginTop: '1.5rem',
                padding: '0.75rem 1.5rem',
                backgroundColor: '#2563eb',
                border: 'none',
                borderRadius: '0.25rem',
                color: '#fff',
                cursor: 'pointer',
                fontSize: '1rem',
                fontWeight: '600'
              }}>
                Launch VR Lounge
              </button>
            </div>
          </div>
        )}

        {activeTab === 'highroller' && (
          <div className="highroller-section">
            <h3 style={{ fontSize: '1.5rem', marginBottom: '1rem' }}>High Roller Suite</h3>
            <div style={{ 
              padding: '2rem', 
              backgroundColor: '#1e293b',
              borderRadius: '0.5rem',
              border: '2px solid #f59e0b'
            }}>
              <p style={{ marginBottom: '1rem', color: '#fbbf24', fontWeight: 'bold' }}>
                🏆 Exclusive Access for Premium Players
              </p>
              <p style={{ marginBottom: '1rem', color: '#94a3b8' }}>
                Join the elite with higher stakes, exclusive games, and VIP rewards.
              </p>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem', marginTop: '1.5rem' }}>
                <div>
                  <h4 style={{ fontSize: '0.875rem', color: '#94a3b8', marginBottom: '0.25rem' }}>Minimum Buy-in</h4>
                  <p style={{ fontSize: '1.5rem', fontWeight: 'bold', color: '#f59e0b' }}>$10,000</p>
                </div>
                <div>
                  <h4 style={{ fontSize: '0.875rem', color: '#94a3b8', marginBottom: '0.25rem' }}>VIP Benefits</h4>
                  <p style={{ fontSize: '1rem', color: '#10b981' }}>Priority Support, Custom Limits</p>
                </div>
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
        <p>🔒 55-45-17 Compliance Enforced | Responsible Gaming | 18+ Only</p>
      </footer>
    </div>
  );
};

export default CasinoPortal;

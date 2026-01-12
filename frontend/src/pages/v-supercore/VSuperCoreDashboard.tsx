import React, { useState, useEffect } from 'react';
import './VSuperCoreDashboard.css';

interface ResourceTier {
  id: string;
  name: string;
  cpu: string;
  memory: string;
  gpu: string | null;
  storage: string;
  pricePerHour: number;
  features: string[];
}

interface Session {
  id: string;
  tier: string;
  status: 'creating' | 'active' | 'paused' | 'terminated';
  resources: {
    cpu: string;
    memory: string;
    gpu?: string;
    storage: string;
  };
  createdAt: Date;
  lastAccessedAt: Date;
}

const VSuperCoreDashboard: React.FC = () => {
  const [tiers, setTiers] = useState<ResourceTier[]>([]);
  const [sessions, setSessions] = useState<Session[]>([]);
  const [selectedTier, setSelectedTier] = useState<string>('standard');
  const [isCreating, setIsCreating] = useState(false);
  const [activeSession, setActiveSession] = useState<Session | null>(null);

  useEffect(() => {
    fetchTiers();
    fetchSessions();
  }, []);

  const fetchTiers = async () => {
    try {
      const response = await fetch('/api/v1/supercore/resources/tiers', {
        headers: {
          'X-N3XUS-Handshake': '55-45-17',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      const data = await response.json();
      if (data.success) {
        setTiers(data.tiers);
      }
    } catch (error) {
      console.error('Failed to fetch tiers:', error);
    }
  };

  const fetchSessions = async () => {
    try {
      const response = await fetch('/api/v1/supercore/sessions/list', {
        headers: {
          'X-N3XUS-Handshake': '55-45-17',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      const data = await response.json();
      if (data.success) {
        setSessions(data.sessions);
      }
    } catch (error) {
      console.error('Failed to fetch sessions:', error);
    }
  };

  const createSession = async () => {
    setIsCreating(true);
    try {
      const response = await fetch('/api/v1/supercore/sessions/create', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-N3XUS-Handshake': '55-45-17',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: JSON.stringify({ tier: selectedTier })
      });
      const data = await response.json();
      if (data.success) {
        await fetchSessions();
        setActiveSession(data.session);
      }
    } catch (error) {
      console.error('Failed to create session:', error);
    } finally {
      setIsCreating(false);
    }
  };

  const connectToSession = async (sessionId: string) => {
    try {
      const response = await fetch(`/api/v1/supercore/stream/${sessionId}/connect`, {
        headers: {
          'X-N3XUS-Handshake': '55-45-17',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      const data = await response.json();
      if (data.success) {
        // Open streaming window
        window.open(`/v-supercore/stream/${sessionId}`, '_blank');
      }
    } catch (error) {
      console.error('Failed to connect to session:', error);
    }
  };

  return (
    <div className="v-supercore-dashboard">
      <header className="dashboard-header">
        <h1>
          <span className="nexus-logo">N3XUS</span> v-SuperCore
        </h1>
        <p className="tagline">The World's First Fully Virtualized Super PC</p>
      </header>

      <div className="dashboard-content">
        {/* Quick Launch Section */}
        <section className="quick-launch-section">
          <h2>Quick Launch</h2>
          <div className="tier-selector">
            {tiers.map((tier) => (
              <div
                key={tier.id}
                className={`tier-card ${selectedTier === tier.id ? 'selected' : ''}`}
                onClick={() => setSelectedTier(tier.id)}
              >
                <h3>{tier.name}</h3>
                <div className="tier-specs">
                  <div className="spec">
                    <span className="label">CPU:</span>
                    <span className="value">{tier.cpu}</span>
                  </div>
                  <div className="spec">
                    <span className="label">RAM:</span>
                    <span className="value">{tier.memory}</span>
                  </div>
                  {tier.gpu && (
                    <div className="spec">
                      <span className="label">GPU:</span>
                      <span className="value">{tier.gpu}</span>
                    </div>
                  )}
                  <div className="spec">
                    <span className="label">Storage:</span>
                    <span className="value">{tier.storage}</span>
                  </div>
                </div>
                <div className="tier-price">
                  {tier.pricePerHour} NexCoin/hour
                </div>
                <ul className="tier-features">
                  {tier.features.map((feature, index) => (
                    <li key={index}>{feature}</li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
          <button
            className="launch-button"
            onClick={createSession}
            disabled={isCreating}
          >
            {isCreating ? 'Creating Session...' : 'Launch Virtual PC'}
          </button>
        </section>

        {/* Active Sessions Section */}
        <section className="sessions-section">
          <h2>Your Sessions</h2>
          {sessions.length === 0 ? (
            <div className="empty-state">
              <p>No active sessions. Launch your first Virtual PC above!</p>
            </div>
          ) : (
            <div className="sessions-grid">
              {sessions.map((session) => (
                <div key={session.id} className="session-card">
                  <div className="session-header">
                    <span className={`status-badge status-${session.status}`}>
                      {session.status}
                    </span>
                    <span className="session-tier">{session.tier}</span>
                  </div>
                  <div className="session-resources">
                    <div className="resource-item">
                      <span className="resource-label">CPU:</span>
                      <span className="resource-value">{session.resources.cpu}</span>
                    </div>
                    <div className="resource-item">
                      <span className="resource-label">RAM:</span>
                      <span className="resource-value">{session.resources.memory}</span>
                    </div>
                    {session.resources.gpu && (
                      <div className="resource-item">
                        <span className="resource-label">GPU:</span>
                        <span className="resource-value">{session.resources.gpu}</span>
                      </div>
                    )}
                  </div>
                  <div className="session-actions">
                    <button
                      className="connect-button"
                      onClick={() => connectToSession(session.id)}
                      disabled={session.status !== 'active'}
                    >
                      Connect
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </section>

        {/* Info Section */}
        <section className="info-section">
          <div className="info-card">
            <h3>🌐 Universal Access</h3>
            <p>Access your Virtual PC from any device - web browser, mobile app, or AR/VR headset.</p>
          </div>
          <div className="info-card">
            <h3>⚡ Zero-Lag Streaming</h3>
            <p>Sub-50ms latency with adaptive quality streaming for seamless experience.</p>
          </div>
          <div className="info-card">
            <h3>🔒 Quantum-Grade Security</h3>
            <p>End-to-end encryption and complete session isolation for your privacy.</p>
          </div>
          <div className="info-card">
            <h3>📈 On-Demand Scaling</h3>
            <p>Upgrade or downgrade your resources instantly based on your needs.</p>
          </div>
        </section>
      </div>
    </div>
  );
};

export default VSuperCoreDashboard;

import { useState } from 'react';
import { Link } from 'react-router-dom';
import '../App.css';

interface Module {
  id: string;
  name: string;
  icon: string;
  apps: App[];
}

interface App {
  id: string;
  name: string;
  description: string;
  url: string;
}

const modules: Module[] = [
  {
    id: 'v-suite',
    name: 'V-Suite',
    icon: '🎬',
    apps: [
      { id: 'v-prompter', name: 'V-Prompter Pro', description: 'Professional teleprompter', url: '/v-suite/prompter' },
      { id: 'v-screen', name: 'V-Screen Hollywood', description: 'Screen sharing tool', url: '/v-suite/screen' },
      { id: 'v-caster', name: 'V-Caster', description: 'Broadcasting solution', url: '/v-suite/caster' },
      { id: 'v-stage', name: 'V-Stage', description: 'Virtual stage manager', url: '/v-suite/stage' },
    ]
  },
  {
    id: 'creator-hub',
    name: 'Creator Hub',
    icon: '🎨',
    apps: [
      { id: 'asset-manager', name: 'Asset Manager', description: 'Manage your media assets', url: '/creator-hub/assets' },
      { id: 'project-collab', name: 'Project Collaboration', description: 'Team collaboration tools', url: '/creator-hub/projects' },
      { id: 'distribution', name: 'Distribution', description: 'Content distribution', url: '/creator-hub/distribution' },
      { id: 'analytics', name: 'Analytics', description: 'Performance analytics', url: '/creator-hub/analytics' },
    ]
  },
  {
    id: 'puabo-fleet',
    name: 'PUABO Fleet',
    icon: '🚗',
    apps: [
      { id: 'ai-dispatch', name: 'AI Dispatch', description: 'AI-powered dispatch', url: '/puabo-nexus/dispatch' },
      { id: 'driver-backend', name: 'Driver Backend', description: 'Driver management', url: '/puabo-nexus/driver' },
      { id: 'fleet-manager', name: 'Fleet Manager', description: 'Fleet oversight', url: '/puabo-nexus/fleet' },
      { id: 'route-optimizer', name: 'Route Optimizer', description: 'Optimize routes', url: '/puabo-nexus/routes' },
    ]
  },
  {
    id: 'casino-nexus',
    name: 'Casino N3XUS',
    icon: '🎰',
    apps: [
      { id: 'slot-games', name: 'Slot Games', description: 'Play slot machines', url: '/casino' },
      { id: 'table-games', name: 'Table Games', description: 'Classic table games', url: '/casino/table' },
      { id: 'live-dealer', name: 'Live Dealer', description: 'Live dealer games', url: '/casino/live' },
      { id: 'sports-betting', name: 'Sports Betting', description: 'Sports wagering', url: '/casino/sports' },
    ]
  },
  {
    id: 'music-portal',
    name: 'PMMG Music',
    icon: '🎵',
    apps: [
      { id: 'library', name: 'Music Library', description: 'Browse music', url: '/music' },
      { id: 'playlists', name: 'Playlists', description: 'Your playlists', url: '/music/playlists' },
      { id: 'radio', name: 'Radio', description: 'Live radio streams', url: '/music/radio' },
      { id: 'podcasts', name: 'Podcasts', description: 'Podcast library', url: '/music/podcasts' },
    ]
  },
  {
    id: 'admin',
    name: 'Admin Panel',
    icon: '⚙️',
    apps: [
      { id: 'users', name: 'User Management', description: 'Manage users', url: '/admin/users' },
      { id: 'services', name: 'Service Control', description: 'Control services', url: '/admin/services' },
      { id: 'monitoring', name: 'Monitoring', description: 'System monitoring', url: '/admin/monitoring' },
      { id: 'logs', name: 'Logs', description: 'System logs', url: '/admin/logs' },
    ]
  }
];

export default function Desktop() {
  console.log('🖥️ N3XUS COS Virtual Desktop Activated | Handshake: 55-45-17');
  
  const [selectedModule, setSelectedModule] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<string>('modules');

  const handleModuleClick = (moduleId: string) => {
    setSelectedModule(moduleId);
    setActiveTab('apps');
  };

  const handleBack = () => {
    setSelectedModule(null);
    setActiveTab('modules');
  };

  const currentModule = modules.find(m => m.id === selectedModule);

  return (
    <div className="nexus-platform" style={{ minHeight: '100vh', background: '#0f172a' }}>
      <header className="nexus-header">
        <div className="header-content">
          <div className="logo-container">
            <svg width="40" height="40" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
              <circle cx="50" cy="50" r="45" stroke="#2563eb" strokeWidth="5"/>
              <path d="M35 50 L50 35 L65 50 L50 65 Z" fill="#2563eb"/>
              <circle cx="50" cy="50" r="8" fill="#fff"/>
            </svg>
            <h1>N3XUS COS</h1>
          </div>
          <p className="header-subtitle">The Creative Operating System</p>
          <nav className="main-nav">
            <Link to="/">Home</Link>
            <Link to="/dashboard">Dashboard</Link>
            <Link to="/founders">Founders</Link>
            <Link to="/desktop" style={{ background: '#2563eb' }}>Desktop</Link>
          </nav>
        </div>
      </header>

      <main style={{ padding: '2rem', maxWidth: '1400px', margin: '0 auto' }}>
        <div style={{ marginBottom: '2rem' }}>
          <h2 style={{ fontSize: '2rem', fontWeight: 'bold', color: '#fff', marginBottom: '0.5rem' }}>
            🖥️ Virtual Desktop
          </h2>
          <p style={{ color: '#94a3b8' }}>
            Desktop → Module → App flow | Active Tab: {activeTab}
          </p>
        </div>

        {/* Tab Navigation */}
        <div style={{ 
          display: 'flex', 
          gap: '1rem', 
          marginBottom: '2rem',
          borderBottom: '1px solid #334155',
          paddingBottom: '1rem'
        }}>
          <button
            onClick={() => setActiveTab('modules')}
            style={{
              padding: '0.5rem 1.5rem',
              background: activeTab === 'modules' ? '#2563eb' : 'transparent',
              border: '1px solid #334155',
              borderRadius: '0.5rem',
              color: '#fff',
              cursor: 'pointer'
            }}
          >
            Modules
          </button>
          {selectedModule && (
            <button
              onClick={() => setActiveTab('apps')}
              style={{
                padding: '0.5rem 1.5rem',
                background: activeTab === 'apps' ? '#2563eb' : 'transparent',
                border: '1px solid #334155',
                borderRadius: '0.5rem',
                color: '#fff',
                cursor: 'pointer'
              }}
            >
              Apps ({currentModule?.name})
            </button>
          )}
        </div>

        {/* Modules View */}
        {activeTab === 'modules' && (
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(250px, 1fr))',
            gap: '1.5rem'
          }}>
            {modules.map((module) => (
              <div
                key={module.id}
                onClick={() => handleModuleClick(module.id)}
                style={{
                  background: 'linear-gradient(135deg, #1e293b 0%, #0f172a 100%)',
                  border: '1px solid #334155',
                  borderRadius: '1rem',
                  padding: '2rem',
                  cursor: 'pointer',
                  transition: 'all 0.3s',
                  textAlign: 'center'
                }}
                onMouseEnter={(e) => {
                  e.currentTarget.style.transform = 'translateY(-4px)';
                  e.currentTarget.style.borderColor = '#2563eb';
                }}
                onMouseLeave={(e) => {
                  e.currentTarget.style.transform = 'translateY(0)';
                  e.currentTarget.style.borderColor = '#334155';
                }}
              >
                <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>
                  {module.icon}
                </div>
                <h3 style={{ fontSize: '1.25rem', fontWeight: 'bold', color: '#fff', marginBottom: '0.5rem' }}>
                  {module.name}
                </h3>
                <p style={{ color: '#64748b', fontSize: '0.875rem' }}>
                  {module.apps.length} apps available
                </p>
              </div>
            ))}
          </div>
        )}

        {/* Apps View */}
        {activeTab === 'apps' && currentModule && (
          <>
            <div style={{ marginBottom: '2rem' }}>
              <button
                onClick={handleBack}
                style={{
                  padding: '0.5rem 1rem',
                  background: 'transparent',
                  border: '1px solid #334155',
                  borderRadius: '0.5rem',
                  color: '#fff',
                  cursor: 'pointer',
                  marginBottom: '1rem'
                }}
              >
                ← Back to Modules
              </button>
              <h3 style={{ fontSize: '1.5rem', fontWeight: 'bold', color: '#fff' }}>
                {currentModule.icon} {currentModule.name} Apps
              </h3>
            </div>
            <div style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))',
              gap: '1.5rem'
            }}>
              {currentModule.apps.map((app) => (
                <div
                  key={app.id}
                  style={{
                    background: 'linear-gradient(135deg, #1e293b 0%, #0f172a 100%)',
                    border: '1px solid #334155',
                    borderRadius: '1rem',
                    padding: '1.5rem',
                  }}
                >
                  <h4 style={{ fontSize: '1.125rem', fontWeight: 'bold', color: '#fff', marginBottom: '0.5rem' }}>
                    {app.name}
                  </h4>
                  <p style={{ color: '#94a3b8', fontSize: '0.875rem', marginBottom: '1rem' }}>
                    {app.description}
                  </p>
                  <a
                    href={app.url}
                    style={{
                      display: 'inline-block',
                      padding: '0.5rem 1rem',
                      background: '#2563eb',
                      color: '#fff',
                      borderRadius: '0.5rem',
                      textDecoration: 'none',
                      fontSize: '0.875rem'
                    }}
                  >
                    Launch App →
                  </a>
                </div>
              ))}
            </div>
          </>
        )}

        <div style={{ 
          marginTop: '3rem', 
          padding: '1.5rem', 
          background: '#1e293b', 
          borderRadius: '1rem',
          border: '1px solid #334155'
        }}>
          <p style={{ color: '#64748b', textAlign: 'center' }}>
            🔒 N3XUS COS Virtual Desktop | Handshake: 55-45-17
          </p>
        </div>
      </main>
    </div>
  );
}

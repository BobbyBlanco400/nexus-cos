import { useState, useEffect } from 'react';
import TenantTable from './TenantTable';
import CreatorOnboardingForm from './CreatorOnboardingForm';
import './CpsDashboardPage.css';

// Import tenant registry
import tenantsData from '../../../runtime/tenants/tenants.json';

interface Tenant {
  id: number;
  name: string;
  slug: string;
  domain: string;
  category: string;
  status: string;
  deployed: string;
  icon?: string;
  description?: string;
}

export default function CpsDashboardPage() {
  const [tenants, setTenants] = useState<Tenant[]>([]);
  const [activeTab, setActiveTab] = useState<'overview' | 'tenants' | 'onboard'>('overview');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    console.log('🎛️ CPS Dashboard Initialized | Handshake: 55-45-17');
    
    // Load tenants from registry
    try {
      setTenants(tenantsData.tenants as Tenant[]);
      setLoading(false);
    } catch (error) {
      console.error('Failed to load tenant registry:', error);
      setLoading(false);
    }
  }, []);

  const stats = {
    totalTenants: tenants.length,
    liveTenants: tenants.filter(t => t.status === 'live').length,
    activeTenants: tenants.filter(t => t.status === 'active').length,
    streamingTenants: tenants.filter(t => t.status === 'streaming').length,
  };

  if (loading) {
    return (
      <div className="cps-loading">
        <div className="loader"></div>
        <p>Loading CPS Dashboard...</p>
      </div>
    );
  }

  return (
    <div className="cps-dashboard">
      {/* Header */}
      <header className="cps-header">
        <div className="cps-header-content">
          <div className="cps-title-section">
            <h1 className="cps-title">
              <span className="cps-icon">🎛️</span>
              CPS Dashboard
            </h1>
            <p className="cps-subtitle">Creative Platform Service — Control Center</p>
          </div>
          
          <div className="cps-version-badge">
            <span className="version-label">v2.5.0-RC1</span>
            <span className="handshake-badge">🔒 55-45-17</span>
          </div>
        </div>
      </header>

      {/* Navigation Tabs */}
      <nav className="cps-tabs">
        <button 
          className={`cps-tab ${activeTab === 'overview' ? 'active' : ''}`}
          onClick={() => setActiveTab('overview')}
        >
          📊 Overview
        </button>
        <button 
          className={`cps-tab ${activeTab === 'tenants' ? 'active' : ''}`}
          onClick={() => setActiveTab('tenants')}
        >
          🏢 Tenant Registry
        </button>
        <button 
          className={`cps-tab ${activeTab === 'onboard' ? 'active' : ''}`}
          onClick={() => setActiveTab('onboard')}
        >
          ✨ Creator Onboarding
        </button>
      </nav>

      {/* Main Content */}
      <main className="cps-main">
        {/* Overview Tab */}
        {activeTab === 'overview' && (
          <div className="cps-overview">
            <section className="cps-stats-grid">
              <div className="cps-stat-card">
                <div className="stat-icon">🏢</div>
                <div className="stat-content">
                  <div className="stat-value">{stats.totalTenants}</div>
                  <div className="stat-label">Total Platforms</div>
                </div>
              </div>

              <div className="cps-stat-card live">
                <div className="stat-icon">🔴</div>
                <div className="stat-content">
                  <div className="stat-value">{stats.liveTenants}</div>
                  <div className="stat-label">Live</div>
                </div>
              </div>

              <div className="cps-stat-card active">
                <div className="stat-icon">✅</div>
                <div className="stat-content">
                  <div className="stat-value">{stats.activeTenants}</div>
                  <div className="stat-label">Active</div>
                </div>
              </div>

              <div className="cps-stat-card streaming">
                <div className="stat-icon">📡</div>
                <div className="stat-content">
                  <div className="stat-value">{stats.streamingTenants}</div>
                  <div className="stat-label">Streaming</div>
                </div>
              </div>
            </section>

            <section className="cps-info-section">
              <h2>What is CPS?</h2>
              <p>
                The <strong>Creative Platform Service (CPS)</strong> is the deployment engine that powers N3XUS COS. 
                It enables one-command deployment of independent creator platforms.
              </p>
              
              <div className="cps-features">
                <div className="feature-item">
                  <span className="feature-icon">⚡</span>
                  <div>
                    <h3>One-Command Deployment</h3>
                    <p>Deploy entire creator platforms with a single command</p>
                  </div>
                </div>
                
                <div className="feature-item">
                  <span className="feature-icon">🔒</span>
                  <div>
                    <h3>Isolated Infrastructure</h3>
                    <p>Each creator gets their own sovereign stack</p>
                  </div>
                </div>
                
                <div className="feature-item">
                  <span className="feature-icon">✅</span>
                  <div>
                    <h3>Verified Deployments</h3>
                    <p>Every platform is verified with Handshake 55-45-17</p>
                  </div>
                </div>
              </div>
            </section>

            <section className="cps-quick-actions">
              <h2>Quick Actions</h2>
              <div className="action-buttons">
                <button onClick={() => setActiveTab('tenants')} className="action-button primary">
                  View All Tenants
                </button>
                <button onClick={() => setActiveTab('onboard')} className="action-button secondary">
                  Onboard New Creator
                </button>
              </div>
            </section>
          </div>
        )}

        {/* Tenants Tab */}
        {activeTab === 'tenants' && (
          <div className="cps-tenants">
            <div className="tenants-header">
              <h2>Tenant Registry</h2>
              <p>All {tenants.length} founding resident platforms</p>
            </div>
            <TenantTable tenants={tenants} />
          </div>
        )}

        {/* Onboarding Tab */}
        {activeTab === 'onboard' && (
          <div className="cps-onboarding">
            <div className="onboarding-header">
              <h2>Creator Onboarding</h2>
              <p>Deploy a new creator platform on N3XUS COS</p>
            </div>
            <CreatorOnboardingForm />
          </div>
        )}
      </main>

      {/* Footer */}
      <footer className="cps-footer">
        <p>N3XUS COS v2.5.0-RC1 | 🔒 Handshake: 55-45-17 | CPS Engine: ACTIVE</p>
      </footer>
    </div>
  );
}

import React from 'react'
import { Routes, Route, Link } from 'react-router-dom'
import './App.css'

function Projects() {
  const projects = [
    { id: 1, title: 'Nexus COS UI Redesign', status: 'In Progress', progress: 75 },
    { id: 2, title: 'V-Suite Documentation', status: 'Review', progress: 90 },
    { id: 3, title: 'PuaboVerse Assets', status: 'Draft', progress: 45 }
  ]

  return (
    <div>
      <h2>My Projects</h2>
      <div className="projects-grid">
        {projects.map(project => (
          <div key={project.id} className="project-card">
            <h3>{project.title}</h3>
            <div className="status">{project.status}</div>
            <div className="progress-bar">
              <div className="progress-fill" style={{ width: `${project.progress}%` }}></div>
            </div>
            <p>{project.progress}% complete</p>
          </div>
        ))}
      </div>
    </div>
  )
}

function Assets() {
  return (
    <div>
      <h2>Asset Library</h2>
      <div className="asset-grid">
        <div className="asset-card">
          <div className="asset-thumbnail">🎨</div>
          <h4>Design Templates</h4>
          <p>24 files</p>
        </div>
        <div className="asset-card">
          <div className="asset-thumbnail">📐</div>
          <h4>UI Components</h4>
          <p>18 files</p>
        </div>
        <div className="asset-card">
          <div className="asset-thumbnail">🎭</div>
          <h4>3D Models</h4>
          <p>12 files</p>
        </div>
      </div>
    </div>
  )
}

function Analytics() {
  return (
    <div>
      <h2>Analytics & Insights</h2>
      <div className="analytics-grid">
        <div className="metric-card">
          <h3>Total Views</h3>
          <p className="metric-value">12,345</p>
          <span className="metric-change">+15% this week</span>
        </div>
        <div className="metric-card">
          <h3>Engagement</h3>
          <p className="metric-value">89%</p>
          <span className="metric-change">+5% this week</span>
        </div>
        <div className="metric-card">
          <h3>Revenue</h3>
          <p className="metric-value">$2,456</p>
          <span className="metric-change">+23% this week</span>
        </div>
      </div>
    </div>
  )
}

function HoloSnap() {
  const [preOrderStatus, setPreOrderStatus] = React.useState<'soon' | 'live'>('soon');
  
  return (
    <div>
      <h2>🌟 HoloSnap — Wave 2 Pre-Orders</h2>
      <div className="holosnap-hero">
        <div className="holosnap-image">
          <div style={{ 
            fontSize: '120px', 
            textAlign: 'center', 
            padding: '40px',
            background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
            borderRadius: '16px',
            marginBottom: '24px'
          }}>
            🔮
          </div>
        </div>
        <div className="holosnap-description">
          <h3>Universal Clip-On Spatial Computing Module</h3>
          <p style={{ fontSize: '16px', lineHeight: '1.6', marginBottom: '16px' }}>
            Transform any VR/AR headset into a N3XUS-powered spatial computing device with HoloSnap v1.
          </p>
          <ul style={{ listStyle: 'none', padding: 0, marginBottom: '24px' }}>
            <li style={{ marginBottom: '8px' }}>✅ <strong>Universal Compatibility</strong> — Works with HoloLens, Quest, Vive, and more</li>
            <li style={{ marginBottom: '8px' }}>✅ <strong>N3XUS v-COS Powered</strong> — Full ecosystem integration</li>
            <li style={{ marginBottom: '8px' }}>✅ <strong>MetaTwin Activation</strong> — Handshake 55-45-17 protocol</li>
            <li style={{ marginBottom: '8px' }}>✅ <strong>8-Hour Battery</strong> — All-day usage</li>
            <li style={{ marginBottom: '8px' }}>✅ <strong>Lightweight Design</strong> — Under 50g</li>
          </ul>
          
          <div style={{ 
            background: '#f8f9fa', 
            padding: '24px', 
            borderRadius: '12px',
            marginBottom: '24px'
          }}>
            <h4 style={{ marginTop: 0 }}>Wave 2: Creator Edition</h4>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '16px' }}>
              <div>
                <p style={{ margin: 0, fontSize: '14px', color: '#666' }}>Price</p>
                <p style={{ margin: 0, fontSize: '24px', fontWeight: 'bold' }}>2,000 NexCoin</p>
                <p style={{ margin: 0, fontSize: '12px', color: '#999' }}>~$500 USD value</p>
              </div>
              <div>
                <p style={{ margin: 0, fontSize: '14px', color: '#666' }}>Timeline</p>
                <p style={{ margin: 0, fontSize: '24px', fontWeight: 'bold' }}>Q2 2026</p>
                <p style={{ margin: 0, fontSize: '12px', color: '#999' }}>May-June delivery</p>
              </div>
            </div>
            
            <div style={{ marginBottom: '16px' }}>
              <p style={{ margin: 0, fontSize: '14px', color: '#666', marginBottom: '8px' }}>Status</p>
              {preOrderStatus === 'soon' ? (
                <div style={{ 
                  background: '#ffc107', 
                  color: '#000', 
                  padding: '12px 16px', 
                  borderRadius: '8px',
                  fontWeight: 'bold',
                  textAlign: 'center'
                }}>
                  ⏳ Pre-Order Opening Soon
                </div>
              ) : (
                <div style={{ 
                  background: '#28a745', 
                  color: '#fff', 
                  padding: '12px 16px', 
                  borderRadius: '8px',
                  fontWeight: 'bold',
                  textAlign: 'center'
                }}>
                  🚀 Pre-Order Live!
                </div>
              )}
            </div>
            
            <button 
              style={{
                width: '100%',
                padding: '16px',
                fontSize: '18px',
                fontWeight: 'bold',
                background: preOrderStatus === 'live' ? '#667eea' : '#ccc',
                color: '#fff',
                border: 'none',
                borderRadius: '8px',
                cursor: preOrderStatus === 'live' ? 'pointer' : 'not-allowed',
                transition: 'all 0.3s ease'
              }}
              disabled={preOrderStatus === 'soon'}
              onClick={() => {
                if (preOrderStatus === 'live') {
                  alert('Pre-order confirmation: 2,000 NexCoin will be deducted from your account.\n\nYour HoloSnap Wave 2 device will be added to the Neon Vault ledger and shipped in May-June 2026.\n\nThank you for being an early supporter!');
                }
              }}
            >
              {preOrderStatus === 'soon' ? '🔒 Coming Soon' : '🛒 Pre-Order Now'}
            </button>
          </div>
          
          <div style={{ 
            background: '#e3f2fd', 
            padding: '16px', 
            borderRadius: '8px',
            border: '1px solid #2196f3'
          }}>
            <h4 style={{ marginTop: 0, color: '#1976d2' }}>📋 Phase 2.5 Manufacturing Status</h4>
            <ul style={{ margin: 0, paddingLeft: '20px' }}>
              <li>✅ Design specifications finalized</li>
              <li>✅ Manufacturing partner confirmed (Seeed Studio)</li>
              <li>✅ Firmware v1.0.0 with API stub ready</li>
              <li>✅ 3D enclosure design complete</li>
              <li>✅ Neon Vault ledger integration tested</li>
              <li>🔄 Prototype manufacturing in progress (Q2 2026)</li>
              <li>🔄 Wave 1 fulfillment (Founding Tenants)</li>
              <li>⏳ Wave 2 pre-orders opening soon</li>
            </ul>
          </div>
        </div>
      </div>
      
      <div style={{ marginTop: '40px' }}>
        <h3>Technical Specifications</h3>
        <div style={{ 
          display: 'grid', 
          gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))',
          gap: '16px'
        }}>
          <div style={{ background: '#f8f9fa', padding: '16px', borderRadius: '8px' }}>
            <h4 style={{ marginTop: 0 }}>Hardware</h4>
            <ul style={{ paddingLeft: '20px', fontSize: '14px' }}>
              <li>6DOF spatial tracking</li>
              <li>ESP32-S3 processor</li>
              <li>9-axis IMU sensor</li>
              <li>WiFi 802.11 b/g/n</li>
              <li>Bluetooth 5.0</li>
              <li>1000mAh battery</li>
            </ul>
          </div>
          <div style={{ background: '#f8f9fa', padding: '16px', borderRadius: '8px' }}>
            <h4 style={{ marginTop: 0 }}>Software</h4>
            <ul style={{ paddingLeft: '20px', fontSize: '14px' }}>
              <li>N3XUS v-COS OS</li>
              <li>HoloCore runtime</li>
              <li>MetaTwin integration</li>
              <li>Handshake 55-45-17</li>
              <li>OTA firmware updates</li>
              <li>Full ecosystem access</li>
            </ul>
          </div>
          <div style={{ background: '#f8f9fa', padding: '16px', borderRadius: '8px' }}>
            <h4 style={{ marginTop: 0 }}>Physical</h4>
            <ul style={{ paddingLeft: '20px', fontSize: '14px' }}>
              <li>45mm × 30mm × 15mm</li>
              <li>Weight: {'<'} 50g</li>
              <li>Aluminum housing</li>
              <li>Matte black finish</li>
              <li>Universal clip mount</li>
              <li>USB-C charging</li>
            </ul>
          </div>
        </div>
      </div>
      
      <div style={{ marginTop: '40px', textAlign: 'center', color: '#666' }}>
        <p>
          <strong>Questions?</strong> Email <a href="mailto:holosnap@n3xuscos.com">holosnap@n3xuscos.com</a>
        </p>
        <p style={{ fontSize: '12px' }}>
          All pre-orders are final. Estimated delivery Q2 2026. Devices ship inactive and activate via MetaTwin handshake.
        </p>
      </div>
    </div>
  )
}

function App() {
  return (
    <div className="creator-app">
      <nav className="sidebar">
        <div className="logo">
          <h1>🎨 Creator Hub</h1>
          <p>Nexus COS</p>
        </div>
        <ul className="nav-links">
          <li><Link to="/">Projects</Link></li>
          <li><Link to="/assets">Assets</Link></li>
          <li><Link to="/analytics">Analytics</Link></li>
          <li><Link to="/holosnap">🌟 HoloSnap</Link></li>
        </ul>
      </nav>
      
      <main className="main-content">
        <header className="header">
          <h1>Creator Dashboard</h1>
          <div className="user-info">
            <span>Welcome, Creator</span>
          </div>
        </header>
        
        <div className="content">
          <Routes>
            <Route path="/" element={<Projects />} />
            <Route path="/assets" element={<Assets />} />
            <Route path="/analytics" element={<Analytics />} />
            <Route path="/holosnap" element={<HoloSnap />} />
          </Routes>
        </div>
      </main>
    </div>
  )
}

export default App
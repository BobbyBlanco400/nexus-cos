import { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import './App.css'
import CoreServicesStatus from './components/CoreServicesStatus'
import CasinoPortal from './components/CasinoPortal'
import MusicPortal from './components/MusicPortal'

function App() {
  console.log('🚀 N3XUS COS Platform Mounted | Handshake: 55-45-17');
  
  const [loading, setLoading] = useState(true)
  const [activePortal, setActivePortal] = useState<'home' | 'casino' | 'music'>('home')

  useEffect(() => {
    // Simulate loading of platform services
    const timer = setTimeout(() => {
      setLoading(false)
      console.log('✅ N3XUS COS Platform Ready | Handshake: 55-45-17');
    }, 1500)
    
    return () => clearTimeout(timer)
  }, [])

  if (loading) {
    return (
      <div className="loading-screen">
        <div className="loader"></div>
        <h2>Loading N3XUS COS Platform...</h2>
        <p style={{ marginTop: '1rem', color: '#64748b' }}>The Creative Operating System</p>
      </div>
    )
  }

  return (
    <div className="nexus-platform">
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
            <button onClick={() => setActivePortal('home')} style={{ background: activePortal === 'home' ? '#2563eb' : 'transparent' }}>Home</button>
            <Link to="/residents" style={{ background: 'linear-gradient(135deg, #2563eb, #8b5cf6)', border: 'none' }}>Founding Residents ✨</Link>
            <button onClick={() => setActivePortal('casino')} style={{ background: activePortal === 'casino' ? '#2563eb' : 'transparent' }}>Casino N3XUS</button>
            <button onClick={() => setActivePortal('music')} style={{ background: activePortal === 'music' ? '#8b5cf6' : 'transparent' }}>PMMG Music</button>
            <Link to="/cps">CPS</Link>
            <Link to="/dashboard">Dashboard</Link>
            <Link to="/founders">Founders</Link>
            <Link to="/desktop">Desktop</Link>
          </nav>
        </div>
      </header>

      <main className="nexus-main">
        {activePortal === 'casino' && (
          <section>
            <CasinoPortal />
          </section>
        )}
        
        {activePortal === 'music' && (
          <section>
            <MusicPortal />
          </section>
        )}
        
        {activePortal === 'home' && (
          <>
            <section className="hero-section">
              <div className="hero-content">
                <h2 className="hero-title">N3XUS COS — The Creative Operating System</h2>
                <p className="hero-subtitle">
                  Unified platform integrating V-Suite streaming services, PUABO Fleet management, 
                  and comprehensive content creation tools
                </p>
                <div className="hero-cta">
                  <Link to="/residents" className="cta-button primary" style={{ background: 'linear-gradient(135deg, #2563eb, #8b5cf6)', boxShadow: '0 10px 30px rgba(37, 99, 235, 0.4)' }}>
                    Meet Our Founding Residents ✨
                  </Link>
                  <Link to="/dashboard" className="cta-button secondary">Launch Dashboard</Link>
                  <Link to="/desktop" className="cta-button secondary">Virtual Desktop</Link>
                </div>
              </div>
            </section>

            <section className="services-section">
              <h3 className="section-title">Platform Services</h3>
              <div className="services-grid">
                <div className="service-card">
                  <h4>V-Suite Streaming</h4>
                  <p>Professional streaming and production tools</p>
                  <ul>
                    <li>V-Prompter Pro</li>
                    <li>V-Screen Hollywood</li>
                    <li>V-Caster</li>
                    <li>V-Stage</li>
                  </ul>
                </div>
                
                <div className="service-card">
                  <h4>PUABO NEXUS Fleet</h4>
                  <p>Complete fleet management system</p>
                  <ul>
                    <li>AI Dispatch</li>
                    <li>Driver Backend</li>
                    <li>Fleet Manager</li>
                    <li>Route Optimizer</li>
                  </ul>
                </div>
                
                <div className="service-card">
                  <h4>Creator Hub</h4>
                  <p>Content creation and management platform</p>
                  <ul>
                    <li>Asset Management</li>
                    <li>Project Collaboration</li>
                    <li>Distribution Tools</li>
                    <li>Analytics Dashboard</li>
                  </ul>
                </div>
                
                <div className="service-card">
                  <h4>Virtual Desktop</h4>
                  <p>Module-based application environment</p>
                  <ul>
                    <li>Desktop → Module → App Flow</li>
                    <li>Multi-Service Integration</li>
                    <li>Active Tab State Sync</li>
                  </ul>
                  <div style={{ marginTop: '1rem' }}>
                    <Link to="/desktop" style={{ color: '#2563eb', textDecoration: 'underline' }}>
                      Launch Desktop →
                    </Link>
                  </div>
                </div>
              </div>
            </section>

            <section className="status-section">
              <CoreServicesStatus />
            </section>

            <section className="beta-info">
              <div className="beta-badge">BETA</div>
              <h3>Currently in Beta Launch</h3>
              <p>We're actively onboarding early adopters. Join us in shaping the future of content creation.</p>
              <a href="https://beta.nexuscos.online" className="cta-button">Visit Beta Portal</a>
            </section>
          </>
        )}
      </main>

      <footer className="nexus-footer">
        <div className="footer-content">
          <div className="footer-section">
            <h4>N3XUS COS</h4>
            <p>The Creative Operating System</p>
          </div>
          <div className="footer-section">
            <h4>Navigation</h4>
            <Link to="/dashboard">Dashboard</Link>
            <Link to="/founders">Founders</Link>
            <Link to="/desktop">Virtual Desktop</Link>
          </div>
          <div className="footer-section">
            <h4>Platform</h4>
            <a href="/health/gateway">System Status</a>
            <a href="/api/health">API Health</a>
            <a href="/admin">Admin Panel</a>
          </div>
        </div>
        <div className="footer-bottom">
          <p>&copy; 2024 N3XUS COS. All rights reserved. | 🔒 Handshake: 55-45-17</p>
        </div>
      </footer>
    </div>
  )
}

export default App
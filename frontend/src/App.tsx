import { useState, useEffect } from 'react'
import './App.css'
import CoreServicesStatus from './components/CoreServicesStatus'
import CasinoPortal from './components/CasinoPortal'
import MusicPortal from './components/MusicPortal'

function App() {
  const [loading, setLoading] = useState(true)
  const [activePortal, setActivePortal] = useState<'home' | 'casino' | 'music'>('home')

  useEffect(() => {
    // Simulate loading of platform services
    const timer = setTimeout(() => {
      setLoading(false)
    }, 1500)
    
    return () => clearTimeout(timer)
  }, [])

  if (loading) {
    return (
      <div className="loading-screen">
        <div className="loader"></div>
        <h2>Loading Nexus COS Platform...</h2>
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
            <h1>Nexus COS</h1>
          </div>
          <nav className="main-nav">
            <button onClick={() => setActivePortal('home')} style={{ background: activePortal === 'home' ? '#2563eb' : 'transparent' }}>Home</button>
            <button onClick={() => setActivePortal('casino')} style={{ background: activePortal === 'casino' ? '#2563eb' : 'transparent' }}>Casino N3XUS</button>
            <button onClick={() => setActivePortal('music')} style={{ background: activePortal === 'music' ? '#8b5cf6' : 'transparent' }}>PMMG Music</button>
            <a href="/v-suite/prompter">V-Suite</a>
            <a href="/creator-hub">Creator Hub</a>
            <a href="/admin">Admin</a>
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
                <h2 className="hero-title">Complete Operating System for Modern Content Creators</h2>
                <p className="hero-subtitle">
                  Unified platform integrating V-Suite streaming services, PUABO Fleet management, 
                  and comprehensive content creation tools
                </p>
                <div className="hero-cta">
                  <a href="/v-suite/prompter" className="cta-button primary">Launch V-Suite</a>
                  <a href="/creator-hub" className="cta-button secondary">Creator Hub</a>
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
                  <h4>Platform Services</h4>
                  <p>Core infrastructure and APIs</p>
                  <ul>
                    <li>Authentication</li>
                    <li>Payment Gateway</li>
                    <li>Media Services</li>
                    <li>Monitoring</li>
                  </ul>
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
            <h4>Nexus COS</h4>
            <p>Complete Operating System for Content Creators</p>
          </div>
          <div className="footer-section">
            <h4>Services</h4>
            <a href="/v-suite/prompter">V-Suite</a>
            <a href="/creator-hub">Creator Hub</a>
            <a href="/puabo-nexus">PUABO Fleet</a>
          </div>
          <div className="footer-section">
            <h4>Platform</h4>
            <a href="/health/gateway">System Status</a>
            <a href="/api/health">API Health</a>
            <a href="/admin">Admin Panel</a>
          </div>
        </div>
        <div className="footer-bottom">
          <p>&copy; 2024 Nexus COS. All rights reserved.</p>
        </div>
      </footer>
    </div>
  )
}

export default App
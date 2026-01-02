import { useState } from 'react';
import { Link } from 'react-router-dom';
import CoreServicesStatus from '../components/CoreServicesStatus';
import '../App.css';

export default function Dashboard() {
  console.log('📊 N3XUS COS Dashboard Mounted | Handshake: 55-45-17');

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
            <Link to="/">Home</Link>
            <Link to="/dashboard" style={{ background: '#2563eb' }}>Dashboard</Link>
            <Link to="/founders">Founders</Link>
            <Link to="/desktop">Desktop</Link>
          </nav>
        </div>
      </header>

      <main className="nexus-main">
        <section className="hero-section">
          <div className="hero-content">
            <h2 className="hero-title">N3XUS COS Dashboard</h2>
            <p className="hero-subtitle">
              Real-time monitoring and control center for all platform services
            </p>
          </div>
        </section>

        <section className="services-section">
          <h3 className="section-title">Platform Services Overview</h3>
          <div className="services-grid">
            <div className="service-card">
              <h4>V-Suite Streaming</h4>
              <p>Professional streaming and production tools</p>
              <div style={{ marginTop: '1rem' }}>
                <span style={{ color: '#10b981', fontWeight: 'bold' }}>● Online</span>
              </div>
            </div>
            
            <div className="service-card">
              <h4>PUABO NEXUS Fleet</h4>
              <p>Complete fleet management system</p>
              <div style={{ marginTop: '1rem' }}>
                <span style={{ color: '#10b981', fontWeight: 'bold' }}>● Online</span>
              </div>
            </div>
            
            <div className="service-card">
              <h4>Creator Hub</h4>
              <p>Content creation and management platform</p>
              <div style={{ marginTop: '1rem' }}>
                <span style={{ color: '#10b981', fontWeight: 'bold' }}>● Online</span>
              </div>
            </div>
            
            <div className="service-card">
              <h4>Virtual Desktop</h4>
              <p>Module-based application environment</p>
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
      </main>

      <footer className="nexus-footer">
        <div className="footer-content">
          <div className="footer-section">
            <h4>N3XUS COS</h4>
            <p>The Creative Operating System</p>
          </div>
          <div className="footer-section">
            <p>🔒 Handshake: 55-45-17</p>
          </div>
        </div>
      </footer>
    </div>
  );
}

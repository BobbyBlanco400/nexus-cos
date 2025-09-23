import { useState, useEffect } from 'react'
import './App.css'

interface HealthResponse {
  status: string;
}

function App() {
  const [healthStatus, setHealthStatus] = useState<string>('checking...')
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    // Check backend health
    const checkHealth = async () => {
      try {
        const response = await fetch('http://localhost:3002/health')
        const data: HealthResponse = await response.json()
        setHealthStatus(data.status === 'ok' ? '✅ Backend Connected' : '❌ Backend Error')
      } catch (error) {
        setHealthStatus('❌ Backend Offline')
      } finally {
        setIsLoading(false)
      }
    }

    checkHealth()
  }, [])

  return (
    <div className="nexus-app">
      <header className="nexus-header">
        <div className="logo">
          <h1>🚀 Nexus COS</h1>
          <p>Complete Operating System</p>
        </div>
        <nav className="nav-menu">
          <a href="#home">Home</a>
          <a href="#browse">Browse</a>
          <a href="#search">Search</a>
          <a href="#profile">Profile</a>
        </nav>
      </header>

      <main className="nexus-main">
        <section className="hero">
          <h2>Welcome to Nexus COS</h2>
          <p>Your complete digital operating system for the modern web</p>
          <div className="status-card">
            <h3>System Status</h3>
            <p className={`status ${isLoading ? 'loading' : ''}`}>
              {isLoading ? '🔄 Checking...' : healthStatus}
            </p>
          </div>
        </section>

        <section className="features">
          <div className="feature-grid">
            <div className="feature-card">
              <h3>🏠 Home</h3>
              <p>Your personalized dashboard</p>
            </div>
            <div className="feature-card">
              <h3>📂 Browse</h3>
              <p>Explore content and applications</p>
            </div>
            <div className="feature-card">
              <h3>🔍 Search</h3>
              <p>Find anything quickly</p>
            </div>
            <div className="feature-card">
              <h3>👤 Profile</h3>
              <p>Manage your account</p>
            </div>
          </div>
        </section>
      </main>

      <footer className="nexus-footer">
        <p>&copy; 2024 Nexus COS - Built with React + TypeScript + Vite</p>
      </footer>
    </div>
  )
}

export default App

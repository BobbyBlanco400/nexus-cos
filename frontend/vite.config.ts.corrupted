import { useState, useEffect } from 'react'
import './App.css'
import CoreServicesStatus from './components/CoreServicesStatus'

type StreamingSection = 'home' | 'live-tv' | 'on-demand' | 'modules' | 'settings'

interface SubscriptionTier {
  id: string
  name: string
  price: string
  emoji: string
  color: string
}

interface PlatformStats {
  activeViewers: number
  liveChannels: number
  availableModules: number
  onDemandContent: number
}

function App() {
  const [isLoading, setIsLoading] = useState(true)
  const [currentSection, setCurrentSection] = useState<StreamingSection>('home')
  const [platformStats, setPlatformStats] = useState<PlatformStats>({
    activeViewers: 0,
    liveChannels: 0,
    availableModules: 0,
    onDemandContent: 0
  })

  const subscriptionTiers: SubscriptionTier[] = [
    { id: '1', name: 'Basic', price: '$9.99', emoji: '📺', color: '#2563eb' },
    { id: '2', name: 'Premium', price: '$19.99', emoji: '🎬', color: '#3b82f6' },
    { id: '3', name: 'Studio', price: '$49.99', emoji: '🎥', color: '#1e40af' },
    { id: '4', name: 'Enterprise', price: '$99.99', emoji: '🏢', color: '#60a5fa' },
    { id: '5', name: 'Platform', price: '$199.99', emoji: '🚀', color: '#2563eb' }
  ]

  useEffect(() => {
    // Simulate loading
    const loadTimer = setTimeout(() => {
      setIsLoading(false)
    }, 2000)

    // Simulate platform stats updates
    const statsInterval = setInterval(() => {
      setPlatformStats({
        activeViewers: Math.floor(Math.random() * 10000) + 1000,
        liveChannels: Math.floor(Math.random() * 50) + 10,
        availableModules: 8, // Fixed number: Creator Hub, V-Suite, PuaboVerse, Club Saditty, etc.
        onDemandContent: Math.floor(Math.random() * 5000) + 1000
      })
    }, 3000)

    return () => {
      clearTimeout(loadTimer)
      clearInterval(statsInterval)
    }
  }, [])

  if (isLoading) {
    return (
      <div className="loading-screen">
        <div className="loader"></div>
        <h2>Loading Nexus COS Platform...</h2>
      </div>
    )
  }

  return (
    <div className="streaming-app">
      <div className="animated-background">
        <div className="orb orb-1"></div>
        <div className="orb orb-2"></div>
        <div className="orb orb-3"></div>
      </div>

      <header className="streaming-header">
        <div className="platform-logo">
          <h1>🚀 Nexus COS - OTT/Streaming Platform</h1>
        </div>
        <nav className="platform-nav">
          <button 
            className={`nav-btn ${currentSection === 'home' ? 'active' : ''}`}
            onClick={() => setCurrentSection('home')}
          >
            🏠 Home
          </button>
          <button 
            className={`nav-btn ${currentSection === 'live-tv' ? 'active' : ''}`}
            onClick={() => setCurrentSection('live-tv')}
          >
            📺 Live TV
          </button>
          <button 
            className={`nav-btn ${currentSection === 'on-demand' ? 'active' : ''}`}
            onClick={() => setCurrentSection('on-demand')}
          >
            🎬 On Demand
          </button>
          <button 
            className={`nav-btn ${currentSection === 'modules' ? 'active' : ''}`}
            onClick={() => setCurrentSection('modules')}
          >
            🎯 Modules
          </button>
          <button 
            className={`nav-btn ${currentSection === 'settings' ? 'active' : ''}`}
            onClick={() => setCurrentSection('settings')}
          >
            ⚙️ Settings
          </button>
        </nav>
      </header>

      <main className="streaming-main">
        <CoreServicesStatus />

        <section className="platform-stats">
          <div className="stat-card">
            <div className="stat-value">{platformStats.activeViewers.toLocaleString()}</div>
            <div className="stat-label">Active Viewers</div>
          </div>
          <div className="stat-card">
            <div className="stat-value">{platformStats.liveChannels}</div>
            <div className="stat-label">Live Channels</div>
          </div>
          <div className="stat-card">
            <div className="stat-value">{platformStats.availableModules}</div>
            <div className="stat-label">Available Modules</div>
          </div>
          <div className="stat-card">
            <div className="stat-value">{platformStats.onDemandContent.toLocaleString()}</div>
            <div className="stat-label">On-Demand Content</div>
          </div>
        </section>

        <section className="platform-content">
          {currentSection === 'home' && (
            <div className="section-content">
              <h2 className="neon-text">Welcome to Nexus COS</h2>
              <p className="section-description">
                Your complete OTT/Streaming TV platform. Access live channels, on-demand content, and powerful modules all in one place.
              </p>
            </div>
          )}
          {currentSection === 'live-tv' && (
            <div className="section-content">
              <h2 className="neon-text">📺 Live TV Channels</h2>
              <p className="section-description">
                Stream live content from multiple channels. HD quality with DVR capabilities.
              </p>
              <div className="channel-grid">
                <div className="channel-card">Channel 1 - 🔴 Live</div>
                <div className="channel-card">Channel 2 - 🔴 Live</div>
                <div className="channel-card offline">Channel 3 - Offline</div>
                <div className="channel-card">Channel 4 - 🔴 Live</div>
              </div>
            </div>
          )}
          {currentSection === 'on-demand' && (
            <div className="section-content">
              <h2 className="neon-text">🎬 On-Demand Library</h2>
              <p className="section-description">
                Access thousands of movies, shows, and original content. Watch anytime, anywhere.
              </p>
            </div>
          )}
          {currentSection === 'modules' && (
            <div className="section-content">
              <h2 className="neon-text">🎯 Platform Modules</h2>
              <p className="section-description">
                Explore our powerful modules: Creator Hub, V-Suite, PuaboVerse, Club Saditty, and more.
              </p>
              <div className="module-grid">
                <div className="module-card">🎨 Creator Hub</div>
                <div className="module-card">💼 V-Suite</div>
                <div className="module-card">🌐 PuaboVerse</div>
                <div className="module-card">🎪 Club Saditty</div>
                <div className="module-card">🎥 V-Screen Hollywood</div>
                <div className="module-card">📊 Analytics</div>
              </div>
            </div>
          )}
          {currentSection === 'settings' && (
            <div className="section-content">
              <h2 className="neon-text">⚙️ Platform Settings</h2>
              <p className="section-description">
                Configure your streaming preferences, manage subscriptions, and customize your experience.
              </p>
            </div>
          )}
        </section>

        <section className="subscription-tiers">
          <h2 className="section-title">Subscription Plans</h2>
          <div className="tiers-grid">
            {subscriptionTiers.map(tier => (
              <div key={tier.id} className="tier-card glass-effect" style={{ borderColor: tier.color }}>
                <div className="tier-emoji">{tier.emoji}</div>
                <h3 className="tier-name">{tier.name}</h3>
                <div className="tier-price">{tier.price}/month</div>
                <button className="tier-btn" style={{ backgroundColor: tier.color }}>
                  Subscribe
                </button>
              </div>
            ))}
          </div>
        </section>
      </main>

      <footer className="streaming-footer">
        <p>🚀 Nexus COS - Complete Operating System | OTT/Streaming TV Platform with Integrated Modules</p>
      </footer>
    </div>
  )
}

export default App
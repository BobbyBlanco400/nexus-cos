import { useState, useEffect } from 'react'
import './App.css'
import CoreServicesStatus from './components/CoreServicesStatus'

type ClubArea = 'lobby' | 'main-stage' | 'vip-suites' | 'dressing-rooms' | 'office'

interface MembershipTier {
  id: string
  name: string
  price: string
  emoji: string
  color: string
}

interface LiveStats {
  onlineUsers: number
  activePerformers: number
  vipSuitesOccupied: number
  mainStageViewers: number
}

function App() {
  const [isLoading, setIsLoading] = useState(true)
  const [currentArea, setCurrentArea] = useState<ClubArea>('lobby')
  const [liveStats, setLiveStats] = useState<LiveStats>({
    onlineUsers: 0,
    activePerformers: 0,
    vipSuitesOccupied: 0,
    mainStageViewers: 0
  })

  const membershipTiers: MembershipTier[] = [
    { id: '1', name: 'General Admission', price: '$9.99', emoji: '🎫', color: '#8b5cf6' },
    { id: '2', name: 'Backstage Pass', price: '$29.99', emoji: '🎭', color: '#a78bfa' },
    { id: '3', name: 'VIP Lounge', price: '$59.99', emoji: '👑', color: '#c4b5fd' },
    { id: '4', name: 'Champagne Room', price: '$999', emoji: '🥂', color: '#ddd6fe' },
    { id: '5', name: 'Black Card', price: '$1999.99', emoji: '♠️', color: '#ede9fe' }
  ]

  useEffect(() => {
    // Simulate loading
    const loadTimer = setTimeout(() => {
      setIsLoading(false)
    }, 2000)

    // Simulate live stats updates
    const statsInterval = setInterval(() => {
      setLiveStats({
        onlineUsers: Math.floor(Math.random() * 500) + 100,
        activePerformers: Math.floor(Math.random() * 20) + 5,
        vipSuitesOccupied: Math.floor(Math.random() * 10) + 2,
        mainStageViewers: Math.floor(Math.random() * 200) + 50
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
        <h2>Loading Club Saditty...</h2>
      </div>
    )
  }

  return (
    <div className="club-app">
      <div className="animated-background">
        <div className="orb orb-1"></div>
        <div className="orb orb-2"></div>
        <div className="orb orb-3"></div>
      </div>

      <header className="club-header">
        <div className="club-logo">
          <h1>🏠 Club Saditty Lobby</h1>
        </div>
        <nav className="club-nav">
          <button 
            className={`nav-btn ${currentArea === 'lobby' ? 'active' : ''}`}
            onClick={() => setCurrentArea('lobby')}
          >
            🏠 Lobby
          </button>
          <button 
            className={`nav-btn ${currentArea === 'main-stage' ? 'active' : ''}`}
            onClick={() => setCurrentArea('main-stage')}
          >
            🎭 Main Stage
          </button>
          <button 
            className={`nav-btn ${currentArea === 'vip-suites' ? 'active' : ''}`}
            onClick={() => setCurrentArea('vip-suites')}
          >
            👑 VIP Suites
          </button>
          <button 
            className={`nav-btn ${currentArea === 'dressing-rooms' ? 'active' : ''}`}
            onClick={() => setCurrentArea('dressing-rooms')}
          >
            💄 Dressing Rooms
          </button>
          <button 
            className={`nav-btn ${currentArea === 'office' ? 'active' : ''}`}
            onClick={() => setCurrentArea('office')}
          >
            🎩 Saditty's Office
          </button>
        </nav>
      </header>

      <main className="club-main">
        <CoreServicesStatus />
        
        <section className="live-stats">
          <div className="stat-card">
            <div className="stat-value">{liveStats.onlineUsers}</div>
            <div className="stat-label">Online Users</div>
          </div>
          <div className="stat-card">
            <div className="stat-value">{liveStats.activePerformers}</div>
            <div className="stat-label">Active Performers</div>
          </div>
          <div className="stat-card">
            <div className="stat-value">{liveStats.vipSuitesOccupied}</div>
            <div className="stat-label">VIP Suites Occupied</div>
          </div>
          <div className="stat-card">
            <div className="stat-value">{liveStats.mainStageViewers}</div>
            <div className="stat-label">Main Stage Viewers</div>
          </div>
        </section>

        <section className="club-content">
          {currentArea === 'lobby' && (
            <div className="area-content">
              <h2 className="neon-text">Welcome to Club Saditty</h2>
              <p className="area-description">
                The premier virtual club experience. Select your destination or browse our membership tiers below.
              </p>
            </div>
          )}
          {currentArea === 'main-stage' && (
            <div className="area-content">
              <h2 className="neon-text">🎭 Main Stage</h2>
              <p className="area-description">
                Watch live performances from our talented performers. Premium features available for VIP members.
              </p>
              <div className="stage-placeholder">
                <div className="stage-lights"></div>
                <p>🎪 Live Performance Area</p>
              </div>
            </div>
          )}
          {currentArea === 'vip-suites' && (
            <div className="area-content">
              <h2 className="neon-text">👑 VIP Suites</h2>
              <p className="area-description">
                Book your private suite for an exclusive experience. Limited availability.
              </p>
              <div className="suite-grid">
                <div className="suite-card">Suite 1 - Available</div>
                <div className="suite-card occupied">Suite 2 - Occupied</div>
                <div className="suite-card">Suite 3 - Available</div>
                <div className="suite-card occupied">Suite 4 - Occupied</div>
              </div>
            </div>
          )}
          {currentArea === 'dressing-rooms' && (
            <div className="area-content">
              <h2 className="neon-text">💄 Dressing Rooms</h2>
              <p className="area-description">
                Performer preparation area. Customize your avatar and get ready for the stage.
              </p>
            </div>
          )}
          {currentArea === 'office' && (
            <div className="area-content">
              <h2 className="neon-text">🎩 Saditty's Office</h2>
              <p className="area-description">
                Private area for club management and exclusive Black Card members.
              </p>
            </div>
          )}
        </section>

        <section className="membership-tiers">
          <h2 className="section-title">Membership Tiers</h2>
          <div className="tiers-grid">
            {membershipTiers.map(tier => (
              <div key={tier.id} className="tier-card glass-effect" style={{ borderColor: tier.color }}>
                <div className="tier-emoji">{tier.emoji}</div>
                <h3 className="tier-name">{tier.name}</h3>
                <div className="tier-price">{tier.price}</div>
                <button className="tier-btn" style={{ backgroundColor: tier.color }}>
                  Select Tier
                </button>
              </div>
            ))}
          </div>
        </section>
      </main>

      <footer className="club-footer">
        <p>🎪 Club Saditty - Virtual Club Experience | Powered by Nexus COS</p>
      </footer>
    </div>
  )
}

export default App

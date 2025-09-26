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
          </Routes>
        </div>
      </main>
    </div>
  )
}

export default App
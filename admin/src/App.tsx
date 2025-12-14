import React from 'react'
import { Routes, Route, Link } from 'react-router-dom'
import './App.css'
import LaunchReadinessChecklist from './components/LaunchReadinessChecklist'

function Dashboard() {
  return (
    <div>
      <h2>Dashboard</h2>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div className="card">
          <h3>Users</h3>
          <p className="text-2xl font-bold">1,234</p>
        </div>
        <div className="card">
          <h3>Projects</h3>
          <p className="text-2xl font-bold">56</p>
        </div>
        <div className="card">
          <h3>Revenue</h3>
          <p className="text-2xl font-bold">$12,345</p>
        </div>
      </div>
    </div>
  )
}

function Users() {
  return (
    <div>
      <h2>Users Management</h2>
      <p>Manage users, permissions, and access control.</p>
    </div>
  )
}

function Settings() {
  return (
    <div>
      <h2>System Settings</h2>
      <p>Configure system preferences and settings.</p>
    </div>
  )
}

function App() {
  return (
    <div className="admin-app">
      <nav className="sidebar">
        <div className="logo">
          <h1>🚀 Nexus COS</h1>
          <p>Admin Panel</p>
        </div>
        <ul className="nav-links">
          <li><Link to="/">Dashboard</Link></li>
          <li><Link to="/users">Users</Link></li>
          <li><Link to="/launch-checklist">🚀 Launch Readiness</Link></li>
          <li><Link to="/settings">Settings</Link></li>
        </ul>
      </nav>
      
      <main className="main-content">
        <header className="header">
          <h1>Admin Panel</h1>
          <div className="user-info">
            <span>Welcome, Administrator</span>
          </div>
        </header>
        
        <div className="content">
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/users" element={<Users />} />
            <Route path="/launch-checklist" element={<LaunchReadinessChecklist />} />
            <Route path="/settings" element={<Settings />} />
          </Routes>
        </div>
      </main>
    </div>
  )
}

export default App
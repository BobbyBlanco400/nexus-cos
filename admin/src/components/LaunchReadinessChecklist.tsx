import React, { useState, useEffect } from 'react'
import './LaunchReadinessChecklist.css'

interface ChecklistItem {
  id: string
  item: string
  status: boolean
  notes: string
  assignedTo: string
  verifiedDate: string
}

interface ChecklistCategory {
  name: string
  items: ChecklistItem[]
}

const initialChecklistData: ChecklistCategory[] = [
  {
    name: 'Platform Core & Infrastructure',
    items: [
      { id: 'pci-1', item: 'Server Health - CPU / Memory / Disk usage', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pci-2', item: 'OS & Node - Ubuntu 22.04+, Node 20+', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pci-3', item: 'PM2 Processes - All services running', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pci-4', item: 'Docker - Containers up & healthy', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pci-5', item: 'Redis / Cache - Caching operational', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pci-6', item: 'Load Balancer / Failover - Auto-scaling works', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pci-7', item: 'SSL / HTTPS - Certificates valid', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
    ]
  },
  {
    name: 'PMMG Nexus Recordings',
    items: [
      { id: 'pnr-1', item: 'Repo & Build - Clone repo', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pnr-2', item: 'Repo & Build - Install dependencies', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pnr-3', item: 'Repo & Build - Build frontend', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pnr-4', item: 'Repo & Build - Deploy backend', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pnr-5', item: 'Studio Features - Multi-track recording', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pnr-6', item: 'Studio Features - Mixing & Mastering', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pnr-7', item: 'Collaboration - Real-time session', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pnr-8', item: 'Collaboration - File management / versioning', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pnr-9', item: 'Licensing - IP registration', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pnr-10', item: 'Distribution - Push to Nexus Store / Partners', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pnr-11', item: 'Roles - Artist / Producer / Engineer / Label', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pnr-12', item: 'Monitoring - Logs / PM2 health', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
    ]
  },
  {
    name: 'Rise Sacramento: VoicesOfThe916',
    items: [
      { id: 'rsv-1', item: 'Repo & Build - Clone repo', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-2', item: 'Repo & Build - Install dependencies', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-3', item: 'Repo & Build - Build frontend', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-4', item: 'Repo & Build - Deploy backend', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-5', item: 'Virtual Showcases - Live streaming setup', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-6', item: 'Virtual Showcases - Multi-artist sessions', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-7', item: 'Virtual Showcases - Audience interaction (chat/Q&A)', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-8', item: 'Virtual Showcases - Performance recording & replay', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-9', item: 'Media Upload - Audio/video upload', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-10', item: 'Media Upload - Cloud storage & version history', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-11', item: 'Licensing - IP registration & royalties', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-12', item: 'Distribution - Push to Nexus Store / streaming partners', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-13', item: 'Collaboration - Artist / Producer / Admin roles', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-14', item: 'Collaboration - Shared session / moderation', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-15', item: 'Performance & UX - Load testing for audience', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-16', item: 'Performance & UX - Latency / streaming quality', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-17', item: 'Performance & UX - Cross-browser & device testing', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-18', item: 'Monitoring & Analytics - Backend logs & errors', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-19', item: 'Monitoring & Analytics - Audience engagement metrics', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-20', item: 'Security & Compliance - Artist login / OAuth / MFA', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-21', item: 'Security & Compliance - Cloud storage encryption', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-22', item: 'Global Launch Readiness - E2E workflow (signup → showcase → distribution)', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-23', item: 'Global Launch Readiness - QA Sign-Off', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
    ]
  },
  {
    name: 'Platform Modules (All 17 Verified)',
    items: [
      { id: 'pm-1', item: '1. Casino-Nexus - Gaming platform deployment', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pm-2', item: '2. Club Saditty - Social club features deployment', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pm-3', item: '3. Core-OS - Operating system core deployment', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pm-4', item: '4. GameCore - Game engine integration deployment', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pm-5', item: '5. MusicChain - Music blockchain deployment', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pm-6', item: '6. Nexus Studio AI - Studio AI features deployment', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pm-7', item: '7. PUABO BLAC - Banking platform deployment', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pm-8', item: '8. PUABO DSP - DSP infrastructure deployment', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pm-9', item: '9. PUABO Nexus - Integration hub deployment', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pm-10', item: '10. PUABO Nuki - E-commerce platform deployment', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pm-11', item: '11. PUABO Nuki Clothing - Fashion E-commerce deployment', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pm-12', item: '12. PUABO OS v200 - OS v2.0 deployment', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pm-13', item: '13. PUABO OTT TV Streaming - OTT platform deployment', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pm-14', item: '14. PUABO Studio - Studio module deployment', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pm-15', item: '15. PUABOverse - Metaverse platform deployment', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pm-16', item: '16. StreamCore - Streaming core deployment', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pm-17', item: '17. V-Suite - Professional video suite deployment', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pm-18', item: 'All 17 Platforms - Modules active / functional', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pm-19', item: 'All 17 Platforms - Licensing automation hooks working', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pm-20', item: 'All 17 Platforms - Health endpoints responding', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
    ]
  },
  {
    name: 'Licensing & IP Management',
    items: [
      { id: 'lipm-1', item: 'License Server - Connectivity verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'lipm-2', item: 'IP Registration - Auto-registration works', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'lipm-3', item: 'Royalty Splits - Correct calculation', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'lipm-4', item: 'Contract Templates - Functional & accurate', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'lipm-5', item: 'Legal / Terms - Stored & accessible', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
    ]
  },
  {
    name: 'Distribution & Monetization',
    items: [
      { id: 'dm-1', item: 'Nexus Store - Upload / Display verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'dm-2', item: 'Streaming Partners - Integration tested', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'dm-3', item: 'Payments - Payouts & splits verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'dm-4', item: 'Release Scheduling - Auto/manual release tested', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'dm-5', item: 'Analytics - Dashboard accurate', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
    ]
  },
  {
    name: 'Collaboration & Communication',
    items: [
      { id: 'cc-1', item: 'Messaging - Real-time messaging', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'cc-2', item: 'Invitations - Multi-user session joins', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'cc-3', item: 'Notifications - Push / email alerts', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'cc-4', item: 'Access Control - Role-based permissions', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'cc-5', item: 'Audio/Video Sync - Realtime lag-free', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
    ]
  },
  {
    name: 'Security & Compliance',
    items: [
      { id: 'sc-1', item: 'HTTPS - Endpoints secured', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'sc-2', item: 'Data Encryption - Rest & transit', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'sc-3', item: 'Authentication - OAuth / SSO / MFA', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'sc-4', item: 'Audit Logs - Activity tracking', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'sc-5', item: 'Vulnerability Scan - Penetration tests', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
    ]
  },
  {
    name: 'UX/UI & Accessibility',
    items: [
      { id: 'ux-1', item: 'Browser Compatibility - Chrome / Edge / Safari / Firefox', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'ux-2', item: 'Mobile / Tablet - Responsive', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'ux-3', item: 'Accessibility - WCAG 2.1 standards', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'ux-4', item: 'Load Times - Critical pages <2s', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'ux-5', item: 'Error Handling - Graceful fallbacks', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
    ]
  },
  {
    name: 'Performance & Load',
    items: [
      { id: 'pl-1', item: 'Stress Test - Concurrent users', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pl-2', item: 'Latency Test - Real-time audio/video', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pl-3', item: 'Throughput - Large file upload/download', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pl-4', item: 'Auto-scaling - Dynamic cloud scaling', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pl-5', item: 'CDN / Media Delivery - Global performance', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
    ]
  },
  {
    name: 'Backups & DR',
    items: [
      { id: 'bdr-1', item: 'Backup Verification - Daily & DB / media', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'bdr-2', item: 'Restore Test - Full system restore', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'bdr-3', item: 'Redundancy - Failover tested', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'bdr-4', item: 'Incident Response - Documented & tested', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
    ]
  },
  {
    name: 'Global Launch Sign-Off',
    items: [
      { id: 'gls-1', item: 'End-to-End Workflow - Recording / Showcase → Licensing → Distribution', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'gls-2', item: 'Admin & User Dashboards - Verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'gls-3', item: 'Monitoring & Alerts - Active & accurate', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'gls-4', item: 'Legal & Compliance - IP, contracts, GDPR, DMCA', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'gls-5', item: 'Global CDN & Streaming - Verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'gls-6', item: 'Final QA Sign-Off - Trae / QA Lead Approval', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
    ]
  },
]

export default function LaunchReadinessChecklist() {
  const [checklist, setChecklist] = useState<ChecklistCategory[]>(initialChecklistData)
  const [expandedCategories, setExpandedCategories] = useState<Set<string>>(new Set())
  const [thiioCompliance, setThiioCompliance] = useState({
    thiioCompliant: false,
    legalCleared: false,
    ipVerified: false,
    productionReady: false
  })

  // Load checklist from localStorage on mount
  useEffect(() => {
    const saved = localStorage.getItem('nexus-launch-checklist')
    const savedThiio = localStorage.getItem('nexus-thiio-compliance')
    if (saved) {
      try {
        setChecklist(JSON.parse(saved))
      } catch (e) {
        console.error('Failed to load saved checklist:', e)
      }
    }
    if (savedThiio) {
      try {
        setThiioCompliance(JSON.parse(savedThiio))
      } catch (e) {
        console.error('Failed to load THIIO compliance:', e)
      }
    }
    // Expand all categories by default
    setExpandedCategories(new Set(initialChecklistData.map(cat => cat.name)))
  }, [])

  // Save checklist to localStorage whenever it changes
  useEffect(() => {
    localStorage.setItem('nexus-launch-checklist', JSON.stringify(checklist))
  }, [checklist])

  // Save THIIO compliance status
  useEffect(() => {
    localStorage.setItem('nexus-thiio-compliance', JSON.stringify(thiioCompliance))
  }, [thiioCompliance])

  const toggleItemStatus = (categoryName: string, itemId: string) => {
    setChecklist(prev => prev.map(category => {
      if (category.name === categoryName) {
        return {
          ...category,
          items: category.items.map(item => {
            if (item.id === itemId) {
              const newStatus = !item.status
              return {
                ...item,
                status: newStatus,
                verifiedDate: newStatus ? new Date().toLocaleDateString() : ''
              }
            }
            return item
          })
        }
      }
      return category
    }))
  }

  const updateItemNotes = (categoryName: string, itemId: string, notes: string) => {
    setChecklist(prev => prev.map(category => {
      if (category.name === categoryName) {
        return {
          ...category,
          items: category.items.map(item => 
            item.id === itemId ? { ...item, notes } : item
          )
        }
      }
      return category
    }))
  }

  const updateItemAssignee = (categoryName: string, itemId: string, assignedTo: string) => {
    setChecklist(prev => prev.map(category => {
      if (category.name === categoryName) {
        return {
          ...category,
          items: category.items.map(item => 
            item.id === itemId ? { ...item, assignedTo } : item
          )
        }
      }
      return category
    }))
  }

  const toggleCategory = (categoryName: string) => {
    setExpandedCategories(prev => {
      const next = new Set(prev)
      if (next.has(categoryName)) {
        next.delete(categoryName)
      } else {
        next.add(categoryName)
      }
      return next
    })
  }

  const getCategoryProgress = (category: ChecklistCategory) => {
    const total = category.items.length
    const completed = category.items.filter(item => item.status).length
    return { total, completed, percentage: Math.round((completed / total) * 100) }
  }

  const getTotalProgress = () => {
    const total = checklist.reduce((sum, cat) => sum + cat.items.length, 0)
    const completed = checklist.reduce((sum, cat) => 
      sum + cat.items.filter(item => item.status).length, 0)
    return { total, completed, percentage: Math.round((completed / total) * 100) }
  }

  const exportChecklist = () => {
    const thiioManifest = {
      deployment_manifest_id: `NEXUS_COS_LAUNCH_${new Date().getTime()}`,
      project_name: "Nexus COS Global Launch Readiness",
      version: "1.0.0",
      created: new Date().toISOString().split('T')[0],
      status: thiioCompliance.productionReady ? "production_ready" : "in_progress",
      metadata: {
        thiio_compliant: thiioCompliance.thiioCompliant,
        legal_cleared: thiioCompliance.legalCleared,
        ip_verified: thiioCompliance.ipVerified,
        production_ready: thiioCompliance.productionReady
      },
      checklist_progress: getTotalProgress(),
      categories: checklist.map(cat => ({
        category: cat.name,
        progress: getCategoryProgress(cat),
        items: cat.items
      })),
      thiio_handoff_compliance: {
        package_version: "2.0.0",
        license_id: "THIIO-NEXUS-COS-2025-001",
        expected_sha256: "23E511A6F52F17FE12DED43E32F71D748FBEF1B32CA339DBB60C253E03339AB4",
        services_count: "45+",
        modules_count: "43",
        platform_modules_count: "17",
        total_platforms_verified: "17",
        server_injected_updates: true
      },
      export_timestamp: new Date().toISOString()
    }
    
    const data = JSON.stringify(thiioManifest, null, 2)
    const blob = new Blob([data], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `nexus-thiio-launch-checklist-${new Date().toISOString().split('T')[0]}.json`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
  }

  const resetChecklist = () => {
    if (confirm('Are you sure you want to reset the entire checklist? This cannot be undone.')) {
      setChecklist(initialChecklistData)
      localStorage.removeItem('nexus-launch-checklist')
    }
  }

  const totalProgress = getTotalProgress()

  return (
    <div className="launch-checklist">
      <div className="checklist-header">
        <div className="header-content">
          <h1>🚀 Nexus COS Global Launch Readiness Checklist</h1>
          <p className="subtitle">THIIO Handoff System - Master PF Compliance Framework</p>
          <p className="thiio-version">THIIO Package v2.0.0 | License: THIIO-NEXUS-COS-2025-001</p>
        </div>

        <div className="thiio-compliance-status">
          <h3>THIIO Handoff Compliance Status</h3>
          <div className="compliance-grid">
            <div className={`compliance-item ${thiioCompliance.thiioCompliant ? 'verified' : 'pending'}`}>
              <span className="compliance-icon">{thiioCompliance.thiioCompliant ? '✅' : '⚠️'}</span>
              <span className="compliance-label">THIIO Compliant</span>
            </div>
            <div className={`compliance-item ${thiioCompliance.legalCleared ? 'verified' : 'pending'}`}>
              <span className="compliance-icon">{thiioCompliance.legalCleared ? '✅' : '⚠️'}</span>
              <span className="compliance-label">Legal Cleared</span>
            </div>
            <div className={`compliance-item ${thiioCompliance.ipVerified ? 'verified' : 'pending'}`}>
              <span className="compliance-icon">{thiioCompliance.ipVerified ? '✅' : '⚠️'}</span>
              <span className="compliance-label">IP Verified</span>
            </div>
            <div className={`compliance-item ${thiioCompliance.productionReady ? 'verified' : 'pending'}`}>
              <span className="compliance-icon">{thiioCompliance.productionReady ? '✅' : '⚠️'}</span>
              <span className="compliance-label">Production Ready</span>
            </div>
          </div>
        </div>
        
        <div className="overall-progress">
          <h3>Overall Progress</h3>
          <div className="progress-bar">
            <div 
              className="progress-fill" 
              style={{ width: `${totalProgress.percentage}%` }}
            />
          </div>
          <p className="progress-stats">
            {totalProgress.completed} of {totalProgress.total} items completed ({totalProgress.percentage}%)
          </p>
        </div>

        <div className="actions">
          <button onClick={exportChecklist} className="btn btn-secondary">
            📥 Export THIIO Manifest
          </button>
          <button onClick={resetChecklist} className="btn btn-danger">
            🔄 Reset All
          </button>
        </div>
      </div>

      <div className="checklist-content">{checklist.map(category => {
          const progress = getCategoryProgress(category)
          const isExpanded = expandedCategories.has(category.name)

          return (
            <div key={category.name} className="category-section">
              <div 
                className="category-header"
                onClick={() => toggleCategory(category.name)}
              >
                <div className="category-title">
                  <span className="expand-icon">{isExpanded ? '▼' : '▶'}</span>
                  <h2>{category.name}</h2>
                  <span className="category-count">
                    {progress.completed}/{progress.total}
                  </span>
                </div>
                <div className="category-progress">
                  <div className="progress-bar small">
                    <div 
                      className="progress-fill" 
                      style={{ width: `${progress.percentage}%` }}
                    />
                  </div>
                  <span className="percentage">{progress.percentage}%</span>
                </div>
              </div>

              {isExpanded && (
                <div className="category-items">
                  <table className="checklist-table">
                    <thead>
                      <tr>
                        <th className="col-status">Status</th>
                        <th className="col-item">Item</th>
                        <th className="col-notes">Notes / Comments</th>
                        <th className="col-assigned">Assigned To</th>
                        <th className="col-date">Verified Date</th>
                      </tr>
                    </thead>
                    <tbody>
                      {category.items.map(item => (
                        <tr key={item.id} className={item.status ? 'completed' : ''}>
                          <td className="col-status">
                            <label className="checkbox-container">
                              <input
                                type="checkbox"
                                checked={item.status}
                                onChange={() => toggleItemStatus(category.name, item.id)}
                              />
                              <span className="checkmark"></span>
                              <span className="status-icon">
                                {item.status ? '✅' : '☐'}
                              </span>
                            </label>
                          </td>
                          <td className="col-item">{item.item}</td>
                          <td className="col-notes">
                            <input
                              type="text"
                              value={item.notes}
                              onChange={(e) => updateItemNotes(category.name, item.id, e.target.value)}
                              placeholder="Add notes..."
                              className="notes-input"
                            />
                          </td>
                          <td className="col-assigned">
                            <input
                              type="text"
                              value={item.assignedTo}
                              onChange={(e) => updateItemAssignee(category.name, item.id, e.target.value)}
                              className="assigned-input"
                            />
                          </td>
                          <td className="col-date">
                            {item.verifiedDate}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          )
        })}
      </div>
    </div>
  )
}

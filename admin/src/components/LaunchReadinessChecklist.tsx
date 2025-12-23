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
    name: 'Nexus Stream - Public Entrypoint (Port 3000)',
    items: [
      { id: 'ns-1', item: 'Port 3000 - Public binding verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'ns-2', item: 'Port 3001 - Fallback configured', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'ns-3', item: 'Routing - Public routing confirmed', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'ns-4', item: 'Authentication - Auth system operational', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'ns-5', item: 'Onboarding - User onboarding flow verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'ns-6', item: 'CDN / HTTPS - Public access secured', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'ns-7', item: 'NGINX - Reverse proxy configured', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
    ]
  },
  {
    name: 'Nexus COS Core (Internal Services)',
    items: [
      { id: 'ncc-1', item: 'Core Services - Ports 4000-4099 operational', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'ncc-2', item: 'Internal Routing - Service discovery working', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'ncc-3', item: 'PM2 Processes - All core services running', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'ncc-4', item: 'Docker - Containers up & healthy', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'ncc-5', item: 'Redis / Cache - Caching operational', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'ncc-6', item: 'Database - PostgreSQL connections verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'ncc-7', item: 'Network Boundary - Internal services not publicly accessible', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
    ]
  },
  {
    name: 'PMMG Nexus Recordings (Ports 4100-4199)',
    items: [
      { id: 'pnr-1', item: 'Browser-Based Studio Engine - Operational', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pnr-2', item: 'Recording - Multi-track recording functional', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pnr-3', item: 'Mixing - Mixing tools operational', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pnr-4', item: 'Mastering - Mastering pipeline verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pnr-5', item: 'IP Registration - Auto-registration working', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pnr-6', item: 'Distribution - Push to platforms operational', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pnr-7', item: 'Collaboration - Real-time session sharing', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pnr-8', item: 'File Management - Versioning & storage verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pnr-9', item: 'Roles - Artist / Producer / Engineer / Label access', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pnr-10', item: 'Monitoring - PM2 health & logs operational', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
    ]
  },
  {
    name: 'Rise Sacramento: VoicesOfThe916',
    items: [
      { id: 'rsv-1', item: 'Live Streaming - Setup verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-2', item: 'Virtual Showcases - Multi-artist sessions operational', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-3', item: 'Audience Interaction - Chat/Q&A functional', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-4', item: 'Performance Recording - Recording & replay verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-5', item: 'Media Upload - Audio/video upload working', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-6', item: 'Cloud Storage - Version history operational', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-7', item: 'Analytics - Audience engagement metrics tracking', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-8', item: 'Security - Artist login / OAuth / MFA verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-9', item: 'Performance Testing - Load testing for audience completed', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'rsv-10', item: 'Streaming Quality - Latency / quality verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
    ]
  },
  {
    name: 'Other Platforms (14 Additional Platforms)',
    items: [
      { id: 'op-1', item: 'Platform 1 - Deployment verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'op-2', item: 'Platform 2 - Deployment verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'op-3', item: 'Platform 3 - Deployment verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'op-4', item: 'Platform 4 - Deployment verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'op-5', item: 'Platform 5 - Deployment verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'op-6', item: 'Platform 6 - Deployment verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'op-7', item: 'Platform 7 - Deployment verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'op-8', item: 'Platform 8 - Deployment verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'op-9', item: 'Platform 9 - Deployment verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'op-10', item: 'Platform 10 - Deployment verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'op-11', item: 'Platform 11 - Deployment verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'op-12', item: 'Platform 12 - Deployment verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'op-13', item: 'Platform 13 - Deployment verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'op-14', item: 'Platform 14 - Deployment verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'op-15', item: 'All 14 Platforms - Licensing automation verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
    ]
  },
  {
    name: 'Licensing & IP Management (Ports 4200-4299)',
    items: [
      { id: 'lipm-1', item: 'License Server - Connectivity verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'lipm-2', item: 'IP Registration - Auto-registration operational', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'lipm-3', item: 'Royalty Splits - Correct calculation verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'lipm-4', item: 'Contract Templates - Functional & accurate', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'lipm-5', item: 'Licensing Automation - Hooks working globally', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
    ]
  },
  {
    name: 'Distribution & Monetization (Ports 4300-4399)',
    items: [
      { id: 'dm-1', item: 'Distribution Services - Upload / Display verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'dm-2', item: 'Streaming Partners - Integration tested', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'dm-3', item: 'Payments - Payouts & splits verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'dm-4', item: 'Release Scheduling - Auto/manual release tested', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'dm-5', item: 'Analytics - Dashboard accurate & operational', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
    ]
  },
  {
    name: 'Security & Compliance',
    items: [
      { id: 'sc-1', item: 'HTTPS - All endpoints secured', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'sc-2', item: 'Data Encryption - Rest & transit verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'sc-3', item: 'Authentication - OAuth / SSO / MFA operational', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'sc-4', item: 'Audit Logs - Activity tracking verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'sc-5', item: 'Vulnerability Scan - Penetration tests passed', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'sc-6', item: 'Security Compliance - Global standards met', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
    ]
  },
  {
    name: 'Performance & Global Access',
    items: [
      { id: 'pl-1', item: 'Stress Test - Concurrent users verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pl-2', item: 'Latency Test - Real-time audio/video acceptable', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pl-3', item: 'Throughput - Large file upload/download verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pl-4', item: 'Auto-scaling - Dynamic scaling operational', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pl-5', item: 'CDN / Media Delivery - Global performance verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'pl-6', item: 'Global Access - Worldwide availability confirmed', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
    ]
  },
  {
    name: 'Backup & Disaster Recovery',
    items: [
      { id: 'bdr-1', item: 'Backup Verification - Daily DB / media backups', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'bdr-2', item: 'Restore Test - Full system restore verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'bdr-3', item: 'Redundancy - Failover tested', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'bdr-4', item: 'Incident Response - Documented & tested', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
    ]
  },
  {
    name: 'Global Launch Sign-Off (Final Approval)',
    items: [
      { id: 'gls-1', item: 'E2E Workflow - Create → Record → License → Distribute → Monetize', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'gls-2', item: 'Nexus Stream Entrypoint - Public routing confirmed on Port 3000', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'gls-3', item: 'PMMG Nexus Recordings - Fully operational & verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'gls-4', item: 'Licensing & IP Automation - Globally verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'gls-5', item: 'Distribution & Payouts - Verified & operational', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'gls-6', item: 'Security & Compliance - Passed all checks', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'gls-7', item: 'Performance & Global Access - Verified worldwide', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'gls-8', item: 'All 16 Platforms - Operational & verified', status: false, notes: '', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'gls-9', item: 'THIIO Independence - Self-sufficient operation confirmed', status: false, notes: 'No external dependency required', assignedTo: 'Trae', verifiedDate: '' },
      { id: 'gls-10', item: 'Final QA Sign-Off - Trae / QA Lead Approval', status: false, notes: 'GREENLIT / BLOCKED status', assignedTo: 'Trae', verifiedDate: '' },
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
        pf_version: "1.1",
        pf_name: "Nexus COS Global Launch Verification",
        total_platforms: "16",
        core_platforms: ["Nexus Stream", "Nexus COS Core", "PMMG Nexus Recordings", "Rise Sacramento", "Other 14 Platforms"],
        thiio_independent: true,
        execution_owner: "Trae",
        entrypoint: {
          platform: "Nexus Stream",
          port: 3000,
          fallback: 3001,
          public: true
        }
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
          <p className="subtitle">PF v1.1 - Agent-Executable Launch Verification (THIIO Independent)</p>
          <p className="thiio-version">16-Platform Stack | Entrypoint: Nexus Stream (Port 3000) | Execution Owner: Trae</p>
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

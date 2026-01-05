import { useState, useEffect } from 'react';
import './FoundingResidents.css';

interface Tenant {
  id: number;
  name: string;
  slug: string;
  category: string;
  status: 'live' | 'active' | 'streaming';
}

const FOUNDING_RESIDENTS: Tenant[] = [
  { id: 1, name: "Club Saditty", slug: "club-saditty", category: "Entertainment & Lifestyle", status: "live" },
  { id: 2, name: "Faith Through Fitness", slug: "faith-through-fitness", category: "Health & Wellness", status: "active" },
  { id: 3, name: "Ashanti's Munch & Mingle", slug: "ashantis-munch-and-mingle", category: "Food & Community", status: "live" },
  { id: 4, name: "Ro Ro's Gamers Lounge", slug: "ro-ros-gamers-lounge", category: "Gaming & Esports", status: "streaming" },
  { id: 5, name: "IDH-Live!", slug: "idh-live", category: "Talk & Discussion", status: "active" },
  { id: 6, name: "Clocking T. Wit Ya Gurl P", slug: "clocking-t", category: "Urban Entertainment", status: "live" },
  { id: 7, name: "Tyshawn's V-Dance Studio", slug: "tyshawn-dance-studio", category: "Dance & Performing Arts", status: "active" },
  { id: 8, name: "Fayeloni-Kreations", slug: "fayeloni-kreations", category: "Creative Arts", status: "live" },
  { id: 9, name: "Sassie Lashes", slug: "sassie-lashes", category: "Beauty & Fashion", status: "active" },
  { id: 10, name: "Nee Nee & Kids", slug: "neenee-and-kids", category: "Family & Children", status: "live" },
  { id: 11, name: "Headwina's Comedy Club", slug: "headwinas-comedy-club", category: "Comedy & Entertainment", status: "streaming" },
  { id: 12, name: "Rise Sacramento 916", slug: "rise-sacramento-916", category: "Local Community", status: "active" },
  { id: 13, name: "Sheda Shay's Butter Bar", slug: "sheda-shays-butter-bar", category: "Food & Lifestyle", status: "live" },
];

export default function FoundingResidents() {
  const [showIntro, setShowIntro] = useState(true);
  const [introPhase, setIntroPhase] = useState(0);
  const [selectedTenant, setSelectedTenant] = useState<Tenant | null>(null);

  useEffect(() => {
    console.log('🚀 Founding Residents Portal Initialized | Handshake: 55-45-17');
    
    // Intro animation sequence
    const phases = [
      { delay: 0, phase: 0 },      // "A new way to create"
      { delay: 2000, phase: 1 },   // Tenants slide in
      { delay: 5000, phase: 2 },   // "Independent. Live. Creator-Owned."
      { delay: 8000, phase: 3 },   // Final lock
      { delay: 10000, phase: 4 },  // End intro
    ];

    const timers = phases.map(({ delay, phase }) =>
      setTimeout(() => {
        setIntroPhase(phase);
        if (phase === 4) setShowIntro(false);
      }, delay)
    );

    return () => timers.forEach(clearTimeout);
  }, []);

  const handleTenantClick = (tenant: Tenant) => {
    console.log(`🎯 Opening Platform: ${tenant.name}`);
    setSelectedTenant(tenant);
    
    // In production, this would navigate to the tenant's platform
    // For now, we'll use a simple feedback mechanism
    // TODO: Replace with proper routing to tenant platform (e.g., /platform/${tenant.slug})
    setTimeout(() => {
      // Temporary alert for demonstration - replace with navigation in production
      const message = `🚀 Opening ${tenant.name}\n\nCategory: ${tenant.category}\nStatus: ${tenant.status.toUpperCase()}\n\nIn production, this would navigate to their independent platform.`;
      alert(message);
      setSelectedTenant(null);
    }, 300);
  };

  if (showIntro) {
    return (
      <div className="founding-intro">
        <div className="intro-background">
          <div className="cosmic-orb orb-1"></div>
          <div className="cosmic-orb orb-2"></div>
          <div className="cosmic-orb orb-3"></div>
        </div>
        
        <div className="intro-content">
          {introPhase >= 0 && (
            <h1 className={`intro-text phase-0 ${introPhase >= 0 ? 'active' : ''}`}>
              A new way to create.
            </h1>
          )}
          
          {introPhase >= 1 && (
            <div className={`intro-tenants-preview ${introPhase >= 1 ? 'active' : ''}`}>
              {FOUNDING_RESIDENTS.slice(0, 5).map((tenant, index) => (
                <div 
                  key={tenant.id} 
                  className="intro-tenant-card"
                  style={{ animationDelay: `${index * 0.15}s` }}
                >
                  <div className="tenant-glow-pulse"></div>
                  <span className="tenant-mini-name">{tenant.name}</span>
                </div>
              ))}
            </div>
          )}
          
          {introPhase >= 2 && (
            <div className={`intro-text phase-2 ${introPhase >= 2 ? 'active' : ''}`}>
              <p className="intro-attribute">Independent</p>
              <p className="intro-attribute">Live</p>
              <p className="intro-attribute">Creator-Owned</p>
            </div>
          )}
          
          {introPhase >= 3 && (
            <div className={`intro-text phase-3 ${introPhase >= 3 ? 'active' : ''}`}>
              <h2 className="intro-final-title">Founding Residents</h2>
              <p className="intro-final-subtitle">Powered by a Creative Operating System</p>
            </div>
          )}
        </div>
      </div>
    );
  }

  return (
    <div className="founding-residents">
      {/* Animated cosmic background */}
      <div className="cosmic-background">
        <div className="cosmic-orb orb-1"></div>
        <div className="cosmic-orb orb-2"></div>
        <div className="cosmic-orb orb-3"></div>
        <div className="cosmic-grid"></div>
      </div>

      {/* Hero Section */}
      <section className="residents-hero">
        <div className="hero-badge">
          <span className="badge-pulse"></span>
          FOUNDING RESIDENTS
        </div>
        
        <h1 className="residents-title">
          Meet the Founding Residents<br/>
          <span className="title-gradient">of a New Creative Era</span>
        </h1>
        
        <p className="residents-subtitle">
          These are independent creator platforms — each live, autonomous, and streaming —<br/>
          powered by a single Creative Operating System.
        </p>
        
        <div className="hook-container">
          <p className="one-line-hook">Not channels. Not pages. <span className="hook-emphasis">Platforms.</span></p>
        </div>

        <div className="stats-bar">
          <div className="stat-item">
            <span className="stat-number">13</span>
            <span className="stat-label">Live Platforms</span>
          </div>
          <div className="stat-divider"></div>
          <div className="stat-item">
            <span className="stat-number">∞</span>
            <span className="stat-label">Streaming Hours</span>
          </div>
          <div className="stat-divider"></div>
          <div className="stat-item">
            <span className="stat-number">1</span>
            <span className="stat-label">Operating System</span>
          </div>
        </div>
      </section>

      {/* Tenant Grid */}
      <section className="residents-grid-section">
        <h2 className="grid-title">
          13 Live Creator Platforms
          <span className="grid-subtitle">Entertainment • Wellness • Gaming • Food • Community • Culture</span>
        </h2>

        <div className="residents-grid">
          {FOUNDING_RESIDENTS.map((tenant, index) => (
            <div 
              key={tenant.id}
              className={`resident-card ${selectedTenant?.id === tenant.id ? 'selected' : ''}`}
              onClick={() => handleTenantClick(tenant)}
              style={{ animationDelay: `${index * 0.08}s` }}
            >
              {/* Animated glow border */}
              <div className="card-glow-border"></div>
              
              {/* Soft pulse effect */}
              <div className="card-pulse-effect"></div>
              
              {/* Live indicator */}
              <div className={`live-indicator ${tenant.status}`}>
                <span className="live-dot"></span>
                <span className="live-text">{tenant.status.toUpperCase()}</span>
              </div>

              {/* Card content */}
              <div className="card-content">
                <div className="card-icon">
                  {/* Dynamic icon based on category */}
                  <div className="icon-pulse"></div>
                  {getCategoryIcon(tenant.category)}
                </div>
                
                <h3 className="resident-name">{tenant.name}</h3>
                <p className="resident-category">{tenant.category}</p>
                
                <div className="card-footer">
                  <span className="platform-badge">INDEPENDENT PLATFORM</span>
                  <svg className="arrow-icon" width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
                    <path d="M10 0L8.59 1.41L15.17 8H0v2h15.17l-6.58 6.59L10 18l8-8z"/>
                  </svg>
                </div>
              </div>

              {/* Hover effect overlay */}
              <div className="card-hover-overlay">
                <p className="hover-text">Launch Platform →</p>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Platform Features */}
      <section className="platform-features">
        <h2 className="features-title">Each resident operates their own:</h2>
        <div className="features-grid">
          <div className="feature-item">
            <div className="feature-icon">🎥</div>
            <p>Streaming experience</p>
          </div>
          <div className="feature-item">
            <div className="feature-icon">👥</div>
            <p>Audience space</p>
          </div>
          <div className="feature-item">
            <div className="feature-icon">✨</div>
            <p>Creative identity</p>
          </div>
        </div>
        <p className="features-note">All powered by the same core system.</p>
      </section>

      {/* Call to Action */}
      <section className="cta-section">
        <div className="cta-content">
          <h2 className="cta-title">This is not a network.</h2>
          <h2 className="cta-title">This is not a directory.</h2>
          <h2 className="cta-title-emphasis">This is a Creative Operating System.</h2>
          
          <div className="cta-tagline">
            <p className="tagline-lg">Thirteen creators.</p>
            <p className="tagline-lg">Thirteen platforms.</p>
            <p className="tagline-lg">One creative operating system.</p>
          </div>
        </div>
      </section>
    </div>
  );
}

// Helper function to get category-specific icons
function getCategoryIcon(category: string): JSX.Element {
  const iconMap: { [key: string]: string } = {
    'Entertainment & Lifestyle': '🎭',
    'Health & Wellness': '💪',
    'Food & Community': '🍽️',
    'Gaming & Esports': '🎮',
    'Talk & Discussion': '🎙️',
    'Urban Entertainment': '🎵',
    'Dance & Performing Arts': '💃',
    'Creative Arts': '🎨',
    'Beauty & Fashion': '💄',
    'Family & Children': '👨‍👩‍👧‍👦',
    'Comedy & Entertainment': '😂',
    'Local Community': '🏙️',
    'Food & Lifestyle': '🍰',
  };

  const emoji = iconMap[category] || '⭐';
  
  return <span className="category-emoji">{emoji}</span>;
}

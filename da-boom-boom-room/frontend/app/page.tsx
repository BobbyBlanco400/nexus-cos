'use client'

import React, { useState } from 'react'
import Link from 'next/link'
import { cn } from '@/lib/utils'

export default function HomePage() {
  // Mock user state for demo
  const [user, setUser] = useState<any>(null)
  const [activeTab, setActiveTab] = useState<'streams' | 'subscriptions'>('streams')

  return (
    <div className="min-h-screen bg-club-dark">
      {/* Hero Section */}
      <div className="relative overflow-hidden">
        {/* Background Effects */}
        <div className="absolute inset-0">
          <div className="absolute inset-0 bg-gradient-to-br from-black via-purple-900/20 to-black" />
          <div className="absolute inset-0 bg-[radial-gradient(circle_at_50%_50%,rgba(255,0,128,0.1),transparent_50%)]" />
          <div className="absolute inset-0 bg-[radial-gradient(circle_at_80%_20%,rgba(128,0,255,0.1),transparent_50%)]" />
          <div className="absolute inset-0 bg-[radial-gradient(circle_at_20%_80%,rgba(0,128,255,0.1),transparent_50%)]" />
        </div>

        {/* Navigation Header */}
        <div className="nav-header relative z-10">
          <div className="max-w-7xl mx-auto px-4 py-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-4">
                <img 
                  src="/images/nexus-cos-logo.svg" 
                  alt="Nexus COS" 
                  className="nexus-logo h-12 w-auto"
                />
              <div className="text-white">
                <div className="text-sm opacity-75">Powered by</div>
                <div className="font-bold">NEXUS COS</div>
              </div>
            </div>
            <div className="flex items-center space-x-4">
              {!user ? (
                <button 
                  onClick={() => setUser({ name: 'Demo User', tier: 'vip' })}
                  className="bg-gradient-to-r from-pink-500 to-purple-500 text-white px-6 py-2 rounded-full text-sm font-bold hover:from-pink-600 hover:to-purple-600 transition-all duration-300"
                >
                  Sign In
                </button>
              ) : (
                <div className="text-white">
                  Welcome, {user.name}
                </div>
              )}
             </div>
           </div>
         </div>
        </div>

        {/* Hero Content */}
        <div className="relative z-10 max-w-7xl mx-auto px-4 py-16">
          <div className="text-center">
            <h1 className="text-6xl md:text-8xl font-display font-bold gradient-text mb-6 floating-animation">
              Da Boom Boom Room
            </h1>
            <p className="text-xl md:text-2xl text-gray-300 mb-8 max-w-3xl mx-auto">
              Experience the world's first virtual strip club with live streaming, VR experiences, 
              tiered subscriptions, and virtual tipping
            </p>
            
            {/* Feature Highlights */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-12">
              <div className="glass-effect rounded-lg p-6 text-center">
                <div className="text-4xl mb-3">🎭</div>
                <h3 className="text-lg font-semibold text-white mb-2">Live Streaming</h3>
                <p className="text-gray-400 text-sm">HD quality live performances</p>
              </div>
              <div className="glass-effect rounded-lg p-6 text-center">
                <div className="text-4xl mb-3">🥽</div>
                <h3 className="text-lg font-semibold text-white mb-2">VR Experience</h3>
                <p className="text-gray-400 text-sm">Immersive 360° virtual reality</p>
              </div>
              <div className="glass-effect rounded-lg p-6 text-center">
                <div className="text-4xl mb-3">👑</div>
                <h3 className="text-lg font-semibold text-white mb-2">Tier System</h3>
                <p className="text-gray-400 text-sm">5 exclusive membership levels</p>
              </div>
              <div className="glass-effect rounded-lg p-6 text-center">
                <div className="text-4xl mb-3">💰</div>
                <h3 className="text-lg font-semibold text-white mb-2">Virtual Tipping</h3>
                <p className="text-gray-400 text-sm">Interactive wallet system</p>
              </div>
            </div>

            {/* CTA Buttons */}
            <div className="flex flex-col sm:flex-row items-center justify-center space-y-4 sm:space-y-0 sm:space-x-6">
              {!user ? (
                <>
                  <button 
                    onClick={() => setUser({ name: 'Demo User', tier: 'vip' })}
                    className="club-button text-lg px-8 py-4"
                  >
                    Sign Up Free (Demo)
                  </button>
                  <div className="flex gap-4">
                    <Link 
                      href="/streams"
                      className="bg-gradient-to-r from-cyan-500 to-blue-500 text-white px-8 py-4 rounded-full text-lg font-bold hover:from-cyan-600 hover:to-blue-600 transition-all duration-300 shadow-lg hover:shadow-cyan-500/25"
                    >
                      🎭 Live Streams
                    </Link>
                    <Link 
                      href="/subscription"
                      className="bg-gradient-to-r from-pink-500 to-purple-500 text-white px-8 py-4 rounded-full text-lg font-bold hover:from-pink-600 hover:to-purple-600 transition-all duration-300 shadow-lg hover:shadow-pink-500/25"
                    >
                      View Membership Tiers
                    </Link>
                  </div>
                </>
              ) : (
                <button 
                  onClick={() => setActiveTab('streams')}
                  className="club-button text-lg px-8 py-4"
                >
                  Enter the Club
                </button>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Navigation Tabs */}
      {user && (
        <div className="bg-black/50 backdrop-blur-sm border-b border-white/10">
          <div className="max-w-7xl mx-auto px-4">
            <div className="flex space-x-1">
              <button
                onClick={() => setActiveTab('streams')}
                className={cn(
                  'px-6 py-4 font-semibold transition-all duration-300',
                  activeTab === 'streams'
                    ? 'text-neon-pink border-b-2 border-neon-pink'
                    : 'text-gray-400 hover:text-white'
                )}
              >
                Live Streams
              </button>
              <button
                onClick={() => setActiveTab('subscriptions')}
                className={cn(
                  'px-6 py-4 font-semibold transition-all duration-300',
                  activeTab === 'subscriptions'
                    ? 'text-neon-pink border-b-2 border-neon-pink'
                    : 'text-gray-400 hover:text-white'
                )}
              >
                Subscriptions
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Main Content */}
      {user ? (
        <div className="max-w-7xl mx-auto px-4 py-16">
          <div className="text-center">
            <h2 className="text-4xl font-display font-bold gradient-text mb-8">
              {activeTab === 'streams' ? 'Live Streams' : 'Subscription Tiers'}
            </h2>
            <div className="glass-dark rounded-lg p-12">
              <p className="text-gray-300 text-lg mb-4">
                {activeTab === 'streams' 
                  ? 'Welcome to the live streaming experience! VR streams, interactive tipping, and exclusive content await.'
                  : 'Choose your membership tier and unlock exclusive features, VR access, and premium content.'}
              </p>
              <button 
                onClick={() => setUser(null)}
                className="club-button"
              >
                Sign Out (Demo)
              </button>
            </div>
          </div>
        </div>
      ) : (
        <div className="max-w-7xl mx-auto px-4 py-16">
          {/* Features Section */}
          <div className="text-center mb-16">
            <h2 className="text-4xl font-display font-bold gradient-text mb-8">
              Revolutionary Features
            </h2>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              <div className="glass-dark rounded-lg p-8">
                <div className="text-5xl mb-4">🎪</div>
                <h3 className="text-xl font-semibold text-white mb-4">Multiple Stages</h3>
                <p className="text-gray-300">
                  From Main Stage public shows to exclusive Black Card private experiences
                </p>
              </div>
              <div className="glass-dark rounded-lg p-8">
                <div className="text-5xl mb-4">🌐</div>
                <h3 className="text-xl font-semibold text-white mb-4">360° Streaming</h3>
                <p className="text-gray-300">
                  Immersive 360-degree video with interactive controls and VR support
                </p>
              </div>
              <div className="glass-dark rounded-lg p-8">
                <div className="text-5xl mb-4">🏆</div>
                <h3 className="text-xl font-semibold text-white mb-4">Gamified Tipping</h3>
                <p className="text-gray-300">
                  Leaderboards, animated effects, and exclusive rewards for top tippers
                </p>
              </div>
              <div className="glass-dark rounded-lg p-8">
                <div className="text-5xl mb-4">💎</div>
                <h3 className="text-xl font-semibold text-white mb-4">NFT Membership</h3>
                <p className="text-gray-300">
                  Black Card tier includes exclusive NFT membership with special perks
                </p>
              </div>
              <div className="glass-dark rounded-lg p-8">
                <div className="text-5xl mb-4">🔒</div>
                <h3 className="text-xl font-semibold text-white mb-4">Secure Payments</h3>
                <p className="text-gray-300">
                  Stripe integration for secure subscriptions and wallet deposits
                </p>
              </div>
              <div className="glass-dark rounded-lg p-8">
                <div className="text-5xl mb-4">📱</div>
                <h3 className="text-xl font-semibold text-white mb-4">Mobile Optimized</h3>
                <p className="text-gray-300">
                  Responsive design with dark mode and mobile-friendly controls
                </p>
              </div>
            </div>
          </div>

          {/* Subscription Preview */}
          <div className="text-center mb-16">
            <h2 className="text-4xl font-display font-bold gradient-text mb-8">
              Membership Tiers
            </h2>
            <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
              {[
                { name: 'Floor Pass', icon: '🎫', color: 'from-green-500 to-emerald-600', price: '$9.99' },
                { name: 'Backstage Pass', icon: '🎭', color: 'from-blue-500 to-cyan-600', price: '$19.99' },
                { name: 'VIP Lounge', icon: '👑', color: 'from-purple-500 to-violet-600', price: '$39.99' },
                { name: 'Champagne Room', icon: '🥂', color: 'from-yellow-500 to-orange-600', price: '$79.99' },
                { name: 'Black Card', icon: '💎', color: 'from-gray-700 to-black', price: '$199.99' }
              ].map((tier) => (
                <div key={tier.name} className="glass-dark rounded-lg p-6 text-center">
                  <div className="text-4xl mb-3">{tier.icon}</div>
                  <h3 className="text-lg font-semibold text-white mb-2">{tier.name}</h3>
                  <p className="text-2xl font-bold gradient-text">{tier.price}</p>
                  <p className="text-gray-400 text-sm">/month</p>
                </div>
              ))}
            </div>
          </div>

          {/* Call to Action */}
          <div className="text-center">
            <div className="glass-dark rounded-lg p-12 max-w-2xl mx-auto">
              <h2 className="text-3xl font-display font-bold gradient-text mb-4">
                Ready to Experience the Future?
              </h2>
              <p className="text-gray-300 mb-8">
                Join thousands of members already enjoying premium adult entertainment 
                with cutting-edge technology.
              </p>
              <div className="space-y-4">
                <button className="club-button text-lg px-8 py-4 w-full sm:w-auto">
                  Start Free Trial
                </button>
                <p className="text-gray-400 text-sm">
                  18+ only • Secure & Private • Cancel Anytime
                </p>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Footer */}
      <footer className="bg-black/80 border-t border-white/10 mt-20">
        <div className="max-w-7xl mx-auto px-4 py-12">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div>
              <h3 className="text-xl font-display font-bold gradient-text mb-4">
                Da Boom Boom Room
              </h3>
              <p className="text-gray-400 text-sm">
                The world's first virtual strip club powered by Nexus COS architecture.
              </p>
            </div>
            <div>
              <h4 className="text-white font-semibold mb-4">Features</h4>
              <ul className="space-y-2 text-gray-400 text-sm">
                <li>Live Streaming</li>
                <li>VR Experience</li>
                <li>Virtual Tipping</li>
                <li>NFT Membership</li>
              </ul>
            </div>
            <div>
              <h4 className="text-white font-semibold mb-4">Support</h4>
              <ul className="space-y-2 text-gray-400 text-sm">
                <li>Help Center</li>
                <li>Contact Us</li>
                <li>Privacy Policy</li>
                <li>Terms of Service</li>
              </ul>
            </div>
            <div>
              <h4 className="text-white font-semibold mb-4">Connect</h4>
              <ul className="space-y-2 text-gray-400 text-sm">
                <li>Twitter</li>
                <li>Discord</li>
                <li>Telegram</li>
                <li>Newsletter</li>
              </ul>
            </div>
          </div>
          <div className="border-t border-white/10 mt-8 pt-8 text-center">
            <p className="text-gray-400 text-sm">
              © 2024 Da Boom Boom Room. All rights reserved. 18+ only.
            </p>
          </div>
        </div>
      </footer>
    </div>
  )
}
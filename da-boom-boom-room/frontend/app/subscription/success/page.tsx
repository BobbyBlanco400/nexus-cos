'use client'

import React, { useEffect, useState } from 'react'
import Link from 'next/link'
import { useSearchParams } from 'next/navigation'
import { getTierById } from '@/lib/subscription-tiers'

export default function SubscriptionSuccessPage() {
  const searchParams = useSearchParams()
  const [sessionId, setSessionId] = useState<string | null>(null)
  const [tierInfo, setTierInfo] = useState<any>(null)

  useEffect(() => {
    const sessionIdParam = searchParams.get('session_id')
    const tierParam = searchParams.get('tier')
    
    setSessionId(sessionIdParam)
    
    if (tierParam) {
      const tier = getTierById(tierParam)
      setTierInfo(tier)
    }
  }, [searchParams])

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-purple-900 to-black flex items-center justify-center p-4">
      <div className="max-w-2xl mx-auto text-center">
        {/* Success Animation */}
        <div className="mb-8">
          <div className="w-24 h-24 mx-auto mb-6 rounded-full bg-gradient-to-r from-green-400 to-emerald-500 flex items-center justify-center">
            <svg className="w-12 h-12 text-white" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
            </svg>
          </div>
          <h1 className="text-5xl font-bold bg-gradient-to-r from-green-400 to-emerald-500 bg-clip-text text-transparent mb-4">
            Welcome to the Club!
          </h1>
          <p className="text-xl text-gray-300">
            Your subscription has been successfully activated
          </p>
        </div>

        {/* Tier Information */}
        {tierInfo && (
          <div className="bg-gray-800/50 backdrop-blur-sm rounded-2xl p-8 mb-8 border border-gray-700">
            <div className="flex items-center justify-center mb-4">
              <span className="text-4xl mr-3">{tierInfo.icon}</span>
              <h2 className="text-3xl font-bold text-white">{tierInfo.name}</h2>
            </div>
            <p className="text-gray-300 mb-6">{tierInfo.description}</p>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="bg-gray-700/50 rounded-lg p-4">
                <h3 className="text-lg font-semibold text-white mb-2">What's Included:</h3>
                <ul className="text-sm text-gray-300 space-y-1">
                  {tierInfo.features.slice(0, 3).map((feature: string, index: number) => (
                    <li key={index} className="flex items-center">
                      <span className="w-2 h-2 bg-green-400 rounded-full mr-2"></span>
                      {feature}
                    </li>
                  ))}
                  {tierInfo.features.length > 3 && (
                    <li className="text-gray-400 italic">+ {tierInfo.features.length - 3} more features</li>
                  )}
                </ul>
              </div>
              
              <div className="bg-gray-700/50 rounded-lg p-4">
                <h3 className="text-lg font-semibold text-white mb-2">Next Steps:</h3>
                <ul className="text-sm text-gray-300 space-y-1">
                  <li className="flex items-center">
                    <span className="w-2 h-2 bg-purple-400 rounded-full mr-2"></span>
                    Explore exclusive content
                  </li>
                  <li className="flex items-center">
                    <span className="w-2 h-2 bg-purple-400 rounded-full mr-2"></span>
                    Join VIP chat rooms
                  </li>
                  <li className="flex items-center">
                    <span className="w-2 h-2 bg-purple-400 rounded-full mr-2"></span>
                    Access premium features
                  </li>
                </ul>
              </div>
            </div>
          </div>
        )}

        {/* Session Information */}
        {sessionId && (
          <div className="bg-gray-800/30 rounded-lg p-4 mb-8">
            <p className="text-sm text-gray-400">
              Transaction ID: <span className="font-mono text-gray-300">{sessionId}</span>
            </p>
          </div>
        )}

        {/* Action Buttons */}
        <div className="flex flex-col sm:flex-row gap-4 justify-center">
          <Link href="/">
            <button className="bg-gradient-to-r from-purple-600 to-cyan-600 hover:from-purple-700 hover:to-cyan-700 text-white font-bold py-4 px-8 rounded-full text-lg transition-all duration-200 transform hover:scale-105">
              Start Exploring
            </button>
          </Link>
          
          <Link href="/subscription">
            <button className="bg-gray-700 hover:bg-gray-600 text-white font-bold py-4 px-8 rounded-full text-lg transition-all duration-200">
              Manage Subscription
            </button>
          </Link>
        </div>

        {/* Support Information */}
        <div className="mt-12 text-center">
          <p className="text-gray-400 mb-2">
            Need help? Contact our support team 24/7
          </p>
          <div className="flex justify-center space-x-6 text-sm text-gray-500">
            <span>📧 support@daboomroom.com</span>
            <span>💬 Live Chat</span>
            <span>📞 1-800-BOOM-ROOM</span>
          </div>
        </div>
      </div>
    </div>
  )
}
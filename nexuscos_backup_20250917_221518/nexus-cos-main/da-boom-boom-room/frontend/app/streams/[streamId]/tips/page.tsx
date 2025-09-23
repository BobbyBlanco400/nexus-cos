'use client'

import { useState, useEffect } from 'react'
import { useParams, useRouter } from 'next/navigation'
import { TippingService, TIP_OPTIONS, type TipWallet, type Performer, type TipTransaction } from '@/lib/tipping-system'
import { AccessControlService, type User } from '@/lib/access-control'

// Mock user - in real app, this would come from auth context
const mockUser: User = {
  id: '1',
  name: 'Demo User',
  email: 'demo@example.com',
  tier: 3, // VIP Lounge
  subscriptionStatus: 'active'
}

export default function TipsPage() {
  const params = useParams()
  const router = useRouter()
  const streamId = params.streamId as string
  
  const [user] = useState<User>(mockUser)
  const [wallet, setWallet] = useState<TipWallet | null>(null)
  const [performers, setPerformers] = useState<Performer[]>([])
  const [selectedPerformer, setSelectedPerformer] = useState<Performer | null>(null)
  const [customAmount, setCustomAmount] = useState('')
  const [tipMessage, setTipMessage] = useState('')
  const [recentTips, setRecentTips] = useState<TipTransaction[]>([])
  const [leaderboard, setLeaderboard] = useState<any[]>([])
  const [showAddCredits, setShowAddCredits] = useState(false)
  const [creditAmount, setCreditAmount] = useState('')
  const [isProcessing, setIsProcessing] = useState(false)
  const [lastTipAnimation, setLastTipAnimation] = useState<string | null>(null)

  useEffect(() => {
    // Check stream access
    const access = AccessControlService.checkStreamAccess(user, streamId)
    if (!access.hasAccess) {
      router.push('/streams')
      return
    }

    // Load wallet and performers
    const userWallet = TippingService.getWallet(user.id)
    const streamPerformers = TippingService.getPerformersInStream(streamId)
    const tips = TippingService.getRecentTips(streamId, 20)
    const board = TippingService.getTipLeaderboard(streamId, 'daily')
    
    setWallet(userWallet)
    setPerformers(streamPerformers)
    setSelectedPerformer(streamPerformers[0] || null)
    setRecentTips(tips)
    setLeaderboard(board)
  }, [user.id, streamId, router])

  const handleAddCredits = async () => {
    if (!creditAmount || isProcessing) return
    
    setIsProcessing(true)
    const result = await TippingService.addCredits(user.id, parseFloat(creditAmount))
    
    if (result.success) {
      const updatedWallet = TippingService.getWallet(user.id)
      setWallet(updatedWallet)
      setCreditAmount('')
      setShowAddCredits(false)
      alert(`Successfully added $${creditAmount} to your wallet!`)
    } else {
      alert(`Failed to add credits: ${result.error}`)
    }
    
    setIsProcessing(false)
  }

  const handleSendTip = async (amount: number) => {
    if (!selectedPerformer || isProcessing) return
    
    setIsProcessing(true)
    const result = await TippingService.sendTip({
      fromUserId: user.id,
      toPerformerId: selectedPerformer.id,
      amount,
      message: tipMessage || undefined,
      streamId
    })
    
    if (result.success) {
      const updatedWallet = TippingService.getWallet(user.id)
      const updatedTips = TippingService.getRecentTips(streamId, 20)
      const updatedBoard = TippingService.getTipLeaderboard(streamId, 'daily')
      
      setWallet(updatedWallet)
      setRecentTips(updatedTips)
      setLeaderboard(updatedBoard)
      setTipMessage('')
      
      if (result.animation) {
        setLastTipAnimation(result.animation)
        setTimeout(() => setLastTipAnimation(null), 3000)
      }
      
      alert(`Tip sent successfully! 🎉`)
    } else {
      alert(`Failed to send tip: ${result.error}`)
    }
    
    setIsProcessing(false)
  }

  const quickTipAmounts = TippingService.getQuickTipAmounts(user.tier)
  const tipLimits = AccessControlService.getTipLimits(user)

  if (!wallet) {
    return (
      <div className="min-h-screen bg-black text-white flex items-center justify-center">
        <div className="text-center">
          <div className="text-4xl mb-4">💰</div>
          <div className="text-xl">Loading wallet...</div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-black text-white">
      {/* Header */}
      <div className="bg-gradient-to-r from-green-900 via-emerald-900 to-teal-900 p-6">
        <div className="max-w-7xl mx-auto">
          <div className="flex justify-between items-center">
            <div>
              <h1 className="text-4xl font-bold bg-gradient-to-r from-green-400 to-emerald-400 bg-clip-text text-transparent">
                💰 Virtual Tipping
              </h1>
              <p className="text-gray-300 mt-2">
                Support your favorite performers in {streamId.replace('-', ' ')}
              </p>
            </div>
            <button
              onClick={() => router.back()}
              className="bg-black/30 hover:bg-black/50 px-4 py-2 rounded-lg transition-all"
            >
              ← Back to Stream
            </button>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto p-6">
        <div className="grid lg:grid-cols-3 gap-8">
          {/* Wallet & Tipping */}
          <div className="lg:col-span-2 space-y-6">
            {/* Wallet Balance */}
            <div className="bg-gray-900 rounded-xl p-6 border border-green-500/30">
              <div className="flex justify-between items-center mb-4">
                <h2 className="text-2xl font-bold text-green-400">💳 Your Wallet</h2>
                <button
                  onClick={() => setShowAddCredits(true)}
                  className="bg-gradient-to-r from-green-500 to-emerald-500 text-white px-4 py-2 rounded-lg font-bold hover:from-green-600 hover:to-emerald-600 transition-all"
                >
                  + Add Credits
                </button>
              </div>
              
              <div className="grid grid-cols-3 gap-4">
                <div className="bg-black/30 rounded-lg p-4 text-center">
                  <div className="text-2xl font-bold text-green-400">${wallet.balance.toFixed(2)}</div>
                  <div className="text-gray-400 text-sm">Available Balance</div>
                </div>
                <div className="bg-black/30 rounded-lg p-4 text-center">
                  <div className="text-2xl font-bold text-yellow-400">${wallet.dailySpent.toFixed(2)}</div>
                  <div className="text-gray-400 text-sm">Today's Tips</div>
                </div>
                <div className="bg-black/30 rounded-lg p-4 text-center">
                  <div className="text-2xl font-bold text-purple-400">{wallet.transactions.filter(t => t.type === 'tip').length}</div>
                  <div className="text-gray-400 text-sm">Total Tips</div>
                </div>
              </div>
              
              {tipLimits.dailyLimit && (
                <div className="mt-4 bg-yellow-500/10 border border-yellow-500/30 rounded-lg p-3">
                  <div className="text-yellow-400 text-sm">
                    Daily limit: ${tipLimits.dailyLimit} | Remaining: ${(tipLimits.dailyLimit - wallet.dailySpent).toFixed(2)}
                  </div>
                </div>
              )}
            </div>

            {/* Performer Selection */}
            {performers.length > 0 && (
              <div className="bg-gray-900 rounded-xl p-6 border border-purple-500/30">
                <h2 className="text-2xl font-bold text-purple-400 mb-4">🎭 Select Performer</h2>
                
                <div className="grid gap-3">
                  {performers.map((performer) => (
                    <div
                      key={performer.id}
                      className={`border-2 rounded-lg p-4 cursor-pointer transition-all ${
                        selectedPerformer?.id === performer.id
                          ? 'border-purple-500 bg-purple-500/10'
                          : 'border-gray-600 hover:border-purple-400 hover:bg-purple-500/5'
                      }`}
                      onClick={() => setSelectedPerformer(performer)}
                    >
                      <div className="flex justify-between items-center">
                        <div>
                          <div className="font-bold text-white">{performer.displayName}</div>
                          <div className="text-gray-400 text-sm">{performer.name}</div>
                        </div>
                        <div className="text-right">
                          <div className="text-green-400 text-sm font-bold">● Online</div>
                          {performer.tipGoal && (
                            <div className="text-xs text-gray-400">
                              Goal: ${performer.tipGoalProgress}/${performer.tipGoal}
                            </div>
                          )}
                        </div>
                      </div>
                      
                      {performer.tipGoal && (
                        <div className="mt-3">
                          <div className="bg-gray-700 rounded-full h-2">
                            <div 
                              className="bg-gradient-to-r from-green-500 to-emerald-500 h-2 rounded-full transition-all"
                              style={{ width: `${Math.min(100, (performer.tipGoalProgress! / performer.tipGoal) * 100)}%` }}
                            ></div>
                          </div>
                        </div>
                      )}
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Tipping Interface */}
            {selectedPerformer && (
              <div className="bg-gray-900 rounded-xl p-6 border border-pink-500/30">
                <h2 className="text-2xl font-bold text-pink-400 mb-4">
                  💝 Send Tip to {selectedPerformer.displayName}
                </h2>
                
                {/* Quick Tip Buttons */}
                <div className="grid grid-cols-4 gap-3 mb-6">
                  {TIP_OPTIONS.filter(opt => quickTipAmounts.includes(opt.amount)).map((option) => (
                    <button
                      key={option.amount}
                      onClick={() => handleSendTip(option.amount)}
                      disabled={isProcessing || wallet.balance < option.amount}
                      className={`bg-gradient-to-r from-pink-500 to-purple-500 text-white p-4 rounded-lg font-bold transition-all hover:from-pink-600 hover:to-purple-600 disabled:opacity-50 disabled:cursor-not-allowed ${
                        lastTipAnimation === option.animation ? 'animate-bounce' : ''
                      }`}
                    >
                      <div className="text-2xl mb-1">{option.emoji}</div>
                      <div className="text-sm">${option.amount}</div>
                    </button>
                  ))}
                </div>
                
                {/* Custom Amount */}
                <div className="space-y-4">
                  <div>
                    <label className="block text-gray-400 text-sm mb-2">Custom Amount</label>
                    <input
                      type="number"
                      value={customAmount}
                      onChange={(e) => setCustomAmount(e.target.value)}
                      placeholder="Enter amount..."
                      className="w-full bg-black/30 border border-gray-600 rounded-lg px-4 py-3 text-white focus:border-pink-500 focus:outline-none"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-gray-400 text-sm mb-2">Message (Optional)</label>
                    <input
                      type="text"
                      value={tipMessage}
                      onChange={(e) => setTipMessage(e.target.value)}
                      placeholder="Add a message..."
                      className="w-full bg-black/30 border border-gray-600 rounded-lg px-4 py-3 text-white focus:border-pink-500 focus:outline-none"
                    />
                  </div>
                  
                  <button
                    onClick={() => handleSendTip(parseFloat(customAmount))}
                    disabled={isProcessing || !customAmount || wallet.balance < parseFloat(customAmount || '0')}
                    className="w-full bg-gradient-to-r from-pink-500 to-purple-500 text-white py-3 rounded-lg font-bold hover:from-pink-600 hover:to-purple-600 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {isProcessing ? 'Processing...' : `Send $${customAmount || '0'} Tip`}
                  </button>
                </div>
              </div>
            )}
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Recent Tips */}
            <div className="bg-gray-900 rounded-xl p-6 border border-blue-500/30">
              <h3 className="text-xl font-bold text-blue-400 mb-4">🎉 Recent Tips</h3>
              
              <div className="space-y-3 max-h-64 overflow-y-auto">
                {recentTips.map((tip) => {
                  const performer = TippingService.getPerformer(tip.toPerformerId!)
                  return (
                    <div key={tip.id} className="bg-black/30 rounded-lg p-3">
                      <div className="flex justify-between items-start">
                        <div className="flex-1">
                          <div className="text-white font-bold">${tip.amount}</div>
                          <div className="text-gray-400 text-sm">
                            to {performer?.displayName || 'Unknown'}
                          </div>
                          {tip.message && (
                            <div className="text-gray-300 text-xs mt-1 italic">
                              "{tip.message}"
                            </div>
                          )}
                        </div>
                        <div className="text-gray-500 text-xs">
                          {new Date(tip.timestamp).toLocaleTimeString()}
                        </div>
                      </div>
                    </div>
                  )
                })}
                
                {recentTips.length === 0 && (
                  <div className="text-center text-gray-500 py-8">
                    No recent tips
                  </div>
                )}
              </div>
            </div>

            {/* Tip Leaderboard */}
            <div className="bg-gray-900 rounded-xl p-6 border border-yellow-500/30">
              <h3 className="text-xl font-bold text-yellow-400 mb-4">🏆 Today's Top Tippers</h3>
              
              <div className="space-y-3">
                {leaderboard.slice(0, 5).map((entry, index) => (
                  <div key={entry.userId} className="flex justify-between items-center">
                    <div className="flex items-center gap-3">
                      <div className={`w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold ${
                        index === 0 ? 'bg-yellow-500 text-black' :
                        index === 1 ? 'bg-gray-400 text-black' :
                        index === 2 ? 'bg-orange-600 text-white' :
                        'bg-gray-600 text-white'
                      }`}>
                        {index + 1}
                      </div>
                      <div className="text-white">
                        {entry.userId === user.id ? 'You' : `User ${entry.userId.slice(-4)}`}
                      </div>
                    </div>
                    <div className="text-green-400 font-bold">
                      ${entry.totalTipped}
                    </div>
                  </div>
                ))}
                
                {leaderboard.length === 0 && (
                  <div className="text-center text-gray-500 py-4">
                    No tips today yet
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Add Credits Modal */}
      {showAddCredits && (
        <div className="fixed inset-0 bg-black/80 flex items-center justify-center z-50">
          <div className="bg-gray-900 rounded-xl p-6 border border-green-500/30 max-w-md w-full mx-4">
            <h3 className="text-2xl font-bold text-green-400 mb-4">💳 Add Credits</h3>
            
            <div className="space-y-4">
              <div>
                <label className="block text-gray-400 text-sm mb-2">Amount (USD)</label>
                <input
                  type="number"
                  value={creditAmount}
                  onChange={(e) => setCreditAmount(e.target.value)}
                  placeholder="Enter amount..."
                  className="w-full bg-black/30 border border-gray-600 rounded-lg px-4 py-3 text-white focus:border-green-500 focus:outline-none"
                />
              </div>
              
              <div className="grid grid-cols-3 gap-2">
                {[10, 25, 50, 100, 250, 500].map(amount => (
                  <button
                    key={amount}
                    onClick={() => setCreditAmount(amount.toString())}
                    className="bg-green-500/20 text-green-400 py-2 rounded hover:bg-green-500/30 transition-all"
                  >
                    ${amount}
                  </button>
                ))}
              </div>
              
              <div className="flex gap-3">
                <button
                  onClick={() => setShowAddCredits(false)}
                  className="flex-1 bg-gray-600 text-white py-3 rounded-lg font-bold hover:bg-gray-700 transition-all"
                >
                  Cancel
                </button>
                <button
                  onClick={handleAddCredits}
                  disabled={isProcessing || !creditAmount}
                  className="flex-1 bg-gradient-to-r from-green-500 to-emerald-500 text-white py-3 rounded-lg font-bold hover:from-green-600 hover:to-emerald-600 transition-all disabled:opacity-50"
                >
                  {isProcessing ? 'Processing...' : 'Add Credits'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
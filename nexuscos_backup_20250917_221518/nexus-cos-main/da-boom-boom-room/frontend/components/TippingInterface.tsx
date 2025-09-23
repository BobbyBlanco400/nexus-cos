'use client'

import React, { useState, useEffect } from 'react'
import { useTip } from '@/contexts/TipContext'
import { useAuth } from '@/contexts/AuthContext'
import { useSocket } from '@/contexts/SocketContext'
import { useMutation, useQuery, useQueryClient } from 'react-query'
import { api } from '@/lib/api'
import { toast } from 'react-hot-toast'
import { cn } from '@/lib/utils'

interface TippingInterfaceProps {
  performerId: string
  streamId?: string
  className?: string
}

interface TipAmount {
  amount: number
  emoji: string
  message?: string
  color: string
}

interface WalletData {
  balance: number
  currency: string
  transactions: Array<{
    id: string
    amount: number
    type: 'tip' | 'deposit' | 'withdrawal'
    createdAt: string
    description: string
  }>
}

interface TipLeaderboard {
  userId: string
  username: string
  totalTipped: number
  rank: number
}

const quickTipAmounts: TipAmount[] = [
  { amount: 5, emoji: '💋', message: 'Kiss', color: 'from-pink-500 to-red-500' },
  { amount: 10, emoji: '🌹', message: 'Rose', color: 'from-red-500 to-pink-600' },
  { amount: 25, emoji: '💎', message: 'Diamond', color: 'from-blue-400 to-cyan-500' },
  { amount: 50, emoji: '👑', message: 'Crown', color: 'from-yellow-400 to-orange-500' },
  { amount: 100, emoji: '🔥', message: 'Fire', color: 'from-orange-500 to-red-600' },
  { amount: 250, emoji: '⭐', message: 'Star', color: 'from-yellow-300 to-yellow-600' },
  { amount: 500, emoji: '🚀', message: 'Rocket', color: 'from-purple-500 to-pink-600' },
  { amount: 1000, emoji: '💰', message: 'Jackpot', color: 'from-green-400 to-emerald-600' }
]

export function TippingInterface({ performerId, streamId, className }: TippingInterfaceProps) {
  const { user } = useAuth()
  const { socket } = useSocket()
  const { sendTip, tipHistory } = useTip()
  const queryClient = useQueryClient()
  const [customAmount, setCustomAmount] = useState('')
  const [tipMessage, setTipMessage] = useState('')
  const [showWallet, setShowWallet] = useState(false)
  const [showLeaderboard, setShowLeaderboard] = useState(false)
  const [animatingTips, setAnimatingTips] = useState<Array<{ id: string; amount: number; emoji: string; x: number; y: number }>>>([])
  const [depositAmount, setDepositAmount] = useState('')

  const { data: wallet, refetch: refetchWallet } = useQuery<WalletData>(
    'wallet',
    () => api.get('/tipping/wallet').then(res => res.data),
    {
      enabled: !!user,
      refetchInterval: 30000, // Refetch every 30 seconds
    }
  )

  const { data: leaderboard } = useQuery<TipLeaderboard[]>(
    ['tip-leaderboard', performerId],
    () => api.get(`/tipping/leaderboard/${performerId}`).then(res => res.data),
    {
      enabled: !!performerId,
      refetchInterval: 60000, // Refetch every minute
    }
  )

  const tipMutation = useMutation(
    async ({ amount, message }: { amount: number; message?: string }) => {
      const response = await api.post('/tipping/send', {
        performerId,
        streamId,
        amount,
        message: message || ''
      })
      return response.data
    },
    {
      onSuccess: (data) => {
        toast.success(`Tipped $${data.amount} successfully!`)
        refetchWallet()
        queryClient.invalidateQueries(['tip-leaderboard', performerId])
        
        // Add animation
        const newTip = {
          id: Date.now().toString(),
          amount: data.amount,
          emoji: quickTipAmounts.find(t => t.amount === data.amount)?.emoji || '💝',
          x: Math.random() * 300,
          y: Math.random() * 200
        }
        setAnimatingTips(prev => [...prev, newTip])
        
        // Remove animation after 3 seconds
        setTimeout(() => {
          setAnimatingTips(prev => prev.filter(tip => tip.id !== newTip.id))
        }, 3000)
        
        // Send socket event
        if (socket) {
          socket.emit('tip_sent', {
            performerId,
            streamId,
            amount: data.amount,
            message: data.message,
            user: user?.username
          })
        }
      },
      onError: (error: any) => {
        toast.error(error.response?.data?.message || 'Failed to send tip')
      }
    }
  )

  const depositMutation = useMutation(
    async (amount: number) => {
      const response = await api.post('/tipping/deposit', { amount })
      return response.data
    },
    {
      onSuccess: (data) => {
        if (data.checkoutUrl) {
          window.open(data.checkoutUrl, '_blank')
        }
        toast.success('Redirecting to payment...')
      },
      onError: (error: any) => {
        toast.error(error.response?.data?.message || 'Failed to initiate deposit')
      }
    }
  )

  const handleQuickTip = (tipAmount: TipAmount) => {
    if (!user) {
      toast.error('Please sign in to send tips')
      return
    }

    if (!wallet || wallet.balance < tipAmount.amount) {
      toast.error('Insufficient balance. Please add funds to your wallet.')
      setShowWallet(true)
      return
    }

    tipMutation.mutate({ amount: tipAmount.amount, message: tipAmount.message })
  }

  const handleCustomTip = () => {
    const amount = parseFloat(customAmount)
    if (!amount || amount <= 0) {
      toast.error('Please enter a valid amount')
      return
    }

    if (!user) {
      toast.error('Please sign in to send tips')
      return
    }

    if (!wallet || wallet.balance < amount) {
      toast.error('Insufficient balance. Please add funds to your wallet.')
      setShowWallet(true)
      return
    }

    tipMutation.mutate({ amount, message: tipMessage })
    setCustomAmount('')
    setTipMessage('')
  }

  const handleDeposit = () => {
    const amount = parseFloat(depositAmount)
    if (!amount || amount < 5) {
      toast.error('Minimum deposit is $5')
      return
    }

    depositMutation.mutate(amount)
    setDepositAmount('')
  }

  const userRank = leaderboard?.find(entry => entry.userId === user?.id)?.rank

  return (
    <div className={cn('relative', className)}>
      {/* Animated Tips */}
      <div className="absolute inset-0 pointer-events-none z-50">
        {animatingTips.map(tip => (
          <div
            key={tip.id}
            className="absolute text-4xl tip-float"
            style={{ left: tip.x, top: tip.y }}
          >
            {tip.emoji}
          </div>
        ))}
      </div>

      {/* Main Tipping Interface */}
      <div className="glass-dark rounded-lg p-6 space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <h3 className="text-xl font-display font-bold gradient-text">
            Send Tips
          </h3>
          <div className="flex items-center space-x-2">
            <button
              onClick={() => setShowLeaderboard(!showLeaderboard)}
              className="p-2 rounded-lg bg-gray-700 hover:bg-gray-600 text-white transition-colors duration-200"
              title="Leaderboard"
            >
              🏆
            </button>
            <button
              onClick={() => setShowWallet(!showWallet)}
              className="p-2 rounded-lg bg-gray-700 hover:bg-gray-600 text-white transition-colors duration-200"
              title="Wallet"
            >
              💰
            </button>
          </div>
        </div>

        {/* Wallet Balance */}
        {user && wallet && (
          <div className="flex items-center justify-between p-3 bg-black/30 rounded-lg">
            <span className="text-gray-400">Wallet Balance:</span>
            <span className="text-neon-green font-bold text-lg">
              ${wallet.balance.toFixed(2)}
            </span>
          </div>
        )}

        {/* User Rank */}
        {userRank && (
          <div className="flex items-center justify-between p-3 bg-gradient-to-r from-yellow-500/20 to-orange-500/20 rounded-lg border border-yellow-500/30">
            <span className="text-yellow-400">Your Rank:</span>
            <span className="text-yellow-300 font-bold text-lg">
              #{userRank}
            </span>
          </div>
        )}

        {/* Quick Tip Buttons */}
        <div className="grid grid-cols-4 gap-3">
          {quickTipAmounts.map((tipAmount) => (
            <button
              key={tipAmount.amount}
              onClick={() => handleQuickTip(tipAmount)}
              disabled={tipMutation.isLoading}
              className={cn(
                'relative overflow-hidden rounded-lg p-3 text-center transition-all duration-300 transform hover:scale-105 hover:shadow-lg',
                'bg-gradient-to-br',
                tipAmount.color,
                tipMutation.isLoading && 'opacity-50 cursor-not-allowed'
              )}
            >
              <div className="text-2xl mb-1">{tipAmount.emoji}</div>
              <div className="text-white font-bold text-sm">${tipAmount.amount}</div>
              <div className="text-white/80 text-xs">{tipAmount.message}</div>
            </button>
          ))}
        </div>

        {/* Custom Tip */}
        <div className="space-y-3">
          <div className="flex space-x-2">
            <input
              type="number"
              placeholder="Custom amount"
              value={customAmount}
              onChange={(e) => setCustomAmount(e.target.value)}
              className="flex-1 px-3 py-2 bg-black/50 border border-white/20 rounded-lg text-white placeholder-gray-400 focus:border-neon-pink focus:outline-none"
              min="1"
              step="0.01"
            />
            <button
              onClick={handleCustomTip}
              disabled={tipMutation.isLoading || !customAmount}
              className={cn(
                'px-6 py-2 rounded-lg font-semibold transition-all duration-300 transform hover:scale-105',
                'bg-gradient-to-r from-neon-pink to-neon-purple text-white',
                (tipMutation.isLoading || !customAmount) && 'opacity-50 cursor-not-allowed'
              )}
            >
              {tipMutation.isLoading ? (
                <div className="flex items-center">
                  <div className="loading-spinner w-4 h-4 mr-2" />
                  Sending...
                </div>
              ) : (
                'Send'
              )}
            </button>
          </div>
          <input
            type="text"
            placeholder="Optional message"
            value={tipMessage}
            onChange={(e) => setTipMessage(e.target.value)}
            className="w-full px-3 py-2 bg-black/50 border border-white/20 rounded-lg text-white placeholder-gray-400 focus:border-neon-pink focus:outline-none"
            maxLength={100}
          />
        </div>

        {/* Wallet Modal */}
        {showWallet && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm">
            <div className="glass-dark rounded-lg p-6 max-w-md w-full mx-4 max-h-[80vh] overflow-y-auto">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-xl font-display font-bold gradient-text">Wallet</h3>
                <button
                  onClick={() => setShowWallet(false)}
                  className="p-2 rounded-lg bg-gray-700 hover:bg-gray-600 text-white transition-colors duration-200"
                >
                  ✕
                </button>
              </div>

              {/* Balance */}
              <div className="p-4 bg-black/30 rounded-lg mb-4">
                <div className="text-center">
                  <p className="text-gray-400 text-sm">Current Balance</p>
                  <p className="text-neon-green font-bold text-3xl">
                    ${wallet?.balance.toFixed(2) || '0.00'}
                  </p>
                </div>
              </div>

              {/* Deposit */}
              <div className="space-y-3 mb-6">
                <h4 className="text-white font-semibold">Add Funds</h4>
                <div className="flex space-x-2">
                  <input
                    type="number"
                    placeholder="Amount ($5 minimum)"
                    value={depositAmount}
                    onChange={(e) => setDepositAmount(e.target.value)}
                    className="flex-1 px-3 py-2 bg-black/50 border border-white/20 rounded-lg text-white placeholder-gray-400 focus:border-neon-pink focus:outline-none"
                    min="5"
                    step="1"
                  />
                  <button
                    onClick={handleDeposit}
                    disabled={depositMutation.isLoading || !depositAmount}
                    className={cn(
                      'px-4 py-2 rounded-lg font-semibold transition-all duration-300',
                      'bg-gradient-to-r from-green-500 to-emerald-600 text-white',
                      (depositMutation.isLoading || !depositAmount) && 'opacity-50 cursor-not-allowed'
                    )}
                  >
                    {depositMutation.isLoading ? 'Processing...' : 'Add'}
                  </button>
                </div>
                <p className="text-gray-400 text-xs">
                  Secure payment via Stripe. Funds are available immediately.
                </p>
              </div>

              {/* Recent Transactions */}
              <div>
                <h4 className="text-white font-semibold mb-3">Recent Transactions</h4>
                <div className="space-y-2 max-h-40 overflow-y-auto">
                  {wallet?.transactions.slice(0, 5).map((transaction) => (
                    <div key={transaction.id} className="flex items-center justify-between p-2 bg-black/20 rounded">
                      <div>
                        <p className="text-white text-sm">{transaction.description}</p>
                        <p className="text-gray-400 text-xs">
                          {new Date(transaction.createdAt).toLocaleDateString()}
                        </p>
                      </div>
                      <span className={cn(
                        'font-semibold',
                        transaction.type === 'tip' ? 'text-red-400' : 'text-green-400'
                      )}>
                        {transaction.type === 'tip' ? '-' : '+'}${transaction.amount.toFixed(2)}
                      </span>
                    </div>
                  ))}
                  {!wallet?.transactions.length && (
                    <p className="text-gray-400 text-sm text-center py-4">
                      No transactions yet
                    </p>
                  )}
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Leaderboard Modal */}
        {showLeaderboard && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm">
            <div className="glass-dark rounded-lg p-6 max-w-md w-full mx-4 max-h-[80vh] overflow-y-auto">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-xl font-display font-bold gradient-text">Tip Leaderboard</h3>
                <button
                  onClick={() => setShowLeaderboard(false)}
                  className="p-2 rounded-lg bg-gray-700 hover:bg-gray-600 text-white transition-colors duration-200"
                >
                  ✕
                </button>
              </div>

              <div className="space-y-2">
                {leaderboard?.slice(0, 10).map((entry, index) => (
                  <div
                    key={entry.userId}
                    className={cn(
                      'flex items-center justify-between p-3 rounded-lg',
                      index === 0 && 'bg-gradient-to-r from-yellow-500/20 to-orange-500/20 border border-yellow-500/30',
                      index === 1 && 'bg-gradient-to-r from-gray-400/20 to-gray-500/20 border border-gray-400/30',
                      index === 2 && 'bg-gradient-to-r from-orange-600/20 to-orange-700/20 border border-orange-600/30',
                      index > 2 && 'bg-black/20'
                    )}
                  >
                    <div className="flex items-center space-x-3">
                      <span className={cn(
                        'w-8 h-8 rounded-full flex items-center justify-center font-bold text-sm',
                        index === 0 && 'bg-yellow-500 text-black',
                        index === 1 && 'bg-gray-400 text-black',
                        index === 2 && 'bg-orange-600 text-white',
                        index > 2 && 'bg-gray-600 text-white'
                      )}>
                        {index + 1}
                      </span>
                      <span className={cn(
                        'font-semibold',
                        entry.userId === user?.id ? 'text-neon-pink' : 'text-white'
                      )}>
                        {entry.username}
                        {entry.userId === user?.id && ' (You)'}
                      </span>
                    </div>
                    <span className="text-neon-green font-bold">
                      ${entry.totalTipped.toFixed(2)}
                    </span>
                  </div>
                ))}
                {!leaderboard?.length && (
                  <p className="text-gray-400 text-sm text-center py-4">
                    No tips yet. Be the first!
                  </p>
                )}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

export default TippingInterface
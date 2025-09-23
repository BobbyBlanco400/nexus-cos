'use client'

import React, { createContext, useContext, useEffect, useState, ReactNode } from 'react'
import { useQuery, useMutation, useQueryClient } from 'react-query'
import { tippingApi, TipTransaction, handleApiError } from '@/lib/api'
import { useAuth } from './AuthContext'
import { useSocket } from './SocketContext'
import { toast } from 'react-hot-toast'

interface TipContextType {
  // Wallet state
  wallet: {
    balance: number
    totalDeposited: number
    totalSpent: number
  } | null
  isLoadingWallet: boolean
  
  // Tip history
  tipHistory: TipTransaction[]
  isLoadingHistory: boolean
  
  // Leaderboard
  leaderboard: {
    rank: number
    username: string
    displayName?: string
    totalTips: number
    isCurrentUser: boolean
  }[]
  isLoadingLeaderboard: boolean
  
  // Actions
  refreshWallet: () => void
  depositCredits: (amount: number) => Promise<boolean>
  sendTip: (performerId: string, amount: number, message?: string, isAnonymous?: boolean) => Promise<boolean>
  refreshHistory: () => void
  refreshLeaderboard: () => void
  
  // Quick tip amounts
  quickTipAmounts: number[]
  
  // Tip animations
  tipAnimations: {
    id: string
    amount: number
    fromUsername?: string
    message?: string
    timestamp: Date
  }[]
  
  // Statistics
  tipStats: {
    totalSent: number
    totalReceived: number
    averageTip: number
    topPerformer: string
    monthlyStats: any[]
  } | null
}

const TipContext = createContext<TipContextType | undefined>(undefined)

interface TipProviderProps {
  children: ReactNode
}

export function TipProvider({ children }: TipProviderProps) {
  const [tipAnimations, setTipAnimations] = useState<any[]>([])
  const [quickTipAmounts] = useState([1, 5, 10, 25, 50, 100])
  
  const { user, isAuthenticated } = useAuth()
  const { socket, isConnected } = useSocket()
  const queryClient = useQueryClient()

  // Fetch wallet data
  const {
    data: walletData,
    isLoading: isLoadingWallet,
    refetch: refreshWallet,
  } = useQuery(
    ['wallet'],
    () => tippingApi.getWallet(),
    {
      enabled: isAuthenticated,
      refetchInterval: 60000, // Refresh every minute
      onError: (error) => {
        console.error('Failed to fetch wallet:', error)
      },
    }
  )

  const wallet = walletData?.data?.data || null

  // Fetch tip history
  const {
    data: historyData,
    isLoading: isLoadingHistory,
    refetch: refreshHistory,
  } = useQuery(
    ['tipHistory'],
    () => tippingApi.getTipHistory(1, 50),
    {
      enabled: isAuthenticated,
      onError: (error) => {
        console.error('Failed to fetch tip history:', error)
      },
    }
  )

  const tipHistory = historyData?.data?.data?.data || []

  // Fetch leaderboard
  const {
    data: leaderboardData,
    isLoading: isLoadingLeaderboard,
    refetch: refreshLeaderboard,
  } = useQuery(
    ['tipLeaderboard'],
    () => tippingApi.getLeaderboard('month'),
    {
      enabled: true, // Public data
      refetchInterval: 300000, // Refresh every 5 minutes
      onError: (error) => {
        console.error('Failed to fetch leaderboard:', error)
      },
    }
  )

  const leaderboard = leaderboardData?.data?.data || []

  // Fetch tip statistics
  const {
    data: statsData,
  } = useQuery(
    ['tipStats'],
    () => tippingApi.getTipStats(),
    {
      enabled: isAuthenticated,
      onError: (error) => {
        console.error('Failed to fetch tip stats:', error)
      },
    }
  )

  const tipStats = statsData?.data?.data || null

  // Listen for tip events from socket
  useEffect(() => {
    if (socket && isConnected) {
      const handleTipReceived = (data: any) => {
        // Add tip animation
        const animationId = Date.now() + Math.random()
        setTipAnimations(prev => [...prev, {
          id: animationId,
          amount: data.amount,
          fromUsername: data.isAnonymous ? undefined : data.fromUsername,
          message: data.message,
          timestamp: new Date(),
        }])

        // Remove animation after 5 seconds
        setTimeout(() => {
          setTipAnimations(prev => prev.filter(anim => anim.id !== animationId))
        }, 5000)

        // Refresh wallet and history
        refreshWallet()
        refreshHistory()
        refreshLeaderboard()
      }

      const handleTipSent = (data: any) => {
        // Refresh wallet and history
        refreshWallet()
        refreshHistory()
        refreshLeaderboard()
      }

      socket.on('tip_received', handleTipReceived)
      socket.on('tip_sent', handleTipSent)

      return () => {
        socket.off('tip_received', handleTipReceived)
        socket.off('tip_sent', handleTipSent)
      }
    }
  }, [socket, isConnected, refreshWallet, refreshHistory, refreshLeaderboard])

  // Deposit credits mutation
  const depositCreditsMutation = useMutation(
    (amount: number) => tippingApi.depositCredits(amount),
    {
      onSuccess: (response) => {
        if (response.data.success && response.data.data?.url) {
          // Redirect to Stripe checkout
          window.location.href = response.data.data.url
        }
      },
      onError: (error) => {
        const errorMessage = handleApiError(error)
        toast.error(`Failed to initiate deposit: ${errorMessage}`)
      },
    }
  )

  // Send tip mutation
  const sendTipMutation = useMutation(
    (tipData: {
      performerId: string
      amount: number
      message?: string
      isAnonymous?: boolean
    }) => tippingApi.sendTip(tipData),
    {
      onSuccess: (response, variables) => {
        if (response.data.success) {
          toast.success(`Tip of $${variables.amount} sent successfully!`)
          
          // Refresh data
          refreshWallet()
          refreshHistory()
          refreshLeaderboard()
          
          // Trigger tip animation via socket
          if (socket && isConnected) {
            socket.emit('tip_animation', {
              amount: variables.amount,
              message: variables.message,
              isAnonymous: variables.isAnonymous,
            })
          }
        }
      },
      onError: (error) => {
        const errorMessage = handleApiError(error)
        toast.error(`Failed to send tip: ${errorMessage}`)
      },
    }
  )

  // Actions
  const depositCredits = async (amount: number): Promise<boolean> => {
    if (!isAuthenticated) {
      toast.error('Please log in to deposit credits')
      return false
    }

    if (amount < 1) {
      toast.error('Minimum deposit amount is $1')
      return false
    }

    if (amount > 1000) {
      toast.error('Maximum deposit amount is $1000')
      return false
    }

    try {
      await depositCreditsMutation.mutateAsync(amount)
      return true
    } catch {
      return false
    }
  }

  const sendTip = async (
    performerId: string,
    amount: number,
    message?: string,
    isAnonymous?: boolean
  ): Promise<boolean> => {
    if (!isAuthenticated) {
      toast.error('Please log in to send tips')
      return false
    }

    if (!wallet) {
      toast.error('Unable to load wallet information')
      return false
    }

    if (amount < 1) {
      toast.error('Minimum tip amount is $1')
      return false
    }

    if (amount > wallet.balance) {
      toast.error('Insufficient balance. Please deposit more credits.')
      return false
    }

    if (amount > 500) {
      toast.error('Maximum tip amount is $500')
      return false
    }

    if (message && message.length > 200) {
      toast.error('Tip message cannot exceed 200 characters')
      return false
    }

    try {
      await sendTipMutation.mutateAsync({
        performerId,
        amount,
        message: message?.trim(),
        isAnonymous: isAnonymous || false,
      })
      return true
    } catch {
      return false
    }
  }

  const value: TipContextType = {
    wallet,
    isLoadingWallet,
    tipHistory,
    isLoadingHistory,
    leaderboard,
    isLoadingLeaderboard,
    refreshWallet,
    depositCredits,
    sendTip,
    refreshHistory,
    refreshLeaderboard,
    quickTipAmounts,
    tipAnimations,
    tipStats,
  }

  return <TipContext.Provider value={value}>{children}</TipContext.Provider>
}

// Custom hook to use tip context
export function useTip(): TipContextType {
  const context = useContext(TipContext)
  if (context === undefined) {
    throw new Error('useTip must be used within a TipProvider')
  }
  return context
}

// Custom hook for quick tipping
export function useQuickTip() {
  const { sendTip, quickTipAmounts, wallet } = useTip()
  const [isLoading, setIsLoading] = useState(false)

  const quickTip = async (performerId: string, amount: number) => {
    setIsLoading(true)
    try {
      const success = await sendTip(performerId, amount)
      return success
    } finally {
      setIsLoading(false)
    }
  }

  const canAfford = (amount: number) => {
    return wallet ? wallet.balance >= amount : false
  }

  return {
    quickTip,
    quickTipAmounts,
    isLoading,
    canAfford,
  }
}

// Custom hook for tip leaderboard position
export function useTipLeaderboard() {
  const { leaderboard, isLoadingLeaderboard, refreshLeaderboard } = useTip()
  const { user } = useAuth()

  const currentUserPosition = leaderboard.find(entry => entry.isCurrentUser)
  const topTippers = leaderboard.slice(0, 10)

  const getUserRank = () => {
    return currentUserPosition?.rank || null
  }

  const getUserTotalTips = () => {
    return currentUserPosition?.totalTips || 0
  }

  const isInTopTen = () => {
    return currentUserPosition ? currentUserPosition.rank <= 10 : false
  }

  return {
    leaderboard: topTippers,
    isLoading: isLoadingLeaderboard,
    refresh: refreshLeaderboard,
    currentUserPosition,
    getUserRank,
    getUserTotalTips,
    isInTopTen,
  }
}

// Custom hook for tip animations
export function useTipAnimations() {
  const { tipAnimations } = useTip()
  const [displayedAnimations, setDisplayedAnimations] = useState<any[]>([])

  useEffect(() => {
    // Add new animations
    tipAnimations.forEach(animation => {
      if (!displayedAnimations.find(a => a.id === animation.id)) {
        setDisplayedAnimations(prev => [...prev, animation])
        
        // Remove after animation duration
        setTimeout(() => {
          setDisplayedAnimations(prev => prev.filter(a => a.id !== animation.id))
        }, 3000)
      }
    })
  }, [tipAnimations, displayedAnimations])

  return displayedAnimations
}

// Custom hook for wallet management
export function useWallet() {
  const {
    wallet,
    isLoadingWallet,
    refreshWallet,
    depositCredits,
    tipHistory,
    isLoadingHistory,
    refreshHistory,
  } = useTip()

  const getBalanceStatus = () => {
    if (!wallet) return 'unknown'
    if (wallet.balance === 0) return 'empty'
    if (wallet.balance < 10) return 'low'
    if (wallet.balance < 50) return 'medium'
    return 'good'
  }

  const getRecommendedDeposit = () => {
    if (!wallet) return 25
    if (wallet.balance === 0) return 25
    if (wallet.balance < 10) return 50
    if (wallet.balance < 25) return 25
    return 100
  }

  const formatBalance = () => {
    return wallet ? `$${wallet.balance.toFixed(2)}` : '$0.00'
  }

  const getSpendingStats = () => {
    if (!wallet) return null
    
    const totalTransactions = wallet.totalDeposited + wallet.totalSpent
    const spendingRatio = totalTransactions > 0 ? wallet.totalSpent / totalTransactions : 0
    
    return {
      totalDeposited: wallet.totalDeposited,
      totalSpent: wallet.totalSpent,
      currentBalance: wallet.balance,
      spendingRatio,
    }
  }

  return {
    wallet,
    isLoading: isLoadingWallet,
    refresh: refreshWallet,
    deposit: depositCredits,
    history: tipHistory,
    isLoadingHistory,
    refreshHistory,
    getBalanceStatus,
    getRecommendedDeposit,
    formatBalance,
    getSpendingStats,
  }
}
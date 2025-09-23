'use client'

import React, { createContext, useContext, useEffect, useState, ReactNode } from 'react'
import { useRouter } from 'next/navigation'
import { authApi, User, handleApiError } from '@/lib/api'
import { storage } from '@/lib/utils'
import { toast } from 'react-hot-toast'

interface AuthContextType {
  user: User | null
  isLoading: boolean
  isAuthenticated: boolean
  login: (email: string, password: string) => Promise<boolean>
  register: (userData: {
    username: string
    email: string
    password: string
    role?: 'USER' | 'PERFORMER'
  }) => Promise<boolean>
  logout: () => void
  updateUser: (userData: Partial<User>) => void
  refreshUser: () => Promise<void>
  checkAuth: () => Promise<boolean>
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

interface AuthProviderProps {
  children: ReactNode
}

export function AuthProvider({ children }: AuthProviderProps) {
  const [user, setUser] = useState<User | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const router = useRouter()

  const isAuthenticated = !!user

  // Check authentication status on mount
  useEffect(() => {
    checkAuth()
  }, [])

  // Check if user is authenticated
  const checkAuth = async (): Promise<boolean> => {
    try {
      const token = storage.get('auth_token')
      if (!token) {
        setIsLoading(false)
        return false
      }

      // Try to get user profile to verify token
      const response = await authApi.refreshToken()
      if (response.data.success && response.data.data?.token) {
        storage.set('auth_token', response.data.data.token)
        await refreshUser()
        return true
      } else {
        // Token is invalid
        storage.remove('auth_token')
        storage.remove('user')
        setUser(null)
        setIsLoading(false)
        return false
      }
    } catch (error) {
      console.error('Auth check failed:', error)
      storage.remove('auth_token')
      storage.remove('user')
      setUser(null)
      setIsLoading(false)
      return false
    }
  }

  // Login function
  const login = async (email: string, password: string): Promise<boolean> => {
    try {
      setIsLoading(true)
      const response = await authApi.login({ email, password })
      
      if (response.data.success && response.data.data) {
        const { user: userData, token } = response.data.data
        
        // Store token and user data
        storage.set('auth_token', token)
        storage.set('user', userData)
        setUser(userData)
        
        toast.success(`Welcome back, ${userData.username}!`)
        return true
      } else {
        toast.error(response.data.message || 'Login failed')
        return false
      }
    } catch (error) {
      const errorMessage = handleApiError(error)
      toast.error(errorMessage)
      return false
    } finally {
      setIsLoading(false)
    }
  }

  // Register function
  const register = async (userData: {
    username: string
    email: string
    password: string
    role?: 'USER' | 'PERFORMER'
  }): Promise<boolean> => {
    try {
      setIsLoading(true)
      const response = await authApi.register(userData)
      
      if (response.data.success && response.data.data) {
        const { user: newUser, token } = response.data.data
        
        // Store token and user data
        storage.set('auth_token', token)
        storage.set('user', newUser)
        setUser(newUser)
        
        toast.success(`Welcome to Da Boom Boom Room, ${newUser.username}!`)
        return true
      } else {
        toast.error(response.data.message || 'Registration failed')
        return false
      }
    } catch (error) {
      const errorMessage = handleApiError(error)
      toast.error(errorMessage)
      return false
    } finally {
      setIsLoading(false)
    }
  }

  // Logout function
  const logout = async () => {
    try {
      // Call logout endpoint to invalidate token on server
      await authApi.logout()
    } catch (error) {
      console.error('Logout error:', error)
    } finally {
      // Clear local storage and state regardless of API call result
      storage.remove('auth_token')
      storage.remove('user')
      setUser(null)
      toast.success('Logged out successfully')
      router.push('/auth/login')
    }
  }

  // Update user data
  const updateUser = (userData: Partial<User>) => {
    if (user) {
      const updatedUser = { ...user, ...userData }
      setUser(updatedUser)
      storage.set('user', updatedUser)
    }
  }

  // Refresh user data from server
  const refreshUser = async () => {
    try {
      const storedUser = storage.get('user')
      if (storedUser) {
        setUser(storedUser)
      }
      setIsLoading(false)
    } catch (error) {
      console.error('Failed to refresh user:', error)
      setIsLoading(false)
    }
  }

  const value: AuthContextType = {
    user,
    isLoading,
    isAuthenticated,
    login,
    register,
    logout,
    updateUser,
    refreshUser,
    checkAuth,
  }

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

// Custom hook to use auth context
export function useAuth(): AuthContextType {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}

// HOC for protected routes
export function withAuth<P extends object>(
  Component: React.ComponentType<P>,
  options?: {
    redirectTo?: string
    requiredRole?: 'USER' | 'PERFORMER' | 'ADMIN'
    requiredTier?: string
  }
) {
  return function AuthenticatedComponent(props: P) {
    const { user, isLoading, isAuthenticated } = useAuth()
    const router = useRouter()

    useEffect(() => {
      if (!isLoading) {
        if (!isAuthenticated) {
          router.push(options?.redirectTo || '/auth/login')
          return
        }

        if (options?.requiredRole && user?.role !== options.requiredRole) {
          toast.error('You do not have permission to access this page')
          router.push('/')
          return
        }

        if (options?.requiredTier) {
          // Check if user has required subscription tier
          const tierHierarchy = {
            'FLOOR_PASS': 1,
            'BACKSTAGE_PASS': 2,
            'VIP_LOUNGE': 3,
            'CHAMPAGNE_ROOM': 4,
            'BLACK_CARD': 5,
          }

          const userLevel = tierHierarchy[user?.subscriptionTier as keyof typeof tierHierarchy] || 0
          const requiredLevel = tierHierarchy[options.requiredTier as keyof typeof tierHierarchy] || 0

          if (userLevel < requiredLevel) {
            toast.error('You need a higher subscription tier to access this content')
            router.push('/subscriptions')
            return
          }
        }
      }
    }, [isLoading, isAuthenticated, user, router])

    if (isLoading) {
      return (
        <div className="min-h-screen flex items-center justify-center bg-club-dark">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-neon-pink"></div>
        </div>
      )
    }

    if (!isAuthenticated) {
      return null
    }

    if (options?.requiredRole && user?.role !== options.requiredRole) {
      return null
    }

    return <Component {...props} />
  }
}

// Hook for checking permissions
export function usePermissions() {
  const { user } = useAuth()

  const hasRole = (role: 'USER' | 'PERFORMER' | 'ADMIN'): boolean => {
    return user?.role === role
  }

  const hasTier = (tier: string): boolean => {
    if (!user?.subscriptionTier) return false

    const tierHierarchy = {
      'FLOOR_PASS': 1,
      'BACKSTAGE_PASS': 2,
      'VIP_LOUNGE': 3,
      'CHAMPAGNE_ROOM': 4,
      'BLACK_CARD': 5,
    }

    const userLevel = tierHierarchy[user.subscriptionTier as keyof typeof tierHierarchy] || 0
    const requiredLevel = tierHierarchy[tier as keyof typeof tierHierarchy] || 0

    return userLevel >= requiredLevel
  }

  const canAccessStream = (streamType: string): boolean => {
    const streamTierMap = {
      'MAIN_STAGE': 'FLOOR_PASS',
      'BACKSTAGE': 'BACKSTAGE_PASS',
      'VIP_LOUNGE': 'VIP_LOUNGE',
      'CHAMPAGNE_ROOM': 'CHAMPAGNE_ROOM',
      'BLACK_CARD': 'BLACK_CARD',
    }

    const requiredTier = streamTierMap[streamType as keyof typeof streamTierMap]
    return requiredTier ? hasTier(requiredTier) : false
  }

  const isPerformer = (): boolean => hasRole('PERFORMER')
  const isAdmin = (): boolean => hasRole('ADMIN')
  const isUser = (): boolean => hasRole('USER')

  return {
    hasRole,
    hasTier,
    canAccessStream,
    isPerformer,
    isAdmin,
    isUser,
  }
}
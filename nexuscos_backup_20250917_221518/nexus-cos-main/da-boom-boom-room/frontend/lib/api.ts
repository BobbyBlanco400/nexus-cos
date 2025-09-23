import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios'
import { storage } from './utils'

// API Configuration
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000/api'
const API_TIMEOUT = 30000 // 30 seconds

// Create axios instance
const api: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  timeout: API_TIMEOUT,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    const token = storage.get('auth_token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Response interceptor for error handling
api.interceptors.response.use(
  (response: AxiosResponse) => {
    return response
  },
  (error) => {
    if (error.response?.status === 401) {
      // Token expired or invalid
      storage.remove('auth_token')
      storage.remove('user')
      window.location.href = '/auth/login'
    }
    return Promise.reject(error)
  }
)

// API Response Types
export interface ApiResponse<T = any> {
  success: boolean
  data?: T
  message?: string
  error?: string
}

export interface PaginatedResponse<T> {
  data: T[]
  pagination: {
    page: number
    limit: number
    total: number
    totalPages: number
  }
}

// User Types
export interface User {
  id: string
  username: string
  email: string
  role: 'USER' | 'PERFORMER' | 'ADMIN'
  subscriptionTier: string
  credits: number
  isActive: boolean
  createdAt: string
  updatedAt: string
  profile?: {
    displayName?: string
    avatar?: string
    bio?: string
    preferences?: any
  }
}

export interface Performer {
  id: string
  username: string
  displayName: string
  avatar?: string
  bio?: string
  isOnline: boolean
  isStreaming: boolean
  streamTitle?: string
  tags: string[]
  rating: number
  totalEarnings: number
  followerCount: number
  createdAt: string
}

export interface Stream {
  id: string
  performerId: string
  performer: Performer
  title: string
  description?: string
  type: 'MAIN_STAGE' | 'BACKSTAGE' | 'VIP_LOUNGE' | 'CHAMPAGNE_ROOM' | 'BLACK_CARD'
  isVREnabled: boolean
  isActive: boolean
  viewerCount: number
  requiredTier: string
  streamUrl?: string
  vrStreamUrl?: string
  thumbnailUrl?: string
  startedAt: string
  tags: string[]
}

export interface Subscription {
  id: string
  userId: string
  tier: string
  status: 'ACTIVE' | 'CANCELED' | 'PAST_DUE' | 'UNPAID'
  currentPeriodStart: string
  currentPeriodEnd: string
  cancelAtPeriodEnd: boolean
  stripeSubscriptionId: string
  createdAt: string
  updatedAt: string
}

export interface TipTransaction {
  id: string
  fromUserId: string
  toPerformerId: string
  amount: number
  message?: string
  isAnonymous: boolean
  createdAt: string
  fromUser: {
    username: string
    displayName?: string
  }
  toPerformer: {
    username: string
    displayName: string
  }
}

// Auth API
export const authApi = {
  login: (credentials: { email: string; password: string }) =>
    api.post<ApiResponse<{ user: User; token: string }>>('/auth/login', credentials),

  register: (userData: {
    username: string
    email: string
    password: string
    role?: 'USER' | 'PERFORMER'
  }) => api.post<ApiResponse<{ user: User; token: string }>>('/auth/register', userData),

  logout: () => api.post<ApiResponse>('/auth/logout'),

  refreshToken: () => api.post<ApiResponse<{ token: string }>>('/auth/refresh'),

  forgotPassword: (email: string) =>
    api.post<ApiResponse>('/auth/forgot-password', { email }),

  resetPassword: (token: string, password: string) =>
    api.post<ApiResponse>('/auth/reset-password', { token, password }),

  changePassword: (currentPassword: string, newPassword: string) =>
    api.put<ApiResponse>('/auth/change-password', { currentPassword, newPassword }),

  updateProfile: (profileData: Partial<User['profile']>) =>
    api.put<ApiResponse<User>>('/auth/profile', profileData),
}

// Users API
export const usersApi = {
  getProfile: () => api.get<ApiResponse<User>>('/users/profile'),

  getStats: () =>
    api.get<ApiResponse<{
      totalTips: number
      totalSpent: number
      favoritePerformers: number
      watchTime: number
    }>>('/users/stats'),

  getPreferences: () => api.get<ApiResponse<any>>('/users/preferences'),

  updatePreferences: (preferences: any) =>
    api.put<ApiResponse>('/users/preferences', preferences),

  getFavorites: () => api.get<ApiResponse<Performer[]>>('/users/favorites'),

  addFavorite: (performerId: string) =>
    api.post<ApiResponse>('/users/favorites', { performerId }),

  removeFavorite: (performerId: string) =>
    api.delete<ApiResponse>(`/users/favorites/${performerId}`),

  getViewingHistory: (page = 1, limit = 20) =>
    api.get<ApiResponse<PaginatedResponse<Stream>>>('/users/viewing-history', {
      params: { page, limit },
    }),

  getTipLeaderboardPosition: () =>
    api.get<ApiResponse<{ position: number; totalTips: number }>>('/users/leaderboard-position'),

  deactivateAccount: () => api.delete<ApiResponse>('/users/account'),
}

// Performers API
export const performersApi = {
  getPerformers: (params?: {
    page?: number
    limit?: number
    search?: string
    tags?: string[]
    isOnline?: boolean
    sortBy?: 'rating' | 'followers' | 'earnings' | 'recent'
  }) => api.get<ApiResponse<PaginatedResponse<Performer>>>('/performers', { params }),

  getPerformer: (id: string) => api.get<ApiResponse<Performer>>(`/performers/${id}`),

  updateProfile: (profileData: Partial<Performer>) =>
    api.put<ApiResponse<Performer>>('/performers/profile', profileData),

  setOnlineStatus: (isOnline: boolean) =>
    api.put<ApiResponse>('/performers/online-status', { isOnline }),

  getEarnings: (period?: 'day' | 'week' | 'month' | 'year') =>
    api.get<ApiResponse<{
      total: number
      tips: number
      subscriptions: number
      breakdown: any[]
    }>>('/performers/earnings', { params: { period } }),
}

// Streams API
export const streamsApi = {
  getStreams: (params?: {
    type?: string
    isActive?: boolean
    page?: number
    limit?: number
  }) => api.get<ApiResponse<PaginatedResponse<Stream>>>('/streaming/streams', { params }),

  getStream: (id: string) => api.get<ApiResponse<Stream>>(`/streaming/streams/${id}`),

  createStream: (streamData: {
    title: string
    description?: string
    type: string
    isVREnabled?: boolean
    tags?: string[]
  }) => api.post<ApiResponse<Stream>>('/streaming/streams', streamData),

  updateStream: (id: string, streamData: Partial<Stream>) =>
    api.put<ApiResponse<Stream>>(`/streaming/streams/${id}`, streamData),

  endStream: (id: string) => api.delete<ApiResponse>(`/streaming/streams/${id}`),

  joinStream: (id: string) => api.post<ApiResponse>(`/streaming/streams/${id}/join`),

  leaveStream: (id: string) => api.post<ApiResponse>(`/streaming/streams/${id}/leave`),

  getVRStream: (id: string) =>
    api.get<ApiResponse<{ vrStreamUrl: string }>>(`/streaming/streams/${id}/vr`),

  getStreamHistory: (page = 1, limit = 20) =>
    api.get<ApiResponse<PaginatedResponse<Stream>>>('/streaming/history', {
      params: { page, limit },
    }),

  getStreamStats: (id: string) =>
    api.get<ApiResponse<{
      viewerCount: number
      totalViews: number
      duration: number
      peakViewers: number
    }>>(`/streaming/streams/${id}/stats`),
}

// Subscriptions API
export const subscriptionsApi = {
  getTiers: () =>
    api.get<ApiResponse<{
      id: string
      name: string
      price: number
      features: string[]
      stripePriceId: string
    }[]>>('/subscriptions/tiers'),

  getCurrentSubscription: () =>
    api.get<ApiResponse<Subscription>>('/subscriptions/current'),

  createCheckoutSession: (tierId: string) =>
    api.post<ApiResponse<{ sessionId: string; url: string }>>('/subscriptions/checkout', {
      tierId,
    }),

  cancelSubscription: () => api.post<ApiResponse>('/subscriptions/cancel'),

  reactivateSubscription: () => api.post<ApiResponse>('/subscriptions/reactivate'),

  getBillingPortal: () =>
    api.get<ApiResponse<{ url: string }>>('/subscriptions/billing-portal'),

  getUsageStats: () =>
    api.get<ApiResponse<{
      streamsWatched: number
      totalWatchTime: number
      tipsGiven: number
      currentPeriodUsage: any
    }>>('/subscriptions/usage'),
}

// Tipping API
export const tippingApi = {
  getWallet: () =>
    api.get<ApiResponse<{ balance: number; totalDeposited: number; totalSpent: number }>>(
      '/tipping/wallet'
    ),

  depositCredits: (amount: number) =>
    api.post<ApiResponse<{ sessionId: string; url: string }>>('/tipping/deposit', { amount }),

  sendTip: (tipData: {
    performerId: string
    amount: number
    message?: string
    isAnonymous?: boolean
  }) => api.post<ApiResponse<TipTransaction>>('/tipping/send', tipData),

  getTipHistory: (page = 1, limit = 20) =>
    api.get<ApiResponse<PaginatedResponse<TipTransaction>>>('/tipping/history', {
      params: { page, limit },
    }),

  getLeaderboard: (period?: 'day' | 'week' | 'month' | 'all') =>
    api.get<ApiResponse<{
      rank: number
      username: string
      displayName?: string
      totalTips: number
      isCurrentUser: boolean
    }[]>>('/tipping/leaderboard', { params: { period } }),

  getTipStats: () =>
    api.get<ApiResponse<{
      totalSent: number
      totalReceived: number
      averageTip: number
      topPerformer: string
      monthlyStats: any[]
    }>>('/tipping/stats'),
}

// Upload API
export const uploadApi = {
  uploadAvatar: (file: File) => {
    const formData = new FormData()
    formData.append('avatar', file)
    return api.post<ApiResponse<{ url: string }>>('/upload/avatar', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    })
  },

  uploadStreamThumbnail: (file: File) => {
    const formData = new FormData()
    formData.append('thumbnail', file)
    return api.post<ApiResponse<{ url: string }>>('/upload/stream-thumbnail', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    })
  },
}

// Admin API (for admin users)
export const adminApi = {
  getUsers: (params?: {
    page?: number
    limit?: number
    search?: string
    role?: string
    isActive?: boolean
  }) => api.get<ApiResponse<PaginatedResponse<User>>>('/admin/users', { params }),

  updateUser: (userId: string, userData: Partial<User>) =>
    api.put<ApiResponse<User>>(`/admin/users/${userId}`, userData),

  deleteUser: (userId: string) => api.delete<ApiResponse>(`/admin/users/${userId}`),

  getSystemStats: () =>
    api.get<ApiResponse<{
      totalUsers: number
      totalPerformers: number
      activeStreams: number
      totalRevenue: number
      monthlyGrowth: number
    }>>('/admin/stats'),

  getReports: (type: 'revenue' | 'users' | 'streams', period: string) =>
    api.get<ApiResponse<any>>('/admin/reports', { params: { type, period } }),
}

// Export the main API instance
export default api

// Helper function to handle API errors
export function handleApiError(error: any): string {
  if (error.response?.data?.message) {
    return error.response.data.message
  }
  if (error.response?.data?.error) {
    return error.response.data.error
  }
  if (error.message) {
    return error.message
  }
  return 'An unexpected error occurred'
}

// Helper function to check if error is network related
export function isNetworkError(error: any): boolean {
  return !error.response && error.code === 'NETWORK_ERROR'
}

// Helper function to check if error is timeout
export function isTimeoutError(error: any): boolean {
  return error.code === 'ECONNABORTED' || error.message?.includes('timeout')
}
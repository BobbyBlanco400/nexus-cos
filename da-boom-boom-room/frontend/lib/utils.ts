import { type ClassValue, clsx } from 'clsx'
import { twMerge } from 'tailwind-merge'

/**
 * Utility function to merge Tailwind CSS classes
 */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

/**
 * Format currency values
 */
export function formatCurrency(amount: number, currency: string = 'USD'): string {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency,
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(amount)
}

/**
 * Format large numbers with abbreviations (K, M, B)
 */
export function formatNumber(num: number): string {
  if (num >= 1000000000) {
    return (num / 1000000000).toFixed(1) + 'B'
  }
  if (num >= 1000000) {
    return (num / 1000000).toFixed(1) + 'M'
  }
  if (num >= 1000) {
    return (num / 1000).toFixed(1) + 'K'
  }
  return num.toString()
}

/**
 * Format time duration (seconds to human readable)
 */
export function formatDuration(seconds: number): string {
  const hours = Math.floor(seconds / 3600)
  const minutes = Math.floor((seconds % 3600) / 60)
  const remainingSeconds = seconds % 60

  if (hours > 0) {
    return `${hours}:${minutes.toString().padStart(2, '0')}:${remainingSeconds.toString().padStart(2, '0')}`
  }
  return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`
}

/**
 * Format relative time (e.g., "2 hours ago")
 */
export function formatRelativeTime(date: Date | string): string {
  const now = new Date()
  const targetDate = new Date(date)
  const diffInSeconds = Math.floor((now.getTime() - targetDate.getTime()) / 1000)

  if (diffInSeconds < 60) {
    return 'just now'
  }

  const diffInMinutes = Math.floor(diffInSeconds / 60)
  if (diffInMinutes < 60) {
    return `${diffInMinutes} minute${diffInMinutes > 1 ? 's' : ''} ago`
  }

  const diffInHours = Math.floor(diffInMinutes / 60)
  if (diffInHours < 24) {
    return `${diffInHours} hour${diffInHours > 1 ? 's' : ''} ago`
  }

  const diffInDays = Math.floor(diffInHours / 24)
  if (diffInDays < 7) {
    return `${diffInDays} day${diffInDays > 1 ? 's' : ''} ago`
  }

  const diffInWeeks = Math.floor(diffInDays / 7)
  if (diffInWeeks < 4) {
    return `${diffInWeeks} week${diffInWeeks > 1 ? 's' : ''} ago`
  }

  const diffInMonths = Math.floor(diffInDays / 30)
  if (diffInMonths < 12) {
    return `${diffInMonths} month${diffInMonths > 1 ? 's' : ''} ago`
  }

  const diffInYears = Math.floor(diffInDays / 365)
  return `${diffInYears} year${diffInYears > 1 ? 's' : ''} ago`
}

/**
 * Debounce function
 */
export function debounce<T extends (...args: any[]) => any>(
  func: T,
  wait: number
): (...args: Parameters<T>) => void {
  let timeout: NodeJS.Timeout
  return (...args: Parameters<T>) => {
    clearTimeout(timeout)
    timeout = setTimeout(() => func(...args), wait)
  }
}

/**
 * Throttle function
 */
export function throttle<T extends (...args: any[]) => any>(
  func: T,
  limit: number
): (...args: Parameters<T>) => void {
  let inThrottle: boolean
  return (...args: Parameters<T>) => {
    if (!inThrottle) {
      func(...args)
      inThrottle = true
      setTimeout(() => (inThrottle = false), limit)
    }
  }
}

/**
 * Generate random ID
 */
export function generateId(length: number = 8): string {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
  let result = ''
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length))
  }
  return result
}

/**
 * Validate email format
 */
export function isValidEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return emailRegex.test(email)
}

/**
 * Validate password strength
 */
export function validatePassword(password: string): {
  isValid: boolean
  errors: string[]
} {
  const errors: string[] = []

  if (password.length < 8) {
    errors.push('Password must be at least 8 characters long')
  }

  if (!/[a-z]/.test(password)) {
    errors.push('Password must contain at least one lowercase letter')
  }

  if (!/[A-Z]/.test(password)) {
    errors.push('Password must contain at least one uppercase letter')
  }

  if (!/\d/.test(password)) {
    errors.push('Password must contain at least one number')
  }

  if (!/[@$!%*?&]/.test(password)) {
    errors.push('Password must contain at least one special character (@$!%*?&)')
  }

  return {
    isValid: errors.length === 0,
    errors,
  }
}

/**
 * Get subscription tier color
 */
export function getTierColor(tier: string): string {
  switch (tier.toUpperCase()) {
    case 'FLOOR_PASS':
      return 'text-tier-floor'
    case 'BACKSTAGE_PASS':
      return 'text-tier-backstage'
    case 'VIP_LOUNGE':
      return 'text-tier-vip'
    case 'CHAMPAGNE_ROOM':
      return 'text-tier-champagne'
    case 'BLACK_CARD':
      return 'text-tier-black'
    default:
      return 'text-gray-400'
  }
}

/**
 * Get subscription tier name
 */
export function getTierName(tier: string): string {
  switch (tier.toUpperCase()) {
    case 'FLOOR_PASS':
      return 'Floor Pass'
    case 'BACKSTAGE_PASS':
      return 'Backstage Pass'
    case 'VIP_LOUNGE':
      return 'VIP Lounge'
    case 'CHAMPAGNE_ROOM':
      return 'Champagne Room'
    case 'BLACK_CARD':
      return 'Black Card'
    default:
      return 'No Subscription'
  }
}

/**
 * Get subscription tier price
 */
export function getTierPrice(tier: string): number {
  switch (tier.toUpperCase()) {
    case 'FLOOR_PASS':
      return 9.99
    case 'BACKSTAGE_PASS':
      return 19.99
    case 'VIP_LOUNGE':
      return 39.99
    case 'CHAMPAGNE_ROOM':
      return 79.99
    case 'BLACK_CARD':
      return 199.99
    default:
      return 0
  }
}

/**
 * Check if user can access content based on tier
 */
export function canAccessTier(userTier: string, requiredTier: string): boolean {
  const tierHierarchy = {
    'NONE': 0,
    'FLOOR_PASS': 1,
    'BACKSTAGE_PASS': 2,
    'VIP_LOUNGE': 3,
    'CHAMPAGNE_ROOM': 4,
    'BLACK_CARD': 5,
  }

  const userLevel = tierHierarchy[userTier.toUpperCase() as keyof typeof tierHierarchy] || 0
  const requiredLevel = tierHierarchy[requiredTier.toUpperCase() as keyof typeof tierHierarchy] || 0

  return userLevel >= requiredLevel
}

/**
 * Format file size
 */
export function formatFileSize(bytes: number): string {
  if (bytes === 0) return '0 Bytes'

  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))

  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

/**
 * Copy text to clipboard
 */
export async function copyToClipboard(text: string): Promise<boolean> {
  try {
    await navigator.clipboard.writeText(text)
    return true
  } catch (err) {
    // Fallback for older browsers
    const textArea = document.createElement('textarea')
    textArea.value = text
    document.body.appendChild(textArea)
    textArea.focus()
    textArea.select()
    try {
      document.execCommand('copy')
      document.body.removeChild(textArea)
      return true
    } catch (err) {
      document.body.removeChild(textArea)
      return false
    }
  }
}

/**
 * Download file from URL
 */
export function downloadFile(url: string, filename: string): void {
  const link = document.createElement('a')
  link.href = url
  link.download = filename
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}

/**
 * Get device type
 */
export function getDeviceType(): 'mobile' | 'tablet' | 'desktop' {
  if (typeof window === 'undefined') return 'desktop'

  const width = window.innerWidth
  if (width < 768) return 'mobile'
  if (width < 1024) return 'tablet'
  return 'desktop'
}

/**
 * Check if device supports VR
 */
export function supportsVR(): boolean {
  if (typeof window === 'undefined') return false
  return 'xr' in navigator && 'isSessionSupported' in (navigator as any).xr
}

/**
 * Generate avatar URL from username
 */
export function generateAvatarUrl(username: string, size: number = 100): string {
  const hash = username.split('').reduce((a, b) => {
    a = ((a << 5) - a) + b.charCodeAt(0)
    return a & a
  }, 0)
  
  const colors = [
    'ff0080', '8000ff', '0080ff', '00ff80', 'ffff00', 'ff8000',
    'ff0040', '4080ff', '80ff00', 'ff4080', '8040ff', '40ff80'
  ]
  
  const color = colors[Math.abs(hash) % colors.length]
  return `https://ui-avatars.com/api/?name=${encodeURIComponent(username)}&size=${size}&background=${color}&color=fff&bold=true`
}

/**
 * Local storage helpers with error handling
 */
export const storage = {
  get: (key: string): any => {
    if (typeof window === 'undefined') return null
    try {
      const item = localStorage.getItem(key)
      return item ? JSON.parse(item) : null
    } catch {
      return null
    }
  },
  
  set: (key: string, value: any): boolean => {
    if (typeof window === 'undefined') return false
    try {
      localStorage.setItem(key, JSON.stringify(value))
      return true
    } catch {
      return false
    }
  },
  
  remove: (key: string): boolean => {
    if (typeof window === 'undefined') return false
    try {
      localStorage.removeItem(key)
      return true
    } catch {
      return false
    }
  },
  
  clear: (): boolean => {
    if (typeof window === 'undefined') return false
    try {
      localStorage.clear()
      return true
    } catch {
      return false
    }
  }
}

/**
 * Session storage helpers
 */
export const sessionStorage = {
  get: (key: string): any => {
    if (typeof window === 'undefined') return null
    try {
      const item = window.sessionStorage.getItem(key)
      return item ? JSON.parse(item) : null
    } catch {
      return null
    }
  },
  
  set: (key: string, value: any): boolean => {
    if (typeof window === 'undefined') return false
    try {
      window.sessionStorage.setItem(key, JSON.stringify(value))
      return true
    } catch {
      return false
    }
  },
  
  remove: (key: string): boolean => {
    if (typeof window === 'undefined') return false
    try {
      window.sessionStorage.removeItem(key)
      return true
    } catch {
      return false
    }
  }
}
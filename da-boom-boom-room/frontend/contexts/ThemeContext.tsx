'use client'

import React, { createContext, useContext, useEffect, useState, ReactNode } from 'react'
import { storage } from '@/lib/utils'

type Theme = 'dark' | 'light'
type ClubTheme = 'neon' | 'classic' | 'vip' | 'champagne'
type AnimationLevel = 'none' | 'reduced' | 'normal' | 'enhanced'

interface ThemeContextType {
  // Theme state
  theme: Theme
  clubTheme: ClubTheme
  animationLevel: AnimationLevel
  
  // Theme actions
  setTheme: (theme: Theme) => void
  setClubTheme: (clubTheme: ClubTheme) => void
  setAnimationLevel: (level: AnimationLevel) => void
  toggleTheme: () => void
  
  // Accessibility
  highContrast: boolean
  setHighContrast: (enabled: boolean) => void
  reducedMotion: boolean
  setReducedMotion: (enabled: boolean) => void
  
  // Performance
  enableParticles: boolean
  setEnableParticles: (enabled: boolean) => void
  enableBlur: boolean
  setEnableBlur: (enabled: boolean) => void
  
  // Club-specific settings
  neonIntensity: number
  setNeonIntensity: (intensity: number) => void
  backgroundEffects: boolean
  setBackgroundEffects: (enabled: boolean) => void
  
  // Utility functions
  getThemeClasses: () => string
  getClubThemeClasses: () => string
  isDark: boolean
  isLight: boolean
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined)

interface ThemeProviderProps {
  children: ReactNode
}

export function ThemeProvider({ children }: ThemeProviderProps) {
  const [theme, setThemeState] = useState<Theme>('dark')
  const [clubTheme, setClubThemeState] = useState<ClubTheme>('neon')
  const [animationLevel, setAnimationLevelState] = useState<AnimationLevel>('normal')
  const [highContrast, setHighContrastState] = useState(false)
  const [reducedMotion, setReducedMotionState] = useState(false)
  const [enableParticles, setEnableParticlesState] = useState(true)
  const [enableBlur, setEnableBlurState] = useState(true)
  const [neonIntensity, setNeonIntensityState] = useState(100)
  const [backgroundEffects, setBackgroundEffectsState] = useState(true)
  const [isInitialized, setIsInitialized] = useState(false)

  // Initialize theme from storage and system preferences
  useEffect(() => {
    const initializeTheme = () => {
      // Load saved preferences
      const savedTheme = storage.get('theme') as Theme
      const savedClubTheme = storage.get('clubTheme') as ClubTheme
      const savedAnimationLevel = storage.get('animationLevel') as AnimationLevel
      const savedHighContrast = storage.get('highContrast') as boolean
      const savedReducedMotion = storage.get('reducedMotion') as boolean
      const savedEnableParticles = storage.get('enableParticles') as boolean
      const savedEnableBlur = storage.get('enableBlur') as boolean
      const savedNeonIntensity = storage.get('neonIntensity') as number
      const savedBackgroundEffects = storage.get('backgroundEffects') as boolean

      // Check system preferences
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
      const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches
      const prefersHighContrast = window.matchMedia('(prefers-contrast: high)').matches

      // Set theme
      setThemeState(savedTheme || (prefersDark ? 'dark' : 'light'))
      setClubThemeState(savedClubTheme || 'neon')
      setAnimationLevelState(savedAnimationLevel || (prefersReducedMotion ? 'reduced' : 'normal'))
      setHighContrastState(savedHighContrast ?? prefersHighContrast)
      setReducedMotionState(savedReducedMotion ?? prefersReducedMotion)
      setEnableParticlesState(savedEnableParticles ?? true)
      setEnableBlurState(savedEnableBlur ?? true)
      setNeonIntensityState(savedNeonIntensity ?? 100)
      setBackgroundEffectsState(savedBackgroundEffects ?? true)

      setIsInitialized(true)
    }

    if (typeof window !== 'undefined') {
      initializeTheme()
    }
  }, [])

  // Listen for system theme changes
  useEffect(() => {
    if (typeof window === 'undefined') return

    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
    const handleChange = (e: MediaQueryListEvent) => {
      const savedTheme = storage.get('theme')
      if (!savedTheme) {
        setThemeState(e.matches ? 'dark' : 'light')
      }
    }

    mediaQuery.addEventListener('change', handleChange)
    return () => mediaQuery.removeEventListener('change', handleChange)
  }, [])

  // Listen for reduced motion preference changes
  useEffect(() => {
    if (typeof window === 'undefined') return

    const mediaQuery = window.matchMedia('(prefers-reduced-motion: reduce)')
    const handleChange = (e: MediaQueryListEvent) => {
      const savedReducedMotion = storage.get('reducedMotion')
      if (savedReducedMotion === null || savedReducedMotion === undefined) {
        setReducedMotionState(e.matches)
        if (e.matches) {
          setAnimationLevelState('reduced')
        }
      }
    }

    mediaQuery.addEventListener('change', handleChange)
    return () => mediaQuery.removeEventListener('change', handleChange)
  }, [])

  // Apply theme to document
  useEffect(() => {
    if (!isInitialized || typeof window === 'undefined') return

    const root = document.documentElement
    
    // Remove existing theme classes
    root.classList.remove('light', 'dark')
    root.classList.remove('club-neon', 'club-classic', 'club-vip', 'club-champagne')
    root.classList.remove('high-contrast', 'reduced-motion')
    root.classList.remove('no-particles', 'no-blur', 'no-bg-effects')
    
    // Add current theme classes
    root.classList.add(theme)
    root.classList.add(`club-${clubTheme}`)
    
    if (highContrast) root.classList.add('high-contrast')
    if (reducedMotion) root.classList.add('reduced-motion')
    if (!enableParticles) root.classList.add('no-particles')
    if (!enableBlur) root.classList.add('no-blur')
    if (!backgroundEffects) root.classList.add('no-bg-effects')
    
    // Set CSS custom properties
    root.style.setProperty('--neon-intensity', `${neonIntensity}%`)
    root.style.setProperty('--animation-level', animationLevel)
    
    // Update meta theme-color
    const metaThemeColor = document.querySelector('meta[name="theme-color"]')
    if (metaThemeColor) {
      metaThemeColor.setAttribute('content', theme === 'dark' ? '#0a0a0a' : '#ffffff')
    }
  }, [theme, clubTheme, animationLevel, highContrast, reducedMotion, enableParticles, enableBlur, neonIntensity, backgroundEffects, isInitialized])

  // Theme setters with persistence
  const setTheme = (newTheme: Theme) => {
    setThemeState(newTheme)
    storage.set('theme', newTheme)
  }

  const setClubTheme = (newClubTheme: ClubTheme) => {
    setClubThemeState(newClubTheme)
    storage.set('clubTheme', newClubTheme)
  }

  const setAnimationLevel = (level: AnimationLevel) => {
    setAnimationLevelState(level)
    storage.set('animationLevel', level)
    
    // Auto-adjust related settings
    if (level === 'none') {
      setReducedMotionState(true)
      setEnableParticlesState(false)
      setBackgroundEffectsState(false)
    } else if (level === 'enhanced') {
      setReducedMotionState(false)
      setEnableParticlesState(true)
      setBackgroundEffectsState(true)
    }
  }

  const toggleTheme = () => {
    setTheme(theme === 'dark' ? 'light' : 'dark')
  }

  const setHighContrast = (enabled: boolean) => {
    setHighContrastState(enabled)
    storage.set('highContrast', enabled)
  }

  const setReducedMotion = (enabled: boolean) => {
    setReducedMotionState(enabled)
    storage.set('reducedMotion', enabled)
    
    if (enabled && animationLevel === 'enhanced') {
      setAnimationLevel('reduced')
    }
  }

  const setEnableParticles = (enabled: boolean) => {
    setEnableParticlesState(enabled)
    storage.set('enableParticles', enabled)
  }

  const setEnableBlur = (enabled: boolean) => {
    setEnableBlurState(enabled)
    storage.set('enableBlur', enabled)
  }

  const setNeonIntensity = (intensity: number) => {
    const clampedIntensity = Math.max(0, Math.min(200, intensity))
    setNeonIntensityState(clampedIntensity)
    storage.set('neonIntensity', clampedIntensity)
  }

  const setBackgroundEffects = (enabled: boolean) => {
    setBackgroundEffectsState(enabled)
    storage.set('backgroundEffects', enabled)
  }

  // Utility functions
  const getThemeClasses = (): string => {
    const classes = [theme]
    
    if (highContrast) classes.push('high-contrast')
    if (reducedMotion) classes.push('reduced-motion')
    
    return classes.join(' ')
  }

  const getClubThemeClasses = (): string => {
    const classes = [`club-${clubTheme}`]
    
    if (!enableParticles) classes.push('no-particles')
    if (!enableBlur) classes.push('no-blur')
    if (!backgroundEffects) classes.push('no-bg-effects')
    
    return classes.join(' ')
  }

  const isDark = theme === 'dark'
  const isLight = theme === 'light'

  const value: ThemeContextType = {
    theme,
    clubTheme,
    animationLevel,
    setTheme,
    setClubTheme,
    setAnimationLevel,
    toggleTheme,
    highContrast,
    setHighContrast,
    reducedMotion,
    setReducedMotion,
    enableParticles,
    setEnableParticles,
    enableBlur,
    setEnableBlur,
    neonIntensity,
    setNeonIntensity,
    backgroundEffects,
    setBackgroundEffects,
    getThemeClasses,
    getClubThemeClasses,
    isDark,
    isLight,
  }

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>
}

// Custom hook to use theme context
export function useTheme(): ThemeContextType {
  const context = useContext(ThemeContext)
  if (context === undefined) {
    throw new Error('useTheme must be used within a ThemeProvider')
  }
  return context
}

// Custom hook for responsive theme adjustments
export function useResponsiveTheme() {
  const {
    animationLevel,
    setAnimationLevel,
    enableParticles,
    setEnableParticles,
    enableBlur,
    setEnableBlur,
  } = useTheme()
  
  const [deviceType, setDeviceType] = useState<'mobile' | 'tablet' | 'desktop'>('desktop')

  useEffect(() => {
    const updateDeviceType = () => {
      const width = window.innerWidth
      if (width < 768) {
        setDeviceType('mobile')
      } else if (width < 1024) {
        setDeviceType('tablet')
      } else {
        setDeviceType('desktop')
      }
    }

    updateDeviceType()
    window.addEventListener('resize', updateDeviceType)
    return () => window.removeEventListener('resize', updateDeviceType)
  }, [])

  // Auto-adjust performance settings based on device
  useEffect(() => {
    if (deviceType === 'mobile') {
      // Reduce effects on mobile for better performance
      if (animationLevel === 'enhanced') {
        setAnimationLevel('normal')
      }
      if (enableParticles) {
        setEnableParticles(false)
      }
      if (enableBlur) {
        setEnableBlur(false)
      }
    }
  }, [deviceType])

  return {
    deviceType,
    isMobile: deviceType === 'mobile',
    isTablet: deviceType === 'tablet',
    isDesktop: deviceType === 'desktop',
  }
}

// Custom hook for accessibility features
export function useAccessibility() {
  const {
    highContrast,
    setHighContrast,
    reducedMotion,
    setReducedMotion,
    animationLevel,
    setAnimationLevel,
  } = useTheme()

  const enableAccessibilityMode = () => {
    setHighContrast(true)
    setReducedMotion(true)
    setAnimationLevel('none')
  }

  const disableAccessibilityMode = () => {
    setHighContrast(false)
    setReducedMotion(false)
    setAnimationLevel('normal')
  }

  const isAccessibilityMode = highContrast && reducedMotion && animationLevel === 'none'

  return {
    highContrast,
    setHighContrast,
    reducedMotion,
    setReducedMotion,
    enableAccessibilityMode,
    disableAccessibilityMode,
    isAccessibilityMode,
  }
}

// Custom hook for performance optimization
export function usePerformanceSettings() {
  const {
    enableParticles,
    setEnableParticles,
    enableBlur,
    setEnableBlur,
    backgroundEffects,
    setBackgroundEffects,
    animationLevel,
    setAnimationLevel,
  } = useTheme()

  const enableHighPerformance = () => {
    setEnableParticles(true)
    setEnableBlur(true)
    setBackgroundEffects(true)
    setAnimationLevel('enhanced')
  }

  const enableLowPerformance = () => {
    setEnableParticles(false)
    setEnableBlur(false)
    setBackgroundEffects(false)
    setAnimationLevel('reduced')
  }

  const getPerformanceLevel = (): 'low' | 'medium' | 'high' => {
    if (!enableParticles && !enableBlur && !backgroundEffects) {
      return 'low'
    }
    if (enableParticles && enableBlur && backgroundEffects && animationLevel === 'enhanced') {
      return 'high'
    }
    return 'medium'
  }

  return {
    enableParticles,
    setEnableParticles,
    enableBlur,
    setEnableBlur,
    backgroundEffects,
    setBackgroundEffects,
    enableHighPerformance,
    enableLowPerformance,
    performanceLevel: getPerformanceLevel(),
  }
}
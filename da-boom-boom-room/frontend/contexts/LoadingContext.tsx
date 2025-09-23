'use client'

import React, { createContext, useContext, useState, ReactNode, useCallback } from 'react'

interface LoadingState {
  id: string
  message?: string
  progress?: number
  type?: 'default' | 'upload' | 'payment' | 'stream' | 'auth'
}

interface LoadingContextType {
  // Global loading state
  isLoading: boolean
  loadingStates: LoadingState[]
  
  // Loading actions
  startLoading: (id: string, message?: string, type?: LoadingState['type']) => void
  stopLoading: (id: string) => void
  updateLoading: (id: string, updates: Partial<LoadingState>) => void
  clearAllLoading: () => void
  
  // Specific loading states
  isAuthLoading: boolean
  isStreamLoading: boolean
  isPaymentLoading: boolean
  isUploadLoading: boolean
  
  // Progress tracking
  setProgress: (id: string, progress: number) => void
  
  // Utility functions
  getLoadingState: (id: string) => LoadingState | undefined
  hasLoadingType: (type: LoadingState['type']) => boolean
}

const LoadingContext = createContext<LoadingContextType | undefined>(undefined)

interface LoadingProviderProps {
  children: ReactNode
}

export function LoadingProvider({ children }: LoadingProviderProps) {
  const [loadingStates, setLoadingStates] = useState<LoadingState[]>([])

  const startLoading = useCallback((id: string, message?: string, type: LoadingState['type'] = 'default') => {
    setLoadingStates(prev => {
      // Remove existing state with same id
      const filtered = prev.filter(state => state.id !== id)
      // Add new loading state
      return [...filtered, { id, message, type, progress: 0 }]
    })
  }, [])

  const stopLoading = useCallback((id: string) => {
    setLoadingStates(prev => prev.filter(state => state.id !== id))
  }, [])

  const updateLoading = useCallback((id: string, updates: Partial<LoadingState>) => {
    setLoadingStates(prev => 
      prev.map(state => 
        state.id === id ? { ...state, ...updates } : state
      )
    )
  }, [])

  const clearAllLoading = useCallback(() => {
    setLoadingStates([])
  }, [])

  const setProgress = useCallback((id: string, progress: number) => {
    updateLoading(id, { progress: Math.max(0, Math.min(100, progress)) })
  }, [updateLoading])

  const getLoadingState = useCallback((id: string) => {
    return loadingStates.find(state => state.id === id)
  }, [loadingStates])

  const hasLoadingType = useCallback((type: LoadingState['type']) => {
    return loadingStates.some(state => state.type === type)
  }, [loadingStates])

  // Computed states
  const isLoading = loadingStates.length > 0
  const isAuthLoading = hasLoadingType('auth')
  const isStreamLoading = hasLoadingType('stream')
  const isPaymentLoading = hasLoadingType('payment')
  const isUploadLoading = hasLoadingType('upload')

  const value: LoadingContextType = {
    isLoading,
    loadingStates,
    startLoading,
    stopLoading,
    updateLoading,
    clearAllLoading,
    isAuthLoading,
    isStreamLoading,
    isPaymentLoading,
    isUploadLoading,
    setProgress,
    getLoadingState,
    hasLoadingType,
  }

  return <LoadingContext.Provider value={value}>{children}</LoadingContext.Provider>
}

// Custom hook to use loading context
export function useLoading(): LoadingContextType {
  const context = useContext(LoadingContext)
  if (context === undefined) {
    throw new Error('useLoading must be used within a LoadingProvider')
  }
  return context
}

// Custom hook for managing specific loading operations
export function useLoadingOperation() {
  const { startLoading, stopLoading, updateLoading, setProgress } = useLoading()

  const withLoading = useCallback(async <T>(
    operation: () => Promise<T>,
    options: {
      id: string
      message?: string
      type?: LoadingState['type']
      onProgress?: (progress: number) => void
    }
  ): Promise<T> => {
    const { id, message, type, onProgress } = options
    
    try {
      startLoading(id, message, type)
      
      if (onProgress) {
        const progressInterval = setInterval(() => {
          // Simulate progress if no real progress is provided
          const currentState = loadingStates.find(s => s.id === id)
          if (currentState && currentState.progress !== undefined && currentState.progress < 90) {
            setProgress(id, currentState.progress + Math.random() * 10)
          }
        }, 500)
        
        const result = await operation()
        clearInterval(progressInterval)
        setProgress(id, 100)
        
        // Keep at 100% for a brief moment before removing
        setTimeout(() => stopLoading(id), 300)
        
        return result
      } else {
        const result = await operation()
        stopLoading(id)
        return result
      }
    } catch (error) {
      stopLoading(id)
      throw error
    }
  }, [startLoading, stopLoading, setProgress, loadingStates])

  return { withLoading }
}

// Custom hook for auth loading states
export function useAuthLoading() {
  const { startLoading, stopLoading, isAuthLoading } = useLoading()

  const startAuthLoading = (message: string = 'Authenticating...') => {
    startLoading('auth', message, 'auth')
  }

  const stopAuthLoading = () => {
    stopLoading('auth')
  }

  return {
    isAuthLoading,
    startAuthLoading,
    stopAuthLoading,
  }
}

// Custom hook for stream loading states
export function useStreamLoading() {
  const { startLoading, stopLoading, updateLoading, isStreamLoading } = useLoading()

  const startStreamLoading = (action: 'joining' | 'starting' | 'ending' | 'loading') => {
    const messages = {
      joining: 'Joining stream...',
      starting: 'Starting stream...',
      ending: 'Ending stream...',
      loading: 'Loading stream...',
    }
    startLoading('stream', messages[action], 'stream')
  }

  const updateStreamLoading = (message: string) => {
    updateLoading('stream', { message })
  }

  const stopStreamLoading = () => {
    stopLoading('stream')
  }

  return {
    isStreamLoading,
    startStreamLoading,
    updateStreamLoading,
    stopStreamLoading,
  }
}

// Custom hook for payment loading states
export function usePaymentLoading() {
  const { startLoading, stopLoading, setProgress, isPaymentLoading } = useLoading()

  const startPaymentLoading = (action: 'processing' | 'redirecting' | 'verifying') => {
    const messages = {
      processing: 'Processing payment...',
      redirecting: 'Redirecting to payment...',
      verifying: 'Verifying payment...',
    }
    startLoading('payment', messages[action], 'payment')
  }

  const updatePaymentProgress = (progress: number) => {
    setProgress('payment', progress)
  }

  const stopPaymentLoading = () => {
    stopLoading('payment')
  }

  return {
    isPaymentLoading,
    startPaymentLoading,
    updatePaymentProgress,
    stopPaymentLoading,
  }
}

// Custom hook for upload loading states
export function useUploadLoading() {
  const { startLoading, stopLoading, setProgress, isUploadLoading, getLoadingState } = useLoading()

  const startUploadLoading = (filename: string) => {
    startLoading('upload', `Uploading ${filename}...`, 'upload')
  }

  const updateUploadProgress = (progress: number) => {
    setProgress('upload', progress)
  }

  const stopUploadLoading = () => {
    stopLoading('upload')
  }

  const getUploadProgress = () => {
    const state = getLoadingState('upload')
    return state?.progress || 0
  }

  return {
    isUploadLoading,
    startUploadLoading,
    updateUploadProgress,
    stopUploadLoading,
    getUploadProgress,
  }
}

// Custom hook for batch loading operations
export function useBatchLoading() {
  const { startLoading, stopLoading, updateLoading } = useLoading()

  const startBatchLoading = (operations: { id: string; message: string }[]) => {
    operations.forEach(({ id, message }) => {
      startLoading(id, message)
    })
  }

  const stopBatchLoading = (ids: string[]) => {
    ids.forEach(id => stopLoading(id))
  }

  const updateBatchLoading = (updates: { id: string; updates: Partial<LoadingState> }[]) => {
    updates.forEach(({ id, updates: stateUpdates }) => {
      updateLoading(id, stateUpdates)
    })
  }

  return {
    startBatchLoading,
    stopBatchLoading,
    updateBatchLoading,
  }
}

// Custom hook for conditional loading
export function useConditionalLoading() {
  const { startLoading, stopLoading } = useLoading()

  const loadingIf = (condition: boolean, id: string, message?: string, type?: LoadingState['type']) => {
    if (condition) {
      startLoading(id, message, type)
    } else {
      stopLoading(id)
    }
  }

  return { loadingIf }
}

// Custom hook for debounced loading
export function useDebouncedLoading() {
  const { startLoading, stopLoading } = useLoading()
  const [timeouts, setTimeouts] = useState<Map<string, NodeJS.Timeout>>(new Map())

  const debouncedStartLoading = useCallback((
    id: string,
    message?: string,
    type?: LoadingState['type'],
    delay: number = 300
  ) => {
    // Clear existing timeout
    const existingTimeout = timeouts.get(id)
    if (existingTimeout) {
      clearTimeout(existingTimeout)
    }

    // Set new timeout
    const newTimeout = setTimeout(() => {
      startLoading(id, message, type)
      setTimeouts(prev => {
        const newMap = new Map(prev)
        newMap.delete(id)
        return newMap
      })
    }, delay)

    setTimeouts(prev => {
      const newMap = new Map(prev)
      newMap.set(id, newTimeout)
      return newMap
    })
  }, [startLoading, timeouts])

  const debouncedStopLoading = useCallback((id: string, delay: number = 300) => {
    // Clear any pending start
    const existingTimeout = timeouts.get(id)
    if (existingTimeout) {
      clearTimeout(existingTimeout)
      setTimeouts(prev => {
        const newMap = new Map(prev)
        newMap.delete(id)
        return newMap
      })
    }

    // Set stop timeout
    const stopTimeout = setTimeout(() => {
      stopLoading(id)
    }, delay)

    setTimeouts(prev => {
      const newMap = new Map(prev)
      newMap.set(`${id}_stop`, stopTimeout)
      return newMap
    })
  }, [stopLoading, timeouts])

  return {
    debouncedStartLoading,
    debouncedStopLoading,
  }
}
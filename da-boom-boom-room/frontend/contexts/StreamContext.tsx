'use client'

import React, { createContext, useContext, useEffect, useState, ReactNode } from 'react'
import { useQuery, useMutation, useQueryClient } from 'react-query'
import { streamsApi, Stream, Performer, handleApiError } from '@/lib/api'
import { useAuth } from './AuthContext'
import { useSocket } from './SocketContext'
import { toast } from 'react-hot-toast'

interface StreamContextType {
  // Current streams
  streams: Stream[]
  featuredStreams: Stream[]
  isLoadingStreams: boolean
  
  // Current viewing stream
  currentStream: Stream | null
  isWatchingStream: boolean
  
  // Stream management (for performers)
  isStreaming: boolean
  myStream: Stream | null
  
  // Actions
  refreshStreams: () => void
  joinStream: (streamId: string) => Promise<boolean>
  leaveCurrentStream: () => void
  startStream: (streamData: {
    title: string
    description?: string
    type: string
    isVREnabled?: boolean
    tags?: string[]
  }) => Promise<boolean>
  endStream: () => Promise<boolean>
  updateStream: (streamData: Partial<Stream>) => Promise<boolean>
  
  // Filters and search
  streamFilters: {
    type?: string
    isActive?: boolean
    search?: string
    tags?: string[]
    sortBy?: 'viewers' | 'recent' | 'rating'
  }
  setStreamFilters: (filters: any) => void
  
  // VR functionality
  enterVRMode: (streamId: string) => Promise<boolean>
  exitVRMode: () => void
  isVRMode: boolean
  vrStreamUrl: string | null
}

const StreamContext = createContext<StreamContextType | undefined>(undefined)

interface StreamProviderProps {
  children: ReactNode
}

export function StreamProvider({ children }: StreamProviderProps) {
  const [currentStream, setCurrentStream] = useState<Stream | null>(null)
  const [isWatchingStream, setIsWatchingStream] = useState(false)
  const [myStream, setMyStream] = useState<Stream | null>(null)
  const [isStreaming, setIsStreaming] = useState(false)
  const [isVRMode, setIsVRMode] = useState(false)
  const [vrStreamUrl, setVrStreamUrl] = useState<string | null>(null)
  const [streamFilters, setStreamFilters] = useState({
    type: undefined,
    isActive: true,
    search: undefined,
    tags: undefined,
    sortBy: 'viewers' as const,
  })

  const { user, isAuthenticated } = useAuth()
  const { joinStream: socketJoinStream, leaveStream: socketLeaveStream, isConnected } = useSocket()
  const queryClient = useQueryClient()

  // Fetch streams
  const {
    data: streamsData,
    isLoading: isLoadingStreams,
    refetch: refreshStreams,
  } = useQuery(
    ['streams', streamFilters],
    () => streamsApi.getStreams(streamFilters),
    {
      enabled: true,
      refetchInterval: 30000, // Refresh every 30 seconds
      onError: (error) => {
        console.error('Failed to fetch streams:', error)
      },
    }
  )

  const streams = streamsData?.data?.data?.data || []
  const featuredStreams = streams.filter((stream: Stream) => 
    stream.viewerCount > 10 || stream.performer.rating > 4.5
  ).slice(0, 6)

  // Check if user is currently streaming (for performers)
  useEffect(() => {
    if (user?.role === 'PERFORMER' && isAuthenticated) {
      const userStream = streams.find((stream: Stream) => 
        stream.performerId === user.id && stream.isActive
      )
      if (userStream) {
        setMyStream(userStream)
        setIsStreaming(true)
      } else {
        setMyStream(null)
        setIsStreaming(false)
      }
    }
  }, [streams, user, isAuthenticated])

  // Start stream mutation (for performers)
  const startStreamMutation = useMutation(
    (streamData: {
      title: string
      description?: string
      type: string
      isVREnabled?: boolean
      tags?: string[]
    }) => streamsApi.createStream(streamData),
    {
      onSuccess: (response) => {
        if (response.data.success && response.data.data) {
          setMyStream(response.data.data)
          setIsStreaming(true)
          toast.success('Stream started successfully!')
          refreshStreams()
        }
      },
      onError: (error) => {
        const errorMessage = handleApiError(error)
        toast.error(`Failed to start stream: ${errorMessage}`)
      },
    }
  )

  // End stream mutation (for performers)
  const endStreamMutation = useMutation(
    (streamId: string) => streamsApi.endStream(streamId),
    {
      onSuccess: () => {
        setMyStream(null)
        setIsStreaming(false)
        toast.success('Stream ended successfully!')
        refreshStreams()
      },
      onError: (error) => {
        const errorMessage = handleApiError(error)
        toast.error(`Failed to end stream: ${errorMessage}`)
      },
    }
  )

  // Update stream mutation (for performers)
  const updateStreamMutation = useMutation(
    ({ streamId, streamData }: { streamId: string; streamData: Partial<Stream> }) =>
      streamsApi.updateStream(streamId, streamData),
    {
      onSuccess: (response) => {
        if (response.data.success && response.data.data) {
          setMyStream(response.data.data)
          toast.success('Stream updated successfully!')
          refreshStreams()
        }
      },
      onError: (error) => {
        const errorMessage = handleApiError(error)
        toast.error(`Failed to update stream: ${errorMessage}`)
      },
    }
  )

  // Join stream mutation
  const joinStreamMutation = useMutation(
    (streamId: string) => streamsApi.joinStream(streamId),
    {
      onSuccess: (response, streamId) => {
        if (response.data.success) {
          const stream = streams.find((s: Stream) => s.id === streamId)
          if (stream) {
            setCurrentStream(stream)
            setIsWatchingStream(true)
            if (isConnected) {
              socketJoinStream(streamId)
            }
            toast.success(`Joined ${stream.performer.displayName}'s stream!`)
          }
        }
      },
      onError: (error) => {
        const errorMessage = handleApiError(error)
        toast.error(`Failed to join stream: ${errorMessage}`)
      },
    }
  )

  // Leave stream mutation
  const leaveStreamMutation = useMutation(
    (streamId: string) => streamsApi.leaveStream(streamId),
    {
      onSuccess: () => {
        if (currentStream && isConnected) {
          socketLeaveStream(currentStream.id)
        }
        setCurrentStream(null)
        setIsWatchingStream(false)
        setIsVRMode(false)
        setVrStreamUrl(null)
        toast.success('Left stream')
      },
      onError: (error) => {
        const errorMessage = handleApiError(error)
        toast.error(`Failed to leave stream: ${errorMessage}`)
      },
    }
  )

  // Get VR stream mutation
  const getVRStreamMutation = useMutation(
    (streamId: string) => streamsApi.getVRStream(streamId),
    {
      onSuccess: (response) => {
        if (response.data.success && response.data.data?.vrStreamUrl) {
          setVrStreamUrl(response.data.data.vrStreamUrl)
          setIsVRMode(true)
          toast.success('Entering VR mode...')
        }
      },
      onError: (error) => {
        const errorMessage = handleApiError(error)
        toast.error(`Failed to enter VR mode: ${errorMessage}`)
      },
    }
  )

  // Actions
  const joinStream = async (streamId: string): Promise<boolean> => {
    if (!isAuthenticated) {
      toast.error('Please log in to watch streams')
      return false
    }

    try {
      await joinStreamMutation.mutateAsync(streamId)
      return true
    } catch {
      return false
    }
  }

  const leaveCurrentStream = () => {
    if (currentStream) {
      leaveStreamMutation.mutate(currentStream.id)
    }
  }

  const startStream = async (streamData: {
    title: string
    description?: string
    type: string
    isVREnabled?: boolean
    tags?: string[]
  }): Promise<boolean> => {
    if (user?.role !== 'PERFORMER') {
      toast.error('Only performers can start streams')
      return false
    }

    try {
      await startStreamMutation.mutateAsync(streamData)
      return true
    } catch {
      return false
    }
  }

  const endStream = async (): Promise<boolean> => {
    if (!myStream) {
      toast.error('No active stream to end')
      return false
    }

    try {
      await endStreamMutation.mutateAsync(myStream.id)
      return true
    } catch {
      return false
    }
  }

  const updateStream = async (streamData: Partial<Stream>): Promise<boolean> => {
    if (!myStream) {
      toast.error('No active stream to update')
      return false
    }

    try {
      await updateStreamMutation.mutateAsync({
        streamId: myStream.id,
        streamData,
      })
      return true
    } catch {
      return false
    }
  }

  const enterVRMode = async (streamId: string): Promise<boolean> => {
    if (!currentStream || currentStream.id !== streamId) {
      toast.error('You must be watching the stream to enter VR mode')
      return false
    }

    if (!currentStream.isVREnabled) {
      toast.error('This stream does not support VR')
      return false
    }

    // Check VR support
    if (typeof window !== 'undefined' && !('xr' in navigator)) {
      toast.error('Your device does not support VR')
      return false
    }

    try {
      await getVRStreamMutation.mutateAsync(streamId)
      return true
    } catch {
      return false
    }
  }

  const exitVRMode = () => {
    setIsVRMode(false)
    setVrStreamUrl(null)
    toast.success('Exited VR mode')
  }

  const value: StreamContextType = {
    streams,
    featuredStreams,
    isLoadingStreams,
    currentStream,
    isWatchingStream,
    isStreaming,
    myStream,
    refreshStreams,
    joinStream,
    leaveCurrentStream,
    startStream,
    endStream,
    updateStream,
    streamFilters,
    setStreamFilters,
    enterVRMode,
    exitVRMode,
    isVRMode,
    vrStreamUrl,
  }

  return <StreamContext.Provider value={value}>{children}</StreamContext.Provider>
}

// Custom hook to use stream context
export function useStream(): StreamContextType {
  const context = useContext(StreamContext)
  if (context === undefined) {
    throw new Error('useStream must be used within a StreamProvider')
  }
  return context
}

// Custom hook for stream filtering
export function useStreamFilters() {
  const { streamFilters, setStreamFilters } = useStream()

  const updateFilter = (key: string, value: any) => {
    setStreamFilters(prev => ({ ...prev, [key]: value }))
  }

  const clearFilters = () => {
    setStreamFilters({
      type: undefined,
      isActive: true,
      search: undefined,
      tags: undefined,
      sortBy: 'viewers',
    })
  }

  const setSearch = (search: string) => {
    updateFilter('search', search || undefined)
  }

  const setType = (type: string) => {
    updateFilter('type', type || undefined)
  }

  const setSortBy = (sortBy: 'viewers' | 'recent' | 'rating') => {
    updateFilter('sortBy', sortBy)
  }

  const toggleTag = (tag: string) => {
    const currentTags = streamFilters.tags || []
    const newTags = currentTags.includes(tag)
      ? currentTags.filter(t => t !== tag)
      : [...currentTags, tag]
    updateFilter('tags', newTags.length > 0 ? newTags : undefined)
  }

  return {
    filters: streamFilters,
    updateFilter,
    clearFilters,
    setSearch,
    setType,
    setSortBy,
    toggleTag,
  }
}

// Custom hook for performer stream management
export function usePerformerStream() {
  const { user } = useAuth()
  const {
    isStreaming,
    myStream,
    startStream,
    endStream,
    updateStream,
  } = useStream()

  const isPerformer = user?.role === 'PERFORMER'

  if (!isPerformer) {
    return {
      isPerformer: false,
      isStreaming: false,
      myStream: null,
      startStream: async () => false,
      endStream: async () => false,
      updateStream: async () => false,
    }
  }

  return {
    isPerformer: true,
    isStreaming,
    myStream,
    startStream,
    endStream,
    updateStream,
  }
}

// Custom hook for stream viewer functionality
export function useStreamViewer() {
  const {
    currentStream,
    isWatchingStream,
    joinStream,
    leaveCurrentStream,
    enterVRMode,
    exitVRMode,
    isVRMode,
    vrStreamUrl,
  } = useStream()

  return {
    currentStream,
    isWatchingStream,
    joinStream,
    leaveCurrentStream,
    enterVRMode,
    exitVRMode,
    isVRMode,
    vrStreamUrl,
  }
}
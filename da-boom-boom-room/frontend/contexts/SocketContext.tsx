'use client'

import React, { createContext, useContext, useEffect, useState, ReactNode } from 'react'
import { io, Socket } from 'socket.io-client'
import { useAuth } from './AuthContext'
import { storage } from '@/lib/utils'
import { toast } from 'react-hot-toast'

interface SocketContextType {
  socket: Socket | null
  isConnected: boolean
  joinStream: (streamId: string) => void
  leaveStream: (streamId: string) => void
  sendChatMessage: (streamId: string, message: string) => void
  sendTip: (streamId: string, amount: number, message?: string) => void
  onStreamEvent: (event: string, callback: (data: any) => void) => void
  offStreamEvent: (event: string, callback?: (data: any) => void) => void
}

const SocketContext = createContext<SocketContextType | undefined>(undefined)

interface SocketProviderProps {
  children: ReactNode
}

export function SocketProvider({ children }: SocketProviderProps) {
  const [socket, setSocket] = useState<Socket | null>(null)
  const [isConnected, setIsConnected] = useState(false)
  const { user, isAuthenticated } = useAuth()

  useEffect(() => {
    if (isAuthenticated && user) {
      initializeSocket()
    } else {
      disconnectSocket()
    }

    return () => {
      disconnectSocket()
    }
  }, [isAuthenticated, user])

  const initializeSocket = () => {
    const token = storage.get('auth_token')
    if (!token) return

    const socketUrl = process.env.NEXT_PUBLIC_SOCKET_URL || 'http://localhost:5000'
    
    const newSocket = io(socketUrl, {
      auth: {
        token,
      },
      transports: ['websocket', 'polling'],
      timeout: 20000,
      reconnection: true,
      reconnectionAttempts: 5,
      reconnectionDelay: 1000,
    })

    // Connection events
    newSocket.on('connect', () => {
      console.log('Socket connected:', newSocket.id)
      setIsConnected(true)
      toast.success('Connected to live features')
    })

    newSocket.on('disconnect', (reason) => {
      console.log('Socket disconnected:', reason)
      setIsConnected(false)
      if (reason === 'io server disconnect') {
        // Server disconnected, try to reconnect
        newSocket.connect()
      }
    })

    newSocket.on('connect_error', (error) => {
      console.error('Socket connection error:', error)
      setIsConnected(false)
      toast.error('Failed to connect to live features')
    })

    newSocket.on('reconnect', (attemptNumber) => {
      console.log('Socket reconnected after', attemptNumber, 'attempts')
      setIsConnected(true)
      toast.success('Reconnected to live features')
    })

    newSocket.on('reconnect_error', (error) => {
      console.error('Socket reconnection error:', error)
    })

    newSocket.on('reconnect_failed', () => {
      console.error('Socket reconnection failed')
      toast.error('Failed to reconnect to live features')
    })

    // Authentication events
    newSocket.on('auth_error', (error) => {
      console.error('Socket auth error:', error)
      toast.error('Authentication failed for live features')
      disconnectSocket()
    })

    // Stream events
    newSocket.on('stream_started', (data) => {
      toast.success(`${data.performerName} started streaming!`)
    })

    newSocket.on('stream_ended', (data) => {
      toast.info(`${data.performerName} ended their stream`)
    })

    newSocket.on('viewer_joined', (data) => {
      console.log('Viewer joined:', data)
    })

    newSocket.on('viewer_left', (data) => {
      console.log('Viewer left:', data)
    })

    newSocket.on('viewer_count_updated', (data) => {
      console.log('Viewer count updated:', data)
    })

    // Chat events
    newSocket.on('chat_message', (data) => {
      console.log('Chat message received:', data)
    })

    newSocket.on('chat_message_deleted', (data) => {
      console.log('Chat message deleted:', data)
    })

    // Tip events
    newSocket.on('tip_received', (data) => {
      if (data.isAnonymous) {
        toast.success(`Anonymous tip of $${data.amount}!`)
      } else {
        toast.success(`${data.fromUsername} tipped $${data.amount}!`)
      }
    })

    newSocket.on('tip_animation', (data) => {
      console.log('Tip animation:', data)
      // Trigger tip animation in UI
    })

    // VR events
    newSocket.on('vr_session_started', (data) => {
      console.log('VR session started:', data)
    })

    newSocket.on('vr_session_ended', (data) => {
      console.log('VR session ended:', data)
    })

    // Error events
    newSocket.on('error', (error) => {
      console.error('Socket error:', error)
      toast.error(error.message || 'An error occurred')
    })

    newSocket.on('rate_limit', (data) => {
      toast.error(`Rate limited: ${data.message}`)
    })

    newSocket.on('insufficient_tier', (data) => {
      toast.error(`Insufficient subscription tier: ${data.message}`)
    })

    setSocket(newSocket)
  }

  const disconnectSocket = () => {
    if (socket) {
      socket.disconnect()
      setSocket(null)
      setIsConnected(false)
    }
  }

  const joinStream = (streamId: string) => {
    if (socket && isConnected) {
      socket.emit('join_stream', { streamId })
    }
  }

  const leaveStream = (streamId: string) => {
    if (socket && isConnected) {
      socket.emit('leave_stream', { streamId })
    }
  }

  const sendChatMessage = (streamId: string, message: string) => {
    if (socket && isConnected) {
      socket.emit('chat_message', {
        streamId,
        message: message.trim(),
        timestamp: new Date().toISOString(),
      })
    }
  }

  const sendTip = (streamId: string, amount: number, message?: string) => {
    if (socket && isConnected) {
      socket.emit('send_tip', {
        streamId,
        amount,
        message: message?.trim(),
        timestamp: new Date().toISOString(),
      })
    }
  }

  const onStreamEvent = (event: string, callback: (data: any) => void) => {
    if (socket) {
      socket.on(event, callback)
    }
  }

  const offStreamEvent = (event: string, callback?: (data: any) => void) => {
    if (socket) {
      if (callback) {
        socket.off(event, callback)
      } else {
        socket.off(event)
      }
    }
  }

  const value: SocketContextType = {
    socket,
    isConnected,
    joinStream,
    leaveStream,
    sendChatMessage,
    sendTip,
    onStreamEvent,
    offStreamEvent,
  }

  return <SocketContext.Provider value={value}>{children}</SocketContext.Provider>
}

// Custom hook to use socket context
export function useSocket(): SocketContextType {
  const context = useContext(SocketContext)
  if (context === undefined) {
    throw new Error('useSocket must be used within a SocketProvider')
  }
  return context
}

// Custom hook for stream-specific socket events
export function useStreamSocket(streamId: string | null) {
  const { socket, isConnected, joinStream, leaveStream } = useSocket()
  const [viewerCount, setViewerCount] = useState(0)
  const [chatMessages, setChatMessages] = useState<any[]>([])
  const [isJoined, setIsJoined] = useState(false)

  useEffect(() => {
    if (streamId && isConnected) {
      joinStream(streamId)
      setIsJoined(true)

      // Listen for stream-specific events
      const handleViewerCountUpdate = (data: any) => {
        if (data.streamId === streamId) {
          setViewerCount(data.count)
        }
      }

      const handleChatMessage = (data: any) => {
        if (data.streamId === streamId) {
          setChatMessages(prev => [...prev, data])
        }
      }

      const handleChatMessageDeleted = (data: any) => {
        if (data.streamId === streamId) {
          setChatMessages(prev => prev.filter(msg => msg.id !== data.messageId))
        }
      }

      socket?.on('viewer_count_updated', handleViewerCountUpdate)
      socket?.on('chat_message', handleChatMessage)
      socket?.on('chat_message_deleted', handleChatMessageDeleted)

      return () => {
        socket?.off('viewer_count_updated', handleViewerCountUpdate)
        socket?.off('chat_message', handleChatMessage)
        socket?.off('chat_message_deleted', handleChatMessageDeleted)
        
        if (isJoined) {
          leaveStream(streamId)
          setIsJoined(false)
        }
      }
    }
  }, [streamId, isConnected, socket])

  return {
    viewerCount,
    chatMessages,
    isJoined,
  }
}

// Custom hook for tip animations
export function useTipAnimations() {
  const { socket } = useSocket()
  const [tipAnimations, setTipAnimations] = useState<any[]>([])

  useEffect(() => {
    const handleTipAnimation = (data: any) => {
      const animationId = Date.now() + Math.random()
      setTipAnimations(prev => [...prev, { ...data, id: animationId }])
      
      // Remove animation after duration
      setTimeout(() => {
        setTipAnimations(prev => prev.filter(anim => anim.id !== animationId))
      }, data.duration || 3000)
    }

    socket?.on('tip_animation', handleTipAnimation)

    return () => {
      socket?.off('tip_animation', handleTipAnimation)
    }
  }, [socket])

  return tipAnimations
}

// Custom hook for VR session management
export function useVRSocket() {
  const { socket, isConnected } = useSocket()
  const [vrSession, setVrSession] = useState<any>(null)
  const [isVRSupported, setIsVRSupported] = useState(false)

  useEffect(() => {
    // Check VR support
    if (typeof window !== 'undefined' && 'xr' in navigator) {
      setIsVRSupported(true)
    }

    const handleVRSessionStarted = (data: any) => {
      setVrSession(data)
    }

    const handleVRSessionEnded = () => {
      setVrSession(null)
    }

    socket?.on('vr_session_started', handleVRSessionStarted)
    socket?.on('vr_session_ended', handleVRSessionEnded)

    return () => {
      socket?.off('vr_session_started', handleVRSessionStarted)
      socket?.off('vr_session_ended', handleVRSessionEnded)
    }
  }, [socket])

  const startVRSession = (streamId: string) => {
    if (socket && isConnected && isVRSupported) {
      socket.emit('start_vr_session', { streamId })
    }
  }

  const endVRSession = () => {
    if (socket && isConnected && vrSession) {
      socket.emit('end_vr_session', { sessionId: vrSession.id })
    }
  }

  return {
    vrSession,
    isVRSupported,
    startVRSession,
    endVRSession,
  }
}
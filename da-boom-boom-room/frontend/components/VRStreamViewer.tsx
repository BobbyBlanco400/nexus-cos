'use client'

import React, { useState, useRef, useEffect } from 'react'
import { useStream } from '@/contexts/StreamContext'
import { useAuth } from '@/contexts/AuthContext'
import { cn } from '@/lib/utils'
import { toast } from 'react-hot-toast'

interface VRStreamViewerProps {
  streamId: string
  streamUrl: string
  isVREnabled?: boolean
  onVRToggle?: (enabled: boolean) => void
}

interface VRControls {
  zoom: number
  rotation: { x: number; y: number; z: number }
  position: { x: number; y: number; z: number }
  fov: number
}

export function VRStreamViewer({ 
  streamId, 
  streamUrl, 
  isVREnabled = false, 
  onVRToggle 
}: VRStreamViewerProps) {
  const { user } = useAuth()
  const { currentStream, joinStream, leaveStream } = useStream()
  const videoRef = useRef<HTMLVideoElement>(null)
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const [isFullscreen, setIsFullscreen] = useState(false)
  const [isLoading, setIsLoading] = useState(true)
  const [vrSupported, setVRSupported] = useState(false)
  const [vrSession, setVRSession] = useState<any>(null)
  const [controls, setControls] = useState<VRControls>({
    zoom: 1,
    rotation: { x: 0, y: 0, z: 0 },
    position: { x: 0, y: 0, z: 0 },
    fov: 90
  })
  const [isDragging, setIsDragging] = useState(false)
  const [lastMousePos, setLastMousePos] = useState({ x: 0, y: 0 })
  const [viewMode, setViewMode] = useState<'normal' | '360' | 'vr'>('normal')

  useEffect(() => {
    // Check for WebXR support
    if ('xr' in navigator) {
      (navigator as any).xr.isSessionSupported('immersive-vr').then((supported: boolean) => {
        setVRSupported(supported)
      })
    }
  }, [])

  useEffect(() => {
    if (videoRef.current) {
      const video = videoRef.current
      video.addEventListener('loadstart', () => setIsLoading(true))
      video.addEventListener('canplay', () => setIsLoading(false))
      video.addEventListener('error', () => {
        setIsLoading(false)
        toast.error('Failed to load stream')
      })
    }
  }, [streamUrl])

  const handleVRToggle = async () => {
    if (!vrSupported) {
      toast.error('VR not supported on this device')
      return
    }

    try {
      if (!vrSession) {
        const session = await (navigator as any).xr.requestSession('immersive-vr')
        setVRSession(session)
        setViewMode('vr')
        onVRToggle?.(true)
        toast.success('VR mode activated')
      } else {
        await vrSession.end()
        setVRSession(null)
        setViewMode('normal')
        onVRToggle?.(false)
        toast.success('VR mode deactivated')
      }
    } catch (error) {
      toast.error('Failed to start VR session')
    }
  }

  const handle360Toggle = () => {
    if (viewMode === '360') {
      setViewMode('normal')
    } else {
      setViewMode('360')
      toast.success('360° mode activated - drag to look around')
    }
  }

  const handleFullscreen = async () => {
    if (!document.fullscreenElement) {
      await videoRef.current?.requestFullscreen()
      setIsFullscreen(true)
    } else {
      await document.exitFullscreen()
      setIsFullscreen(false)
    }
  }

  const handleMouseDown = (e: React.MouseEvent) => {
    if (viewMode === '360') {
      setIsDragging(true)
      setLastMousePos({ x: e.clientX, y: e.clientY })
    }
  }

  const handleMouseMove = (e: React.MouseEvent) => {
    if (isDragging && viewMode === '360') {
      const deltaX = e.clientX - lastMousePos.x
      const deltaY = e.clientY - lastMousePos.y
      
      setControls(prev => ({
        ...prev,
        rotation: {
          x: Math.max(-90, Math.min(90, prev.rotation.x + deltaY * 0.5)),
          y: prev.rotation.y + deltaX * 0.5,
          z: prev.rotation.z
        }
      }))
      
      setLastMousePos({ x: e.clientX, y: e.clientY })
    }
  }

  const handleMouseUp = () => {
    setIsDragging(false)
  }

  const handleZoom = (delta: number) => {
    setControls(prev => ({
      ...prev,
      zoom: Math.max(0.5, Math.min(3, prev.zoom + delta))
    }))
  }

  const resetView = () => {
    setControls({
      zoom: 1,
      rotation: { x: 0, y: 0, z: 0 },
      position: { x: 0, y: 0, z: 0 },
      fov: 90
    })
  }

  const getVideoStyle = () => {
    if (viewMode === '360') {
      return {
        transform: `
          scale(${controls.zoom})
          rotateX(${controls.rotation.x}deg)
          rotateY(${controls.rotation.y}deg)
          rotateZ(${controls.rotation.z}deg)
          translate3d(${controls.position.x}px, ${controls.position.y}px, ${controls.position.z}px)
        `,
        transformOrigin: 'center center',
        cursor: isDragging ? 'grabbing' : 'grab'
      }
    }
    return {}
  }

  return (
    <div className="relative w-full h-full bg-black rounded-lg overflow-hidden">
      {/* Loading Overlay */}
      {isLoading && (
        <div className="absolute inset-0 z-20 flex items-center justify-center bg-black/80">
          <div className="flex flex-col items-center space-y-4">
            <div className="loading-spinner w-12 h-12" />
            <p className="text-white font-display text-lg">Loading stream...</p>
          </div>
        </div>
      )}

      {/* Video Element */}
      <video
        ref={videoRef}
        src={streamUrl}
        autoPlay
        muted
        playsInline
        className={cn(
          'w-full h-full object-cover transition-transform duration-200',
          viewMode === '360' && 'perspective-1000 preserve-3d'
        )}
        style={getVideoStyle()}
        onMouseDown={handleMouseDown}
        onMouseMove={handleMouseMove}
        onMouseUp={handleMouseUp}
        onMouseLeave={handleMouseUp}
      />

      {/* Canvas for VR rendering */}
      <canvas
        ref={canvasRef}
        className={cn(
          'absolute inset-0 w-full h-full',
          viewMode === 'vr' ? 'block' : 'hidden'
        )}
      />

      {/* VR Controls Overlay */}
      <div className="absolute top-4 left-4 z-10 flex flex-col space-y-2">
        {/* View Mode Buttons */}
        <div className="flex space-x-2">
          <button
            onClick={() => setViewMode('normal')}
            className={cn(
              'px-3 py-2 rounded-lg text-sm font-semibold transition-all duration-300',
              viewMode === 'normal'
                ? 'bg-neon-pink text-white'
                : 'glass-dark text-gray-300 hover:text-white'
            )}
          >
            Normal
          </button>
          <button
            onClick={handle360Toggle}
            className={cn(
              'px-3 py-2 rounded-lg text-sm font-semibold transition-all duration-300',
              viewMode === '360'
                ? 'bg-neon-blue text-white'
                : 'glass-dark text-gray-300 hover:text-white'
            )}
          >
            360°
          </button>
          {vrSupported && (
            <button
              onClick={handleVRToggle}
              className={cn(
                'px-3 py-2 rounded-lg text-sm font-semibold transition-all duration-300 vr-glow',
                viewMode === 'vr'
                  ? 'bg-neon-green text-black'
                  : 'glass-dark text-gray-300 hover:text-white'
              )}
            >
              {vrSession ? 'Exit VR' : 'Enter VR'}
            </button>
          )}
        </div>

        {/* 360° Controls */}
        {viewMode === '360' && (
          <div className="glass-dark rounded-lg p-3 space-y-2">
            <div className="flex items-center space-x-2">
              <span className="text-xs text-gray-400">Zoom:</span>
              <button
                onClick={() => handleZoom(-0.1)}
                className="w-6 h-6 rounded bg-gray-700 hover:bg-gray-600 text-white text-xs"
              >
                −
              </button>
              <span className="text-xs text-white w-12 text-center">
                {(controls.zoom * 100).toFixed(0)}%
              </span>
              <button
                onClick={() => handleZoom(0.1)}
                className="w-6 h-6 rounded bg-gray-700 hover:bg-gray-600 text-white text-xs"
              >
                +
              </button>
            </div>
            <button
              onClick={resetView}
              className="w-full px-3 py-1 bg-gray-700 hover:bg-gray-600 text-white text-xs rounded"
            >
              Reset View
            </button>
          </div>
        )}
      </div>

      {/* Stream Info */}
      <div className="absolute top-4 right-4 z-10">
        <div className="glass-dark rounded-lg p-3">
          <div className="flex items-center space-x-2">
            <div className="w-2 h-2 bg-red-500 rounded-full animate-pulse" />
            <span className="text-white text-sm font-semibold">LIVE</span>
          </div>
          {currentStream?.viewerCount && (
            <p className="text-gray-400 text-xs mt-1">
              {currentStream.viewerCount} viewers
            </p>
          )}
        </div>
      </div>

      {/* Bottom Controls */}
      <div className="absolute bottom-4 left-1/2 transform -translate-x-1/2 z-10">
        <div className="flex items-center space-x-3 glass-dark rounded-lg p-3">
          {/* Fullscreen Button */}
          <button
            onClick={handleFullscreen}
            className="p-2 rounded-lg bg-gray-700 hover:bg-gray-600 text-white transition-colors duration-200"
            title="Toggle Fullscreen"
          >
            <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M3 4a1 1 0 011-1h4a1 1 0 010 2H6.414l2.293 2.293a1 1 0 11-1.414 1.414L5 6.414V8a1 1 0 01-2 0V4zm9 1a1 1 0 010-2h4a1 1 0 011 1v4a1 1 0 01-2 0V6.414l-2.293 2.293a1 1 0 11-1.414-1.414L13.586 5H12zm-9 7a1 1 0 012 0v1.586l2.293-2.293a1 1 0 111.414 1.414L6.414 15H8a1 1 0 010 2H4a1 1 0 01-1-1v-4zm13-1a1 1 0 011 1v4a1 1 0 01-1 1h-4a1 1 0 010-2h1.586l-2.293-2.293a1 1 0 111.414-1.414L15 13.586V12a1 1 0 011-1z" clipRule="evenodd" />
            </svg>
          </button>

          {/* Quality Selector */}
          <select className="bg-gray-700 text-white rounded-lg px-3 py-2 text-sm">
            <option value="auto">Auto</option>
            <option value="1080p">1080p</option>
            <option value="720p">720p</option>
            <option value="480p">480p</option>
          </select>

          {/* Volume Control */}
          <div className="flex items-center space-x-2">
            <button className="p-2 rounded-lg bg-gray-700 hover:bg-gray-600 text-white transition-colors duration-200">
              <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M9.383 3.076A1 1 0 0110 4v12a1 1 0 01-1.617.816L4.846 13H2a1 1 0 01-1-1V8a1 1 0 011-1h2.846l3.537-3.816a1 1 0 011.617.816zM16 8a2 2 0 11-4 0 2 2 0 014 0z" clipRule="evenodd" />
              </svg>
            </button>
            <input
              type="range"
              min="0"
              max="100"
              defaultValue="50"
              className="w-20 h-2 bg-gray-600 rounded-lg appearance-none cursor-pointer"
            />
          </div>
        </div>
      </div>

      {/* VR Instructions */}
      {viewMode === '360' && (
        <div className="absolute bottom-20 left-1/2 transform -translate-x-1/2 z-10">
          <div className="glass-dark rounded-lg p-3 text-center">
            <p className="text-white text-sm">
              Drag to look around • Scroll to zoom • Click reset to center
            </p>
          </div>
        </div>
      )}

      {/* VR Not Supported Message */}
      {!vrSupported && (
        <div className="absolute bottom-4 right-4 z-10">
          <div className="glass-dark rounded-lg p-3">
            <p className="text-gray-400 text-xs">
              VR not supported on this device
            </p>
          </div>
        </div>
      )}
    </div>
  )
}

export default VRStreamViewer
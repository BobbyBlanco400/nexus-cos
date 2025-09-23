'use client'

import React from 'react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
import { Elements } from '@stripe/react-stripe-js'
import { loadStripe } from '@stripe/stripe-js'
// import { AuthProvider } from '@/contexts/AuthContext'
// import { SocketProvider } from '@/contexts/SocketContext'
// import { StreamProvider } from '@/contexts/StreamContext'
// import { TipProvider } from '@/contexts/TipContext'
// import { ThemeProvider } from '@/contexts/ThemeContext'
// import { ErrorBoundary } from '@/components/ErrorBoundary'
// import { LoadingProvider } from '@/contexts/LoadingContext'

// Initialize Stripe
const stripePromise = process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY 
  ? loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY)
  : Promise.resolve(null)

// Create a client for React Query
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 3,
      retryDelay: (attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30000),
      staleTime: 5 * 60 * 1000, // 5 minutes
      cacheTime: 10 * 60 * 1000, // 10 minutes
      refetchOnWindowFocus: false,
      refetchOnReconnect: true,
    },
    mutations: {
      retry: 1,
      retryDelay: 1000,
    },
  },
})

interface ProvidersProps {
  children: React.ReactNode
}

export function Providers({ children }: { children: React.ReactNode }) {
  const [stripe, setStripe] = React.useState<any>(null)
  
  React.useEffect(() => {
    stripePromise.then(setStripe)
  }, [])
  
  return (
    <QueryClientProvider client={queryClient}>
      {stripe ? (
        <Elements stripe={stripe}>
          {children}
        </Elements>
      ) : (
        children
      )}
      {process.env.NODE_ENV === 'development' && (
        <ReactQueryDevtools initialIsOpen={false} />
      )}
    </QueryClientProvider>
  )
}
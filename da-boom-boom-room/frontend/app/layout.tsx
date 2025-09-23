import type { Metadata } from 'next'
import { Inter, Orbitron } from 'next/font/google'
import './globals.css'
import { Providers } from './providers'
import { Toaster } from 'react-hot-toast'
import { cn } from '@/lib/utils'

const inter = Inter({ 
  subsets: ['latin'],
  variable: '--font-inter',
  display: 'swap',
})

const orbitron = Orbitron({ 
  subsets: ['latin'],
  variable: '--font-orbitron',
  display: 'swap',
})

export const metadata: Metadata = {
  title: {
    default: 'Da Boom Boom Room Live! - Powered by Nexus COS',
    template: '%s | Da Boom Boom Room Live!'
  },
  description: 'Experience the future of adult entertainment with our revolutionary virtual strip club featuring live streaming, VR experiences, tiered subscriptions, and virtual tipping. Powered by Nexus COS.',
  icons: {
    icon: '/favicon.ico',
    shortcut: '/favicon.ico',
    apple: '/favicon.ico',
  },
  keywords: [
    'virtual strip club',
    'live streaming',
    'VR adult entertainment',
    'subscription platform',
    'virtual tipping',
    'adult webcam',
    'interactive entertainment',
    'premium content'
  ],
  authors: [{ name: 'Da Boom Boom Room Team' }],
  creator: 'Da Boom Boom Room',
  publisher: 'Da Boom Boom Room',
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  metadataBase: new URL(process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000'),
  alternates: {
    canonical: '/',
  },
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: '/',
    title: 'Da Boom Boom Room Live! - World\'s First Virtual Strip Club',
    description: 'Experience the future of adult entertainment with our revolutionary virtual strip club featuring live streaming, VR experiences, tiered subscriptions, and virtual tipping.',
    siteName: 'Da Boom Boom Room Live!',
    images: [
      {
        url: '/og-image.jpg',
        width: 1200,
        height: 630,
        alt: 'Da Boom Boom Room Live!',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Da Boom Boom Room Live! - World\'s First Virtual Strip Club',
    description: 'Experience the future of adult entertainment with our revolutionary virtual strip club.',
    images: ['/og-image.jpg'],
    creator: '@daboombooomroom',
  },
  robots: {
    index: process.env.NODE_ENV === 'production',
    follow: process.env.NODE_ENV === 'production',
    googleBot: {
      index: process.env.NODE_ENV === 'production',
      follow: process.env.NODE_ENV === 'production',
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  verification: {
    google: process.env.GOOGLE_VERIFICATION_ID,
  },
  category: 'entertainment',
  classification: 'Adult Entertainment',
  other: {
    'age-rating': '18+',
    'content-rating': 'mature',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className="dark" suppressHydrationWarning>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />
        <meta name="theme-color" content="#ff0080" />
        <meta name="color-scheme" content="dark" />
        <meta name="rating" content="adult" />
        <meta name="age-rating" content="18+" />
        <link rel="icon" href="/favicon.ico" />
        <link rel="apple-touch-icon" href="/apple-touch-icon.png" />
        <link rel="manifest" href="/manifest.json" />
        
        {/* Preload critical fonts */}
        <link
          rel="preload"
          href="https://fonts.googleapis.com/css2?family=Inter:wght@100;200;300;400;500;600;700;800;900&display=swap"
          as="style"
        />
        <link
          rel="preload"
          href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;500;600;700;800;900&display=swap"
          as="style"
        />
        
        {/* Age verification and content warnings */}
        <script
          dangerouslySetInnerHTML={{
            __html: `
              // Age verification check
              if (typeof window !== 'undefined') {
                const ageVerified = localStorage.getItem('ageVerified');
                if (!ageVerified) {
                  // Redirect to age verification page
                  window.location.href = '/age-verification';
                }
              }
            `,
          }}
        />
      </head>
      <body 
        className={cn(
          'min-h-screen bg-club-dark font-sans antialiased',
          inter.variable,
          orbitron.variable
        )}
      >
        <Providers>
          {/* Background effects */}
          <div className="fixed inset-0 z-0">
            <div className="absolute inset-0 bg-gradient-to-br from-black via-purple-900/20 to-black" />
            <div className="absolute inset-0 bg-[radial-gradient(circle_at_50%_50%,rgba(255,0,128,0.1),transparent_50%)]" />
            <div className="absolute inset-0 bg-[radial-gradient(circle_at_80%_20%,rgba(128,0,255,0.1),transparent_50%)]" />
            <div className="absolute inset-0 bg-[radial-gradient(circle_at_20%_80%,rgba(0,128,255,0.1),transparent_50%)]" />
          </div>
          
          {/* Main content */}
          <div className="relative z-10">
            {children}
          </div>
          
          {/* Toast notifications */}
          <Toaster
            position="top-right"
            toastOptions={{
              duration: 4000,
              style: {
                background: 'rgba(0, 0, 0, 0.8)',
                color: '#fff',
                border: '1px solid rgba(255, 0, 128, 0.3)',
                borderRadius: '8px',
                backdropFilter: 'blur(10px)',
              },
              success: {
                iconTheme: {
                  primary: '#00ff80',
                  secondary: '#000',
                },
              },
              error: {
                iconTheme: {
                  primary: '#ff0040',
                  secondary: '#000',
                },
              },
            }}
          />
          
          {/* Loading overlay for page transitions */}
          <div id="loading-overlay" className="hidden fixed inset-0 z-50 bg-black/80 backdrop-blur-sm">
            <div className="flex items-center justify-center min-h-screen">
              <div className="flex flex-col items-center space-y-4">
                <div className="loading-spinner w-12 h-12" />
                <p className="text-white font-display text-lg">Loading...</p>
              </div>
            </div>
          </div>
          
          {/* Age verification modal backdrop */}
          <div id="age-verification-backdrop" className="hidden fixed inset-0 z-50 bg-black" />
        </Providers>
        
        {/* Analytics and tracking scripts */}
        {process.env.NODE_ENV === 'production' && (
          <>
            {/* Google Analytics */}
            {process.env.NEXT_PUBLIC_GA_ID && (
              <>
                <script
                  async
                  src={`https://www.googletagmanager.com/gtag/js?id=${process.env.NEXT_PUBLIC_GA_ID}`}
                />
                <script
                  dangerouslySetInnerHTML={{
                    __html: `
                      window.dataLayer = window.dataLayer || [];
                      function gtag(){dataLayer.push(arguments);}
                      gtag('js', new Date());
                      gtag('config', '${process.env.NEXT_PUBLIC_GA_ID}', {
                        page_title: document.title,
                        page_location: window.location.href,
                      });
                    `,
                  }}
                />
              </>
            )}
            
            {/* Hotjar */}
            {process.env.NEXT_PUBLIC_HOTJAR_ID && (
              <script
                dangerouslySetInnerHTML={{
                  __html: `
                    (function(h,o,t,j,a,r){
                      h.hj=h.hj||function(){(h.hj.q=h.hj.q||[]).push(arguments)};
                      h._hjSettings={hjid:${process.env.NEXT_PUBLIC_HOTJAR_ID},hjsv:6};
                      a=o.getElementsByTagName('head')[0];
                      r=o.createElement('script');r.async=1;
                      r.src=t+h._hjSettings.hjid+j+h._hjSettings.hjsv;
                      a.appendChild(r);
                    })(window,document,'https://static.hotjar.com/c/hotjar-','.js?sv=');
                  `,
                }}
              />
            )}
          </>
        )}
        
        {/* Service Worker Registration */}
        <script
          dangerouslySetInnerHTML={{
            __html: `
              if ('serviceWorker' in navigator) {
                window.addEventListener('load', function() {
                  navigator.serviceWorker.register('/sw.js')
                    .then(function(registration) {
                      console.log('SW registered: ', registration);
                    })
                    .catch(function(registrationError) {
                      console.log('SW registration failed: ', registrationError);
                    });
                });
              }
            `,
          }}
        />
      </body>
    </html>
  )
}
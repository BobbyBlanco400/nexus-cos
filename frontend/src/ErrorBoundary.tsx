import { Component, ErrorInfo, ReactNode } from 'react'

interface Props {
  children: ReactNode
}

interface State {
  hasError: boolean
  error: Error | null
  errorInfo: ErrorInfo | null
}

class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props)
    this.state = {
      hasError: false,
      error: null,
      errorInfo: null
    }
  }

  static getDerivedStateFromError(error: Error): State {
    // Update state so the next render will show the fallback UI
    return {
      hasError: true,
      error,
      errorInfo: null
    }
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    // Log the error to console for debugging
    console.error('❌ React Error Boundary caught an error:', error, errorInfo)
    this.setState({
      error,
      errorInfo
    })
  }

  render() {
    if (this.state.hasError) {
      return (
        <div style={{
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          alignItems: 'center',
          minHeight: '100vh',
          background: 'linear-gradient(135deg, #000000 0%, #1a0033 50%, #330066 100%)',
          color: 'white',
          fontFamily: 'system-ui, sans-serif',
          textAlign: 'center',
          padding: '20px'
        }}>
          <h1 style={{ color: '#8b5cf6', marginBottom: '20px', fontSize: '2rem' }}>
            ⚠️ Something Went Wrong
          </h1>
          <p style={{ maxWidth: '600px', lineHeight: '1.6', marginBottom: '20px' }}>
            Club Saditty encountered an unexpected error. Our technical team has been notified.
          </p>
          {this.state.error && (
            <details style={{
              maxWidth: '800px',
              background: 'rgba(0,0,0,0.5)',
              padding: '20px',
              borderRadius: '10px',
              textAlign: 'left',
              cursor: 'pointer',
              border: '2px solid #8b5cf6'
            }}>
              <summary style={{ 
                fontWeight: 'bold', 
                marginBottom: '10px',
                cursor: 'pointer',
                color: '#8b5cf6'
              }}>
                🔍 Error Details (Click to expand)
              </summary>
              <div style={{ 
                fontFamily: 'monospace', 
                fontSize: '0.9rem',
                whiteSpace: 'pre-wrap',
                wordBreak: 'break-word'
              }}>
                <strong>Error:</strong> {this.state.error.toString()}
                {this.state.errorInfo && (
                  <>
                    <br /><br />
                    <strong>Component Stack:</strong>
                    <br />
                    {this.state.errorInfo.componentStack}
                  </>
                )}
              </div>
            </details>
          )}
          <button
            onClick={() => window.location.reload()}
            style={{
              marginTop: '30px',
              padding: '15px 30px',
              fontSize: '1rem',
              fontWeight: 'bold',
              color: 'white',
              background: '#8b5cf6',
              border: 'none',
              borderRadius: '10px',
              cursor: 'pointer',
              transition: 'all 0.3s ease',
              boxShadow: '0 4px 15px rgba(139, 92, 246, 0.4)'
            }}
            onMouseOver={(e) => {
              e.currentTarget.style.background = '#a78bfa'
              e.currentTarget.style.transform = 'translateY(-2px)'
            }}
            onMouseOut={(e) => {
              e.currentTarget.style.background = '#8b5cf6'
              e.currentTarget.style.transform = 'translateY(0)'
            }}
          >
            🔄 Reload Application
          </button>
          <p style={{ marginTop: '20px', opacity: '0.7', fontSize: '0.9rem' }}>
            If the problem persists, please contact support.
          </p>
        </div>
      )
    }

    return this.props.children
  }
}

export default ErrorBoundary

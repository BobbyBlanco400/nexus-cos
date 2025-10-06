import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'
import ErrorBoundary from './ErrorBoundary.tsx'

// Log that the script is loading
console.log('✅ Nexus COS Frontend - main.tsx loaded')

// Ensure the root element exists before mounting
const rootElement = document.getElementById('root')

if (!rootElement) {
  console.error('❌ FATAL: Root element not found in DOM')
  document.body.innerHTML = `
    <div style="
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      background: linear-gradient(135deg, #000000 0%, #1a0033 50%, #330066 100%);
      color: white;
      font-family: system-ui, sans-serif;
      text-align: center;
      padding: 20px;
    ">
      <h1 style="color: #8b5cf6; margin-bottom: 20px;">⚠️ Application Error</h1>
      <p style="max-width: 600px; line-height: 1.6;">
        Unable to mount the Nexus COS application. The root element is missing from the HTML.
        Please ensure the application is properly deployed.
      </p>
      <p style="margin-top: 20px; opacity: 0.7;">Check browser console for details.</p>
    </div>
  `
} else {
  console.log('✅ Root element found, mounting React app...')
  try {
    createRoot(rootElement).render(
      <StrictMode>
        <ErrorBoundary>
          <App />
        </ErrorBoundary>
      </StrictMode>,
    )
    console.log('✅ React app mounted successfully')
  } catch (error) {
    console.error('❌ Error mounting React app:', error)
    rootElement.innerHTML = `
      <div style="
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        min-height: 100vh;
        background: linear-gradient(135deg, #000000 0%, #1a0033 50%, #330066 100%);
        color: white;
        font-family: system-ui, sans-serif;
        text-align: center;
        padding: 20px;
      ">
        <h1 style="color: #8b5cf6; margin-bottom: 20px;">⚠️ Application Error</h1>
        <p style="max-width: 600px; line-height: 1.6;">
          Failed to mount the Nexus COS application due to an error.
        </p>
        <p style="margin-top: 20px; font-family: monospace; background: rgba(0,0,0,0.5); padding: 10px; border-radius: 5px;">
          ${error instanceof Error ? error.message : String(error)}
        </p>
        <p style="margin-top: 20px; opacity: 0.7;">Check browser console for full stack trace.</p>
      </div>
    `
  }
}

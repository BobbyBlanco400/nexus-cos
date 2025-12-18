/**
 * Nexus COS Beta - Main Entry Point
 * Beta testing environment with X-Nexus-Handshake: beta-55-45-17
 */

import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './App';
import './index.css';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
);

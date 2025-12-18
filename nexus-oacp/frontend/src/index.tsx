/**
 * Nexus OACP - Owner/Admin Control Panel
 * Main entry point for the control panel application
 * 
 * Manages: Beta, CIM-B, PWA, NexusVision, HoloCore, and 19+ Mini Platforms
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

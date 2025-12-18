/**
 * Nexus COS Beta App
 * Beta testing environment with handshake enforcement
 */

import React from 'react';
import BetaDashboard from './components/BetaDashboard';

const App: React.FC = () => {
  return (
    <div className="app">
      <BetaDashboard />
    </div>
  );
};

export default App;

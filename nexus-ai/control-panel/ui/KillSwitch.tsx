/**
 * N.E.X.U.S AI Control Panel - Kill Switch Component
 * 
 * Emergency control interface (Founder Authorization Required)
 * 
 * @module control-panel/ui/KillSwitch
 */

import React, { useState, useEffect } from 'react';

interface LockdownState {
  active: boolean;
  level: string;
  reason: string;
  initiatedAt: number;
}

const KillSwitch: React.FC = () => {
  const [lockdownState, setLockdownState] = useState<LockdownState | null>(null);
  const [founderCode, setFounderCode] = useState('');
  const [reason, setReason] = useState('');
  const [isProcessing, setIsProcessing] = useState(false);
  const [message, setMessage] = useState('');

  useEffect(() => {
    fetchLockdownState();
    const interval = setInterval(fetchLockdownState, 3000);
    return () => clearInterval(interval);
  }, []);

  const fetchLockdownState = async () => {
    try {
      const response = await fetch('/api/emergency/status');
      const data = await response.json();
      setLockdownState(data);
    } catch (error) {
      console.error('Failed to fetch lockdown state:', error);
    }
  };

  const handleLockdownAll = async () => {
    if (!founderCode || founderCode.length < 8) {
      setMessage('Error: Founder code must be at least 8 characters');
      return;
    }

    if (!reason) {
      setMessage('Error: Reason is required for lockdown');
      return;
    }

    if (!window.confirm('⚠️  CONFIRM EMERGENCY LOCKDOWN?\n\nThis will immediately stop all casino operations.')) {
      return;
    }

    setIsProcessing(true);
    setMessage('');

    try {
      const response = await fetch('/api/emergency/lockdown', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'x-user-tier': 'founder'
        },
        body: JSON.stringify({ founderCode, reason })
      });

      const data = await response.json();

      if (response.ok) {
        setMessage(`✅ Lockdown activated: ${data.affectedCasinos} casinos affected`);
        setFounderCode('');
        setReason('');
      } else {
        setMessage(`❌ ${data.error}`);
      }
    } catch (error) {
      setMessage('❌ Failed to execute lockdown');
    } finally {
      setIsProcessing(false);
    }
  };

  const handleFreezeWallets = async () => {
    if (!founderCode || founderCode.length < 8) {
      setMessage('Error: Founder code must be at least 8 characters');
      return;
    }

    if (!window.confirm('⚠️  CONFIRM WALLET FREEZE?\n\nThis will freeze ALL user wallets immediately.')) {
      return;
    }

    setIsProcessing(true);
    setMessage('');

    try {
      const response = await fetch('/api/emergency/freeze-wallets', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'x-user-tier': 'founder'
        },
        body: JSON.stringify({ founderCode, reason: reason || 'Emergency freeze' })
      });

      const data = await response.json();

      if (response.ok) {
        setMessage('✅ All wallets frozen');
        setFounderCode('');
      } else {
        setMessage(`❌ ${data.error}`);
      }
    } catch (error) {
      setMessage('❌ Failed to freeze wallets');
    } finally {
      setIsProcessing(false);
    }
  };

  const handleLiftLockdown = async () => {
    if (!founderCode || founderCode.length < 8) {
      setMessage('Error: Founder code required');
      return;
    }

    if (!window.confirm('Lift emergency lockdown and restore normal operations?')) {
      return;
    }

    setIsProcessing(true);
    setMessage('');

    try {
      const response = await fetch('/api/emergency/lift', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'x-user-tier': 'founder'
        },
        body: JSON.stringify({ founderCode })
      });

      const data = await response.json();

      if (response.ok) {
        setMessage('✅ Lockdown lifted');
        setFounderCode('');
        setReason('');
      } else {
        setMessage(`❌ ${data.error}`);
      }
    } catch (error) {
      setMessage('❌ Failed to lift lockdown');
    } finally {
      setIsProcessing(false);
    }
  };

  return (
    <div style={styles.container}>
      <h3 style={styles.title}>🚨 EMERGENCY CONTROL</h3>
      
      {lockdownState?.active && (
        <div style={styles.alert}>
          <strong>⚠️  LOCKDOWN ACTIVE</strong>
          <p>Level: {lockdownState.level.toUpperCase()}</p>
          <p>Reason: {lockdownState.reason}</p>
        </div>
      )}

      <div style={styles.inputSection}>
        <input
          type="password"
          placeholder="Founder Authorization Code"
          value={founderCode}
          onChange={(e) => setFounderCode(e.target.value)}
          style={styles.input}
          disabled={isProcessing}
        />
        <input
          type="text"
          placeholder="Reason for action"
          value={reason}
          onChange={(e) => setReason(e.target.value)}
          style={styles.input}
          disabled={isProcessing}
        />
      </div>

      <div style={styles.buttonRow}>
        <button
          onClick={handleLockdownAll}
          disabled={isProcessing || lockdownState?.active}
          style={{
            ...styles.button,
            ...styles.dangerButton,
            ...(isProcessing || lockdownState?.active ? styles.disabledButton : {})
          }}
        >
          {isProcessing ? 'PROCESSING...' : '[ LOCKDOWN ALL WORLDS ]'}
        </button>
        <button
          onClick={handleFreezeWallets}
          disabled={isProcessing || lockdownState?.active}
          style={{
            ...styles.button,
            ...styles.dangerButton,
            ...(isProcessing || lockdownState?.active ? styles.disabledButton : {})
          }}
        >
          {isProcessing ? 'PROCESSING...' : '[ FREEZE ALL WALLETS ]'}
        </button>
        {lockdownState?.active && (
          <button
            onClick={handleLiftLockdown}
            disabled={isProcessing}
            style={{
              ...styles.button,
              ...styles.successButton,
              ...(isProcessing ? styles.disabledButton : {})
            }}
          >
            {isProcessing ? 'PROCESSING...' : '[ LIFT LOCKDOWN ]'}
          </button>
        )}
      </div>

      {message && (
        <div style={styles.message}>
          {message}
        </div>
      )}

      <p style={styles.subtitle}>Founder Authorization Required</p>
    </div>
  );
};

const styles: Record<string, React.CSSProperties> = {
  container: {
    border: '2px solid #ff0000',
    padding: '20px',
    backgroundColor: '#1a0000'
  },
  title: {
    margin: 0,
    marginBottom: '15px',
    fontSize: '16px',
    color: '#ff0000',
    borderBottom: '1px solid #ff0000',
    paddingBottom: '10px'
  },
  alert: {
    padding: '15px',
    backgroundColor: '#ff000020',
    border: '1px solid #ff0000',
    marginBottom: '15px',
    color: '#ff0000'
  },
  inputSection: {
    display: 'flex',
    gap: '10px',
    marginBottom: '15px'
  },
  input: {
    flex: 1,
    padding: '10px',
    backgroundColor: '#0a0a0a',
    border: '1px solid #333',
    color: '#00ff00',
    fontFamily: 'monospace',
    fontSize: '12px'
  },
  buttonRow: {
    display: 'flex',
    gap: '10px',
    marginBottom: '15px'
  },
  button: {
    flex: 1,
    padding: '15px',
    fontSize: '12px',
    fontFamily: 'monospace',
    fontWeight: 'bold',
    cursor: 'pointer',
    border: '2px solid',
    transition: 'all 0.2s'
  },
  dangerButton: {
    backgroundColor: '#0a0a0a',
    color: '#ff0000',
    borderColor: '#ff0000'
  },
  successButton: {
    backgroundColor: '#0a0a0a',
    color: '#00ff00',
    borderColor: '#00ff00'
  },
  disabledButton: {
    opacity: 0.5,
    cursor: 'not-allowed'
  },
  message: {
    padding: '10px',
    backgroundColor: '#0a0a0a',
    border: '1px solid #333',
    marginBottom: '10px',
    fontSize: '12px'
  },
  subtitle: {
    margin: 0,
    fontSize: '10px',
    color: '#888',
    fontStyle: 'italic',
    textAlign: 'center'
  }
};

export default KillSwitch;

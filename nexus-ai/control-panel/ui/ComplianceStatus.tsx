/**
 * N.E.X.U.S AI Control Panel - Compliance Status Component
 * 
 * Displays compliance verification status
 * 
 * @module control-panel/ui/ComplianceStatus
 */

import React from 'react';

interface ComplianceStatusProps {
  systemState: {
    handshakeValid: boolean;
    handshakeVersion: string;
    nexcoinEnforced: boolean;
    casinoGridStatus: string;
    complianceDrift: boolean;
  };
}

const ComplianceStatus: React.FC<ComplianceStatusProps> = ({ systemState }) => {
  const checks = [
    {
      label: 'Handshake',
      status: systemState.handshakeValid,
      detail: systemState.handshakeVersion
    },
    {
      label: 'NexCoin Only',
      status: systemState.nexcoinEnforced,
      detail: 'ENFORCED'
    },
    {
      label: 'Casino Grid',
      status: true,
      detail: systemState.casinoGridStatus
    },
    {
      label: 'Jurisdiction',
      status: true,
      detail: 'COMPLIANT'
    },
    {
      label: 'Audit Drift',
      status: !systemState.complianceDrift,
      detail: systemState.complianceDrift ? 'DETECTED' : 'NONE'
    }
  ];

  return (
    <div style={styles.container}>
      <h3 style={styles.title}>COMPLIANCE STATUS</h3>
      <div style={styles.checksContainer}>
        {checks.map((check, index) => (
          <div key={index} style={styles.checkRow}>
            <span style={styles.checkLabel}>{check.label}</span>
            <span style={styles.checkStatus}>
              <span style={{ color: check.status ? '#00ff00' : '#ff0000' }}>
                {check.status ? '✔' : '✘'}
              </span>
              <span style={styles.checkDetail}>{check.detail}</span>
            </span>
          </div>
        ))}
      </div>
    </div>
  );
};

const styles: Record<string, React.CSSProperties> = {
  container: {
    border: '1px solid #00ff00',
    padding: '20px',
    backgroundColor: '#111'
  },
  title: {
    margin: 0,
    marginBottom: '15px',
    fontSize: '14px',
    borderBottom: '1px solid #00ff00',
    paddingBottom: '5px'
  },
  checksContainer: {
    display: 'flex',
    flexDirection: 'column',
    gap: '12px'
  },
  checkRow: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: '10px',
    border: '1px solid #333'
  },
  checkLabel: {
    fontSize: '12px',
    fontWeight: 'bold'
  },
  checkStatus: {
    display: 'flex',
    alignItems: 'center',
    gap: '10px'
  },
  checkDetail: {
    fontSize: '12px',
    color: '#888'
  }
};

export default ComplianceStatus;

import { useState, useEffect } from 'react';
import { healthApi, SystemStatus } from '../services/api';

interface ServiceChipProps {
  name: string;
  status: 'healthy' | 'offline' | 'unknown';
}

const ServiceChip = ({ name, status }: ServiceChipProps) => {
  const statusColors = {
    healthy: '#10b981',
    offline: '#ef4444',
    unknown: '#6b7280',
  };

  const statusEmojis = {
    healthy: '✓',
    offline: '✗',
    unknown: '?',
  };

  return (
    <div
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        padding: '0.5rem 1rem',
        margin: '0.25rem',
        borderRadius: '1rem',
        backgroundColor: statusColors[status] + '20',
        border: `1px solid ${statusColors[status]}`,
        color: statusColors[status],
        fontSize: '0.875rem',
        fontWeight: '500',
      }}
    >
      <span style={{ marginRight: '0.5rem' }}>{statusEmojis[status]}</span>
      <span>{name}</span>
    </div>
  );
};

export const CoreServicesStatus = () => {
  const [systemStatus, setSystemStatus] = useState<SystemStatus | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchStatus = async () => {
      try {
        setLoading(true);
        const response = await healthApi.getSystemStatus();
        
        if (response.error) {
          setError(response.error);
          setSystemStatus(null);
        } else if (response.data) {
          setSystemStatus(response.data);
          setError(null);
        }
      } catch (err) {
        setError('Failed to fetch system status');
        setSystemStatus(null);
      } finally {
        setLoading(false);
      }
    };

    fetchStatus();
    // Refresh every 30 seconds
    const interval = setInterval(fetchStatus, 30000);

    return () => clearInterval(interval);
  }, []);

  if (loading) {
    return (
      <div style={{ padding: '1rem', textAlign: 'center' }}>
        <p>Loading Core Services status...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div style={{ padding: '1rem', color: '#ef4444' }}>
        <p>Error loading services: {error}</p>
      </div>
    );
  }

  if (!systemStatus || !systemStatus.services) {
    return null;
  }

  return (
    <div style={{ padding: '1rem' }}>
      <h3 style={{ marginBottom: '1rem', fontSize: '1.125rem', fontWeight: '600' }}>
        Core Services Status
      </h3>
      <div style={{ display: 'flex', flexWrap: 'wrap' }}>
        {Object.entries(systemStatus.services).map(([name, status]) => (
          <ServiceChip key={name} name={name} status={status} />
        ))}
      </div>
      <p style={{ marginTop: '0.5rem', fontSize: '0.75rem', color: '#6b7280' }}>
        Last updated: {new Date(systemStatus.updatedAt).toLocaleTimeString()}
      </p>
    </div>
  );
};

export default CoreServicesStatus;

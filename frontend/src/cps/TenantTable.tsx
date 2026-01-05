import { useState } from 'react';
import './TenantTable.css';

interface Tenant {
  id: number;
  name: string;
  slug: string;
  domain: string;
  category: string;
  status: string;
  deployed: string;
  icon?: string;
  description?: string;
}

interface Props {
  tenants: Tenant[];
}

export default function TenantTable({ tenants }: Props) {
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState<string>('all');
  const [sortField, setSortField] = useState<'name' | 'status' | 'deployed'>('id');
  const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('asc');

  // Filter tenants
  const filteredTenants = tenants.filter(tenant => {
    const matchesSearch = tenant.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         tenant.category.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         tenant.slug.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = filterStatus === 'all' || tenant.status === filterStatus;
    return matchesSearch && matchesStatus;
  });

  // Sort tenants
  const sortedTenants = [...filteredTenants].sort((a, b) => {
    let aVal = a[sortField];
    let bVal = b[sortField];
    
    if (sortField === 'name') {
      aVal = a.name.toLowerCase();
      bVal = b.name.toLowerCase();
    }
    
    if (aVal < bVal) return sortDirection === 'asc' ? -1 : 1;
    if (aVal > bVal) return sortDirection === 'asc' ? 1 : -1;
    return 0;
  });

  const handleSort = (field: 'name' | 'status' | 'deployed') => {
    if (sortField === field) {
      setSortDirection(sortDirection === 'asc' ? 'desc' : 'asc');
    } else {
      setSortField(field);
      setSortDirection('asc');
    }
  };

  const getStatusBadge = (status: string) => {
    const statusClasses = {
      live: 'status-badge status-live',
      active: 'status-badge status-active',
      streaming: 'status-badge status-streaming',
    };
    
    return (
      <span className={statusClasses[status as keyof typeof statusClasses] || 'status-badge'}>
        {status === 'live' && '🔴'}
        {status === 'active' && '✅'}
        {status === 'streaming' && '📡'}
        {' '}
        {status.toUpperCase()}
      </span>
    );
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', { 
      year: 'numeric', 
      month: 'short', 
      day: 'numeric' 
    });
  };

  return (
    <div className="tenant-table-container">
      {/* Controls */}
      <div className="table-controls">
        <div className="search-box">
          <input
            type="text"
            placeholder="Search tenants..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="search-input"
          />
          <span className="search-icon">🔍</span>
        </div>

        <div className="filter-box">
          <label htmlFor="status-filter">Status:</label>
          <select
            id="status-filter"
            value={filterStatus}
            onChange={(e) => setFilterStatus(e.target.value)}
            className="filter-select"
          >
            <option value="all">All</option>
            <option value="live">Live</option>
            <option value="active">Active</option>
            <option value="streaming">Streaming</option>
          </select>
        </div>

        <div className="table-info">
          Showing {sortedTenants.length} of {tenants.length} platforms
        </div>
      </div>

      {/* Table */}
      <div className="table-wrapper">
        <table className="tenant-table">
          <thead>
            <tr>
              <th className="th-icon">#</th>
              <th 
                className="th-name sortable"
                onClick={() => handleSort('name')}
              >
                Platform Name
                {sortField === 'name' && (
                  <span className="sort-indicator">
                    {sortDirection === 'asc' ? ' ↑' : ' ↓'}
                  </span>
                )}
              </th>
              <th>Slug</th>
              <th>Category</th>
              <th 
                className="sortable"
                onClick={() => handleSort('status')}
              >
                Status
                {sortField === 'status' && (
                  <span className="sort-indicator">
                    {sortDirection === 'asc' ? ' ↑' : ' ↓'}
                  </span>
                )}
              </th>
              <th>Domain</th>
              <th 
                className="sortable"
                onClick={() => handleSort('deployed')}
              >
                Deployed
                {sortField === 'deployed' && (
                  <span className="sort-indicator">
                    {sortDirection === 'asc' ? ' ↑' : ' ↓'}
                  </span>
                )}
              </th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {sortedTenants.map((tenant) => (
              <tr key={tenant.id} className="tenant-row">
                <td className="td-icon">
                  {tenant.icon || '⭐'}
                </td>
                <td className="td-name">
                  <strong>{tenant.name}</strong>
                </td>
                <td className="td-slug">
                  <code>{tenant.slug}</code>
                </td>
                <td className="td-category">{tenant.category}</td>
                <td className="td-status">{getStatusBadge(tenant.status)}</td>
                <td className="td-domain">
                  <a 
                    href={`https://${tenant.domain}`} 
                    target="_blank" 
                    rel="noopener noreferrer"
                    className="domain-link"
                  >
                    {tenant.domain} ↗
                  </a>
                </td>
                <td className="td-date">{formatDate(tenant.deployed)}</td>
                <td className="td-actions">
                  <button className="action-btn" title="View Details">
                    👁️
                  </button>
                  <button className="action-btn" title="Manage">
                    ⚙️
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>

        {sortedTenants.length === 0 && (
          <div className="empty-state">
            <p>No tenants found matching your filters.</p>
          </div>
        )}
      </div>

      {/* Legend */}
      <div className="table-legend">
        <h4>Status Legend:</h4>
        <div className="legend-items">
          <span className="legend-item">
            <span className="status-badge status-live">🔴 LIVE</span>
            Platform is live and operational
          </span>
          <span className="legend-item">
            <span className="status-badge status-active">✅ ACTIVE</span>
            Platform is active and available
          </span>
          <span className="legend-item">
            <span className="status-badge status-streaming">📡 STREAMING</span>
            Platform is actively streaming
          </span>
        </div>
      </div>
    </div>
  );
}

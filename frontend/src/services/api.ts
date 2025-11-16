/**
 * API Service for Nexus COS
 * Handles all API calls with proper baseURL configuration
 */

// Determine the base URL based on environment
const getBaseURL = (): string => {
  // In development, when running on localhost:3000, target backend on 3004
  if (import.meta.env.DEV && window.location.port === '3000') {
    return 'http://localhost:3004';
  }
  
  // Use environment variable or default to /api for production
  return import.meta.env.VITE_API_URL || '/api';
};

const BASE_URL = getBaseURL();

interface ApiResponse<T = any> {
  data?: T;
  error?: string;
  status: number;
}

/**
 * Generic API request handler
 */
async function request<T = any>(
  endpoint: string,
  options: RequestInit = {}
): Promise<ApiResponse<T>> {
  try {
    // Ensure endpoint starts with /
    const path = endpoint.startsWith('/') ? endpoint : `/${endpoint}`;
    const url = `${BASE_URL}${path}`;

    const response = await fetch(url, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
    });

    // Check if response is ok before parsing
    if (!response.ok) {
      return {
        error: `HTTP ${response.status}: ${response.statusText}`,
        status: response.status,
      };
    }

    // Check if response is JSON
    const contentType = response.headers.get('content-type');
    if (!contentType || !contentType.includes('application/json')) {
      return {
        error: 'Server returned non-JSON response',
        status: response.status,
      };
    }

    const data = await response.json();

    return {
      data,
      status: response.status,
    };
  } catch (error) {
    console.error('API request failed:', error);
    return {
      error: error instanceof Error ? error.message : 'Unknown error',
      status: 0,
    };
  }
}

/**
 * API client methods
 */
export const api = {
  /**
   * GET request
   */
  get: <T = any>(endpoint: string, options?: RequestInit) =>
    request<T>(endpoint, { ...options, method: 'GET' }),

  /**
   * POST request
   */
  post: <T = any>(endpoint: string, body?: any, options?: RequestInit) =>
    request<T>(endpoint, {
      ...options,
      method: 'POST',
      body: body ? JSON.stringify(body) : undefined,
    }),

  /**
   * PUT request
   */
  put: <T = any>(endpoint: string, body?: any, options?: RequestInit) =>
    request<T>(endpoint, {
      ...options,
      method: 'PUT',
      body: body ? JSON.stringify(body) : undefined,
    }),

  /**
   * DELETE request
   */
  delete: <T = any>(endpoint: string, options?: RequestInit) =>
    request<T>(endpoint, { ...options, method: 'DELETE' }),
};

/**
 * Health check endpoints
 */
export const healthApi = {
  /**
   * Get overall system status
   */
  getSystemStatus: () => api.get<SystemStatus>('/api/system/status'),

  /**
   * Get health status for a specific service
   */
  getServiceHealth: (service: string) =>
    api.get<ServiceHealth>(`/api/services/${service}/health`),

  /**
   * Get basic health check
   */
  getHealth: () => api.get<{ status: string }>('/health'),
};

// Type definitions for health responses
export interface SystemStatus {
  services: {
    [key: string]: 'healthy' | 'offline' | 'unknown';
  };
  updatedAt: string;
}

export interface ServiceHealth {
  service: string;
  status: 'healthy' | 'offline' | 'unknown';
  updatedAt: string;
}

export default api;

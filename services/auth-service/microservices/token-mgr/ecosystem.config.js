module.exports = {
  apps: [{
    name: 'nexus-admin-auth',
    script: 'server.js',
    cwd: '/home/runner/work/nexus-cos/nexus-cos/services/auth-service/microservices/token-mgr',
    instances: 1,
    exec_mode: 'fork',
    
    // Environment variables
    env: {
      NODE_ENV: 'production',
      PORT: 3102,
      MONGODB_URI: 'mongodb://localhost:27017/nexus-cos-admin'
    },
    
    // PM2 configuration
    watch: false,
    max_memory_restart: '500M',
    
    // Logging
    log_file: './logs/nexus-admin-auth.log',
    out_file: './logs/nexus-admin-auth-out.log',
    error_file: './logs/nexus-admin-auth-error.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    
    // Auto restart configuration
    autorestart: true,
    max_restarts: 10,
    min_uptime: '10s',
    
    // Health monitoring
    health_check_grace_period: 3000,
    health_check_fatal_exceptions: true
  }]
};
// PM2 Ecosystem Configuration for Platform Services
// Nexus COS - Core Platform Services Configuration
// Services verified with server.js entry points

module.exports = {
  apps: [
    // ========================================
    // AUTHENTICATION SERVICES
    // ========================================
    {
      name: 'auth-service',
      script: './services/auth-service-v2/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3301,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password',
        JWT_SECRET: process.env.JWT_SECRET || 'nexus-cos-secret-key'
      },
      log_file: './logs/platform/auth-service.log',
      out_file: './logs/platform/auth-service-out.log',
      error_file: './logs/platform/auth-service-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'user-auth',
      script: './services/user-auth/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3304,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password',
        JWT_SECRET: process.env.JWT_SECRET || 'nexus-cos-secret-key'
      },
      log_file: './logs/platform/user-auth.log',
      out_file: './logs/platform/user-auth-out.log',
      error_file: './logs/platform/user-auth-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },

    // ========================================
    // CONTENT MANAGEMENT SERVICES
    // ========================================
    {
      name: 'content-management',
      script: './services/content-management/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3302,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password'
      },
      log_file: './logs/platform/content-management.log',
      out_file: './logs/platform/content-management-out.log',
      error_file: './logs/platform/content-management-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },

    // ========================================
    // CREATOR PLATFORM SERVICES
    // ========================================
    {
      name: 'creator-hub',
      script: './services/creator-hub-v2/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3303,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password'
      },
      log_file: './logs/platform/creator-hub.log',
      out_file: './logs/platform/creator-hub-out.log',
      error_file: './logs/platform/creator-hub-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },

    // ========================================
    // SESSION & TOKEN MANAGEMENT
    // ========================================
    {
      name: 'session-mgr',
      script: './services/session-mgr/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '256M',
      env: {
        NODE_ENV: 'production',
        PORT: 3101,
        REDIS_HOST: process.env.REDIS_HOST || 'localhost',
        REDIS_PORT: process.env.REDIS_PORT || 6379,
        SESSION_SECRET: process.env.SESSION_SECRET || 'nexus-session-secret'
      },
      log_file: './logs/platform/session-mgr.log',
      out_file: './logs/platform/session-mgr-out.log',
      error_file: './logs/platform/session-mgr-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'token-mgr',
      script: './services/token-mgr/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '256M',
      env: {
        NODE_ENV: 'production',
        PORT: 3102,
        JWT_SECRET: process.env.JWT_SECRET || 'nexus-cos-secret-key',
        JWT_EXPIRY: process.env.JWT_EXPIRY || '24h'
      },
      log_file: './logs/platform/token-mgr.log',
      out_file: './logs/platform/token-mgr-out.log',
      error_file: './logs/platform/token-mgr-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },

    // ========================================
    // FINANCIAL SERVICES
    // ========================================
    {
      name: 'ledger-mgr',
      script: './services/ledger-mgr/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3112,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password'
      },
      log_file: './logs/platform/ledger-mgr.log',
      out_file: './logs/platform/ledger-mgr-out.log',
      error_file: './logs/platform/ledger-mgr-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'invoice-gen',
      script: './services/invoice-gen/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '256M',
      env: {
        NODE_ENV: 'production',
        PORT: 3111,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password'
      },
      log_file: './logs/platform/invoice-gen.log',
      out_file: './logs/platform/invoice-gen-out.log',
      error_file: './logs/platform/invoice-gen-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },

    // ========================================
    // STREAMING SERVICES
    // ========================================
    {
      name: 'streaming',
      script: './services/streaming-service-v2/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 3404,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password'
      },
      log_file: './logs/platform/streaming.log',
      out_file: './logs/platform/streaming-out.log',
      error_file: './logs/platform/streaming-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },

    // ========================================
    // CORE PLATFORM SERVICES
    // ========================================
    {
      name: 'kei-ai',
      script: './services/kei-ai/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 3401,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password'
      },
      log_file: './logs/platform/kei-ai.log',
      out_file: './logs/platform/kei-ai-out.log',
      error_file: './logs/platform/kei-ai-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'nexus-cos-studio-ai',
      script: './services/nexus-cos-studio-ai/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 3402,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password'
      },
      log_file: './logs/platform/nexus-cos-studio-ai.log',
      out_file: './logs/platform/nexus-cos-studio-ai-out.log',
      error_file: './logs/platform/nexus-cos-studio-ai-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'puaboverse',
      script: './services/puaboverse-v2/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3403,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password'
      },
      log_file: './logs/platform/puaboverse.log',
      out_file: './logs/platform/puaboverse-out.log',
      error_file: './logs/platform/puaboverse-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    }
  ]
};

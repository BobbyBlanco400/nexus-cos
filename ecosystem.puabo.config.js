// PM2 Ecosystem Configuration for PUABO Business Suite
// Nexus COS - PUABO Microservices Configuration
// Includes: DSP (3), BLAC (2), Nexus Fleet (4), NUKI E-Commerce (4)

module.exports = {
  apps: [
    // ========================================
    // PUABO DSP - Digital Streaming Platform (3 microservices)
    // ========================================
    {
      name: 'puabo-dsp-upload-mgr',
      script: './services/puabo-dsp-upload-mgr/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3211,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password',
        UPLOAD_MAX_SIZE: process.env.UPLOAD_MAX_SIZE || '500MB',
        STORAGE_PATH: process.env.STORAGE_PATH || '/var/nexus-cos/uploads'
      },
      log_file: './logs/puabo/dsp-upload-mgr.log',
      out_file: './logs/puabo/dsp-upload-mgr-out.log',
      error_file: './logs/puabo/dsp-upload-mgr-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'puabo-dsp-metadata-mgr',
      script: './services/puabo-dsp-metadata-mgr/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3212,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password'
      },
      log_file: './logs/puabo/dsp-metadata-mgr.log',
      out_file: './logs/puabo/dsp-metadata-mgr-out.log',
      error_file: './logs/puabo/dsp-metadata-mgr-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'puabo-dsp-streaming-api',
      script: './services/puabo-dsp-streaming-api/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3213,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password'
      },
      log_file: './logs/puabo/dsp-streaming-api.log',
      out_file: './logs/puabo/dsp-streaming-api-out.log',
      error_file: './logs/puabo/dsp-streaming-api-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },

    // ========================================
    // PUABO BLAC - Business Loans & Credit (2 microservices)
    // ========================================
    {
      name: 'puabo-blac-loan-processor',
      script: './services/puabo-blac-loan-processor/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3221,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password',
        LOAN_API_KEY: process.env.LOAN_API_KEY || ''
      },
      log_file: './logs/puabo/blac-loan-processor.log',
      out_file: './logs/puabo/blac-loan-processor-out.log',
      error_file: './logs/puabo/blac-loan-processor-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'puabo-blac-risk-assessment',
      script: './services/puabo-blac-risk-assessment/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3222,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password',
        CREDIT_API_KEY: process.env.CREDIT_API_KEY || ''
      },
      log_file: './logs/puabo/blac-risk-assessment.log',
      out_file: './logs/puabo/blac-risk-assessment-out.log',
      error_file: './logs/puabo/blac-risk-assessment-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },

    // ========================================
    // PUABO NEXUS - AI Fleet Management (4 microservices)
    // ========================================
    {
      name: 'puabo-nexus-ai-dispatch',
      script: './services/puabo-nexus-ai-dispatch/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3231,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password',
        AI_API_KEY: process.env.AI_API_KEY || ''
      },
      log_file: './logs/puabo/nexus-ai-dispatch.log',
      out_file: './logs/puabo/nexus-ai-dispatch-out.log',
      error_file: './logs/puabo/nexus-ai-dispatch-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'puabo-nexus-driver-app-backend',
      script: './services/puabo-nexus-driver-app-backend/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3232,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password'
      },
      log_file: './logs/puabo/nexus-driver-app-backend.log',
      out_file: './logs/puabo/nexus-driver-app-backend-out.log',
      error_file: './logs/puabo/nexus-driver-app-backend-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'puabo-nexus-fleet-manager',
      script: './services/puabo-nexus-fleet-manager/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3233,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password'
      },
      log_file: './logs/puabo/nexus-fleet-manager.log',
      out_file: './logs/puabo/nexus-fleet-manager-out.log',
      error_file: './logs/puabo/nexus-fleet-manager-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'puabo-nexus-route-optimizer',
      script: './services/puabo-nexus-route-optimizer/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3234,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password',
        MAPS_API_KEY: process.env.MAPS_API_KEY || ''
      },
      log_file: './logs/puabo/nexus-route-optimizer.log',
      out_file: './logs/puabo/nexus-route-optimizer-out.log',
      error_file: './logs/puabo/nexus-route-optimizer-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },

    // ========================================
    // PUABO NUKI - E-Commerce Platform (4 microservices)
    // ========================================
    {
      name: 'puabo-nuki-inventory-mgr',
      script: './services/puabo-nuki-inventory-mgr/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3241,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password'
      },
      log_file: './logs/puabo/nuki-inventory-mgr.log',
      out_file: './logs/puabo/nuki-inventory-mgr-out.log',
      error_file: './logs/puabo/nuki-inventory-mgr-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'puabo-nuki-order-processor',
      script: './services/puabo-nuki-order-processor/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3242,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password',
        PAYMENT_API_KEY: process.env.PAYMENT_API_KEY || ''
      },
      log_file: './logs/puabo/nuki-order-processor.log',
      out_file: './logs/puabo/nuki-order-processor-out.log',
      error_file: './logs/puabo/nuki-order-processor-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'puabo-nuki-product-catalog',
      script: './services/puabo-nuki-product-catalog/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3243,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password'
      },
      log_file: './logs/puabo/nuki-product-catalog.log',
      out_file: './logs/puabo/nuki-product-catalog-out.log',
      error_file: './logs/puabo/nuki-product-catalog-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'puabo-nuki-shipping-service',
      script: './services/puabo-nuki-shipping-service/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3244,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password',
        SHIPPING_API_KEY: process.env.SHIPPING_API_KEY || ''
      },
      log_file: './logs/puabo/nuki-shipping-service.log',
      out_file: './logs/puabo/nuki-shipping-service-out.log',
      error_file: './logs/puabo/nuki-shipping-service-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },

    // ========================================
    // PUABO CORE PLATFORM SERVICES
    // ========================================
    {
      name: 'puaboai-sdk',
      script: './services/puaboai-sdk/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3012,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password'
      },
      log_file: './logs/puabo/puaboai-sdk.log',
      out_file: './logs/puabo/puaboai-sdk-out.log',
      error_file: './logs/puabo/puaboai-sdk-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'puabomusicchain',
      script: './services/puabomusicchain/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3013,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password',
        BLOCKCHAIN_API_KEY: process.env.BLOCKCHAIN_API_KEY || ''
      },
      log_file: './logs/puabo/puabomusicchain.log',
      out_file: './logs/puabo/puabomusicchain-out.log',
      error_file: './logs/puabo/puabomusicchain-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'pv-keys',
      script: './services/pv-keys/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '256M',
      env: {
        NODE_ENV: 'production',
        PORT: 3015,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password'
      },
      log_file: './logs/puabo/pv-keys.log',
      out_file: './logs/puabo/pv-keys-out.log',
      error_file: './logs/puabo/pv-keys-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'streamcore',
      script: './services/streamcore/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3016,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password'
      },
      log_file: './logs/puabo/streamcore.log',
      out_file: './logs/puabo/streamcore-out.log',
      error_file: './logs/puabo/streamcore-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    }
  ]
};

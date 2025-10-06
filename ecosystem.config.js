// PM2 Ecosystem Configuration for Nexus COS
// Complete 32 Services Deployment Configuration (29 + 3 V-Suite Pro Services)
// Generated for Beta Launch

module.exports = {
  apps: [
    // ========================================
    // PHASE 1: CORE INFRASTRUCTURE SERVICES (Priority: CRITICAL)
    // ========================================
    {
      name: 'backend-api',
      script: './services/backend-api/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3001,
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/backend-api.log',
      out_file: './logs/backend-api-out.log',
      error_file: './logs/backend-api-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'ai-service',
      script: './services/ai-service/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 3010,
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/ai-service.log',
      out_file: './logs/ai-service-out.log',
      error_file: './logs/ai-service-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'key-service',
      script: './services/key-service/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '256M',
      env: {
        NODE_ENV: 'production',
        PORT: 3014,
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/key-service.log',
      out_file: './logs/key-service-out.log',
      error_file: './logs/key-service-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },

    // ========================================
    // PHASE 2: PUABO ECOSYSTEM SERVICES (Priority: HIGH)
    // ========================================
    
    // PUABO Core Platform Services
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
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/puaboai-sdk.log',
      out_file: './logs/puaboai-sdk-out.log',
      error_file: './logs/puaboai-sdk-error.log',
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
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/puabomusicchain.log',
      out_file: './logs/puabomusicchain-out.log',
      error_file: './logs/puabomusicchain-error.log',
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
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/pv-keys.log',
      out_file: './logs/pv-keys-out.log',
      error_file: './logs/pv-keys-error.log',
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
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/streamcore.log',
      out_file: './logs/streamcore-out.log',
      error_file: './logs/streamcore-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'glitch',
      script: './services/glitch/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '256M',
      env: {
        NODE_ENV: 'production',
        PORT: 3017,
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/glitch.log',
      out_file: './logs/glitch-out.log',
      error_file: './logs/glitch-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },

    // PUABO-DSP Services
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
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/puabo-dsp-upload-mgr.log',
      out_file: './logs/puabo-dsp-upload-mgr-out.log',
      error_file: './logs/puabo-dsp-upload-mgr-error.log',
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
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/puabo-dsp-metadata-mgr.log',
      out_file: './logs/puabo-dsp-metadata-mgr-out.log',
      error_file: './logs/puabo-dsp-metadata-mgr-error.log',
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
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/puabo-dsp-streaming-api.log',
      out_file: './logs/puabo-dsp-streaming-api-out.log',
      error_file: './logs/puabo-dsp-streaming-api-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },

    // PUABO-BLAC Services
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
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/puabo-blac-loan-processor.log',
      out_file: './logs/puabo-blac-loan-processor-out.log',
      error_file: './logs/puabo-blac-loan-processor-error.log',
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
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/puabo-blac-risk-assessment.log',
      out_file: './logs/puabo-blac-risk-assessment-out.log',
      error_file: './logs/puabo-blac-risk-assessment-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },

    // PUABO-Nexus Services
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
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/puabo-nexus-ai-dispatch.log',
      out_file: './logs/puabo-nexus-ai-dispatch-out.log',
      error_file: './logs/puabo-nexus-ai-dispatch-error.log',
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
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/puabo-nexus-driver-app-backend.log',
      out_file: './logs/puabo-nexus-driver-app-backend-out.log',
      error_file: './logs/puabo-nexus-driver-app-backend-error.log',
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
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/puabo-nexus-fleet-manager.log',
      out_file: './logs/puabo-nexus-fleet-manager-out.log',
      error_file: './logs/puabo-nexus-fleet-manager-error.log',
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
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/puabo-nexus-route-optimizer.log',
      out_file: './logs/puabo-nexus-route-optimizer-out.log',
      error_file: './logs/puabo-nexus-route-optimizer-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },

    // PUABO-Nuki Services
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
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/puabo-nuki-inventory-mgr.log',
      out_file: './logs/puabo-nuki-inventory-mgr-out.log',
      error_file: './logs/puabo-nuki-inventory-mgr-error.log',
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
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/puabo-nuki-order-processor.log',
      out_file: './logs/puabo-nuki-order-processor-out.log',
      error_file: './logs/puabo-nuki-order-processor-error.log',
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
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/puabo-nuki-product-catalog.log',
      out_file: './logs/puabo-nuki-product-catalog-out.log',
      error_file: './logs/puabo-nuki-product-catalog-error.log',
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
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/puabo-nuki-shipping-service.log',
      out_file: './logs/puabo-nuki-shipping-service-out.log',
      error_file: './logs/puabo-nuki-shipping-service-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },

    // ========================================
    // PHASE 3: PLATFORM SERVICES (Priority: MEDIUM)
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
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/auth-service.log',
      out_file: './logs/auth-service-out.log',
      error_file: './logs/auth-service-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
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
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/content-management.log',
      out_file: './logs/content-management-out.log',
      error_file: './logs/content-management-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
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
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/creator-hub.log',
      out_file: './logs/creator-hub-out.log',
      error_file: './logs/creator-hub-error.log',
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
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/user-auth.log',
      out_file: './logs/user-auth-out.log',
      error_file: './logs/user-auth-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
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
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/kei-ai.log',
      out_file: './logs/kei-ai-out.log',
      error_file: './logs/kei-ai-error.log',
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
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/nexus-cos-studio-ai.log',
      out_file: './logs/nexus-cos-studio-ai-out.log',
      error_file: './logs/nexus-cos-studio-ai-error.log',
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
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/puaboverse.log',
      out_file: './logs/puaboverse-out.log',
      error_file: './logs/puaboverse-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'streaming-service',
      script: './services/streaming-service-v2/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3404,
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/streaming-service.log',
      out_file: './logs/streaming-service-out.log',
      error_file: './logs/streaming-service-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },

    // ========================================
    // PHASE 4: SPECIALIZED SERVICES (Priority: LOW)
    // ========================================
    {
      name: 'boom-boom-room-live',
      script: './services/boom-boom-room-live/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3601,
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/boom-boom-room-live.log',
      out_file: './logs/boom-boom-room-live-out.log',
      error_file: './logs/boom-boom-room-live-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },

    // ========================================
    // PHASE 5: V-SUITE PRO SERVICES (Priority: MEDIUM)
    // ========================================
    {
      name: 'v-caster-pro',
      script: './services/v-caster-pro/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3501,
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/v-caster-pro.log',
      out_file: './logs/v-caster-pro-out.log',
      error_file: './logs/v-caster-pro-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'v-prompter-pro',
      script: './services/v-prompter-pro/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3502,
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/v-prompter-pro.log',
      out_file: './logs/v-prompter-pro-out.log',
      error_file: './logs/v-prompter-pro-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'v-screen-pro',
      script: './services/v-screen-pro/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3503,
        DB_HOST: 'localhost',
        DB_PORT: 5432,
        DB_NAME: 'nexuscos_db',
        DB_USER: 'nexuscos',
        DB_PASSWORD: 'password'
      },
      log_file: './logs/v-screen-pro.log',
      out_file: './logs/v-screen-pro-out.log',
      error_file: './logs/v-screen-pro-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    }
  ]
};
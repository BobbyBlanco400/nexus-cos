// PM2 Ecosystem Configuration for V-Suite Production Tools
// Nexus COS - V-Suite Professional Services Configuration
// Virtual production suite for streaming and content creation

module.exports = {
  apps: [
    // ========================================
    // V-SUITE PRODUCTION TOOLS
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
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password',
        STREAMING_QUALITY: process.env.STREAMING_QUALITY || '1080p'
      },
      log_file: './logs/vsuite/v-caster-pro.log',
      out_file: './logs/vsuite/v-caster-pro-out.log',
      error_file: './logs/vsuite/v-caster-pro-error.log',
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
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password',
        WEBSOCKET_ENABLED: 'true'
      },
      log_file: './logs/vsuite/v-prompter-pro.log',
      out_file: './logs/vsuite/v-prompter-pro-out.log',
      error_file: './logs/vsuite/v-prompter-pro-error.log',
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
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password',
        MAX_RESOLUTION: process.env.MAX_RESOLUTION || '4K'
      },
      log_file: './logs/vsuite/v-screen-pro.log',
      out_file: './logs/vsuite/v-screen-pro-out.log',
      error_file: './logs/vsuite/v-screen-pro-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    },
    {
      name: 'vscreen-hollywood',
      script: './services/vscreen-hollywood/server.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 3504,
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password',
        RENDER_ENGINE: process.env.RENDER_ENGINE || 'webgl',
        MAX_SCENES: process.env.MAX_SCENES || '10'
      },
      log_file: './logs/vsuite/vscreen-hollywood.log',
      out_file: './logs/vsuite/vscreen-hollywood-out.log',
      error_file: './logs/vsuite/vscreen-hollywood-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    }
  ]
};

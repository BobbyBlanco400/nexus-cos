// PM2 Ecosystem Configuration for Family Entertainment Services
// Nexus COS - Family Entertainment Module Configuration
// Ports: 8401-8404 (as per original assignment)
// NOTE: These services are planned but not yet implemented
// This config is a placeholder for future implementation

module.exports = {
  apps: [
    // ========================================
    // FAMILY ENTERTAINMENT MODULES (Planned)
    // ========================================
    // NOTE: The following services need to be created/reclassified
    // from services to full modules as per the PF recommendations
    
    // {
    //   name: 'ahshantis-munch-and-mingle',
    //   script: './modules/ahshantis-munch-and-mingle/server.js',
    //   instances: 1,
    //   autorestart: true,
    //   watch: false,
    //   max_memory_restart: '512M',
    //   env: {
    //     NODE_ENV: 'production',
    //     PORT: 8401,
    //     DB_HOST: process.env.DB_HOST || 'localhost',
    //     DB_PORT: process.env.DB_PORT || 5432,
    //     DB_NAME: process.env.DB_NAME || 'nexuscos_db',
    //     DB_USER: process.env.DB_USER || 'nexuscos',
    //     DB_PASSWORD: process.env.DB_PASSWORD || 'password',
    //     MODULE_TYPE: 'family-entertainment',
    //     CONTENT_CATEGORY: 'asmr-cooking'
    //   },
    //   log_file: './logs/family/ahshantis-munch-and-mingle.log',
    //   out_file: './logs/family/ahshantis-munch-and-mingle-out.log',
    //   error_file: './logs/family/ahshantis-munch-and-mingle-error.log',
    //   log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    // },

    // {
    //   name: 'tyshawns-v-dance-studio',
    //   script: './modules/tyshawns-v-dance-studio/server.js',
    //   instances: 1,
    //   autorestart: true,
    //   watch: false,
    //   max_memory_restart: '512M',
    //   env: {
    //     NODE_ENV: 'production',
    //     PORT: 8402,
    //     DB_HOST: process.env.DB_HOST || 'localhost',
    //     DB_PORT: process.env.DB_PORT || 5432,
    //     DB_NAME: process.env.DB_NAME || 'nexuscos_db',
    //     DB_USER: process.env.DB_USER || 'nexuscos',
    //     DB_PASSWORD: process.env.DB_PASSWORD || 'password',
    //     MODULE_TYPE: 'family-entertainment',
    //     CONTENT_CATEGORY: 'dance-studio'
    //   },
    //   log_file: './logs/family/tyshawns-v-dance-studio.log',
    //   out_file: './logs/family/tyshawns-v-dance-studio-out.log',
    //   error_file: './logs/family/tyshawns-v-dance-studio-error.log',
    //   log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    // },

    // {
    //   name: 'fayeloni-kreation',
    //   script: './modules/fayeloni-kreation/server.js',
    //   instances: 1,
    //   autorestart: true,
    //   watch: false,
    //   max_memory_restart: '512M',
    //   env: {
    //     NODE_ENV: 'production',
    //     PORT: 8403,
    //     DB_HOST: process.env.DB_HOST || 'localhost',
    //     DB_PORT: process.env.DB_PORT || 5432,
    //     DB_NAME: process.env.DB_NAME || 'nexuscos_db',
    //     DB_USER: process.env.DB_USER || 'nexuscos',
    //     DB_PASSWORD: process.env.DB_PASSWORD || 'password',
    //     MODULE_TYPE: 'family-entertainment',
    //     CONTENT_CATEGORY: 'creative-content'
    //   },
    //   log_file: './logs/family/fayeloni-kreation.log',
    //   out_file: './logs/family/fayeloni-kreation-out.log',
    //   error_file: './logs/family/fayeloni-kreation-error.log',
    //   log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    // },

    // {
    //   name: 'sassie-lashes',
    //   script: './modules/sassie-lashes/server.js',
    //   instances: 1,
    //   autorestart: true,
    //   watch: false,
    //   max_memory_restart: '512M',
    //   env: {
    //     NODE_ENV: 'production',
    //     PORT: 8404,
    //     DB_HOST: process.env.DB_HOST || 'localhost',
    //     DB_PORT: process.env.DB_PORT || 5432,
    //     DB_NAME: process.env.DB_NAME || 'nexuscos_db',
    //     DB_USER: process.env.DB_USER || 'nexuscos',
    //     DB_PASSWORD: process.env.DB_PASSWORD || 'password',
    //     MODULE_TYPE: 'family-entertainment',
    //     CONTENT_CATEGORY: 'beauty-lifestyle'
    //   },
    //   log_file: './logs/family/sassie-lashes.log',
    //   out_file: './logs/family/sassie-lashes-out.log',
    //   error_file: './logs/family/sassie-lashes-error.log',
    //   log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    // },

    // {
    //   name: 'neenee-and-kids-show',
    //   script: './modules/neenee-and-kids-show/server.js',
    //   instances: 1,
    //   autorestart: true,
    //   watch: false,
    //   max_memory_restart: '512M',
    //   env: {
    //     NODE_ENV: 'production',
    //     PORT: 8405,
    //     DB_HOST: process.env.DB_HOST || 'localhost',
    //     DB_PORT: process.env.DB_PORT || 5432,
    //     DB_NAME: process.env.DB_NAME || 'nexuscos_db',
    //     DB_USER: process.env.DB_USER || 'nexuscos',
    //     DB_PASSWORD: process.env.DB_PASSWORD || 'password',
    //     MODULE_TYPE: 'family-entertainment',
    //     CONTENT_CATEGORY: 'kids-programming'
    //   },
    //   log_file: './logs/family/neenee-and-kids-show.log',
    //   out_file: './logs/family/neenee-and-kids-show-out.log',
    //   error_file: './logs/family/neenee-and-kids-show-error.log',
    //   log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    // }
  ]
};

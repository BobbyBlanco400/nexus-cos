// PM2 Ecosystem Configuration for Urban Entertainment Services
// Nexus COS - Urban Entertainment Suite Configuration
// NOTE: These services are planned but not yet fully implemented
// This config is based on the PF recommendations

module.exports = {
  apps: [
    // ========================================
    // URBAN ENTERTAINMENT SERVICES (Planned)
    // ========================================
    // NOTE: The following services need to be created according to PF specs
    
    // {
    //   name: 'headwina-comedy-club',
    //   script: './services/HeadwinaComedyClubService/server.js',
    //   instances: 1,
    //   autorestart: true,
    //   watch: false,
    //   max_memory_restart: '512M',
    //   env: {
    //     NODE_ENV: 'production',
    //     PORT: 8501,
    //     DB_HOST: process.env.DB_HOST || 'localhost',
    //     DB_PORT: process.env.DB_PORT || 5432,
    //     DB_NAME: process.env.DB_NAME || 'nexuscos_db',
    //     DB_USER: process.env.DB_USER || 'nexuscos',
    //     DB_PASSWORD: process.env.DB_PASSWORD || 'password',
    //     MODULE_TYPE: 'urban-entertainment',
    //     CONTENT_CATEGORY: 'comedy'
    //   },
    //   log_file: './logs/urban/headwina-comedy-club.log',
    //   out_file: './logs/urban/headwina-comedy-club-out.log',
    //   error_file: './logs/urban/headwina-comedy-club-error.log',
    //   log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    // },

    // {
    //   name: 'idh-live-beauty-salon',
    //   script: './services/IDHLiveBeautySalonService/server.js',
    //   instances: 1,
    //   autorestart: true,
    //   watch: false,
    //   max_memory_restart: '512M',
    //   env: {
    //     NODE_ENV: 'production',
    //     PORT: 8502,
    //     DB_HOST: process.env.DB_HOST || 'localhost',
    //     DB_PORT: process.env.DB_PORT || 5432,
    //     DB_NAME: process.env.DB_NAME || 'nexuscos_db',
    //     DB_USER: process.env.DB_USER || 'nexuscos',
    //     DB_PASSWORD: process.env.DB_PASSWORD || 'password',
    //     MODULE_TYPE: 'urban-entertainment',
    //     CONTENT_CATEGORY: 'beauty'
    //   },
    //   log_file: './logs/urban/idh-live-beauty-salon.log',
    //   out_file: './logs/urban/idh-live-beauty-salon-out.log',
    //   error_file: './logs/urban/idh-live-beauty-salon-error.log',
    //   log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    // },

    // {
    //   name: 'clocking-t-with-tagurl-p',
    //   script: './services/ClockingTWithTaGurlPService/server.js',
    //   instances: 1,
    //   autorestart: true,
    //   watch: false,
    //   max_memory_restart: '512M',
    //   env: {
    //     NODE_ENV: 'production',
    //     PORT: 8503,
    //     DB_HOST: process.env.DB_HOST || 'localhost',
    //     DB_PORT: process.env.DB_PORT || 5432,
    //     DB_NAME: process.env.DB_NAME || 'nexuscos_db',
    //     DB_USER: process.env.DB_USER || 'nexuscos',
    //     DB_PASSWORD: process.env.DB_PASSWORD || 'password',
    //     MODULE_TYPE: 'urban-entertainment',
    //     CONTENT_CATEGORY: 'gossip-entertainment'
    //   },
    //   log_file: './logs/urban/clocking-t-with-tagurl-p.log',
    //   out_file: './logs/urban/clocking-t-with-tagurl-p-out.log',
    //   error_file: './logs/urban/clocking-t-with-tagurl-p-error.log',
    //   log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    // },

    // {
    //   name: 'roro-reefer-gaming-lounge',
    //   script: './services/RoRoReeferGamingLoungeService/server.js',
    //   instances: 1,
    //   autorestart: true,
    //   watch: false,
    //   max_memory_restart: '512M',
    //   env: {
    //     NODE_ENV: 'production',
    //     PORT: 8504,
    //     DB_HOST: process.env.DB_HOST || 'localhost',
    //     DB_PORT: process.env.DB_PORT || 5432,
    //     DB_NAME: process.env.DB_NAME || 'nexuscos_db',
    //     DB_USER: process.env.DB_USER || 'nexuscos',
    //     DB_PASSWORD: process.env.DB_PASSWORD || 'password',
    //     MODULE_TYPE: 'urban-entertainment',
    //     CONTENT_CATEGORY: 'gaming-lounge'
    //   },
    //   log_file: './logs/urban/roro-reefer-gaming-lounge.log',
    //   out_file: './logs/urban/roro-reefer-gaming-lounge-out.log',
    //   error_file: './logs/urban/roro-reefer-gaming-lounge-error.log',
    //   log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    // },

    // {
    //   name: 'ahshantis-munch-and-mingle-service',
    //   script: './services/AhshantisMunchAndMingleService/server.js',
    //   instances: 1,
    //   autorestart: true,
    //   watch: false,
    //   max_memory_restart: '512M',
    //   env: {
    //     NODE_ENV: 'production',
    //     PORT: 8505,
    //     DB_HOST: process.env.DB_HOST || 'localhost',
    //     DB_PORT: process.env.DB_PORT || 5432,
    //     DB_NAME: process.env.DB_NAME || 'nexuscos_db',
    //     DB_USER: process.env.DB_USER || 'nexuscos',
    //     DB_PASSWORD: process.env.DB_PASSWORD || 'password',
    //     MODULE_TYPE: 'urban-entertainment',
    //     CONTENT_CATEGORY: 'asmr-service'
    //   },
    //   log_file: './logs/urban/ahshantis-munch-and-mingle-service.log',
    //   out_file: './logs/urban/ahshantis-munch-and-mingle-service-out.log',
    //   error_file: './logs/urban/ahshantis-munch-and-mingle-service-error.log',
    //   log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    // },

    // Boom Boom Room Live - This one actually exists
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
        DB_HOST: process.env.DB_HOST || 'localhost',
        DB_PORT: process.env.DB_PORT || 5432,
        DB_NAME: process.env.DB_NAME || 'nexuscos_db',
        DB_USER: process.env.DB_USER || 'nexuscos',
        DB_PASSWORD: process.env.DB_PASSWORD || 'password',
        MODULE_TYPE: 'urban-entertainment',
        CONTENT_CATEGORY: 'live-entertainment'
      },
      log_file: './logs/urban/boom-boom-room-live.log',
      out_file: './logs/urban/boom-boom-room-live-out.log',
      error_file: './logs/urban/boom-boom-room-live-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    }
  ]
};

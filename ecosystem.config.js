module.exports = {
  apps: [
    {
      name: 'nexus-backend',
      script: 'npx',
      args: 'ts-node src/server.ts',
      cwd: './backend',
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '500M',
      time: true
    },
    {
      name: 'nexus-python',
      script: './backend/.venv/bin/uvicorn',
      args: 'app.main:app --host 0.0.0.0 --port 3001',
      cwd: './backend',
      env: {
        PYTHONPATH: './backend',
        PORT: 3001
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '500M',
      time: true
    }
  ]
};

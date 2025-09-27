import { defineConfig } from 'vite';

export default defineConfig({
  server: {
    host: true, // allows 0.0.0.0 access
    port: 5173,
    allowedHosts: [
      'localhost',
      'dd92c1962eb4.ngrok-free.app', // your current ngrok URL
    ],
  },
});


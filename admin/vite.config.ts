import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  base: '/admin/',
  server: {
    port: 5173,
    host: true,
  },
  build: {
    outDir: 'build',
    assetsDir: 'static'
  }
})
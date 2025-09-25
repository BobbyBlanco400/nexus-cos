# Use Node.js 20 as the base image
FROM node:20

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --omit=dev

# Copy source files
COPY . .

# Create TypeScript configuration
RUN echo '{ \
  "compilerOptions": { \
    "target": "es5", \
    "lib": ["dom", "dom.iterable", "esnext"], \
    "allowJs": true, \
    "skipLibCheck": true, \
    "esModuleInterop": true, \
    "allowSyntheticDefaultImports": true, \
    "strict": true, \
    "forceConsistentCasingInFileNames": true, \
    "noFallthroughCasesInSwitch": true, \
    "module": "esnext", \
    "moduleResolution": "node", \
    "resolveJsonModule": true, \
    "isolatedModules": true, \
    "noEmit": true, \
    "jsx": "react-jsx" \
  }, \
  "include": ["src"] \
}' > tsconfig.json

# Type check
RUN npx tsc --noEmit

# Set user
RUN adduser -D -u 1001 nextjs && \
    chown -R nextjs:nextjs /app

USER nextjs

# Set working directory
WORKDIR /app

# Install serve
RUN npm install -g serve

# Copy built files from builder stage
COPY --from=builder /app/build ./build

# Set environment variables
ENV PORT=3030
ENV NODE_ENV=production

# Expose port
EXPOSE 3030

# Start the application
CMD ["serve", "-s", "build", "-l", "3030"]
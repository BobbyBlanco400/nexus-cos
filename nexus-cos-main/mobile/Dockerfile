# Mobile App Dockerfile for Nexus COS
# Builds Android APK and iOS IPA from React Native/Flutter

# Base image with Node.js and Android SDK
FROM cimg/android:2024.01.1-node AS mobile-builder

# Set working directory
WORKDIR /app

# Install system dependencies
USER root
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    python3 \
    python3-pip \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

# Switch back to circleci user
USER circleci

# Install React Native CLI and dependencies
RUN npm install -g @react-native-community/cli react-native

# Copy package files
COPY --chown=circleci:circleci package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY --chown=circleci:circleci . .

# Create artifacts directory
RUN mkdir -p /app/artifacts

# Build Android APK
RUN cd android && \
    chmod +x gradlew && \
    ./gradlew assembleRelease && \
    cp app/build/outputs/apk/release/app-release.apk /app/artifacts/nexus-cos.apk

# Production stage for artifacts
FROM alpine:latest AS artifacts

# Install curl for health checks
RUN apk add --no-cache curl

# Create artifacts directory
RUN mkdir -p /artifacts

# Copy built artifacts
COPY --from=mobile-builder /app/artifacts/ /artifacts/

# Create build info
RUN echo "Nexus COS Mobile Build" > /artifacts/BUILD_INFO.txt && \
    echo "Build Date: $(date)" >> /artifacts/BUILD_INFO.txt && \
    echo "Platform: Android APK" >> /artifacts/BUILD_INFO.txt && \
    echo "File: nexus-cos.apk" >> /artifacts/BUILD_INFO.txt

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD test -f /artifacts/nexus-cos.apk || exit 1

# Expose port for artifact server
EXPOSE 8080

# Simple HTTP server to serve artifacts
CMD ["sh", "-c", "cd /artifacts && python3 -m http.server 8080"]

# Alternative: Just keep container running for file extraction
# CMD ["tail", "-f", "/dev/null"]
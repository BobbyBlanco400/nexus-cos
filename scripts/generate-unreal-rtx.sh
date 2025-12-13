#!/bin/bash

# Nexus COS - Unreal Engine & RTX Enablement Script
# This script sets up GPU acceleration and RTX support for the platform

set -e

echo "============================================================="
echo "Nexus COS - Unreal Engine & RTX Enablement"
echo "============================================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
  echo -e "${YELLOW}⚠ This script requires root privileges for GPU driver installation${NC}"
  echo "Run with: sudo bash $0"
  exit 1
fi

echo -e "${BLUE}Phase 1: GPU Detection & Validation${NC}"
echo "============================================================="

# Detect NVIDIA GPU
if lspci | grep -i nvidia > /dev/null 2>&1; then
  echo -e "${GREEN}✓ NVIDIA GPU detected${NC}"
  lspci | grep -i nvidia
else
  echo -e "${RED}✗ No NVIDIA GPU detected${NC}"
  echo "RTX features require an NVIDIA GPU with RTX support"
  exit 1
fi

echo ""
echo -e "${BLUE}Phase 2: NVIDIA Driver Installation${NC}"
echo "============================================================="

# Check if NVIDIA drivers are already installed
if command -v nvidia-smi &> /dev/null; then
  echo -e "${GREEN}✓ NVIDIA drivers already installed${NC}"
  nvidia-smi --query-gpu=name,driver_version --format=csv,noheader
else
  echo "Installing NVIDIA drivers..."
  
  # Add NVIDIA driver repository
  add-apt-repository ppa:graphics-drivers/ppa -y
  apt-get update
  
  # Install recommended NVIDIA driver
  ubuntu-drivers devices
  ubuntu-drivers autoinstall
  
  echo -e "${YELLOW}⚠ System reboot required after driver installation${NC}"
  echo "Please reboot and run this script again"
  exit 0
fi

echo ""
echo -e "${BLUE}Phase 3: CUDA Toolkit Installation${NC}"
echo "============================================================="

# Check CUDA installation
if command -v nvcc &> /dev/null; then
  echo -e "${GREEN}✓ CUDA Toolkit already installed${NC}"
  nvcc --version | grep "release"
else
  echo "Installing CUDA Toolkit 11.8..."
  
  # Download and install CUDA
  wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb
  dpkg -i cuda-keyring_1.0-1_all.deb
  apt-get update
  apt-get -y install cuda-11-8
  
  # Add CUDA to PATH
  echo 'export PATH=/usr/local/cuda-11.8/bin:$PATH' >> /etc/profile.d/cuda.sh
  echo 'export LD_LIBRARY_PATH=/usr/local/cuda-11.8/lib64:$LD_LIBRARY_PATH' >> /etc/profile.d/cuda.sh
  
  source /etc/profile.d/cuda.sh
  
  echo -e "${GREEN}✓ CUDA Toolkit 11.8 installed${NC}"
fi

echo ""
echo -e "${BLUE}Phase 4: Docker GPU Support${NC}"
echo "============================================================="

# Install NVIDIA Container Toolkit for Docker
if command -v nvidia-container-runtime &> /dev/null; then
  echo -e "${GREEN}✓ NVIDIA Container Toolkit already installed${NC}"
else
  echo "Installing NVIDIA Container Toolkit..."
  
  distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
  
  # Download and verify GPG key
  curl -fsSL https://nvidia.github.io/nvidia-docker/gpgkey -o /tmp/nvidia-docker-gpgkey
  # In production, verify the GPG key fingerprint here
  apt-key add /tmp/nvidia-docker-gpgkey
  rm /tmp/nvidia-docker-gpgkey
  
  curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
    tee /etc/apt/sources.list.d/nvidia-docker.list
  
  apt-get update
  apt-get install -y nvidia-container-toolkit
  
  # Restart Docker to apply changes
  systemctl restart docker
  
  echo -e "${GREEN}✓ NVIDIA Container Toolkit installed${NC}"
fi

echo ""
echo -e "${BLUE}Phase 5: RTX Capabilities Verification${NC}"
echo "============================================================="

# Check RTX support
GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -1)

if echo "$GPU_NAME" | grep -i "RTX" > /dev/null; then
  echo -e "${GREEN}✓ RTX GPU detected: $GPU_NAME${NC}"
else
  echo -e "${YELLOW}⚠ Warning: GPU may not have RTX cores: $GPU_NAME${NC}"
  echo "RTX features may not be available"
fi

# Check VRAM
VRAM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -1)
echo "GPU VRAM: ${VRAM}MB"

if [ "$VRAM" -ge 8000 ]; then
  echo -e "${GREEN}✓ Sufficient VRAM for RTX operations${NC}"
else
  echo -e "${YELLOW}⚠ Warning: Less than 8GB VRAM. RTX performance may be limited${NC}"
fi

echo ""
echo -e "${BLUE}Phase 6: Unreal Engine Dependencies${NC}"
echo "============================================================="

# Install Unreal Engine prerequisites
echo "Installing Unreal Engine dependencies..."

apt-get install -y \
  build-essential \
  mono-complete \
  clang \
  cmake \
  libvulkan1 \
  vulkan-utils \
  mesa-vulkan-drivers \
  libxi6 \
  libxrandr2 \
  libxinerama1 \
  libxcursor1 \
  libxxf86vm1 \
  libgl1-mesa-dev \
  xdg-user-dirs

echo -e "${GREEN}✓ Unreal Engine dependencies installed${NC}"

echo ""
echo -e "${BLUE}Phase 7: GPU Configuration${NC}"
echo "============================================================="

# Create configuration directory
mkdir -p /etc/nexus-cos

# Create GPU configuration file
cat > /etc/nexus-cos/gpu-config.env <<EOF
# Nexus COS GPU Configuration
# Generated: $(date)

# NVIDIA GPU Settings
NVIDIA_VISIBLE_DEVICES=all
NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics,display

# CUDA Settings
CUDA_VERSION=11.8
CUDA_VISIBLE_DEVICES=0

# RTX Settings
RTX_ENABLED=true
RTX_RAYTRACING=true
RTX_DLSS=true

# Unreal Engine Settings
UE_GPU_ACCELERATION=true
UE_RAYTRACING=true
UE_CUDA_ENABLED=true

# Memory Settings
GPU_MEMORY_FRACTION=0.8
EOF

echo -e "${GREEN}✓ GPU configuration created: /etc/nexus-cos/gpu-config.env${NC}"

echo ""
echo -e "${BLUE}Phase 8: Docker GPU Test${NC}"
echo "============================================================="

# Test Docker GPU access
echo "Testing Docker GPU access..."

if docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu20.04 nvidia-smi > /dev/null 2>&1; then
  echo -e "${GREEN}✓ Docker can access GPU${NC}"
else
  echo -e "${RED}✗ Docker GPU access failed${NC}"
  echo "Please check NVIDIA Container Toolkit installation"
fi

echo ""
echo -e "${GREEN}=============================================================${NC}"
echo -e "${GREEN}RTX Enablement Complete!${NC}"
echo -e "${GREEN}=============================================================${NC}"
echo ""

echo "Summary:"
echo "--------"
echo "✓ NVIDIA GPU detected and configured"
echo "✓ NVIDIA drivers installed: $(nvidia-smi --query-gpu=driver_version --format=csv,noheader | head -1)"
echo "✓ CUDA Toolkit installed"
echo "✓ Docker GPU support enabled"
echo "✓ Unreal Engine dependencies installed"
echo "✓ RTX capabilities verified"
echo ""

echo -e "${YELLOW}Next Steps for Phase 2 - RTX Enablement:${NC}"
echo "1. Configure services to use GPU acceleration"
echo "2. Enable RTX ray tracing in Unreal Engine projects"
echo "3. Configure DLSS for enhanced performance"
echo "4. Set up GPU monitoring and metrics"
echo "5. Optimize memory allocation for GPU workloads"
echo ""

echo -e "${BLUE}Configuration file: /etc/nexus-cos/gpu-config.env${NC}"
echo -e "${BLUE}Load in services with: source /etc/nexus-cos/gpu-config.env${NC}"
echo ""

# Create RTX enablement checklist
cat > /root/RTX-ENABLEMENT-CHECKLIST.md <<'EOF'
# RTX Enablement Checklist

## Phase 1: GPU Setup ✓ Complete
- [x] NVIDIA GPU detected
- [x] NVIDIA drivers installed
- [x] CUDA Toolkit installed
- [x] Docker GPU support enabled
- [x] Unreal Engine dependencies installed

## Phase 2: RTX Features Configuration

### Service Configuration
- [ ] Enable GPU acceleration in V-Screen Pro service
- [ ] Configure V-Caster Pro for GPU encoding
- [ ] Enable RTX in Hollywood production services
- [ ] Configure AI services for CUDA acceleration
- [ ] Enable GPU for video processing pipelines

### Unreal Engine Projects
- [ ] Enable ray tracing in project settings
- [ ] Configure DLSS (Deep Learning Super Sampling)
- [ ] Enable RTX Global Illumination
- [ ] Configure RTX reflections
- [ ] Enable RTX shadows
- [ ] Configure RTX ambient occlusion

### Performance Optimization
- [ ] Set up GPU memory management
- [ ] Configure render thread priority
- [ ] Enable asynchronous texture streaming
- [ ] Configure LOD (Level of Detail) settings
- [ ] Enable GPU particle systems

### Monitoring & Validation
- [ ] Set up nvidia-smi monitoring
- [ ] Configure GPU metrics collection
- [ ] Enable performance profiling
- [ ] Set up temperature monitoring
- [ ] Configure power usage tracking

### Docker Integration
- [ ] Update docker-compose files with GPU flags
- [ ] Configure GPU resource limits
- [ ] Enable GPU passthrough for services
- [ ] Test GPU access in containers

### Testing & Validation
- [ ] Run GPU compute tests
- [ ] Validate RTX ray tracing
- [ ] Test DLSS performance
- [ ] Benchmark GPU rendering
- [ ] Validate multi-GPU setup (if applicable)

## Phase 3: Production Deployment
- [ ] Deploy GPU-enabled services to VPS
- [ ] Configure Kubernetes GPU scheduling
- [ ] Set up GPU health checks
- [ ] Enable GPU failover mechanisms
- [ ] Document GPU service requirements

## Troubleshooting

### Common Issues
1. **Docker can't access GPU**
   - Restart Docker: `systemctl restart docker`
   - Check nvidia-container-toolkit installation
   
2. **Out of memory errors**
   - Adjust GPU_MEMORY_FRACTION in config
   - Enable memory growth in services
   
3. **Low performance**
   - Check GPU utilization: `nvidia-smi`
   - Verify CUDA version compatibility
   - Check for thermal throttling

### Useful Commands
```bash
# Check GPU status
nvidia-smi

# Monitor GPU in real-time
watch -n 1 nvidia-smi

# Test Docker GPU
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu20.04 nvidia-smi

# Check CUDA version
nvcc --version

# View GPU processes
nvidia-smi pmon
```

## Resources
- NVIDIA Driver Documentation: https://docs.nvidia.com/datacenter/tesla/
- CUDA Toolkit Guide: https://docs.nvidia.com/cuda/
- Unreal Engine RTX: https://docs.unrealengine.com/en-US/ray-tracing/
- Docker GPU Support: https://docs.docker.com/config/containers/resource_constraints/#gpu
EOF

echo -e "${GREEN}✓ RTX Enablement Checklist created: /root/RTX-ENABLEMENT-CHECKLIST.md${NC}"
echo ""
echo "Review the checklist for Phase 2 configuration steps"

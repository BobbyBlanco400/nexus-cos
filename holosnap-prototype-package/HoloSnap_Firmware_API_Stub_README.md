# HoloSnap Firmware API Stub
## Preloaded Firmware + API Integration for HoloSnap v1

**Version:** 1.0.0  
**Date:** January 2026  
**Platform:** ESP32-S3 (FreeRTOS)  
**Purpose:** Firmware stub for prototype activation and N3XUS ecosystem integration

---

## 📋 Package Contents

This package contains the firmware stub and API integration code for HoloSnap v1:

### Firmware Binaries
1. `HoloSnap_Firmware_Stub_v1.0.0.bin` — Complete firmware image for ESP32-S3
2. `bootloader.bin` — ESP32-S3 bootloader
3. `partition-table.bin` — Flash partition table
4. `device_id_template.bin` — Device ID programming template

### Source Code (Reference)
- `src/main.cpp` — Main firmware entry point
- `src/holocore_runtime.cpp` — HoloCore runtime engine
- `src/metatwin_handshake.cpp` — MetaTwin 55-45-17 handshake protocol
- `src/sensor_manager.cpp` — IMU and sensor management
- `src/wifi_manager.cpp` — WiFi connectivity
- `src/api_server.cpp` — REST API endpoints

### Documentation
- `FIRMWARE_API_REFERENCE.md` — Complete API documentation
- `FLASH_INSTRUCTIONS.md` — Firmware flashing guide
- `DEVICE_ID_PROGRAMMING.md` — Device ID programming procedure

---

## 🚀 Firmware Overview

### Boot Sequence
1. **Power-On Self-Test (POST)**
   - Check system clock
   - Verify flash integrity
   - Initialize peripherals

2. **Firmware Version Check**
   - Display: `N3XUS HoloSnap v1.0.0`
   - Verify device ID is programmed

3. **Sensor Initialization**
   - Initialize IMU (ICM-20948)
   - Calibrate sensors
   - Start sensor fusion

4. **Network Initialization**
   - Start WiFi in STA+AP mode
   - Create AP: `HoloSnap-XXXX` (where XXXX = last 4 of MAC)
   - Scan for saved networks

5. **Await Activation**
   - Display: `Awaiting Activation`
   - Enable Handshake 55-45-17 protocol
   - Start API server on port 8080

### Firmware Modes

#### 1. Inactive State (Factory Default)
- **Status:** Awaiting Activation
- **LED:** Amber LED blinking (1Hz)
- **Functionality:** Limited
  - Basic sensor data available
  - WiFi connectivity active
  - API server running
  - Handshake protocol ready
  
#### 2. Active State (Post-Activation)
- **Status:** Activated
- **LED:** Green LED solid
- **Functionality:** Full
  - Complete sensor access
  - HoloCore runtime enabled
  - MetaTwin integration active
  - Ecosystem access granted

#### 3. OTA Update Mode
- **Status:** Updating Firmware
- **LED:** Blue LED flashing rapidly
- **Functionality:** Limited during update
  - WiFi active
  - Sensor data paused
  - System reboots after update

---

## 🔐 MetaTwin Handshake 55-45-17

### Protocol Implementation

#### Phase 1: Identity Verification (55)
```cpp
bool verifyIdentity() {
  // 1. Read device ID from EEPROM
  String deviceId = readDeviceId();
  
  // 2. Generate challenge token
  String challenge = generateChallenge();
  
  // 3. Send to N3XUS backend
  HTTPClient http;
  http.begin("https://api.n3xuscos.online/holosnap/verify-identity");
  http.addHeader("Content-Type", "application/json");
  http.addHeader("X-Device-Id", deviceId);
  
  String payload = "{\"challenge\":\"" + challenge + "\"}";
  int httpCode = http.POST(payload);
  
  if (httpCode == 200) {
    String response = http.getString();
    // Verify response signature
    return verifySignature(response, challenge);
  }
  
  return false;
}
```

#### Phase 2: Canon Validation (45)
```cpp
bool validateCanon() {
  // 1. Get firmware version
  String fwVersion = "1.0.0";
  
  // 2. Get hardware revision
  String hwRevision = "A1";
  
  // 3. Get sensor calibration status
  bool sensorsCalibrated = imuCalibrated();
  
  // 4. Send to N3XUS backend
  HTTPClient http;
  http.begin("https://api.n3xuscos.online/holosnap/validate-canon");
  http.addHeader("X-Device-Id", readDeviceId());
  
  String payload = "{"
    "\"firmware\":\"" + fwVersion + "\","
    "\"hardware\":\"" + hwRevision + "\","
    "\"calibrated\":" + (sensorsCalibrated ? "true" : "false") +
  "}";
  
  int httpCode = http.POST(payload);
  return (httpCode == 200);
}
```

#### Phase 3: Context Authorization (17)
```cpp
bool authorizeContext() {
  // 1. Request runtime permissions
  HTTPClient http;
  http.begin("https://api.n3xuscos.online/holosnap/authorize-context");
  http.addHeader("X-Device-Id", readDeviceId());
  
  int httpCode = http.POST("{}");
  
  if (httpCode == 200) {
    String response = http.getString();
    
    // 2. Parse permissions
    DynamicJsonDocument doc(1024);
    deserializeJson(doc, response);
    
    // 3. Enable features based on permissions
    bool ecosystemAccess = doc["ecosystem_access"];
    bool holocoreRuntime = doc["holocore_runtime"];
    
    // 4. Activate device
    if (ecosystemAccess && holocoreRuntime) {
      activateDevice();
      return true;
    }
  }
  
  return false;
}
```

### Complete Handshake Flow
```cpp
void performHandshake() {
  Serial.println("Initiating Handshake 55-45-17...");
  
  // Phase 1: Identity (55)
  if (!verifyIdentity()) {
    Serial.println("❌ Identity verification failed");
    return;
  }
  Serial.println("✅ Identity verified (55)");
  
  // Phase 2: Canon (45)
  if (!validateCanon()) {
    Serial.println("❌ Canon validation failed");
    return;
  }
  Serial.println("✅ Canon validated (45)");
  
  // Phase 3: Context (17)
  if (!authorizeContext()) {
    Serial.println("❌ Context authorization failed");
    return;
  }
  Serial.println("✅ Context authorized (17)");
  
  // Handshake complete!
  Serial.println("🎉 Handshake 55-45-17 complete!");
  Serial.println("🚀 HoloSnap activated!");
  
  // Update LED status
  setLED(LED_STATUS, GREEN, SOLID);
  
  // Enable full functionality
  enableHoloCoreRuntime();
}
```

---

## 🌐 REST API Endpoints

### Device Information
```
GET /api/device/info
```

**Response:**
```json
{
  "device_id": "HSNAP-W1-001",
  "firmware_version": "1.0.0",
  "hardware_revision": "A1",
  "status": "inactive",
  "uptime_seconds": 3600,
  "battery_percent": 85,
  "wifi_connected": true,
  "handshake_ready": true
}
```

### Device Status
```
GET /api/device/status
```

**Response:**
```json
{
  "status": "inactive",
  "activation_date": null,
  "last_handshake": null,
  "ecosystem_access": false,
  "holocore_runtime": false
}
```

### Trigger Activation
```
POST /api/device/activate
```

**Request:**
```json
{
  "user_id": "tenant-uuid-12345",
  "pre_order_id": "HSNAP-W1-001"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Activation initiated",
  "handshake_status": "in_progress"
}
```

### Sensor Data
```
GET /api/sensors/imu
```

**Response:**
```json
{
  "accelerometer": {
    "x": 0.02,
    "y": 0.01,
    "z": 9.81
  },
  "gyroscope": {
    "x": 0.0,
    "y": 0.0,
    "z": 0.0
  },
  "magnetometer": {
    "x": 23.5,
    "y": 5.8,
    "z": -45.2
  },
  "timestamp": "2026-01-15T12:00:00Z"
}
```

### WiFi Configuration
```
POST /api/wifi/config
```

**Request:**
```json
{
  "ssid": "MyNetwork",
  "password": "MyPassword123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "WiFi configured",
  "connected": true,
  "ip_address": "192.168.1.100"
}
```

### Firmware Update (OTA)
```
POST /api/firmware/update
```

**Request:**
```json
{
  "firmware_url": "https://firmware.n3xuscos.online/holosnap/v1.0.1.bin"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Firmware update initiated",
  "current_version": "1.0.0",
  "target_version": "1.0.1"
}
```

---

## 🔧 Flashing Instructions

### Prerequisites
- **Hardware:** ESP32-S3 programmer (USB-C cable)
- **Software:** esptool.py (Python tool)
- **Files:** Firmware binaries from this package

### Installation
```bash
# Install esptool
pip install esptool

# Verify installation
esptool.py version
```

### Flash Complete Firmware
```bash
# Erase flash (optional, for clean install)
esptool.py --chip esp32s3 --port /dev/ttyUSB0 erase_flash

# Flash bootloader, partition table, and firmware
esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 460800 \
  write_flash -z \
  0x1000 bootloader.bin \
  0x8000 partition-table.bin \
  0x10000 HoloSnap_Firmware_Stub_v1.0.0.bin

# Verify flash
esptool.py --chip esp32s3 --port /dev/ttyUSB0 verify_flash \
  0x10000 HoloSnap_Firmware_Stub_v1.0.0.bin
```

### Program Device ID
```bash
# Generate device ID binary
python3 generate_device_id.py HSNAP-W1-001 > device_id_HSNAP-W1-001.bin

# Flash device ID to EEPROM
esptool.py --chip esp32s3 --port /dev/ttyUSB0 \
  write_flash 0x3FC000 device_id_HSNAP-W1-001.bin

# Verify device ID
esptool.py --chip esp32s3 --port /dev/ttyUSB0 \
  read_flash 0x3FC000 0x100 verify_id.bin
```

### Serial Monitor (Debugging)
```bash
# Monitor serial output
esptool.py --chip esp32s3 --port /dev/ttyUSB0 \
  --baud 115200 \
  monitor
```

---

## 📊 System Requirements

### Minimum Requirements
- **Flash:** 4MB (8MB recommended)
- **RAM:** 512KB (2MB PSRAM available)
- **CPU:** Dual-core @ 160MHz (240MHz used)
- **WiFi:** 802.11 b/g/n (2.4GHz)
- **Bluetooth:** BLE 5.0

### Power Consumption
- **Boot:** ~300mA peak (< 1 second)
- **Idle:** ~50mA
- **WiFi Active:** ~150mA
- **Sensor Active:** ~200mA peak
- **Deep Sleep:** ~5µA

---

## 🐛 Debugging & Troubleshooting

### Serial Debug Output
Enable detailed logging via serial:
```cpp
#define DEBUG_LEVEL 2  // 0=Off, 1=Info, 2=Debug, 3=Verbose
```

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Device won't boot | Flash corruption | Re-flash firmware |
| WiFi won't connect | Wrong credentials | Check SSID/password |
| Sensors not working | IMU not initialized | Power cycle device |
| API not responding | Firewall blocking | Check port 8080 open |
| Handshake fails | Backend unreachable | Check internet connection |

---

## 📞 Support

For firmware questions or issues:
- **Technical Team:** architecture@n3xuscos.com
- **Founder:** Bobby Blanco (bobby@n3xuscos.com)
- **Documentation:** https://docs.n3xuscos.online/holosnap

---

**Firmware Version:** 1.0.0  
**Classification:** Production Firmware Stub  
**Maintained By:** N3XUS Firmware Team  
**Last Updated:** January 2026  
**Handshake Compliance:** 55-45-17 ✅

---

*"Code First. Activate Second. Innovate Forever."*  
*— N3XUS v-COS Firmware Philosophy*

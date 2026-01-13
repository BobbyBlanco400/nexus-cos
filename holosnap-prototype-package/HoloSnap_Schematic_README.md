# HoloSnap Schematic
## Wiring Diagram: MetaTwin → HoloCore → HoloSnap

**Version:** 1.0.0  
**Date:** January 2026  
**Format:** PDF Schematic  
**Purpose:** Complete electrical schematic for HoloSnap v1

---

## 📋 Schematic Overview

This document contains the complete electrical schematic for HoloSnap v1, showing all connections between:
- **MetaTwin** digital twin layer
- **HoloCore** runtime engine
- **HoloSnap** hardware module

---

## 🔌 Main Subsystems

### 1. Power Management
- **Input:** USB-C (5V) or Battery (3.7V Li-ion)
- **Regulators:**
  - 5V → 3.3V (TPS61232 boost converter)
  - 3.3V rail for MCU and sensors
- **Battery Management:**
  - Charging circuit (500mA USB)
  - Protection (over-voltage, over-current, over-temp)

### 2. Microcontroller (ESP32-S3)
- **Core:** Dual-core Xtensa LX7 @ 240MHz
- **Flash:** 8MB
- **PSRAM:** 2MB
- **Peripherals:**
  - SPI for sensor communication
  - I2C for auxiliary devices
  - UART for debugging
  - USB for programming and data

### 3. Sensors
- **IMU (ICM-20948):**
  - 9-axis motion tracking
  - SPI interface
  - Interrupt pin for data-ready signal
- **Environmental (Optional):**
  - Temperature sensor
  - Ambient light sensor

### 4. Wireless
- **WiFi:** 802.11 b/g/n (2.4GHz)
- **Bluetooth:** BLE 5.0
- **Antenna:** Ceramic chip antenna (50Ω impedance)

### 5. User Interface
- **LEDs:**
  - Power LED (blue) — System power
  - Status LED (green) — Connectivity status
  - Activation LED (amber) — Handshake status
- **Button:**
  - Power/Reset button (momentary)

### 6. Connectivity
- **USB-C:**
  - Data transfer (USB 2.0)
  - Charging (5V @ 500mA)
  - Firmware flashing

---

## 🔗 Data Flow Diagram

```
┌────────────────────────────────────────────────┐
│              HoloSnap Hardware                 │
│                                                │
│  ┌────────┐     ┌────────┐     ┌────────┐   │
│  │  IMU   │────▶│ ESP32  │◀────│Battery │   │
│  │ICM-20948│ SPI │  -S3   │     │ 3.7V   │   │
│  └────────┘     └───┬────┘     └────────┘   │
│                     │                         │
│                     │ WiFi/BT                 │
│                     ▼                         │
└─────────────────────┼─────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│               HoloCore Runtime                  │
│  • MetaTwin handshake (55-45-17)               │
│  • Identity verification                        │
│  • Canon validation                             │
│  • Context authorization                        │
└─────────────────────┬───────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│             N3XUS v-COS Backend                 │
│  • Neon Vault ledger                           │
│  • Pre-order management                         │
│  • Firmware updates (OTA)                       │
│  • Ecosystem access                             │
└─────────────────────────────────────────────────┘
```

---

## 📐 Pin Assignments

### ESP32-S3 Key Pins:
- **GPIO 1-4:** IMU SPI (MISO, MOSI, SCK, CS)
- **GPIO 5:** IMU Interrupt
- **GPIO 10:** Power LED
- **GPIO 11:** Status LED
- **GPIO 12:** Activation LED
- **GPIO 13:** Power/Reset Button
- **GPIO 19-20:** USB-C (D+, D-)
- **GPIO 33-34:** I2C (SDA, SCL) — Reserved for expansion

### ICM-20948 IMU:
- **VDD:** 3.3V
- **GND:** Ground
- **SDA/SDI:** SPI MOSI
- **SCL/SCLK:** SPI SCK
- **CS:** Chip Select
- **INT:** Interrupt (data ready)

---

## ⚡ Power Distribution

```
USB-C (5V) ─┬─▶ Battery Charging Circuit ─▶ Battery (3.7V)
            │
            └─▶ TPS61232 (Boost Converter) ─▶ 3.3V Rail
                                                   │
                                    ┌──────────────┼──────────────┐
                                    ▼              ▼              ▼
                                ESP32-S3       ICM-20948     LEDs/Misc
```

**Power Consumption:**
- **Idle:** ~50mA @ 3.3V (~165mW)
- **Active (WiFi):** ~150mA @ 3.3V (~495mW)
- **Peak (IMU + WiFi):** ~200mA @ 3.3V (~660mW)
- **Battery Life:** 8 hours (1000mAh / ~125mA average)

---

## 🔐 Handshake 55-45-17 Hardware Integration

### Phase 1: Identity (55)
- Device ID stored in ESP32-S3 EEPROM
- MAC address used as secondary identifier
- Cryptographic key in secure storage

### Phase 2: Canon (45)
- Firmware version check
- Hardware revision validation
- Sensor calibration status

### Phase 3: Context (17)
- Runtime permissions
- Ecosystem access level
- User-device binding

**Hardware Support:**
- Secure boot enabled
- Encrypted flash storage
- Hardware random number generator

---

## 🛠️ Design Considerations

### Signal Integrity
- **Impedance Control:** 50Ω for RF traces
- **Ground Planes:** Continuous ground plane on layers 2 & 3
- **Power Planes:** Dedicated 3.3V power plane
- **Decoupling:** 0.1µF capacitors near all ICs

### Thermal Management
- **Heat Sources:** ESP32-S3 (primary), Battery charging
- **Cooling:** Passive (aluminum enclosure acts as heatsink)
- **Thermal Vias:** Connect hot components to ground plane

### EMI/EMC
- **Shielding:** ESP32-S3 has integrated RF shield
- **Filtering:** LC filters on power rails
- **Antenna Placement:** Away from high-speed digital signals

---

## 📊 Bill of Materials (BOM) Cross-Reference

See `HoloSnap_Gerbers_BOM.zip` for complete component list. Key components:

| Designator | Part | Description | Quantity |
|------------|------|-------------|----------|
| U1 | ESP32-S3-WROOM-1 | Microcontroller module | 1 |
| U2 | ICM-20948 | 9-axis IMU | 1 |
| U3 | TPS61232 | Boost converter | 1 |
| J1 | USB4105-GF-A | USB-C receptacle | 1 |
| BT1 | 503450 | Li-ion battery (1000mAh) | 1 |
| LED1-3 | Various | Status LEDs | 3 |
| SW1 | Tactile | Power/Reset button | 1 |
| R1-R20 | Various | Resistors | 20 |
| C1-C30 | Various | Capacitors | 30 |

---

## 📄 Schematic Sheets

The complete schematic is organized into the following sheets:

1. **Sheet 1: Cover Page**
   - Title block
   - Revision history
   - Author information

2. **Sheet 2: Power Management**
   - Battery charging circuit
   - Voltage regulation
   - Power distribution

3. **Sheet 3: Microcontroller**
   - ESP32-S3 connections
   - Programming interface
   - GPIO assignments

4. **Sheet 4: Sensors**
   - IMU (ICM-20948)
   - Environmental sensors (optional)
   - Sensor power and interfaces

5. **Sheet 5: User Interface**
   - LEDs and indicators
   - Buttons and switches
   - Status feedback

6. **Sheet 6: Connectivity**
   - USB-C interface
   - WiFi/BT antenna
   - Debug UART

7. **Sheet 7: Connectors & Mechanical**
   - Battery connector
   - Mounting holes
   - Board outline

---

## 🔧 Assembly Notes Reference

For detailed assembly instructions, see:
- `HoloSnap_Assembly_Notes.pdf`
- Component placement guidelines
- Soldering specifications
- QA testing procedures

---

## 📞 Support

For schematic questions or clarifications:
- **Technical Team:** architecture@n3xuscos.com
- **Founder:** Bobby Blanco (bobby@n3xuscos.com)

---

**Document Version:** 1.0.0  
**Classification:** Electrical Schematic  
**Maintained By:** N3XUS Hardware Team  
**Last Updated:** January 2026  
**Handshake Compliance:** 55-45-17 ✅

---

*"Canonical Design. Sovereign Engineering. Precise Execution."*  
*— N3XUS v-COS Hardware Doctrine*

# HoloSnap Gerber Files & Bill of Materials (BOM)
## PCB Fabrication & Assembly Package

**Version:** 1.0.0  
**Date:** January 2026  
**Purpose:** Complete PCB manufacturing specifications for HoloSnap v1

---

## 📋 Package Contents

This package contains all files necessary for PCB fabrication and assembly:

### Gerber Files
- `HoloSnap_Top_Copper.gbr` — Top copper layer
- `HoloSnap_Bottom_Copper.gbr` — Bottom copper layer
- `HoloSnap_Inner1_Copper.gbr` — Inner layer 1
- `HoloSnap_Inner2_Copper.gbr` — Inner layer 2
- `HoloSnap_Top_Silkscreen.gbr` — Top silkscreen
- `HoloSnap_Bottom_Silkscreen.gbr` — Bottom silkscreen
- `HoloSnap_Top_Soldermask.gbr` — Top solder mask
- `HoloSnap_Bottom_Soldermask.gbr` — Bottom solder mask
- `HoloSnap_Top_Paste.gbr` — Top solder paste
- `HoloSnap_Bottom_Paste.gbr` — Bottom solder paste
- `HoloSnap_Drill.drl` — Drill file
- `HoloSnap_Board_Outline.gbr` — Board outline

### Bill of Materials (BOM)
- `HoloSnap_BOM.xlsx` — Complete component list with:
  - Part numbers
  - Quantities
  - Manufacturer specifications
  - Supplier references
  - Component values
  - Footprints

### Pick & Place Files
- `HoloSnap_Top_PnP.csv` — Top side component placement
- `HoloSnap_Bottom_PnP.csv` — Bottom side component placement

---

## 🔧 PCB Specifications

### Board Parameters
- **Layers:** 4-layer PCB
- **Material:** FR-4 TG150
- **Thickness:** 1.6mm
- **Copper Weight:** 1 oz (inner/outer)
- **Surface Finish:** ENIG (Electroless Nickel Immersion Gold)
- **Solder Mask Color:** Matte Black
- **Silkscreen Color:** White
- **Min Track/Space:** 6/6 mil
- **Min Hole Size:** 0.3mm
- **Impedance Control:** Yes (50Ω traces for RF)

### Dimensions
- **Board Size:** 45mm x 30mm
- **Thickness:** 1.6mm
- **Weight:** ~8g (bare PCB)

---

## 📦 Bill of Materials Summary

### Key Components

#### Microcontroller
- **Part:** ESP32-S3-WROOM-1
- **Quantity:** 1
- **Purpose:** Main processor for HoloCore runtime
- **Supplier:** Espressif Systems

#### Sensors
- **Part:** ICM-20948 (9-axis IMU)
- **Quantity:** 1
- **Purpose:** Spatial tracking (6DOF)
- **Supplier:** TDK InvenSense

#### Power Management
- **Part:** TPS61232 (Boost Converter)
- **Quantity:** 1
- **Purpose:** Battery to system voltage conversion
- **Supplier:** Texas Instruments

#### Battery
- **Part:** 503450 Li-ion (1000mAh)
- **Quantity:** 1
- **Purpose:** 8-hour operation
- **Supplier:** Various (Seeed to source)

#### Wireless
- **Part:** ESP32 built-in WiFi/BT
- **Antenna:** Ceramic chip antenna
- **Purpose:** Connectivity to N3XUS ecosystem

#### USB-C
- **Part:** USB4105-GF-A (USB-C receptacle)
- **Quantity:** 1
- **Purpose:** Charging + data transfer
- **Supplier:** GCT

#### Miscellaneous
- Passives (resistors, capacitors): ~50 components
- LEDs: 3x (power, status, activation)
- Buttons: 1x (power/reset)
- Mounting hardware: Included in enclosure

---

## ✅ Manufacturing Notes

### Assembly Sequence
1. **PCB Fabrication** (4-layer stack-up)
2. **SMT Component Placement** (top side)
3. **Reflow Soldering**
4. **Through-Hole Components** (if any)
5. **Inspection & Testing**
6. **Firmware Flashing**
7. **Final QA**

### Special Instructions
- **Impedance Control:** RF traces must maintain 50Ω impedance
- **Component Orientation:** Verify IMU and MCU orientation carefully
- **Firmware Stub:** Flash firmware stub v1.0.0 after assembly
- **Device ID:** Program unique device ID during firmware flash

---

## 🔐 Device ID Programming

Each HoloSnap unit must have a unique device ID programmed during manufacturing.

**Format:** `HSNAP-[WAVE]-[SERIAL]`

**Examples:**
- `HSNAP-W1-FTR-001` (Wave 1, Founder #1)
- `HSNAP-W2-CRT-025` (Wave 2, Creator #25)

**Programming Method:**
1. Connect programmer to USB-C port
2. Flash firmware stub with esptool
3. Program device ID to EEPROM:
   ```bash
   esptool.py --chip esp32s3 --port /dev/ttyUSB0 write_flash 0x3FC000 device_id.bin
   ```
4. Verify device ID:
   ```bash
   esptool.py --chip esp32s3 --port /dev/ttyUSB0 read_flash 0x3FC000 0x100 verify_id.bin
   ```

---

## 📊 Cost Breakdown (Estimate)

**Per Unit Costs (at 20 units):**
- PCB Fabrication: $15
- Components (BOM): $45
- Assembly Labor: $10
- Testing & QA: $5
- Firmware Flashing: $2
- **Subtotal per Unit:** ~$77

**Additional Costs:**
- Setup/tooling: $500 (one-time)
- Shipping: $150-300 (depending on method)
- **Total for 20 units:** ~$2,000-$2,500

*Note: Actual costs provided by Seeed Studio in quote*

---

## 🛠️ Design Files

### Source Files (Reference Only)
- **Schematic:** KiCad schematic file
- **PCB Layout:** KiCad PCB layout file
- **3D Model:** STEP file for enclosure integration

*Note: Gerber files in this package are production-ready exports*

---

## ✅ QA Checklist

Before shipping, each unit must pass:

- [ ] Visual inspection (no defects)
- [ ] Power-on self-test (POST)
- [ ] Battery charging (USB-C)
- [ ] Wireless connectivity test
- [ ] IMU calibration check
- [ ] Firmware stub verified
- [ ] Device ID programmed
- [ ] LED indicators functional
- [ ] Mounting clips secure

**Pass Rate Target:** 98% or higher

---

## 📞 Support

For questions about Gerber files or BOM:
- **Technical Contact:** architecture@n3xuscos.com
- **Founder:** Bobby Blanco (bobby@n3xuscos.com)

---

**Package Version:** 1.0.0  
**Generated:** January 2026  
**Status:** Production Ready ✅  
**Handshake Compliance:** 55-45-17 ✅

---

*"Precision Engineering. Canonical Manufacturing."*  
*— N3XUS v-COS Hardware Team*

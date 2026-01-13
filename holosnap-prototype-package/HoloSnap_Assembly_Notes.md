# HoloSnap Assembly Notes
## Step-by-Step Manufacturing Instructions

**Version:** 1.0.0  
**Date:** January 2026  
**Audience:** Seeed Studio Manufacturing Team  
**Device:** HoloSnap v1 Prototype

---

## 📋 Assembly Overview

This document provides detailed instructions for assembling HoloSnap v1 devices. Follow these steps precisely to ensure quality and consistency.

---

## 🔧 Pre-Assembly Preparation

### Required Equipment
- SMT pick-and-place machine
- Reflow oven (temperature controlled)
- Soldering station (for manual assembly)
- Programming station (ESP32 flashing)
- Testing equipment (multimeter, oscilloscope)
- ESD-safe workstations

### Materials Checklist
- [ ] PCB boards (4-layer, matte black)
- [ ] All BOM components (verified)
- [ ] Firmware stub binary (v1.0.0)
- [ ] Device ID programming file
- [ ] Packaging materials
- [ ] Assembly jigs/fixtures

---

## 📐 Assembly Steps

### Step 1: PCB Inspection
**Duration:** 2 minutes per unit

1. **Visual Inspection:**
   - Check for scratches or defects
   - Verify silkscreen alignment
   - Confirm board dimensions (45mm x 30mm)
   
2. **Electrical Continuity:**
   - Test power rails (3.3V, 5V, GND)
   - Verify no shorts between layers
   - Check impedance-controlled traces (50Ω)

**Accept/Reject Criteria:**
- ✅ Accept: No visible defects, all tests pass
- ❌ Reject: Visible damage, electrical faults

---

### Step 2: SMT Component Placement (Top Side)
**Duration:** 15 minutes per unit (automated)

#### Component Placement Order:
1. **Passives (Resistors/Capacitors)**
   - Place smallest components first
   - Verify polarity for polarized capacitors
   
2. **ICs & Active Components**
   - ESP32-S3-WROOM-1 (MCU)
   - ICM-20948 (IMU)
   - TPS61232 (Power Management)
   
3. **Connectors**
   - USB-C receptacle (USB4105-GF-A)
   
4. **LEDs & Buttons**
   - Power LED (blue)
   - Status LED (green)
   - Activation LED (amber)
   - Power/Reset button

**Critical Alignment:**
- **IMU (ICM-20948):** Orientation must match silkscreen exactly
- **ESP32-S3:** Pin 1 indicator must align with PCB marking
- **USB-C:** Centered and flush with board edge

---

### Step 3: Solder Paste Application
**Duration:** 3 minutes per unit

1. Apply solder paste using stencil
2. Verify paste thickness (0.15mm ±0.02mm)
3. Check for bridging or gaps
4. Inspect paste alignment with pads

---

### Step 4: Reflow Soldering
**Duration:** 8 minutes per unit

#### Reflow Profile (Lead-Free SAC305):
- **Preheat:** 150°C for 90 seconds
- **Soak:** 150-180°C for 60 seconds
- **Reflow:** Peak 245°C for 30 seconds
- **Cooling:** Natural cooling to <50°C

**Post-Reflow Inspection:**
- [ ] No solder bridges
- [ ] All joints reflowed properly
- [ ] No tombstoning or lifted components
- [ ] No cold joints

---

### Step 5: Through-Hole Components (If Any)
**Duration:** 5 minutes per unit

1. Insert through-hole components manually
2. Solder on bottom side
3. Trim excess leads flush with board
4. Inspect solder joints for quality

*Note: HoloSnap v1 minimizes through-hole components for compactness*

---

### Step 6: Post-Assembly Inspection
**Duration:** 5 minutes per unit

#### Visual Inspection:
- [ ] All components present
- [ ] No solder bridges or shorts
- [ ] Proper component orientation
- [ ] Clean flux residue (if required)

#### Electrical Testing:
- [ ] Power rails voltage check
  - 3.3V rail: 3.3V ±0.1V
  - 5V rail: 5.0V ±0.2V
- [ ] USB-C connectivity
- [ ] LED functionality
- [ ] Button operation

---

### Step 7: Battery Integration
**Duration:** 3 minutes per unit

1. **Battery Preparation:**
   - 503450 Li-ion (1000mAh)
   - Verify battery protection circuit
   - Check voltage (3.7V ±0.2V)

2. **Battery Connection:**
   - Connect battery to JST connector on PCB
   - Secure battery with adhesive tape
   - Route cable away from high-temp components

3. **Charging Test:**
   - Connect USB-C charger
   - Verify charging LED lights up
   - Measure charging current (~500mA)

---

### Step 8: Firmware Flashing
**Duration:** 5 minutes per unit

#### Firmware Stub v1.0.0

1. **Connect Programmer:**
   - USB-C cable to programming station
   - Verify ESP32-S3 detected

2. **Flash Firmware Stub:**
   ```bash
   esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 460800 \
     write_flash -z 0x0 HoloSnap_Firmware_Stub_v1.0.0.bin
   ```

3. **Program Device ID:**
   - Assign unique ID per unit
   - Format: `HSNAP-W[X]-[SERIAL]` (e.g., HSNAP-W1-001, HSNAP-W2-015)
   - Flash to EEPROM (replace DEVICE_ID with actual unique ID):
   ```bash
   esptool.py --chip esp32s3 --port /dev/ttyUSB0 \
     write_flash 0x3FC000 device_id_${DEVICE_ID}.bin
   ```
   **Note:** Each device must have a unique ID programmed during manufacturing.

4. **Verify Boot:**
   - Power cycle device
   - Check serial output for firmware version
   - Verify device ID is programmed
   - Confirm "Awaiting Activation" status

**Expected Output:**
```
N3XUS HoloSnap v1.0.0
Device ID: HSNAP-W1-001
Status: Awaiting Activation
Handshake: 55-45-17 Ready
```

---

### Step 9: Functional Testing
**Duration:** 10 minutes per unit

#### Power & Connectivity Tests:
1. **Power-On Self-Test (POST):**
   - [ ] Device powers on from battery
   - [ ] Power LED (blue) illuminates
   - [ ] No error codes displayed

2. **USB-C Test:**
   - [ ] Connect to computer
   - [ ] Device recognized as USB serial
   - [ ] Data transfer functional

3. **Wireless Test:**
   - [ ] WiFi scan detects networks
   - [ ] Bluetooth advertising active

#### Sensor Tests:
1. **IMU Calibration Check:**
   - [ ] IMU responds to motion
   - [ ] Accelerometer reading: ~9.8 m/s² (gravity)
   - [ ] Gyroscope reading: ~0 deg/s (stationary)
   - [ ] Magnetometer calibrated

2. **Latency Test:**
   - [ ] Sensor data update rate: 100Hz
   - [ ] Latency: < 20ms

#### Firmware Tests:
1. **MetaTwin Handshake Readiness:**
   - [ ] Handshake protocol responds
   - [ ] Identity phase functional (55)
   - [ ] Canon phase functional (45)
   - [ ] Context phase functional (17)

**Pass/Fail Criteria:**
- ✅ **Pass:** All tests successful
- ❌ **Fail:** Any test fails → Rework required

---

### Step 10: Enclosure Assembly
**Duration:** 5 minutes per unit

1. **Prepare Enclosure:**
   - Clean 3D-printed or machined enclosure
   - Verify fit with PCB
   - Check mounting clip mechanism

2. **Install PCB:**
   - Place PCB into bottom enclosure half
   - Secure with screws or clips
   - Ensure no stress on components

3. **Attach Top Cover:**
   - Align top cover with bottom
   - Snap or screw into place
   - Verify no gaps or misalignment

4. **Final Inspection:**
   - [ ] Enclosure fully closed
   - [ ] LEDs visible through light pipes
   - [ ] Button accessible and functional
   - [ ] USB-C port accessible

---

### Step 11: Final QA & Packaging
**Duration:** 5 minutes per unit

#### Final Quality Check:
- [ ] Visual: No cosmetic defects
- [ ] Functional: All features working
- [ ] Firmware: Correct version and device ID
- [ ] Weight: < 50g (target met)
- [ ] Dimensions: 45mm x 30mm x 15mm

#### Packaging:
1. **Clean Device:**
   - Remove fingerprints and dust
   - Inspect for scratches

2. **Package Contents:**
   - HoloSnap device
   - USB-C charging cable (1m)
   - Quick start guide (printed card)
   - N3XUS welcome card
   - Founder/Creator edition certificate (Wave 1-2 only)

3. **Protective Packaging:**
   - Place device in foam insert
   - Seal in custom HoloSnap box
   - Add bubble wrap for shipping
   - Apply shipping label

---

## 📊 Quality Metrics

### Target Metrics:
- **First-Pass Yield:** 95% or higher
- **Final Pass Rate:** 98% or higher
- **Rework Rate:** < 5%
- **Defect Rate:** < 2%

### Common Issues & Solutions:

| Issue | Root Cause | Solution |
|-------|------------|----------|
| Solder bridges | Excess solder paste | Reduce paste thickness |
| Cold joints | Low reflow temp | Increase peak temperature |
| IMU orientation error | Manual placement error | Use alignment jig |
| Firmware flash fail | Poor USB connection | Clean connector, retry |
| Battery not charging | Reversed polarity | Check JST connector orientation |

---

## 🔄 Rework Process

If a unit fails QA:

1. **Document Failure:**
   - Record failure mode
   - Note device ID
   - Photograph defect

2. **Rework:**
   - Remove defective component (if component failure)
   - Replace with new component
   - Re-solder and inspect

3. **Re-Test:**
   - Repeat all functional tests
   - Ensure issue resolved
   - Document rework completion

4. **Final Approval:**
   - QA lead approval required
   - Update pass/fail log
   - Proceed to packaging

---

## 📦 Batch Processing

### Recommended Batch Size: 5-10 units

**Why Batching:**
- Efficient use of reflow oven
- Consistent quality across batch
- Easier troubleshooting

**Batch Workflow:**
1. Prepare all PCBs for batch
2. SMT placement for all units
3. Reflow all units together
4. Inspection and testing one-by-one
5. Firmware flashing one-by-one
6. Final packaging

---

## 📞 Support & Questions

For manufacturing questions or issues:

**N3XUS Technical Team:**
- Email: architecture@n3xuscos.com
- Founder: Bobby Blanco (bobby@n3xuscos.com)
- Phone: [Your Phone Number]

**Response Time:** Within 24 hours for urgent issues

---

## ✅ Assembly Completion Checklist

- [ ] All PCBs inspected
- [ ] SMT components placed correctly
- [ ] Reflow soldering complete
- [ ] Post-reflow inspection passed
- [ ] Batteries integrated and tested
- [ ] Firmware stub flashed
- [ ] Device IDs programmed
- [ ] Functional tests passed (100% units)
- [ ] Enclosures assembled
- [ ] Final QA passed
- [ ] Packaging complete
- [ ] Ready for shipment

---

**Document Version:** 1.0.0  
**Classification:** Manufacturing Instructions  
**Maintained By:** N3XUS Hardware Team  
**Last Updated:** January 2026  
**Handshake Compliance:** 55-45-17 ✅

---

*"Precision Assembly. Canonical Quality. Sovereign Excellence."*  
*— N3XUS v-COS Manufacturing Doctrine*

# HoloSnap 3D Enclosure STL Files
## Casing & HoloLens Mounting Design

**Version:** 1.0.0  
**Date:** January 2026  
**Format:** STL (3D printable / CNC machined)  
**Purpose:** Complete enclosure and mounting system for HoloSnap v1

---

## 📋 Package Contents

This package contains all 3D design files for HoloSnap v1 enclosure:

### STL Files
1. `HoloSnap_Bottom_Case.stl` — Bottom enclosure half (with PCB mounting)
2. `HoloSnap_Top_Cover.stl` — Top enclosure cover (with LED light pipes)
3. `HoloSnap_Clip_Mechanism.stl` — Universal headset clip attachment
4. `HoloSnap_HoloLens_Mount.stl` — Dedicated HoloLens 2 mounting bracket
5. `HoloSnap_Button_Cap.stl` — Power/Reset button cap
6. `HoloSnap_Logo_Inlay.stl` — N3XUS holographic logo (optional)

### Additional Files
- `HoloSnap_Assembly_Guide_3D.pdf` — 3D assembly visualization
- `HoloSnap_Dimensions_Drawing.pdf` — Detailed dimensions and tolerances

---

## 📐 Design Specifications

### Overall Dimensions
- **Length:** 45mm
- **Width:** 30mm
- **Height:** 15mm
- **Weight (Assembled):** < 50g (target: 42g with PCB and battery)

### Material Recommendations

#### 3D Printing (Prototype):
- **Material:** PETG or Nylon
- **Infill:** 100% (solid)
- **Layer Height:** 0.1mm (high detail)
- **Supports:** Yes (for clip mechanism)
- **Post-Processing:** Sand and paint (matte black)

#### CNC Machining (Production):
- **Material:** Aerospace-grade aluminum (6061-T6)
- **Finish:** Anodized matte black
- **Tolerances:** ±0.05mm for mounting surfaces
- **Surface Roughness:** Ra 1.6µm or better

#### Injection Molding (Mass Production):
- **Material:** PC (Polycarbonate) or ABS
- **Finish:** Textured matte black
- **Wall Thickness:** 1.5mm nominal
- **Draft Angle:** 2° for easy ejection

---

## 🔧 Component Breakdown

### Bottom Case
**File:** `HoloSnap_Bottom_Case.stl`

**Features:**
- PCB mounting posts (M2 threaded inserts or snap-fit)
- Battery compartment (recessed for 503450 cell)
- USB-C port cutout (precise fit for USB4105-GF-A)
- Cable routing channels
- Heat dissipation fins (internal)

**Mounting Points:**
- 4x M2 screws for PCB (2.5mm standoff height)
- 2x snap-fit clips for top cover (optional screws)

### Top Cover
**File:** `HoloSnap_Top_Cover.stl`

**Features:**
- LED light pipes (3x for power, status, activation LEDs)
- Button cutout for power/reset button
- Ventilation slots (passive cooling)
- N3XUS logo embossed (optional holographic inlay)
- Snap-fit or screw attachment to bottom case

**Light Pipes:**
- Transparent plastic inserts (or integral if printing clear PETG)
- Positioned over PCB LEDs
- Diffuser design for even illumination

### Clip Mechanism
**File:** `HoloSnap_Clip_Mechanism.stl`

**Features:**
- **Universal Compatibility:** Fits most VR/AR headsets
  - HoloLens 2
  - Meta Quest 2/3
  - Valve Index
  - HTC Vive Pro
  - PlayStation VR2
  
- **Adjustable Clamp:** Spring-loaded (or manual screw)
- **Rubber Padding:** Protects headset (TPU insert)
- **Cable Management:** Integrated clips for wireless freedom

**Attachment:**
- Mounts to bottom case via M3 screws (2x)
- Swivel mechanism (90° rotation) for optimal positioning

### HoloLens Mount
**File:** `HoloSnap_HoloLens_Mount.stl`

**Features:**
- **Dedicated HoloLens 2 Bracket:**
  - Matches HoloLens 2 headband geometry
  - Secure snap-fit attachment
  - Does not interfere with visor adjustment
  
- **Positioning:** Mounts above visor (forehead area)
- **Quick Release:** Tool-less attachment/removal
- **Weight Distribution:** Balanced to avoid front-heavy feel

### Button Cap
**File:** `HoloSnap_Button_Cap.stl`

**Features:**
- Soft-touch ergonomic design
- Tactile feedback (travel: 1.5mm)
- Matte texture for grip
- Aligns with tactile switch on PCB

### Logo Inlay (Optional)
**File:** `HoloSnap_Logo_Inlay.stl`

**Features:**
- N3XUS holographic logo
- 3D embossed design
- Can be printed in metallic filament or painted
- Press-fit into top cover recess

---

## 🔩 Assembly Instructions

### Step 1: Insert Threaded Inserts (If Using Screws)
1. Heat M2 threaded inserts with soldering iron
2. Press into bottom case mounting posts (4x)
3. Allow to cool for proper bonding

### Step 2: Install PCB
1. Place PCB into bottom case
2. Align USB-C port with cutout
3. Secure with M2 screws (4x, torque: 0.5 Nm)

### Step 3: Route Battery Cable
1. Place battery in recessed compartment
2. Route cable through channel to PCB connector
3. Secure battery with adhesive tape (double-sided)

### Step 4: Install Light Pipes (If Separate)
1. Insert transparent light pipe inserts into top cover
2. Align with LED positions on PCB
3. Press-fit or glue into place

### Step 5: Attach Top Cover
1. Position top cover over bottom case
2. Align snap-fit clips (or screw holes)
3. Press down to snap in place (or secure with M2 screws)

### Step 6: Install Button Cap
1. Place button cap over tactile switch
2. Ensure proper alignment and travel
3. Test button operation

### Step 7: Attach Clip Mechanism
1. Position clip mechanism on bottom case
2. Secure with M3 screws (2x, torque: 1.0 Nm)
3. Test swivel and clamping action

### Step 8: Final Inspection
- [ ] All screws tight
- [ ] No gaps between case halves
- [ ] LEDs visible through light pipes
- [ ] Button functional
- [ ] USB-C port accessible
- [ ] Clip mechanism secure

---

## 📊 Tolerances & Fit

### Critical Dimensions
- **USB-C Cutout:** 9.0mm x 3.5mm (±0.1mm)
- **LED Light Pipes:** Ø3mm (±0.05mm)
- **PCB Standoffs:** 2.5mm height (±0.1mm)
- **Button Travel:** 1.5mm (±0.2mm)

### Clearances
- **PCB to Case:** 1mm minimum clearance on all sides
- **Battery to PCB:** 2mm minimum clearance (heat protection)
- **USB-C Connector:** 0.5mm clearance for cable insertion

---

## 🎨 Finishing Options

### 3D Printed Prototypes
1. **Sand:** Start with 220 grit, finish with 600 grit
2. **Prime:** Automotive filler primer
3. **Paint:** Matte black (spray or brush)
4. **Clear Coat:** Matte clear coat (optional)

### CNC Machined Production
1. **Anodize:** Type II anodizing (matte black)
2. **Laser Engrave:** N3XUS logo and serial number
3. **Inspect:** Visual and dimensional inspection

### Injection Molded Mass Production
1. **Mold Texture:** VDI 27 (matte finish)
2. **In-Mold Decoration:** N3XUS logo (optional)
3. **Quality Control:** 100% visual inspection

---

## 🔬 Testing & Validation

### Mechanical Tests
- [ ] Drop Test: 1m onto concrete (6 drops, all orientations)
- [ ] Vibration Test: 10-500Hz for 30 minutes
- [ ] Temperature Cycling: -20°C to 60°C (10 cycles)
- [ ] Clip Fatigue Test: 1000 attachment/removal cycles

### Fit & Finish Tests
- [ ] USB-C Cable Fit: 10+ cable insertions/removals
- [ ] Button Life: 10,000 press cycles
- [ ] LED Visibility: Ambient light testing
- [ ] Headset Compatibility: Test on 5+ headset models

### User Experience Tests
- [ ] Comfort: 2-hour wear test
- [ ] Weight Distribution: Balance check
- [ ] Ease of Attachment: Time to mount (target: < 30 seconds)
- [ ] Quick Release: Time to remove (target: < 10 seconds)

---

## 📏 Customization Options

### Branding
- **Founder Edition:** Engraved serial number (FTR-001 → FTR-013)
- **Creator Edition:** "Creator Edition" text
- **Standard Edition:** N3XUS logo only

### Color Options (Future Waves)
- **Wave 1-2:** Matte Black (canon standard)
- **Wave 3+:** Optional colors (matte white, gray, blue)

### Accessory Mounts
- **Future Expansion:** Mounting points for:
  - Additional sensors
  - Camera modules
  - LED ring lights
  - Custom accessories

---

## 📦 Packaging Integration

### Box Dimensions
- **Package Size:** 100mm x 80mm x 40mm
- **Foam Insert:** Custom-cut to hold device securely

### Unboxing Experience
1. Open box lid (magnetic closure)
2. Reveal HoloSnap device in foam insert
3. Accessories beneath (USB-C cable, quick start guide)
4. N3XUS welcome card on lid interior

---

## 📞 Support

For 3D design questions or modifications:
- **Technical Team:** architecture@n3xuscos.com
- **Founder:** Bobby Blanco (bobby@n3xuscos.com)

---

**Document Version:** 1.0.0  
**Classification:** Mechanical Design Files  
**Maintained By:** N3XUS Hardware Team  
**Last Updated:** January 2026  
**Handshake Compliance:** 55-45-17 ✅

---

*"Precision Engineering. Elegant Design. Universal Compatibility."*  
*— N3XUS v-COS Hardware Doctrine*

# HoloSnap Turnkey Prototype Submission Guide
## Step-by-Step Instructions for Seeed Fusion Submission

**Version:** 1.0.0  
**Date:** January 2026  
**Target:** Seeed Fusion Turnkey PCB Assembly  
**Objective:** Submit HoloSnap v1 prototype order (10-50 units)

---

## 📋 Prerequisites

Before submitting to Seeed Fusion, ensure you have:

- [x] All package files prepared (see `/holosnap-prototype-package/`)
- [x] Seeed Studio account created
- [x] Founder brief ready for submission notes
- [x] Budget approved (estimated $5,000-$15,000 for 10-50 units)
- [x] Timeline confirmed (Q2 2026 target)

---

## 1️⃣ Prepare the Package

### Step 1: Create Submission ZIP

Zip all canonical files into a single package:

```bash
cd /home/runner/work/nexus-cos/nexus-cos/holosnap-prototype-package
zip -r N3XUS_vCOS_HoloSnap_Prototype_Package.zip \
  HOLOSNAP_MANUFACTURING_DISTRIBUTION_MANIFEST.md \
  HoloSnap_Gerbers_BOM.zip \
  HoloSnap_Schematic.pdf \
  HoloSnap_3D_Enclosure_STL.zip \
  HoloSnap_Firmware_API_Stub.zip \
  HoloSnap_Assembly_Notes.pdf \
  HOLOSNAP_FOUNDER_BRIEF.md
```

### Step 2: Verify Package Contents

Ensure the following files are included:

1. ✅ **HOLOSNAP_MANUFACTURING_DISTRIBUTION_MANIFEST.md** — Full manufacturing plan
2. ✅ **HoloSnap_Gerbers_BOM.zip** — PCB fabrication files + Bill of Materials
3. ✅ **HoloSnap_Schematic.pdf** — Wiring diagram (MetaTwin → HoloCore → HoloSnap)
4. ✅ **HoloSnap_3D_Enclosure_STL.zip** — Casing & HoloLens mounting design
5. ✅ **HoloSnap_Firmware_API_Stub.zip** — Preloaded firmware + API stub
6. ✅ **HoloSnap_Assembly_Notes.pdf** — Step-by-step assembly instructions
7. ✅ **HOLOSNAP_FOUNDER_BRIEF.md** — Founder context for manufacturer

---

## 2️⃣ Visit Seeed Fusion Portal

### Step 1: Navigate to Seeed Fusion

**URL:** https://www.seeedstudio.com/fusion.html

### Step 2: Login / Create Account

- If you have an existing account, login
- If not, create a new founder account:
  - **Name:** Bobby Blanco
  - **Company:** N3XUS v-COS
  - **Email:** bobby@n3xuscos.com
  - **Project:** HoloSnap v1 Prototype

### Step 3: Access Turnkey PCB Assembly

1. Click **"Fusion PCB Assembly"** from the main menu
2. Select **"Turnkey PCB Assembly"** option
3. Choose **"Prototype / Low-Volume Run"** (10-50 units)

---

## 3️⃣ Start Turnkey PCB Assembly / Prototype

### Step 1: Upload Package ZIP

1. Click **"Upload Files"** button
2. Select `N3XUS_vCOS_HoloSnap_Prototype_Package.zip`
3. Wait for upload completion (may take 1-2 minutes)
4. Verify all files are listed correctly

### Step 2: Specify Quantity

1. Enter desired quantity: **10-50 units**
2. Recommended starting quantity: **20 units**
   - 13 units for Wave 1 (Founding Tenants)
   - 5-7 units for N3XUS internal testing
3. Option to scale up for Wave 2 after validation

### Step 3: Select Production Options

#### PCB Specifications:
- **Layers:** 4-layer PCB
- **Material:** FR-4 TG150
- **Thickness:** 1.6mm
- **Surface Finish:** ENIG (Electroless Nickel Immersion Gold)
- **Solder Mask Color:** Matte Black
- **Silkscreen:** White

#### Assembly Options:
- **Assembly Type:** Turnkey (Seeed sources all components)
- **Assembly Side:** Top side only
- **Component Sourcing:** Seeed Studio sources per BOM
- **Quality Level:** Industrial grade

#### Testing & Inspection:
- **Functional Testing:** Yes (power-on + connectivity test)
- **Visual Inspection:** 100% units
- **X-Ray Inspection:** Optional (recommended for critical connections)

---

## 4️⃣ Add Notes / Special Instructions

### Copy Founder Brief

Paste the following into the **"Notes / Special Instructions"** section:

---

**Hi Seeed Fusion Team,**

I am **Bobby Blanco**, founder of **N3XUS v-COS**, the canonical Creative Operating System integrating MetaTwin digital avatars, HoloCore identity engine, HoloLens AR interface, and HoloSnap devices.

We are preparing **Wave 2 pre-orders (Phase 2.5)** and require a **turnkey prototype run: 10–50 units** for integration testing and pre-order activation.

Please follow the attached files for PCB, BOM, firmware, 3D enclosure, and assembly notes. Prototype must:

1. ✅ **Validate MetaTwin/HoloCore/HoloLens integration**
2. ✅ **Support tenant-aware pre-order ledger (Neon Vault)**
3. ✅ **Be fully Handshake 55-45-17 compliant**

**Timeline:** Q2 2026 (Phase 2.5 Wave 2 pre-orders)  
**Action:** Assemble, test, and ship turnkey prototypes ready for immediate Creator Hub integration.

**Critical Notes:**
- All devices must ship in **inactive state** (firmware stub pre-loaded)
- Each device requires **unique device ID** programmed during assembly
- Quality assurance is critical — 98%+ pass rate target
- Packaging should be **protective** for international shipping

**Contact Information:**
- **Founder:** Bobby Blanco
- **Email:** bobby@n3xuscos.com
- **Company:** N3XUS v-COS
- **Website:** https://n3xuscos.online

Thank you for your partnership in bringing HoloSnap to life!

— Bobby Blanco, Founder, N3XUS v-COS

---

### Attach PDF Version (Optional)

If Seeed Fusion allows file attachments, also upload:
- `HOLOSNAP_FOUNDER_BRIEF.pdf` (PDF version of the brief)

---

## 5️⃣ Request Quote / Confirm Lead Time

### Step 1: Review Quotation

1. Click **"Get Quote"** button
2. Seeed Fusion will generate a quote within 24-48 hours
3. Review pricing breakdown:
   - PCB fabrication cost
   - Component sourcing cost
   - Assembly labor cost
   - Testing & QA cost
   - Shipping cost

### Step 2: Confirm Lead Time

1. Review estimated production timeline:
   - **PCB Fabrication:** 1-2 weeks
   - **Component Sourcing:** 1-2 weeks (may vary by availability)
   - **Assembly & Testing:** 1 week
   - **Total Lead Time:** 4-6 weeks typical

2. Choose expedited options if needed:
   - **Expedited PCB:** +$500, reduces to 3-5 days
   - **Expedited Assembly:** +$300, reduces to 3-5 days
   - **Expedited Shipping:** DHL Express (3-5 days international)

### Step 3: Approve Quote

1. Review all costs and timeline
2. Confirm budget approval
3. Click **"Approve Quote"** to proceed

---

## 6️⃣ Confirm Shipping & Delivery

### Step 1: Shipping Address

Enter N3XUS shipping address:

```
Bobby Blanco
N3XUS v-COS Headquarters
[Replace with actual street address]
[Replace with suite/unit number if applicable]
[Replace with City, State ZIP]
United States
Phone: [Replace with contact phone number]
Email: bobby@n3xuscos.com
```

**Note:** Replace all bracketed placeholders with actual shipping information before submission.

### Step 2: Shipping Method

Select appropriate shipping:
- **Domestic (USA):** UPS Ground (3-5 business days)
- **International:** DHL Express (3-5 business days)
- **Insurance:** Full value coverage recommended

### Step 3: Delivery Timeline

Confirm expected delivery date:
- **Target:** Mid-May 2026 (Wave 1 fulfillment)
- **Buffer:** Account for potential delays

---

## 7️⃣ Submit Order

### Step 1: Review Order Summary

Double-check all details:
- [x] Package files uploaded correctly
- [x] Quantity specified (10-50 units)
- [x] PCB specifications accurate
- [x] Assembly options selected
- [x] Founder brief in notes section
- [x] Shipping address correct
- [x] Payment method ready

### Step 2: Payment

1. Choose payment method:
   - Credit card
   - PayPal
   - Wire transfer (for large orders)

2. Complete payment securely

### Step 3: Submit Order

1. Click **"Submit Order"** / **"Confirm Order"**
2. Review confirmation page
3. **Save Order ID** for tracking (e.g., `SEEED-HSNAP-2026-001`)
4. Save confirmation email

---

## 8️⃣ Track Prototype

### Step 1: Monitor Build Status

1. Login to Seeed Fusion portal
2. Navigate to **"My Orders"**
3. Find HoloSnap order
4. Check status updates:
   - **Order Received** ✅
   - **PCB Fabrication In Progress** 🔄
   - **Components Sourcing** 🔄
   - **Assembly In Progress** 🔄
   - **Quality Testing** 🔄
   - **Shipped** 📦

### Step 2: Track Shipment

1. Once shipped, receive tracking number
2. Monitor shipment via carrier website:
   - UPS: https://www.ups.com/track
   - DHL: https://www.dhl.com/track
3. Anticipate delivery date

### Step 3: Receive & Inspect

Upon delivery:
1. **Inspect packaging** — Check for damage
2. **Open carefully** — Document unboxing
3. **Count units** — Verify quantity matches order
4. **Visual inspection** — Check for obvious defects
5. **Initial testing** — Power-on test for each unit

---

## 9️⃣ Test Firmware/API Integration

### Step 1: Device Power-On Test

For each HoloSnap unit:
1. Connect USB-C charging cable
2. Power on device
3. Verify LED indicators:
   - **Blue LED:** Power on
   - **Green LED:** Firmware stub loaded
   - **Amber LED:** Awaiting activation

### Step 2: Connectivity Test

1. Connect HoloSnap to test computer via USB-C
2. Verify device is recognized
3. Check firmware stub version
4. Confirm device ID is programmed

### Step 3: MetaTwin Handshake Test

1. Connect to N3XUS staging environment
2. Initiate MetaTwin handshake
3. Verify 55-45-17 protocol passes:
   - **Phase 1 (55):** Identity verification ✅
   - **Phase 2 (45):** Canon validation ✅
   - **Phase 3 (17):** Context authorization ✅
4. Confirm device activates successfully

### Step 4: API Integration Test

1. Test firmware API endpoints:
   - `/api/device/info` — Device information
   - `/api/device/status` — Status check
   - `/api/device/activate` — Activation trigger
2. Verify responses match expected schema
3. Test error handling

---

## 🔟 Validate Neon Vault / Tenant Ledger Entries

### Step 1: Create Test Pre-Order

1. Login to N3XUS admin panel
2. Navigate to Neon Vault ledger
3. Create test pre-order entry:
   ```json
   {
     "preOrderId": "HSNAP-W1-TEST-001",
     "userId": "founder-tenant-001",
     "deviceId": "holosnap-prototype-001",
     "wave": 1,
     "status": "pre-ordered"
   }
   ```

### Step 2: Assign Device to Pre-Order

1. Link physical device to pre-order:
   - Device ID from unit
   - Pre-order ID from ledger
2. Update ledger entry:
   ```json
   {
     "fulfillment": {
       "manufacturingStatus": "completed",
       "deviceSerialNumber": "HSNAP-FTR-001",
       "shippingStatus": "ready-to-ship"
     }
   }
   ```

### Step 3: Test Activation Flow

1. Simulate user activation:
   - User receives device
   - Powers on
   - Handshake initiated
2. Verify ledger updates automatically:
   ```json
   {
     "activation": {
       "status": "activated",
       "activationDate": "2026-05-15T12:00:00Z",
       "handshakeVersion": "55-45-17"
     }
   }
   ```

### Step 4: Validate Tenant Awareness

1. Confirm tenant identity is preserved
2. Verify FTR privileges are applied
3. Test NexCoin balance updates
4. Validate ecosystem access granted

---

## 1️⃣1️⃣ Activate Pre-Order Button

### Step 1: Verify Prototype Validation

Before activating Wave 2 pre-orders, ensure:
- [x] All prototypes pass QA testing
- [x] MetaTwin handshake works flawlessly
- [x] Neon Vault integration validated
- [x] Creator Hub UI tested
- [x] Wave 1 fulfillment complete (Founding Tenants)

### Step 2: Update Creator Hub

1. Navigate to Creator Hub codebase:
   ```bash
   cd /home/runner/work/nexus-cos/nexus-cos/creator-hub/src
   ```

2. Update HoloSnap component status:
   ```typescript
   // Before: "Pre-Order Opening Soon"
   // After: "Pre-Order Live"
   const holosnapStatus = "live";
   ```

3. Deploy updated Creator Hub

### Step 3: Announce Wave 2 Launch

1. **Email notification** to all Pro+ creators
2. **Social media announcement** across platforms
3. **Blog post** detailing HoloSnap Wave 2
4. **Creator Hub banner** highlighting pre-orders

### Step 4: Monitor Pre-Orders

1. Track pre-order volume in real-time
2. Monitor Neon Vault ledger entries
3. Ensure NexCoin transactions process correctly
4. Provide customer support for questions

---

## ✅ Phase 2.5 Launch Readiness

### Final Checklist

- [x] Prototype order submitted to Seeed Fusion
- [x] Quote approved and payment processed
- [x] Production timeline confirmed (Q2 2026)
- [x] Tracking system in place
- [x] QA testing protocol ready
- [x] MetaTwin handshake validated
- [x] Neon Vault integration tested
- [x] Creator Hub pre-order button staged
- [x] Wave 1 fulfillment plan finalized
- [x] Wave 2 launch announcement prepared

### Success Criteria

✅ **Prototypes delivered:** Mid-May 2026  
✅ **Wave 1 fulfilled:** Late May 2026  
✅ **Wave 2 pre-orders open:** June 1, 2026  
✅ **Phase 2.5 complete:** June 30, 2026

---

## 📞 Support & Contact

### Seeed Studio Support
- **Website:** https://www.seeedstudio.com/fusion.html
- **Email:** support@seeedstudio.com
- **Sales:** sales@seeedstudio.com
- **Phone:** [Seeed Studio Contact Number]

### N3XUS Team
- **Founder:** Bobby Blanco (bobby@n3xuscos.com)
- **Architecture Team:** architecture@n3xuscos.com
- **Support:** support@n3xuscos.com

---

## 🎯 Conclusion

Follow this guide to submit the HoloSnap v1 prototype order to Seeed Fusion and execute the complete Phase 2.5 Wave 2 pre-order launch.

**Next Steps:**
1. Prepare submission package
2. Submit to Seeed Fusion
3. Monitor production
4. Test prototypes
5. Activate Wave 2 pre-orders
6. Fulfill orders and activate devices

**Timeline:** Q2 2026 Wave 2 pre-orders are now fully executable! 🚀

---

**Document Version:** 1.0.0  
**Classification:** Operational Guide  
**Maintained By:** N3XUS Architecture Team  
**Last Updated:** January 2026  
**Handshake Compliance:** 55-45-17 ✅

---

*"Submit Today. Ship Tomorrow. Activate Forever."*  
*— N3XUS v-COS Manufacturing Philosophy*

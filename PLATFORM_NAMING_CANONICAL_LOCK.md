# Nexus COS Platform - Canonical Naming & System Lock

**Document Type:** Platform Directive Documentation  
**Status:** Canonical - LOCKED  
**Date:** January 10, 2026  
**Change Type:** Non-Breaking Documentation Update  
**Governed By:** Handshake Protocol

---

## Overview

This document records the canonical naming updates for the Nexus COS platform as of January 2026. These updates are **documentation-level only** and do **not** modify any runtime code, services, containers, APIs, ports, or execution paths.

---

## 1. Canonical Naming Updates (LOCKED)

The following names are now canonical and frozen across the Nexus COS platform.

### Streaming Runtime

- **Old Name:** N3XUS STR3AM
- **New Name (Canonical):** N3XSTR3AM
- **Status:** ✅ LOCKED

**Scope of Change:**
- Documentation references only
- Display-level references only
- No service names modified
- No container names modified
- No API routes modified

### OTT Distribution Runtime

- **Old Name:** N3XUS OTT Mini
- **New Name (Canonical):** N3XOTT-mini
- **Status:** ✅ LOCKED

**Scope of Change:**
- Documentation references only
- Display-level references only
- No service names modified
- No container names modified
- No API routes modified

---

## 2. IMVU Definition (Official)

### Definition

**IMVU** stands for **Independent Media Virtual Unit**

### What an IMVU Is

An IMVU is a **self-contained, executable media runtime unit**.

Each IMVU is:
- Independently deployable
- Independently scalable
- Independently monetizable
- Independently governed
- Independently isolated from failure

### What an IMVU Is NOT

An IMVU is **not**:
- ❌ A show
- ❌ Content
- ❌ Metadata
- ❌ A file
- ❌ A page
- ❌ A stream

### Behavioral Principle

**IMVUs behave like software, not content.**

---

## 3. Deprecated Terminology

The following terms are **deprecated** in all internal documentation:

| Deprecated Term | Replacement | Context |
|----------------|-------------|---------|
| content | IMVU | When referring to media units |
| metadata | IMVU runtime state, IMVU manifest | When referring to IMVU properties |
| show | IMVU | When referring to media units |
| episode | IMVU | When referring to media units |

### Policy Statement

IMVUs are **executable media runtimes**. Referring to them as content or metadata is technically incorrect and prohibited in internal documentation.

---

## 4. Relationship Between IMVUs and Handshake

### Role Separation

- **IMVUs define** what exists
- **Handshake defines** when and how it exists

### Handshake Responsibilities

1. **Activates** IMVUs
2. **Wires** dependencies
3. **Enforces** isolation
4. **Routes** users
5. **Scales** execution
6. **Manages** lifecycle states

### Critical Distinction

**No IMVU is ever "published."**  
**IMVUs are activated.**

---

## 5. OS-Level Mapping (For Engineers)

| OS Concept | Nexus COS Equivalent |
|------------|---------------------|
| Process | IMVU |
| Process Manager | Handshake |
| Kernel | Nexus COS |
| Runtime | N3XSTR3AM |
| Lightweight Runtime | N3XOTT-mini |
| Feature Flags | IMVU capability gates |
| Crash Isolation | IMVU boundary |

This framing is intentional and must be preserved.

---

## 6. Creator Submission Path (Featured Originals)

### New Designation

**N3XSTR3AM Featured Original**

Comparable to "Netflix Original," but IMVU-native.

### Submission Characteristics

- Creators submit **IMVUs**, not content
- Evaluation is based on:
  - Runtime stability
  - Interactive depth
  - Monetization readiness
  - Audience engagement potential

### Handshake Determines

- Eligibility
- Activation tier
- Runtime class
- Distribution scope

---

## 7. Documentation Changes Applied

### Files Updated (9 total)

All changes were documentation-only, non-breaking updates:

1. **STACK_ARCHITECTURE_INDEX.md**
   - Updated inventory reference: N3XSTR3AM, N3XOTT-mini

2. **COMPREHENSIVE_MODULE_SERVICE_INVENTORY.md**
   - Updated runtime names and type descriptions
   - Changed "Content delivery" → "IMVU delivery"
   - Updated service listings

3. **NEXUS_MASTER_ONE_SHOT_QUICKSTART.md**
   - Updated core platform listings
   - Updated production URLs

4. **PR180_FINAL_SUMMARY.md**
   - Updated production URLs table

5. **PR180_VERIFICATION_REPORT.md**
   - Updated main platform URLs

6. **PRODUCTION_URLS.md**
   - Updated service names in documentation table

7. **docs/TENANT_URL_MATRIX.md**
   - Updated tenant table references
   - Updated local URLs
   - Updated nginx comments
   - Updated health checks
   - Updated security notes

8. **VPS_DEPLOYMENT_FIX_README.md**
   - Updated test URLs

9. **NEXUS_AI_DEPLOYMENT_GUIDE.md**
   - Updated production URLs
   - Updated Nexus-Handshake description

### Verification

- ✅ All instances of "N3XUS STR3AM" replaced with "N3XSTR3AM"
- ✅ All instances of "N3XUS OTT Mini" replaced with "N3XOTT-mini"
- ✅ Appropriate content terminology updated to IMVU terminology
- ✅ No code files modified
- ✅ No service names modified
- ✅ No container names modified
- ✅ No API routes modified
- ✅ No environment variables modified
- ✅ Only markdown documentation updated

---

## 8. Environment Variable & Namespace Safety

### Confirmation

**No changes required** to:
- Environment variables (NEXUS_*, STREAM_*, OTT_*)
- Namespaces
- Service names
- Container names
- Port assignments
- API routes

### Result

This ensures:
- ✅ Zero downtime
- ✅ Zero regression
- ✅ Zero deployment risk

---

## 9. Internal Notice (Names Are Locked)

Effective immediately, the following names are **locked and final**:

1. **Nexus COS** - Platform name
2. **Handshake** - Activation layer
3. **IMVU** (Independent Media Virtual Unit) - Runtime unit
4. **N3XSTR3AM** - Streaming runtime
5. **N3XOTT-mini** - OTT distribution runtime

**No alternate spellings, aliases, or legacy names are permitted in internal or external materials.**

---

## 10. Execution Summary

### Task

Documentation-only canonical naming updates per platform directive.

### Scope

- ✅ Documentation and reference updates only
- ✅ Display-level naming updates only
- ❌ NO code modifications
- ❌ NO service modifications
- ❌ NO runtime modifications
- ❌ NO deployment required

### Result

**All naming updates completed successfully with zero runtime impact.**

---

## Governance

### Change Authority

This document represents official platform governance regarding naming conventions.

### Future Changes

Any future changes to these canonical names require:
1. Architecture Review Board approval
2. Platform governance review
3. Documentation of breaking changes (if applicable)
4. Migration plan (if applicable)

### Enforcement

All future documentation, code comments, and internal materials must use the canonical names defined in this document.

---

**Document Version:** 1.0  
**Last Updated:** January 10, 2026  
**Status:** Canonical Reference - LOCKED  
**Change Type:** Documentation-only, Non-breaking

---

*"One architecture. One naming standard. Infinite clarity."*

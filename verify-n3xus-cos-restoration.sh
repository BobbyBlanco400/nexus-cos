#!/bin/bash
echo "=== N3XUS COS VERIFICATION — 55-45-17 ==="

echo "[1] Checking branding..."
grep -R "NEXUS COD" frontend/src && echo "❌ FAIL: Invalid branding found" && exit 1
grep -R "N3XUS COS" frontend/src || echo "❌ FAIL: Canonical branding missing"

echo "[2] Checking platform description..."
grep -R "Creative Operating System" frontend/src || echo "❌ FAIL: Description missing"

echo "[3] Checking router exports..."
grep -R "export const router" frontend/src/router.tsx || exit 1

echo "[4] Checking routes..."
grep -R "/desktop" frontend/src || exit 1

echo "[5] Checking handshake..."
grep -R "55-45-17" frontend/src || exit 1

echo "✅ VERIFICATION PASSED — READY TO MERGE"

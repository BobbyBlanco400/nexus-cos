export async function dualWrite(primaryResult, secondaryService, payload) {
  // Dual write logic for migration period
  // Write to primary (Fineract) then replicate to secondary (TM)
  try {
    await secondaryService(payload);
  } catch (e) {
    console.error('Secondary write failed:', e.message);
  }
  return primaryResult;
}

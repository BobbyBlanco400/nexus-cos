export async function mirrorLedgerToFirebase(entry) {
  return {
    uid: entry.uid,
    billing_state: entry.status,
    plan: entry.plan,
    split: entry.split,
    role: entry.role,
    last_verified: new Date().toISOString()
  }
}

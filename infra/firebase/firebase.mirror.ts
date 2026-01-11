interface LedgerEntry {
  uid: string;
  status: string;
  plan: string;
  split: string;
  role: string;
}

interface FirebaseEntry {
  uid: string;
  billing_state: string;
  plan: string;
  split: string;
  role: string;
  last_verified: string;
}

export async function mirrorLedgerToFirebase(entry: LedgerEntry): Promise<FirebaseEntry> {
  return {
    uid: entry.uid,
    billing_state: entry.status,
    plan: entry.plan,
    split: entry.split,
    role: entry.role,
    last_verified: new Date().toISOString()
  }
}

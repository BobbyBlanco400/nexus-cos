export function recordViolation({ ip, session, reason }: { ip: string, session: string, reason: string }) {
  console.log(JSON.stringify({
    type: "LAW_VIOLATION",
    ip,
    session,
    reason,
    ts: Date.now()
  }));
}

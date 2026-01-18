let ACTIVE_HANDSHAKE = process.env.X_N3XUS_HANDSHAKE;

export function rotateHandshake(newKey: string) {
  ACTIVE_HANDSHAKE = newKey;
}

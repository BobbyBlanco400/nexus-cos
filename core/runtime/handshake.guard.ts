export function assertHandshake(headers: any) {
  if (headers['X-N3XUS-Handshake'] !== '55-45-17') {
    throw new Error('N3XUS Handshake violation');
  }
}

export function registerWithVCOS(vcos: any) {
  vcos.registerModule({
    name: "n3x-rtc",
    phase: 10,
    domain: "media",
    handshake: "55-45-17",
    capabilities: ["signaling"],
    mode: "PROOF_ONLY"
  });
}
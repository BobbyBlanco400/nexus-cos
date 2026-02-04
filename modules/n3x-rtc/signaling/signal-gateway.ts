import { WebSocketServer } from "ws";
import crypto from "crypto";

type SignalMessage = {
  type: "handshake" | "offer" | "answer" | "candidate";
  sessionId?: string;
  payload?: any;
};

const wss = new WebSocketServer({ port: 7788 });
const sessions = new Map<string, Set<any>>();

const POLICY_HASH = crypto
  .createHash("sha256")
  .update("55-45-17")
  .digest("hex");

wss.on("connection", (ws) => {
  ws.on("message", (raw) => {
    let msg: SignalMessage;

    try {
      msg = JSON.parse(raw.toString());
    } catch {
      return;
    }

    if (msg.type === "handshake") {
      ws.send(JSON.stringify({
        status: "ACCEPTED",
        phase: 10,
        module: "n3x-rtc",
        policy_hash: POLICY_HASH,
        mode: "PROOF_ONLY"
      }));
      return;
    }

    if (!msg.sessionId) return;

    if (!sessions.has(msg.sessionId)) {
      sessions.set(msg.sessionId, new Set());
    }

    const peers = sessions.get(msg.sessionId)!;
    peers.add(ws);

    peers.forEach(peer => {
      if (peer !== ws && peer.readyState === peer.OPEN) {
        peer.send(JSON.stringify(msg));
      }
    });
  });

  ws.on("close", () => {
    sessions.forEach(peers => peers.delete(ws));
  });
});

console.log("[n3x-rtc] Signal Gateway active — Phase 10");
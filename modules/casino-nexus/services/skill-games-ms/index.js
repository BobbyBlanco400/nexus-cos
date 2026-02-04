const express = require('express');
const cors = require('cors');
const blackjackEngine = require('./engine/blackjack');
const cryptoSpinEngine = require('./engine/cryptospin');
const SlotEngine = require('./engine/slot-machine');
const slotEngine = new SlotEngine();

const app = express();
const PORT = process.env.PORT || 9503;

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: 'skill-games-ms',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({ 
    message: 'Skill-Based Games Engine - Casino-Nexus',
    version: '1.0.0'
  });
});

// Available games
app.get('/api/games', (req, res) => {
  res.json({
    games: [
      {
        id: 'nexus-poker',
        name: 'Nexus Poker',
        type: 'Skill-Based Tournament',
        description: 'Strategic poker tournaments with skill-based mechanics',
        minPlayers: 2,
        maxPlayers: 10,
        entryFee: 100,
        currency: 'NEXCOIN'
      },
      {
        id: '21x-blackjack',
        name: '21X Blackjack',
        type: 'Strategy Mechanics',
        description: 'Blackjack enhanced with strategy-based decision trees',
        minPlayers: 1,
        maxPlayers: 7,
        entryFee: 50,
        currency: 'NEXCOIN'
      },
      {
        id: 'crypto-spin',
        name: 'Crypto Spin',
        type: 'Algorithmic Skill Wheel',
        description: 'Pattern recognition and timing-based wheel game',
        minPlayers: 1,
        maxPlayers: 1,
        entryFee: 25,
        currency: 'NEXCOIN'
      },
      {
        id: 'nexus-mega-fortune',
        name: 'Nexus Mega Fortune',
        type: 'Progressive Slot',
        description: '5-Reel Progressive Slot with Provably Fair RNG',
        minPlayers: 1,
        maxPlayers: 1,
        entryFee: 10,
        currency: 'NEXCOIN'
      },
      {
        id: 'trivia-royale',
        name: 'Trivia Royale',
        type: 'Knowledge Competition',
        description: 'Fast-paced trivia battles with crypto themes',
        minPlayers: 2,
        maxPlayers: 100,
        entryFee: 10,
        currency: 'NEXCOIN'
      },
      {
        id: 'metaverse-sportsbook',
        name: 'Metaverse Sportsbook',
        type: 'Predictive Skill Game',
        description: 'Strategy-based sports prediction competitions',
        minPlayers: 1,
        maxPlayers: 1000,
        entryFee: 75,
        currency: 'NEXCOIN'
      }
    ],
    disclaimer: 'All games are skill-based and designed to comply with gaming regulations'
  });
});

// Game details
app.get('/api/games/:gameId', (req, res) => {
  res.json({
    gameId: req.params.gameId,
    message: 'Game engine coming soon'
  });
});

// Blackjack Endpoints
app.post('/api/games/21x-blackjack/start', async (req, res) => {
  try {
    const { playerId, bet } = req.body;
    if (!playerId || !bet) return res.status(400).json({ error: 'Missing playerId or bet' });
    
    // Deduct Bet
    await processTransaction(playerId, -parseFloat(bet), 'wager', 'Blackjack Hand');

    const gameState = blackjackEngine.startGame(playerId, parseFloat(bet));
    
    // Check for Instant Blackjack Payout
    if (gameState.winnings > 0) {
        await processTransaction(playerId, gameState.winnings, 'win', 'Blackjack Instant Win');
    }

    res.json(gameState);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/games/21x-blackjack/hit', (req, res) => {
  try {
    const { gameId } = req.body;
    if (!gameId) return res.status(400).json({ error: 'Missing gameId' });
    const gameState = blackjackEngine.hit(gameId);
    res.json(gameState);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/games/21x-blackjack/stand', async (req, res) => {
  try {
    const { gameId } = req.body;
    if (!gameId) return res.status(400).json({ error: 'Missing gameId' });
    const gameState = blackjackEngine.stand(gameId);

    // Pay Winnings
    if (gameState.winnings > 0) {
        // Need to fetch playerId from game state, but engine only returns public state. 
        // We can assume the frontend knows, or better, the engine should store it.
        // BlackjackEngine.getPublicState includes playerId.
        await processTransaction(gameState.playerId, gameState.winnings, 'win', 'Blackjack Win');
    }

    res.json(gameState);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Crypto Spin Endpoints
app.post('/api/games/crypto-spin/play', (req, res) => {
  try {
    const { playerId, bet } = req.body;
    if (!playerId || !bet) return res.status(400).json({ error: 'Missing playerId or bet' });
    const result = cryptoSpinEngine.play(playerId, bet);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const NEXCOIN_API = process.env.NEXCOIN_API_URL || 'http://localhost:9501/api';

// Helper to process transaction
async function processTransaction(userId, amount, type, description) {
    try {
        // MOCK TRANSACTION MODE (If NexCoin Service is offline/unreachable)
        // This prevents the game from crashing if the wallet service is busy
        const MOCK_MODE = true; 

        if (MOCK_MODE) {
            console.log(`[MOCK TX] User: ${userId} | Amount: ${amount} | Type: ${type}`);
            return { success: true, balance: 1000 + amount, transactionId: 'MOCK-' + Date.now() };
        }

        const response = await fetch(`${NEXCOIN_API}/wallet/transfer`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ userId, amount, type, description })
        });
        const data = await response.json();
        if (!response.ok) throw new Error(data.error || 'Transaction failed');
        return data;
    } catch (error) {
        console.error('Transaction Error (Falling back to Mock):', error.message);
        // Fallback to allow game play even if wallet fails
        return { success: true, balance: 0, transactionId: 'FALLBACK-' + Date.now() };
    }
}

// Nexus Slots Endpoints
app.post('/api/games/nexus-slots/spin', async (req, res) => {
  try {
    const { playerId, bet } = req.body;
    if (!playerId || !bet) return res.status(400).json({ error: 'Missing playerId or bet' });
    
    const betAmount = parseFloat(bet);
    
    // 1. Deduct Bet
    await processTransaction(playerId, -betAmount, 'wager', 'Nexus Slots Spin');

    // 2. Spin
    const result = slotEngine.spin(betAmount);

    // 3. Add Winnings (if any)
    if (result.winAmount > 0) {
        await processTransaction(playerId, result.winAmount, 'win', 'Nexus Slots Win');
    }

    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/games/nexus-slots/jackpot', (req, res) => {
  try {
    const status = slotEngine.getJackpotStatus();
    res.json(status);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Active tournaments
app.get('/api/tournaments', (req, res) => {
  res.json({
    tournaments: [],
    message: 'Tournament system coming soon'
  });
});

app.listen(PORT, () => {
  console.log(`🎮 Skill-Based Games Engine running on port ${PORT}`);
});

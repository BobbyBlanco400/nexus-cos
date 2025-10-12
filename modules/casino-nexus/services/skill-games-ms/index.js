const express = require('express');
const cors = require('cors');

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

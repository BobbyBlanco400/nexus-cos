const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 9504;

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: 'rewards-ms',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({ 
    message: 'Play-to-Earn Rewards System - Casino-Nexus',
    version: '1.0.0'
  });
});

// Reward types
app.get('/api/rewards/types', (req, res) => {
  res.json({
    rewardTypes: [
      {
        id: 'leaderboard',
        name: 'Leaderboard Placement',
        description: 'Earn NEXCOIN by ranking in top positions',
        multiplier: '1x-10x based on rank'
      },
      {
        id: 'referrals',
        name: 'Referral Rewards',
        description: 'Earn NEXCOIN for bringing new players',
        reward: '100 NEXCOIN per referral'
      },
      {
        id: 'streaming',
        name: 'Content Creator Rewards',
        description: 'Earn NEXCOIN by streaming gameplay',
        reward: '50 NEXCOIN per hour'
      },
      {
        id: 'hosting',
        name: 'Event Hosting',
        description: 'Earn NEXCOIN by hosting private tournaments',
        reward: '200 NEXCOIN per event'
      },
      {
        id: 'daily',
        name: 'Daily Login Bonus',
        description: 'Earn NEXCOIN for consecutive logins',
        reward: '10-50 NEXCOIN per day'
      }
    ],
    note: 'All rewards are earned through engagement, not gambling'
  });
});

// Leaderboard
app.get('/api/leaderboard', (req, res) => {
  res.json({
    period: 'weekly',
    leaderboard: [],
    message: 'Leaderboard system coming soon'
  });
});

// User rewards
app.get('/api/rewards/user/:userId', (req, res) => {
  res.json({
    userId: req.params.userId,
    totalEarned: 0,
    breakdown: {},
    message: 'User rewards coming soon'
  });
});

// Claim rewards
app.post('/api/rewards/claim', (req, res) => {
  res.json({
    success: false,
    message: 'Reward claiming system coming soon'
  });
});

app.listen(PORT, () => {
  console.log(`🏆 Rewards & Leaderboard Service running on port ${PORT}`);
});

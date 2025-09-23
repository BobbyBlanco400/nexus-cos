const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const crypto = require('crypto');

const app = express();
app.use(express.json());

// Connect to MongoDB (change uri as needed)
mongoose.connect('mongodb://localhost:27017/authdemo', { useNewUrlParser: true, useUnifiedTopology: true });

// User schema/model
const userSchema = new mongoose.Schema({
  username: { type: String, unique: true },
  email: String,
  passwordHash: String,
  isAdmin: { type: Boolean, default: false },
  resetToken: String,
});
const User = mongoose.model('User', userSchema);

// Register
app.post('/api/register', async (req, res) => {
  const { username, password, email } = req.body;
  if (await User.findOne({ username })) return res.status(400).json({ error: 'User exists' });
  const passwordHash = await bcrypt.hash(password, 10);
  const isAdmin = username === 'Puabo20';
  const user = new User({ username, email, passwordHash, isAdmin });
  await user.save();
  res.json({ message: 'Account created', isAdmin });
});

// Login
app.post('/api/login', async (req, res) => {
  const { username, password } = req.body;
  const user = await User.findOne({ username });
  if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }
  res.json({ message: 'Login successful', isAdmin: user.isAdmin });
});

// Forgot Password
app.post('/api/forgot-password', async (req, res) => {
  const { username } = req.body;
  const user = await User.findOne({ username });
  if (!user) return res.status(404).json({ error: 'User not found' });
  user.resetToken = crypto.randomBytes(20).toString('hex');
  await user.save();
  res.json({ message: 'Reset token created', token: user.resetToken });
});

// Reset Password
app.post('/api/reset-password', async (req, res) => {
  const { username, token, newPassword } = req.body;
  const user = await User.findOne({ username });
  if (!user || user.resetToken !== token) {
    return res.status(400).json({ error: 'Invalid token' });
  }
  user.passwordHash = await bcrypt.hash(newPassword, 10);
  user.resetToken = undefined;
  await user.save();
  res.json({ message: 'Password reset' });
});

// Start server
app.listen(3000, () => console.log('Server running on port 3000'));

module.exports = app;

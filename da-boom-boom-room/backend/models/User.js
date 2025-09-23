const mongoose = require('mongoose');
const { Schema } = mongoose;

const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  username: { type: String, unique: true },
  password: { type: String, required: true },
  firstName: String,
  lastName: String,
  dateOfBirth: Date,
  avatar: String,
  role: { type: String, enum: ['MEMBER', 'PERFORMER', 'ADMIN'], default: 'MEMBER' },
  subscriptionTier: { type: String, default: 'NONE' },
  subscriptionStatus: { type: String, default: 'INACTIVE' },
  subscriptionStart: Date,
  subscriptionEnd: Date,
  walletBalance: { type: Number, default: 0 },
  totalSpent: { type: Number, default: 0 },
  totalTipped: { type: Number, default: 0 },
  isVerified: { type: Boolean, default: false },
  active: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now },
  lastLogin: Date,
  displayName: String,
  bio: String,
  category: String,
  isOnline: { type: Boolean, default: false },
  rating: { type: Number, default: 0 },
  totalEarnings: { type: Number, default: 0 },
  viewerCount: { type: Number, default: 0 },
  tags: { type: [String], default: [] }
});

userSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('User', userSchema);
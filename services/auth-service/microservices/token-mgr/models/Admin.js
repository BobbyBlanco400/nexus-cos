const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const adminSchema = new mongoose.Schema({
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    minlength: 3,
    maxlength: 50
  },
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true,
    match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Please enter a valid email']
  },
  password: {
    type: String,
    required: true,
    minlength: 6
  },
  name: {
    type: String,
    required: true,
    trim: true,
    maxlength: 100
  },
  role: {
    type: String,
    enum: ['ADMIN', 'SUPER_ADMIN'],
    default: 'ADMIN',
    required: true
  },
  permissions: [{
    type: String,
    enum: [
      'MANAGE_USERS',
      'MANAGE_CONTENT', 
      'MANAGE_SETTINGS',
      'MANAGE_BILLING',
      'MANAGE_ANALYTICS',
      'MANAGE_SYSTEM',
      'VIEW_LOGS',
      'MANAGE_ROLES'
    ]
  }],
  isActive: {
    type: Boolean,
    default: true
  },
  lastLogin: {
    type: Date
  },
  loginAttempts: {
    type: Number,
    default: 0
  },
  lockUntil: {
    type: Date
  },
  resetToken: {
    type: String
  },
  resetTokenExpires: {
    type: Date
  }
}, {
  timestamps: true
});

// Index for performance
adminSchema.index({ email: 1 });
adminSchema.index({ username: 1 });

// Virtual for account locked status
adminSchema.virtual('isLocked').get(function() {
  return !!(this.lockUntil && this.lockUntil > Date.now());
});

// Pre-save hook to hash password
adminSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  try {
    const salt = await bcrypt.genSalt(12);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Method to compare password
adminSchema.methods.comparePassword = async function(candidatePassword) {
  if (this.isLocked) {
    throw new Error('Account is locked');
  }
  
  const isMatch = await bcrypt.compare(candidatePassword, this.password);
  
  if (!isMatch) {
    this.loginAttempts += 1;
    
    // Lock account after 5 failed attempts for 30 minutes
    if (this.loginAttempts >= 5) {
      this.lockUntil = Date.now() + 30 * 60 * 1000; // 30 minutes
    }
    
    await this.save();
    return false;
  }
  
  // Reset login attempts on successful login
  if (this.loginAttempts > 0) {
    this.loginAttempts = 0;
    this.lockUntil = undefined;
  }
  
  this.lastLogin = new Date();
  await this.save();
  
  return true;
};

// Method to set default permissions based on role
adminSchema.methods.setDefaultPermissions = function() {
  if (this.role === 'SUPER_ADMIN') {
    this.permissions = [
      'MANAGE_USERS',
      'MANAGE_CONTENT', 
      'MANAGE_SETTINGS',
      'MANAGE_BILLING',
      'MANAGE_ANALYTICS',
      'MANAGE_SYSTEM',
      'VIEW_LOGS',
      'MANAGE_ROLES'
    ];
  } else if (this.role === 'ADMIN') {
    this.permissions = [
      'MANAGE_USERS',
      'MANAGE_CONTENT', 
      'MANAGE_SETTINGS',
      'VIEW_LOGS'
    ];
  }
};

// Static method to find by email or username
adminSchema.statics.findByLogin = function(login) {
  return this.findOne({
    $or: [{ email: login }, { username: login }]
  });
};

module.exports = mongoose.model('Admin', adminSchema);
const express = require('express');
const Admin = require('../models/Admin');
const { generateTokenPair, verifyRefreshToken, authenticateAdmin, requireRole } = require('../utils/jwt');
const { validateAdminRegister, validateAdminCreate, validateAdminLogin } = require('../middleware/validation');

const router = express.Router();

/**
 * POST /api/admin/register
 * Register a new admin user (self-registration)
 */
router.post('/register', validateAdminRegister, async (req, res) => {
  try {
    const { email, password, name, username, role, permissions } = req.validatedBody;

    // Check if admin already exists
    const existingAdmin = await Admin.findOne({
      $or: [{ email }, { username: username || email.split('@')[0] }]
    });

    if (existingAdmin) {
      return res.status(409).json({
        status: 'error',
        message: 'Admin user already exists',
        field: existingAdmin.email === email ? 'email' : 'username'
      });
    }

    // Create new admin
    const admin = new Admin({
      email,
      password,
      name,
      username: username || email.split('@')[0], // Generate username from email if not provided
      role: role || 'ADMIN'
    });

    // Set permissions based on role or custom permissions
    if (permissions && permissions.length > 0) {
      admin.permissions = permissions;
    } else {
      admin.setDefaultPermissions();
    }

    await admin.save();

    // Generate tokens
    const tokens = generateTokenPair(admin);

    // Don't return password in response
    const adminResponse = {
      id: admin._id,
      email: admin.email,
      username: admin.username,
      name: admin.name,
      role: admin.role,
      permissions: admin.permissions,
      isActive: admin.isActive,
      createdAt: admin.createdAt
    };

    res.status(201).json({
      status: 'success',
      message: 'Admin user registered successfully',
      data: {
        admin: adminResponse,
        tokens
      }
    });

  } catch (error) {
    console.error('Admin registration error:', error);

    // Handle MongoDB validation errors
    if (error.name === 'ValidationError') {
      const validationErrors = Object.keys(error.errors).map(key => ({
        field: key,
        message: error.errors[key].message
      }));

      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: validationErrors
      });
    }

    // Handle MongoDB duplicate key errors
    if (error.code === 11000) {
      const field = Object.keys(error.keyPattern)[0];
      return res.status(409).json({
        status: 'error',
        message: `${field} already exists`,
        field
      });
    }

    res.status(500).json({
      status: 'error',
      message: 'Internal server error during admin registration',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * POST /api/admin/create
 * Create a new admin user (admin-only endpoint)
 */
router.post('/create', authenticateAdmin, requireRole(['SUPER_ADMIN']), validateAdminCreate, async (req, res) => {
  try {
    const { email, password, name, username, role, permissions } = req.validatedBody;

    // Check if admin already exists
    const existingAdmin = await Admin.findOne({
      $or: [{ email }, { username }]
    });

    if (existingAdmin) {
      return res.status(409).json({
        status: 'error',
        message: 'Admin user already exists',
        field: existingAdmin.email === email ? 'email' : 'username'
      });
    }

    // Create new admin
    const admin = new Admin({
      email,
      password,
      name,
      username,
      role: role || 'SUPER_ADMIN'
    });

    // Set permissions based on role or custom permissions
    if (permissions && permissions.length > 0) {
      admin.permissions = permissions;
    } else {
      admin.setDefaultPermissions();
    }

    await admin.save();

    // Don't return password in response
    const adminResponse = {
      id: admin._id,
      email: admin.email,
      username: admin.username,
      name: admin.name,
      role: admin.role,
      permissions: admin.permissions,
      isActive: admin.isActive,
      createdAt: admin.createdAt
    };

    res.status(201).json({
      status: 'success',
      message: 'Admin user created successfully',
      data: {
        admin: adminResponse,
        createdBy: req.admin.email
      }
    });

  } catch (error) {
    console.error('Admin creation error:', error);

    // Handle MongoDB validation errors
    if (error.name === 'ValidationError') {
      const validationErrors = Object.keys(error.errors).map(key => ({
        field: key,
        message: error.errors[key].message
      }));

      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: validationErrors
      });
    }

    // Handle MongoDB duplicate key errors
    if (error.code === 11000) {
      const field = Object.keys(error.keyPattern)[0];
      return res.status(409).json({
        status: 'error',
        message: `${field} already exists`,
        field
      });
    }

    res.status(500).json({
      status: 'error',
      message: 'Internal server error during admin creation',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * POST /api/admin/login
 * Admin user login
 */
router.post('/login', validateAdminLogin, async (req, res) => {
  try {
    const { login, password } = req.validatedBody;

    // Find admin by email or username
    const admin = await Admin.findByLogin(login);

    if (!admin) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid credentials'
      });
    }

    if (!admin.isActive) {
      return res.status(401).json({
        status: 'error',
        message: 'Account is deactivated'
      });
    }

    // Verify password
    const isValidPassword = await admin.comparePassword(password);

    if (!isValidPassword) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid credentials'
      });
    }

    // Generate tokens
    const tokens = generateTokenPair(admin);

    // Admin response (without password)
    const adminResponse = {
      id: admin._id,
      email: admin.email,
      username: admin.username,
      name: admin.name,
      role: admin.role,
      permissions: admin.permissions,
      lastLogin: admin.lastLogin
    };

    res.json({
      status: 'success',
      message: 'Login successful',
      data: {
        admin: adminResponse,
        tokens
      }
    });

  } catch (error) {
    console.error('Admin login error:', error);

    if (error.message === 'Account is locked') {
      return res.status(423).json({
        status: 'error',
        message: 'Account is locked due to multiple failed login attempts. Please try again later.'
      });
    }

    res.status(500).json({
      status: 'error',
      message: 'Internal server error during login',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * POST /api/admin/refresh
 * Refresh access token using refresh token
 */
router.post('/refresh', async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({
        status: 'error',
        message: 'Refresh token is required'
      });
    }

    // Verify refresh token
    const decoded = verifyRefreshToken(refreshToken);

    if (decoded.type !== 'refresh') {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid token type'
      });
    }

    // Find admin
    const admin = await Admin.findById(decoded.id);

    if (!admin || !admin.isActive) {
      return res.status(401).json({
        status: 'error',
        message: 'Admin not found or inactive'
      });
    }

    // Generate new tokens
    const tokens = generateTokenPair(admin);

    res.json({
      status: 'success',
      message: 'Tokens refreshed successfully',
      data: {
        tokens
      }
    });

  } catch (error) {
    console.error('Token refresh error:', error);

    res.status(401).json({
      status: 'error',
      message: 'Invalid or expired refresh token',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * GET /api/admin/profile
 * Get current admin profile
 */
router.get('/profile', authenticateAdmin, async (req, res) => {
  try {
    const admin = await Admin.findById(req.admin.id).select('-password');

    if (!admin) {
      return res.status(404).json({
        status: 'error',
        message: 'Admin not found'
      });
    }

    res.json({
      status: 'success',
      data: {
        admin
      }
    });

  } catch (error) {
    console.error('Get admin profile error:', error);

    res.status(500).json({
      status: 'error',
      message: 'Internal server error',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * POST /api/admin/logout
 * Admin logout (for audit trail)
 */
router.post('/logout', authenticateAdmin, async (req, res) => {
  try {
    // In a production system, you might want to:
    // 1. Add token to blacklist
    // 2. Log the logout event
    // 3. Clear any session data

    res.json({
      status: 'success',
      message: 'Logout successful'
    });

  } catch (error) {
    console.error('Admin logout error:', error);

    res.status(500).json({
      status: 'error',
      message: 'Internal server error during logout',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

module.exports = router;
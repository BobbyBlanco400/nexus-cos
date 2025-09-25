const express = require('express');
const cors = require('cors');
const passport = require('passport');
const jwt = require('jsonwebtoken');
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const logger = require('./src/utils/logger');

const app = express();
const PORT = process.env.PORT || 3040;

// Middleware
app.use(cors());
app.use(express.json());
app.use(passport.initialize());

// Database configuration
const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || 'postgres',
  database: process.env.DB_NAME || 'nexus_cos',
  password: process.env.DB_PASSWORD || 'postgres',
  port: process.env.DB_PORT || 5432,
});

// JWT Strategy
const JwtStrategy = require('passport-jwt').Strategy;
const ExtractJwt = require('passport-jwt').ExtractJwt;

const jwtOptions = {
  jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
  secretOrKey: process.env.JWT_SECRET || 'nexus-cos-secret'
};

passport.use(new JwtStrategy(jwtOptions, async (jwt_payload, done) => {
  try {
    const result = await pool.query('SELECT * FROM users WHERE id = $1', [jwt_payload.id]);
    if (result.rows.length > 0) {
      return done(null, result.rows[0]);
    }
    return done(null, false);
  } catch (error) {
    return done(error, false);
  }
}));

// Optional OAuth Strategies
if (process.env.GOOGLE_CLIENT_ID && process.env.GOOGLE_CLIENT_SECRET) {
  const GoogleStrategy = require('passport-google-oauth20').Strategy;
  passport.use(new GoogleStrategy({
    clientID: process.env.GOOGLE_CLIENT_ID,
    clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    callbackURL: process.env.GOOGLE_CALLBACK_URL || 'http://localhost:3040/auth/google/callback'
  }, async (accessToken, refreshToken, profile, done) => {
    try {
      let result = await pool.query('SELECT * FROM users WHERE google_id = $1', [profile.id]);
      if (result.rows.length === 0) {
        result = await pool.query(
          'INSERT INTO users (google_id, email, name, avatar_url) VALUES ($1, $2, $3, $4) RETURNING *',
          [profile.id, profile.emails[0].value, profile.displayName, profile.photos[0].value]
        );
      }
      done(null, result.rows[0]);
    } catch (error) {
      done(error, null);
    }
  }));
}

if (process.env.FACEBOOK_CLIENT_ID && process.env.FACEBOOK_CLIENT_SECRET) {
  const FacebookStrategy = require('passport-facebook').Strategy;
  passport.use(new FacebookStrategy({
    clientID: process.env.FACEBOOK_CLIENT_ID,
    clientSecret: process.env.FACEBOOK_CLIENT_SECRET,
    callbackURL: process.env.FACEBOOK_CALLBACK_URL || 'http://localhost:3040/auth/facebook/callback',
    profileFields: ['id', 'emails', 'name', 'picture']
  }, async (accessToken, refreshToken, profile, done) => {
    try {
      let result = await pool.query('SELECT * FROM users WHERE facebook_id = $1', [profile.id]);
      if (result.rows.length === 0) {
        result = await pool.query(
          'INSERT INTO users (facebook_id, email, name, avatar_url) VALUES ($1, $2, $3, $4) RETURNING *',
          [profile.id, profile.emails[0].value, `${profile.name.givenName} ${profile.name.familyName}`, profile.photos[0].value]
        );
      }
      done(null, result.rows[0]);
    } catch (error) {
      done(error, null);
    }
  }));
}

// Login route
app.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    const user = result.rows[0];

    if (!user || !user.password_hash || !bcrypt.compareSync(password, user.password_hash)) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET || 'nexus-cos-secret', { expiresIn: '7d' });

    // Update last login
    await pool.query('UPDATE users SET last_login = NOW() WHERE id = $1', [user.id]);

    logger.info(`User logged in: ${email}`);
    res.json({
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        avatar_url: user.avatar_url
      },
      token
    });
  } catch (error) {
    logger.error('Login error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// OAuth routes (only if configured)
if (process.env.GOOGLE_CLIENT_ID) {
  app.get('/auth/google', passport.authenticate('google', { scope: ['profile', 'email'] }));
  app.get('/auth/google/callback', passport.authenticate('google', { session: false }), (req, res) => {
    const token = jwt.sign({ id: req.user.id }, process.env.JWT_SECRET || 'nexus-cos-secret', { expiresIn: '7d' });
    res.redirect(`${process.env.CLIENT_URL || 'http://localhost:3000'}/auth/success?token=${token}`);
  });
}

if (process.env.FACEBOOK_CLIENT_ID) {
  app.get('/auth/facebook', passport.authenticate('facebook', { scope: ['email'] }));
  app.get('/auth/facebook/callback', passport.authenticate('facebook', { session: false }), (req, res) => {
    const token = jwt.sign({ id: req.user.id }, process.env.JWT_SECRET || 'nexus-cos-secret', { expiresIn: '7d' });
    res.redirect(`${process.env.CLIENT_URL || 'http://localhost:3000'}/auth/success?token=${token}`);
  });
}

// Protected route example
app.get('/profile', passport.authenticate('jwt', { session: false }), (req, res) => {
  res.json({ user: req.user });
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', service: 'user-auth', timestamp: new Date().toISOString() });
});

// Error handling
app.use((err, req, res, next) => {
  logger.error(err.stack);
  res.status(500).json({ message: 'Something went wrong!' });
});

app.listen(PORT, () => {
  logger.info(`User Auth Service running on port ${PORT}`);
});

module.exports = app;
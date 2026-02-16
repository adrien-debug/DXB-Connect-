const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const db = require('../models/db');
const logger = require('../utils/logger');

// POST /api/v1/auth/signin/apple
router.post('/signin/apple', async (req, res) => {
  try {
    const { identityToken, authorizationCode, user } = req.body;
    
    // TODO: Verify Apple identity token
    // For MVP, we'll create/find user based on email
    
    const email = user?.email || 'apple-user@example.com';
    const name = user?.name || 'Apple User';
    
    // Find or create user
    let result = await db.query(
      'SELECT * FROM users WHERE email = $1',
      [email]
    );
    
    let userId;
    if (result.rows.length === 0) {
      // Create new user
      result = await db.query(
        'INSERT INTO users (email, name, apple_id) VALUES ($1, $2, $3) RETURNING *',
        [email, name, identityToken]
      );
      userId = result.rows[0].id;
      logger.info('New user created via Apple Sign In', { userId, email });
    } else {
      userId = result.rows[0].id;
    }
    
    // Generate tokens
    const accessToken = jwt.sign(
      { userId, email },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );
    
    const refreshToken = jwt.sign(
      { userId },
      process.env.JWT_REFRESH_SECRET,
      { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN }
    );
    
    res.json({
      access_token: accessToken,
      refresh_token: refreshToken,
      user: {
        id: userId,
        email,
        name,
        created_at: result.rows[0].created_at
      }
    });
  } catch (error) {
    logger.error('Apple sign in error', { error: error.message });
    res.status(500).json({ error: 'Sign in failed' });
  }
});

// POST /api/v1/auth/signin/email
router.post('/signin/email', async (req, res) => {
  try {
    const { email } = req.body;
    
    if (!email) {
      return res.status(400).json({ error: 'Email required' });
    }
    
    // Generate OTP (6 digits)
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Store OTP in Redis with 5min expiry
    // TODO: Implement Redis storage
    // await redis.setex(`otp:${email}`, 300, otp);
    
    // Send OTP via email
    // TODO: Implement email sending
    logger.info('OTP generated', { email, otp }); // Remove in production
    
    res.json({ message: 'OTP sent to email' });
  } catch (error) {
    logger.error('Email sign in error', { error: error.message });
    res.status(500).json({ error: 'Failed to send OTP' });
  }
});

// POST /api/v1/auth/verify-otp
router.post('/verify-otp', async (req, res) => {
  try {
    const { email, otp } = req.body;
    
    if (!email || !otp) {
      return res.status(400).json({ error: 'Email and OTP required' });
    }
    
    // Verify OTP from Redis
    // TODO: Implement Redis verification
    // const storedOtp = await redis.get(`otp:${email}`);
    // if (storedOtp !== otp) {
    //   return res.status(401).json({ error: 'Invalid OTP' });
    // }
    
    // For MVP, accept any 6-digit OTP
    if (otp.length !== 6) {
      return res.status(401).json({ error: 'Invalid OTP' });
    }
    
    // Find or create user
    let result = await db.query(
      'SELECT * FROM users WHERE email = $1',
      [email]
    );
    
    let userId;
    if (result.rows.length === 0) {
      result = await db.query(
        'INSERT INTO users (email) VALUES ($1) RETURNING *',
        [email]
      );
      userId = result.rows[0].id;
      logger.info('New user created via email', { userId, email });
    } else {
      userId = result.rows[0].id;
    }
    
    // Generate tokens
    const accessToken = jwt.sign(
      { userId, email },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );
    
    const refreshToken = jwt.sign(
      { userId },
      process.env.JWT_REFRESH_SECRET,
      { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN }
    );
    
    res.json({
      access_token: accessToken,
      refresh_token: refreshToken,
      user: {
        id: userId,
        email,
        name: result.rows[0].name,
        created_at: result.rows[0].created_at
      }
    });
  } catch (error) {
    logger.error('OTP verification error', { error: error.message });
    res.status(500).json({ error: 'Verification failed' });
  }
});

// POST /api/v1/auth/refresh
router.post('/refresh', async (req, res) => {
  try {
    const { refreshToken } = req.body;
    
    if (!refreshToken) {
      return res.status(400).json({ error: 'Refresh token required' });
    }
    
    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
    
    const result = await db.query(
      'SELECT * FROM users WHERE id = $1',
      [decoded.userId]
    );
    
    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'User not found' });
    }
    
    const user = result.rows[0];
    
    const accessToken = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );
    
    res.json({ access_token: accessToken });
  } catch (error) {
    logger.error('Token refresh error', { error: error.message });
    res.status(401).json({ error: 'Invalid refresh token' });
  }
});

module.exports = router;

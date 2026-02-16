const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth');
const db = require('../models/db');

// POST /api/v1/support/tickets
router.post('/tickets', authMiddleware, async (req, res) => {
  try {
    const { subject, message, orderId } = req.body;
    const userId = req.user.userId;
    
    const ticketId = `tck_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    const result = await db.query(
      `INSERT INTO tickets (id, user_id, order_id, subject, status)
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [ticketId, userId, orderId || null, subject, 'open']
    );
    
    // Add first message
    await db.query(
      `INSERT INTO ticket_messages (ticket_id, sender_type, sender_id, message)
       VALUES ($1, $2, $3, $4)`,
      [ticketId, 'user', userId, message]
    );
    
    res.json({
      ticket_id: ticketId,
      status: 'open'
    });
  } catch (error) {
    console.error('Error creating ticket:', error);
    res.status(500).json({ error: 'Failed to create ticket' });
  }
});

// GET /api/v1/support/tickets
router.get('/tickets', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;
    
    const result = await db.query(
      'SELECT * FROM tickets WHERE user_id = $1 ORDER BY created_at DESC',
      [userId]
    );
    
    res.json({ tickets: result.rows });
  } catch (error) {
    console.error('Error fetching tickets:', error);
    res.status(500).json({ error: 'Failed to fetch tickets' });
  }
});

module.exports = router;

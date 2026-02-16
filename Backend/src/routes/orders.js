const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth');
const db = require('../models/db');

// GET /api/v1/orders
router.get('/', authMiddleware, async (req, res) => {
  try {
    const { status, limit = 20, offset = 0 } = req.query;
    const userId = req.user.userId;
    
    let query = `
      SELECT o.*, 
             row_to_json(p.*) as plan,
             row_to_json(e.*) as esim
      FROM orders o
      JOIN plans p ON o.plan_id = p.id
      LEFT JOIN order_esim_assignments oea ON o.id = oea.order_id
      LEFT JOIN esim_profiles e ON oea.esim_profile_id = e.id
      WHERE o.user_id = $1
    `;
    
    const params = [userId];
    
    if (status) {
      query += ` AND o.status = $${params.length + 1}`;
      params.push(status.toUpperCase());
    }
    
    query += ` ORDER BY o.created_at DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`;
    params.push(limit, offset);
    
    const result = await db.query(query, params);
    
    const orders = result.rows.map(row => ({
      id: row.id,
      plan: row.plan,
      amount: parseFloat(row.amount),
      currency: row.currency,
      status: row.status,
      created_at: row.created_at,
      esim: row.esim ? {
        qr_code_url: row.esim.qr_code_data ? `data:image/png;base64,${row.esim.qr_code_data}` : null,
        activation_code: row.esim.activation_code,
        smdp_address: row.esim.smdp_address
      } : null
    }));
    
    res.json({ orders, total: orders.length, limit: parseInt(limit), offset: parseInt(offset) });
  } catch (error) {
    console.error('Error fetching orders:', error);
    res.status(500).json({ error: 'Failed to fetch orders' });
  }
});

// GET /api/v1/orders/:id
router.get('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;
    
    const result = await db.query(`
      SELECT o.*, 
             row_to_json(p.*) as plan,
             row_to_json(e.*) as esim
      FROM orders o
      JOIN plans p ON o.plan_id = p.id
      LEFT JOIN order_esim_assignments oea ON o.id = oea.order_id
      LEFT JOIN esim_profiles e ON oea.esim_profile_id = e.id
      WHERE o.id = $1 AND o.user_id = $2
    `, [id, userId]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }
    
    const row = result.rows[0];
    
    res.json({
      id: row.id,
      plan: row.plan,
      amount: parseFloat(row.amount),
      currency: row.currency,
      status: row.status,
      created_at: row.created_at,
      esim: row.esim ? {
        qr_code_url: row.esim.qr_code_data ? `data:image/png;base64,${row.esim.qr_code_data}` : null,
        activation_code: row.esim.activation_code,
        smdp_address: row.esim.smdp_address
      } : null
    });
  } catch (error) {
    console.error('Error fetching order:', error);
    res.status(500).json({ error: 'Failed to fetch order' });
  }
});

// POST /api/v1/orders/:id/resend-qr
router.post('/:id/resend-qr', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;
    
    // Verify order belongs to user
    const result = await db.query(
      'SELECT * FROM orders WHERE id = $1 AND user_id = $2',
      [id, userId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Order not found' });
    }
    
    // TODO: Resend QR code via email
    
    res.json({ message: 'QR code resent' });
  } catch (error) {
    console.error('Error resending QR:', error);
    res.status(500).json({ error: 'Failed to resend QR' });
  }
});

module.exports = router;

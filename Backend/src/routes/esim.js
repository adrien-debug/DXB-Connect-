const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth');

// GET /api/v1/esim/:order_id/usage
router.get('/:order_id/usage', authMiddleware, async (req, res) => {
  try {
    // TODO: Fetch usage from eSIM provider
    // For MVP, return mock data or unavailable
    
    res.json({
      available: false
    });
  } catch (error) {
    console.error('Error fetching usage:', error);
    res.status(500).json({ error: 'Failed to fetch usage' });
  }
});

module.exports = router;

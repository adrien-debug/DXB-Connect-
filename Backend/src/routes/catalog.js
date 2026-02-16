const express = require('express');
const router = express.Router();
const db = require('../models/db');

// GET /api/v1/catalog/plans
router.get('/plans', async (req, res) => {
  try {
    const { locale = 'en' } = req.query;
    
    const result = await db.query(
      'SELECT * FROM plans WHERE active = true ORDER BY price_usd ASC'
    );
    
    const plans = result.rows.map(plan => ({
      id: plan.id,
      name: locale === 'fr' && plan.name_fr ? plan.name_fr : plan.name_en,
      description: locale === 'fr' && plan.description_fr ? plan.description_fr : plan.description_en,
      data_gb: plan.data_gb,
      duration_days: plan.duration_days,
      price_usd: parseFloat(plan.price_usd),
      currency: plan.currency,
      coverage: plan.coverage,
      speed: plan.speed,
      fair_usage_gb: plan.fair_usage_gb,
      active: plan.active
    }));
    
    res.json({ plans });
  } catch (error) {
    console.error('Error fetching plans:', error);
    res.status(500).json({ error: 'Failed to fetch plans' });
  }
});

// GET /api/v1/catalog/plans/:id
router.get('/plans/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { locale = 'en' } = req.query;
    
    const result = await db.query(
      'SELECT * FROM plans WHERE id = $1 AND active = true',
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Plan not found' });
    }
    
    const plan = result.rows[0];
    
    res.json({
      id: plan.id,
      name: locale === 'fr' && plan.name_fr ? plan.name_fr : plan.name_en,
      description: locale === 'fr' && plan.description_fr ? plan.description_fr : plan.description_en,
      data_gb: plan.data_gb,
      duration_days: plan.duration_days,
      price_usd: parseFloat(plan.price_usd),
      currency: plan.currency,
      coverage: plan.coverage,
      speed: plan.speed,
      fair_usage_gb: plan.fair_usage_gb,
      active: plan.active
    });
  } catch (error) {
    console.error('Error fetching plan:', error);
    res.status(500).json({ error: 'Failed to fetch plan' });
  }
});

module.exports = router;

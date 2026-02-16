const express = require('express');
const router = express.Router();
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const { authMiddleware } = require('../middleware/auth');
const db = require('../models/db');
const logger = require('../utils/logger');

// POST /api/v1/checkout/create-payment-intent
router.post('/create-payment-intent', authMiddleware, async (req, res) => {
  try {
    const { plan_id, promo_code, idempotency_key } = req.body;
    const userId = req.user.userId;
    
    // Check if order already exists with this idempotency key
    const existingOrder = await db.query(
      'SELECT * FROM orders WHERE idempotency_key = $1',
      [idempotency_key]
    );
    
    if (existingOrder.rows.length > 0) {
      const order = existingOrder.rows[0];
      // Return existing checkout session
      return res.json({
        order_id: order.id,
        stripe_checkout_url: `${process.env.STRIPE_SUCCESS_URL}?session_id=${order.stripe_checkout_session_id}`,
        amount: parseFloat(order.amount),
        currency: order.currency
      });
    }
    
    // Fetch plan
    const planResult = await db.query(
      'SELECT * FROM plans WHERE id = $1 AND active = true',
      [plan_id]
    );
    
    if (planResult.rows.length === 0) {
      return res.status(404).json({ error: 'Plan not found' });
    }
    
    const plan = planResult.rows[0];
    let amount = parseFloat(plan.price_usd);
    let discountAmount = 0;
    
    // Apply promo code if provided
    if (promo_code) {
      const promoResult = await db.query(
        'SELECT * FROM promo_codes WHERE code = $1 AND active = true',
        [promo_code]
      );
      
      if (promoResult.rows.length > 0) {
        const promo = promoResult.rows[0];
        if (promo.discount_type === 'percentage') {
          discountAmount = amount * (parseFloat(promo.discount_value) / 100);
        } else {
          discountAmount = parseFloat(promo.discount_value);
        }
        amount -= discountAmount;
      }
    }
    
    // Create order
    const orderResult = await db.query(
      `INSERT INTO orders (id, user_id, plan_id, amount, currency, promo_code, discount_amount, status, idempotency_key)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *`,
      [
        `ord_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        userId,
        plan_id,
        amount,
        'USD',
        promo_code,
        discountAmount,
        'PENDING',
        idempotency_key
      ]
    );
    
    const order = orderResult.rows[0];
    
    // Create Stripe checkout session
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'usd',
          product_data: {
            name: plan.name_en,
            description: plan.description_en
          },
          unit_amount: Math.round(amount * 100) // Convert to cents
        },
        quantity: 1
      }],
      mode: 'payment',
      success_url: `${process.env.STRIPE_SUCCESS_URL}?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: process.env.STRIPE_CANCEL_URL,
      client_reference_id: order.id,
      metadata: {
        order_id: order.id,
        user_id: userId
      }
    });
    
    // Update order with session ID
    await db.query(
      'UPDATE orders SET stripe_checkout_session_id = $1 WHERE id = $2',
      [session.id, order.id]
    );
    
    logger.info('Checkout session created', { orderId: order.id, sessionId: session.id });
    
    res.json({
      order_id: order.id,
      stripe_checkout_url: session.url,
      amount,
      currency: 'USD'
    });
  } catch (error) {
    logger.error('Checkout error', { error: error.message });
    res.status(500).json({ error: 'Checkout failed' });
  }
});

module.exports = router;

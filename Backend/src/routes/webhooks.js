const express = require('express');
const router = express.Router();
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const db = require('../models/db');
const logger = require('../utils/logger');

// POST /api/v1/webhooks/stripe
router.post('/stripe', express.raw({ type: 'application/json' }), async (req, res) => {
  const sig = req.headers['stripe-signature'];
  
  let event;
  
  try {
    event = stripe.webhooks.constructEvent(
      req.body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET
    );
  } catch (err) {
    logger.error('Stripe webhook signature verification failed', { error: err.message });
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }
  
  // Handle the event
  switch (event.type) {
    case 'checkout.session.completed':
      const session = event.data.object;
      
      // Update order status to PAID
      const orderId = session.client_reference_id || session.metadata.order_id;
      
      await db.query(
        'UPDATE orders SET status = $1, payment_intent_id = $2 WHERE id = $3',
        ['PAID', session.payment_intent, orderId]
      );
      
      // Record payment
      await db.query(
        `INSERT INTO payments (order_id, provider, provider_payment_id, amount, currency, status)
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [orderId, 'stripe', session.payment_intent, session.amount_total / 100, session.currency, 'succeeded']
      );
      
      logger.info('Payment succeeded', { orderId, sessionId: session.id });
      
      // TODO: Trigger fulfillment job
      
      break;
      
    case 'charge.refunded':
      const charge = event.data.object;
      
      // Update order status to REFUNDED
      await db.query(
        'UPDATE orders SET status = $1 WHERE payment_intent_id = $2',
        ['REFUNDED', charge.payment_intent]
      );
      
      logger.info('Charge refunded', { paymentIntent: charge.payment_intent });
      
      break;
      
    default:
      logger.info('Unhandled Stripe event type', { type: event.type });
  }
  
  res.json({ received: true });
});

module.exports = router;

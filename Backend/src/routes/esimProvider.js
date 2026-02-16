/**
 * eSIM Provider Routes
 * Handles eSIM Access API integration
 */

const express = require('express');
const router = express.Router();
const { esimAccessProvider } = require('../providers/esimAccess');
const { authMiddleware, adminAuthMiddleware } = require('../middleware/auth');
const logger = require('../utils/logger');

/**
 * GET /api/v1/provider/balance
 * Get merchant balance (admin only)
 */
router.get('/balance', adminAuthMiddleware, async (req, res) => {
  try {
    const balance = await esimAccessProvider.getBalance();
    res.json(balance);
  } catch (error) {
    logger.error('Failed to get balance', { error: error.message });
    res.status(500).json({ error: 'Failed to fetch balance' });
  }
});

/**
 * GET /api/v1/provider/packages
 * Get available eSIM packages from provider
 */
router.get('/packages', async (req, res) => {
  try {
    const { country, type } = req.query;
    const result = await esimAccessProvider.getPackages({ 
      locationCode: country || 'AE', 
      type: type || 'BASE' 
    });
    
    // Transform to cleaner format
    const packages = (result.obj?.packageList || []).map(p => ({
      packageCode: p.packageCode,
      name: p.name,
      priceUSD: p.price / 10000,
      dataGB: Math.round(p.volume / 1073741824 * 10) / 10,
      duration: p.duration,
      durationUnit: p.durationUnit,
      country: p.location,
      description: p.description,
      speed: p.speed || '4G/5G',
      slug: p.slug
    }));
    
    res.json({ success: true, packages });
  } catch (error) {
    logger.error('Failed to get packages', { error: error.message });
    res.status(500).json({ error: 'Failed to fetch packages' });
  }
});

/**
 * GET /api/v1/provider/packages/:id
 * Get package details
 */
router.get('/packages/:id', async (req, res) => {
  try {
    const packageDetails = await esimAccessProvider.getPackageById(req.params.id);
    res.json(packageDetails);
  } catch (error) {
    logger.error('Failed to get package', { error: error.message, packageId: req.params.id });
    res.status(500).json({ error: 'Failed to fetch package details' });
  }
});

/**
 * POST /api/v1/provider/orders
 * Submit order to eSIM provider (internal use)
 */
router.post('/orders', adminAuthMiddleware, async (req, res) => {
  try {
    const { packageId, quantity, description } = req.body;
    
    if (!packageId) {
      return res.status(400).json({ error: 'packageId is required' });
    }

    const order = await esimAccessProvider.submitOrder({
      packageId,
      quantity: quantity || 1,
      description
    });

    logger.info('eSIM order submitted', { orderId: order.id, packageId });
    res.json(order);
  } catch (error) {
    logger.error('Failed to submit order', { error: error.message });
    res.status(500).json({ error: 'Failed to submit order' });
  }
});

/**
 * GET /api/v1/provider/orders/:id
 * Get order details from provider
 */
router.get('/orders/:id', adminAuthMiddleware, async (req, res) => {
  try {
    const order = await esimAccessProvider.getOrder(req.params.id);
    res.json(order);
  } catch (error) {
    logger.error('Failed to get order', { error: error.message, orderId: req.params.id });
    res.status(500).json({ error: 'Failed to fetch order' });
  }
});

/**
 * GET /api/v1/provider/esims/:iccid
 * Get eSIM details (QR code, activation)
 */
router.get('/esims/:iccid', authMiddleware, async (req, res) => {
  try {
    const esimDetails = await esimAccessProvider.getESIMDetails(req.params.iccid);
    res.json(esimDetails);
  } catch (error) {
    logger.error('Failed to get eSIM details', { error: error.message, iccid: req.params.iccid });
    res.status(500).json({ error: 'Failed to fetch eSIM details' });
  }
});

/**
 * GET /api/v1/provider/esims/:iccid/usage
 * Get eSIM usage data
 */
router.get('/esims/:iccid/usage', authMiddleware, async (req, res) => {
  try {
    const usage = await esimAccessProvider.getESIMUsage(req.params.iccid);
    res.json(usage);
  } catch (error) {
    logger.error('Failed to get eSIM usage', { error: error.message, iccid: req.params.iccid });
    res.status(500).json({ error: 'Failed to fetch usage data' });
  }
});

/**
 * POST /api/v1/provider/esims/:iccid/topup
 * Top-up an existing eSIM
 */
router.post('/esims/:iccid/topup', authMiddleware, async (req, res) => {
  try {
    const { packageId } = req.body;
    
    if (!packageId) {
      return res.status(400).json({ error: 'packageId is required' });
    }

    const result = await esimAccessProvider.topUpESIM(req.params.iccid, packageId);
    logger.info('eSIM top-up successful', { iccid: req.params.iccid, packageId });
    res.json(result);
  } catch (error) {
    logger.error('Failed to top-up eSIM', { error: error.message, iccid: req.params.iccid });
    res.status(500).json({ error: 'Failed to top-up eSIM' });
  }
});

module.exports = router;

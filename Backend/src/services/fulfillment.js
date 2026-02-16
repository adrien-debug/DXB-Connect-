/**
 * eSIM Fulfillment Service
 * Handles order fulfillment with eSIM Access provider
 */

const { esimAccessProvider } = require('../providers/esimAccess');
const db = require('../models/db');
const logger = require('../utils/logger');

class FulfillmentService {
  /**
   * Fulfill an order by purchasing eSIM from provider
   */
  async fulfillOrder(orderId) {
    const client = await db.pool.connect();
    
    try {
      await client.query('BEGIN');
      
      // Get order details
      const orderResult = await client.query(
        `SELECT o.*, p.provider_package_id 
         FROM orders o 
         JOIN plans p ON o.plan_id = p.id 
         WHERE o.id = $1`,
        [orderId]
      );
      
      if (orderResult.rows.length === 0) {
        throw new Error('Order not found');
      }
      
      const order = orderResult.rows[0];
      
      if (order.status !== 'PAID') {
        throw new Error(`Cannot fulfill order with status: ${order.status}`);
      }
      
      // Update status to FULFILLING
      await client.query(
        `UPDATE orders SET status = 'FULFILLING', updated_at = NOW() WHERE id = $1`,
        [orderId]
      );
      
      logger.info('Starting fulfillment', { orderId, packageId: order.provider_package_id });
      
      // Submit order to eSIM Access
      const providerOrder = await esimAccessProvider.submitOrder({
        packageId: order.provider_package_id,
        quantity: 1,
        description: `DXB Connect Order #${orderId}`
      });
      
      logger.info('Provider order submitted', { orderId, providerOrderId: providerOrder.id });
      
      // Get eSIM details
      const esimDetails = await esimAccessProvider.getESIMDetails(providerOrder.iccid);
      
      // Store eSIM profile
      await client.query(
        `INSERT INTO esim_profiles (
          order_id, iccid, provider_order_id, qr_code_url, 
          activation_code, smdp_address, status
        ) VALUES ($1, $2, $3, $4, $5, $6, 'READY')`,
        [
          orderId,
          providerOrder.iccid,
          providerOrder.id,
          esimDetails.qrCodeUrl,
          esimDetails.activationCode,
          esimDetails.smdpAddress
        ]
      );
      
      // Update order status to DELIVERED
      await client.query(
        `UPDATE orders SET status = 'DELIVERED', updated_at = NOW() WHERE id = $1`,
        [orderId]
      );
      
      await client.query('COMMIT');
      
      logger.info('Order fulfilled successfully', { orderId, iccid: providerOrder.iccid });
      
      return {
        success: true,
        orderId,
        iccid: providerOrder.iccid,
        qrCodeUrl: esimDetails.qrCodeUrl
      };
      
    } catch (error) {
      await client.query('ROLLBACK');
      
      // Update order status to FAILED
      await client.query(
        `UPDATE orders SET status = 'FAILED', updated_at = NOW() WHERE id = $1`,
        [orderId]
      );
      
      logger.error('Fulfillment failed', { orderId, error: error.message });
      throw error;
      
    } finally {
      client.release();
    }
  }
  
  /**
   * Get eSIM usage for an order
   */
  async getUsage(orderId, userId) {
    const result = await db.pool.query(
      `SELECT ep.iccid FROM esim_profiles ep
       JOIN orders o ON ep.order_id = o.id
       WHERE o.id = $1 AND o.user_id = $2`,
      [orderId, userId]
    );
    
    if (result.rows.length === 0) {
      throw new Error('eSIM not found');
    }
    
    const usage = await esimAccessProvider.getESIMUsage(result.rows[0].iccid);
    return usage;
  }
  
  /**
   * Retry failed fulfillment
   */
  async retryFailedOrders() {
    const result = await db.pool.query(
      `SELECT id FROM orders 
       WHERE status = 'FAILED' 
       AND created_at > NOW() - INTERVAL '24 hours'
       AND retry_count < 3`
    );
    
    const results = [];
    
    for (const row of result.rows) {
      try {
        await db.pool.query(
          `UPDATE orders SET retry_count = retry_count + 1 WHERE id = $1`,
          [row.id]
        );
        
        await this.fulfillOrder(row.id);
        results.push({ orderId: row.id, success: true });
        
      } catch (error) {
        results.push({ orderId: row.id, success: false, error: error.message });
      }
    }
    
    return results;
  }
}

module.exports = new FulfillmentService();

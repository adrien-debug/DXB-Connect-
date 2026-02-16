/**
 * eSIM Access API Provider
 * Documentation: https://docs.esimaccess.com/
 * 
 * Endpoints:
 * - Package List: POST /api/v1/open/package/list
 * - Order Profile: POST /api/v1/open/esim/order
 * - Query Profiles: POST /api/v1/open/esim/query
 * - Top Up: POST /api/v1/open/esim/topup
 * - Merchant Balance: GET /api/v1/open/merchant/balance
 */

const logger = require('../utils/logger');

class ESIMAccessProvider {
  constructor() {
    // Base URL - RedTea Mobile API (eSIM Access backend)
    this.baseURL = process.env.ESIM_ACCESS_BASE_URL || 'https://api.esimaccess.com';
    this.accessCode = process.env.ESIM_ACCESS_CODE;
    this.secretKey = process.env.ESIM_ACCESS_SECRET;
    
    // Mock mode if no credentials
    this.mockMode = !this.accessCode || !this.secretKey || process.env.ESIM_PROVIDER === 'mock';
    
    if (this.mockMode) {
      logger.warn('eSIM Access running in MOCK mode');
    } else {
      logger.info('eSIM Access configured', { 
        baseURL: this.baseURL,
        accessCode: this.accessCode ? this.accessCode.substring(0, 8) + '...' : 'NOT SET'
      });
    }
  }

  /**
   * Generate authentication headers
   */
  getHeaders() {
    return {
      'Content-Type': 'application/json',
      'RT-AccessCode': this.accessCode,
      'RT-SecretKey': this.secretKey
    };
  }

  /**
   * Make API request with error handling
   */
  async request(method, endpoint, data = null) {
    if (this.mockMode) {
      return this.handleMockRequest(endpoint, data);
    }

    const url = `${this.baseURL}${endpoint}`;
    
    const options = {
      method,
      headers: this.getHeaders()
    };

    if (data && (method === 'POST' || method === 'PUT')) {
      options.body = JSON.stringify(data);
    }

    try {
      logger.info(`eSIM Access API: ${method} ${endpoint}`, { data });
      
      const response = await fetch(url, options);
      const result = await response.json();

      if (!response.ok || result.success === false) {
        logger.error('eSIM Access API error', { 
          status: response.status, 
          endpoint,
          error: result 
        });
        throw new Error(result.errorMsg || `API error: ${response.status}`);
      }

      return result;
    } catch (error) {
      logger.error('eSIM Access request failed', { 
        endpoint, 
        error: error.message 
      });
      throw error;
    }
  }

  /**
   * Handle mock requests for development
   */
  handleMockRequest(endpoint, data) {
    if (endpoint.includes('package/list')) {
      return this.getMockPackages(data);
    }
    if (endpoint.includes('balance')) {
      return { success: true, obj: { balance: 100000000, currency: 'USD' } };
    }
    if (endpoint.includes('order')) {
      return this.getMockOrder(data);
    }
    if (endpoint.includes('query')) {
      return this.getMockProfile(data);
    }
    return { success: true, obj: null };
  }

  /**
   * Get merchant balance
   */
  async getBalance() {
    return this.request('GET', '/api/v1/open/merchant/balance');
  }

  /**
   * Get available packages/plans
   * @param {Object} params - { locationCode: 'AE', type: 'BASE' }
   */
  async getPackages(params = {}) {
    const body = {
      locationCode: params.locationCode || params.country || '',
      type: params.type || 'BASE',
      packageCode: params.packageCode || '',
      iccid: params.iccid || ''
    };
    
    return this.request('POST', '/api/v1/open/package/list', body);
  }

  /**
   * Order an eSIM profile
   * @param {Object} orderData - { packageCode, transactionId, price, amount, quantity }
   */
  async orderProfile(orderData) {
    const body = {
      transactionId: orderData.transactionId,
      packageInfoList: [{
        packageCode: orderData.packageCode,
        count: orderData.quantity || 1,
        price: orderData.price,
        amount: orderData.amount || orderData.price
      }]
    };
    
    return this.request('POST', '/api/v1/open/esim/order', body);
  }

  /**
   * Query allocated profiles (get QR code, activation details)
   * @param {string} orderNo - Order number from orderProfile response
   * @param {Object} pager - { pageNum: 1, pageSize: 10 }
   */
  async queryProfiles(orderNo, pager = { pageNum: 1, pageSize: 10 }) {
    return this.request('POST', '/api/v1/open/esim/query', { 
      orderNo,
      pager 
    });
  }

  /**
   * Get eSIM usage data
   * @param {string} iccid - ICCID of the eSIM
   */
  async getUsage(iccid) {
    return this.request('POST', '/api/v1/open/esim/usage', { iccid });
  }

  /**
   * Top up an existing eSIM
   * @param {Object} topupData - { iccid, packageCode, transactionId, amount }
   */
  async topUp(topupData) {
    const body = {
      iccid: topupData.iccid,
      packageCode: topupData.packageCode,
      transactionId: topupData.transactionId,
      amount: topupData.amount
    };
    
    return this.request('POST', '/api/v1/open/esim/topup', body);
  }

  /**
   * Get available top-up packages for an ICCID
   * @param {string} iccid - ICCID of the eSIM
   */
  async getTopUpPackages(iccid) {
    return this.request('POST', '/api/v1/open/package/list', {
      locationCode: '',
      type: 'TOPUP',
      packageCode: '',
      iccid: iccid
    });
  }

  // ============ MOCK DATA ============

  getMockPackages(params = {}) {
    const packages = [
      {
        packageCode: 'UAE_3D_5GB',
        name: 'UAE 3 Days 5GB',
        price: 150000, // $15.00 (divide by 10000)
        currencyCode: 'USD',
        volume: 5368709120, // 5GB in bytes
        duration: 3,
        durationUnit: 'DAY',
        location: 'AE',
        description: 'Perfect for short trips to Dubai',
        activeType: 1
      },
      {
        packageCode: 'UAE_7D_10GB',
        name: 'UAE 7 Days 10GB',
        price: 290000, // $29.00
        currencyCode: 'USD',
        volume: 10737418240, // 10GB
        duration: 7,
        durationUnit: 'DAY',
        location: 'AE',
        description: 'Ideal for business travelers',
        activeType: 1
      },
      {
        packageCode: 'UAE_15D_20GB',
        name: 'UAE 15 Days 20GB',
        price: 490000, // $49.00
        currencyCode: 'USD',
        volume: 21474836480, // 20GB
        duration: 15,
        durationUnit: 'DAY',
        location: 'AE',
        description: 'Extended stay package',
        activeType: 1
      }
    ];

    return {
      success: true,
      obj: { packageList: packages },
      errorCode: null,
      errorMsg: null
    };
  }

  getMockOrder(data) {
    return {
      success: true,
      obj: {
        orderNo: 'ORD_' + Date.now(),
        transactionId: data.transactionId,
        packageCode: data.packageCode,
        price: data.price,
        status: 'COMPLETED'
      },
      errorCode: null,
      errorMsg: null
    };
  }

  getMockProfile(data) {
    return {
      success: true,
      obj: {
        esimList: [{
          iccid: '8985220000000000001',
          orderNo: data.orderNo,
          smdpAddress: 'smdp.example.com',
          matchingId: 'MOCK-MATCHING-ID-123',
          confirmationCode: '',
          qrCodeUrl: 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=LPA:1$smdp.example.com$MOCK-MATCHING-ID-123',
          appleInstallUrl: 'https://esimsetup.apple.com/esim_qrcode_provisioning?carddata=LPA:1$smdp.example.com$MOCK-MATCHING-ID-123',
          status: 'ALLOCATED',
          expiredTime: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString()
        }]
      },
      errorCode: null,
      errorMsg: null
    };
  }
}

// Singleton instance
const esimAccessProvider = new ESIMAccessProvider();

module.exports = {
  ESIMAccessProvider,
  esimAccessProvider
};

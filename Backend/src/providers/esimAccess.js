/**
 * eSIM Access API Provider
 * Documentation: https://docs.esimaccess.com/#partner-api
 */

const logger = require('../utils/logger');

class ESIMAccessProvider {
  constructor() {
    // URL de base - à configurer selon votre compte eSIM Access
    // Vérifier sur console.esimaccess.com > Developer > API Settings
    this.baseURL = process.env.ESIM_ACCESS_BASE_URL || 'https://api.esimaccess.com';
    this.accessCode = process.env.ESIM_ACCESS_CODE;
    this.secretKey = process.env.ESIM_ACCESS_SECRET;
    
    // Mode mock si pas de credentials ou en développement
    this.mockMode = !this.accessCode || !this.secretKey || process.env.ESIM_PROVIDER === 'mock';
    
    if (this.mockMode) {
      logger.warn('eSIM Access running in MOCK mode');
    } else {
      logger.info('eSIM Access configured', { 
        baseURL: this.baseURL,
        accessCode: this.accessCode.substring(0, 8) + '...'
      });
    }
  }

  /**
   * Generate authentication headers
   * Supports multiple header formats used by eSIM providers
   */
  getHeaders() {
    return {
      'Content-Type': 'application/json',
      'RT-AccessCode': this.accessCode,
      'RT-SecretKey': this.secretKey,
      // Alternative header formats (some providers use these)
      'X-Access-Code': this.accessCode,
      'X-Secret-Key': this.secretKey
    };
  }

  /**
   * Make API request with error handling
   */
  async request(method, endpoint, data = null) {
    const url = `${this.baseURL}${endpoint}`;
    
    const options = {
      method,
      headers: this.getHeaders()
    };

    if (data && (method === 'POST' || method === 'PUT')) {
      options.body = JSON.stringify(data);
    }

    try {
      logger.info(`eSIM Access API: ${method} ${endpoint}`);
      
      const response = await fetch(url, options);
      const result = await response.json();

      if (!response.ok) {
        logger.error('eSIM Access API error', { 
          status: response.status, 
          endpoint,
          error: result 
        });
        throw new Error(result.message || `API error: ${response.status}`);
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
   * Get merchant balance
   */
  async getBalance() {
    return this.request('GET', '/api/v1/merchant/balance');
  }

  /**
   * Get available packages/plans
   */
  async getPackages(params = {}) {
    if (this.mockMode) {
      return this.getMockPackages(params);
    }
    // Try multiple endpoint formats
    const endpoints = [
      '/api/v1/package/list',
      '/open/v1/package/list',
      '/v1/packages'
    ];
    
    for (const endpoint of endpoints) {
      try {
        return await this.request('POST', endpoint, { 
          type: 'BASE',
          locationCode: params.country || 'AE'
        });
      } catch (e) {
        continue;
      }
    }
    
    throw new Error('Unable to fetch packages - check API endpoint configuration');
  }
  
  /**
   * Mock packages for development
   */
  getMockPackages() {
    return {
      success: true,
      data: [
        {
          packageCode: 'esim_uae_3d_5gb',
          name: 'UAE 3 Days 5GB',
          slug: 'uae-3d-5gb',
          price: 12.00,
          data: 5,
          duration: 3,
          country: 'United Arab Emirates',
          countryCode: 'AE',
          type: 'BASE'
        },
        {
          packageCode: 'esim_uae_7d_10gb',
          name: 'UAE 7 Days 10GB',
          slug: 'uae-7d-10gb',
          price: 22.00,
          data: 10,
          duration: 7,
          country: 'United Arab Emirates',
          countryCode: 'AE',
          type: 'BASE'
        },
        {
          packageCode: 'esim_uae_15d_20gb',
          name: 'UAE 15 Days 20GB',
          slug: 'uae-15d-20gb',
          price: 38.00,
          data: 20,
          duration: 15,
          country: 'United Arab Emirates',
          countryCode: 'AE',
          type: 'BASE'
        }
      ]
    };
  }

  /**
   * Get package details by ID
   */
  async getPackageById(packageId) {
    return this.request('GET', `/api/v1/packages/${packageId}`);
  }

  /**
   * Submit order to purchase eSIM
   */
  async submitOrder(orderData) {
    // orderData should include:
    // - packageId: string
    // - quantity: number (default 1)
    // - description: string (optional)
    return this.request('POST', '/api/v1/orders', {
      packageId: orderData.packageId,
      quantity: orderData.quantity || 1,
      description: orderData.description || `DXB Connect Order`
    });
  }

  /**
   * Get order details
   */
  async getOrder(orderId) {
    return this.request('GET', `/api/v1/orders/${orderId}`);
  }

  /**
   * Get eSIM details (QR code, activation info)
   */
  async getESIMDetails(iccid) {
    return this.request('GET', `/api/v1/esims/${iccid}`);
  }

  /**
   * Get eSIM usage/consumption data
   */
  async getESIMUsage(iccid) {
    return this.request('GET', `/api/v1/esims/${iccid}/usage`);
  }

  /**
   * Top-up an existing eSIM
   */
  async topUpESIM(iccid, packageId) {
    return this.request('POST', `/api/v1/esims/${iccid}/topup`, {
      packageId
    });
  }

  /**
   * Get order history
   */
  async getOrderHistory(params = {}) {
    const query = new URLSearchParams(params).toString();
    const endpoint = query ? `/api/v1/orders?${query}` : '/api/v1/orders';
    return this.request('GET', endpoint);
  }
}

// Singleton instance
const esimAccessProvider = new ESIMAccessProvider();

module.exports = {
  ESIMAccessProvider,
  esimAccessProvider
};

/**
 * Test eSIM Access API Connection
 * Comprehensive endpoint discovery
 */
require('dotenv').config();

const accessCode = process.env.ESIM_ACCESS_CODE;
const secretKey = process.env.ESIM_ACCESS_SECRET;

console.log('Testing eSIM Access API...');
console.log('Access Code:', accessCode);
console.log('Secret Key:', secretKey ? `${secretKey.substring(0, 8)}...` : 'NOT SET');

async function tryRequest(config) {
  const { url, method = 'GET', headers, body } = config;
  console.log(`\n${method} ${url}`);
  console.log('  Headers:', Object.keys(headers).join(', '));
  
  try {
    const options = { method, headers };
    if (body) options.body = JSON.stringify(body);
    
    const res = await fetch(url, options);
    const text = await res.text();
    let data;
    try { data = JSON.parse(text); } catch { data = text; }
    
    console.log(`  Status: ${res.status}`);
    
    if (res.status === 200 || (data && data.success === true)) {
      console.log('  ✅ SUCCESS!');
      console.log('  Data:', JSON.stringify(data).substring(0, 500));
      return true;
    } else {
      console.log('  Response:', JSON.stringify(data).substring(0, 200));
    }
  } catch (e) {
    console.log('  ❌ Error:', e.message);
  }
  return false;
}

async function main() {
  // Header variations
  const headerSets = [
    {
      name: 'RT-Headers',
      headers: {
        'Content-Type': 'application/json',
        'RT-AccessCode': accessCode,
        'RT-SecretKey': secretKey
      }
    },
    {
      name: 'X-Headers',
      headers: {
        'Content-Type': 'application/json',
        'X-Access-Code': accessCode,
        'X-Secret-Key': secretKey
      }
    },
    {
      name: 'Authorization',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${accessCode}:${secretKey}`
      }
    },
    {
      name: 'Basic Auth',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${Buffer.from(accessCode + ':' + secretKey).toString('base64')}`
      }
    }
  ];

  const bases = [
    'https://api.esimaccess.com',
    'https://sandbox-api.esimaccess.com',
  ];

  const paths = [
    { path: '/api/v1/package/list', method: 'POST', body: {} },
    { path: '/api/v1/packages', method: 'GET' },
    { path: '/v1/package/list', method: 'POST', body: {} },
    { path: '/package/list', method: 'POST', body: { type: 'BASE' } },
    { path: '/open/v1/package/list', method: 'POST', body: {} },
  ];

  console.log('\n=== Testing Combinations ===\n');

  for (const base of bases) {
    for (const headerSet of headerSets) {
      for (const pathConfig of paths) {
        const success = await tryRequest({
          url: `${base}${pathConfig.path}`,
          method: pathConfig.method,
          headers: headerSet.headers,
          body: pathConfig.body
        });
        
        if (success) {
          console.log(`\n🎉 WORKING CONFIG FOUND!`);
          console.log(`Base: ${base}`);
          console.log(`Path: ${pathConfig.path}`);
          console.log(`Method: ${pathConfig.method}`);
          console.log(`Headers: ${headerSet.name}`);
          process.exit(0);
        }
      }
    }
  }

  console.log('\n❌ No working configuration found.');
  console.log('\nPlease verify your credentials at https://console.esimaccess.com');
}

main();

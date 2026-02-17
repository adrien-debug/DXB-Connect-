/**
 * Update plans with real eSIM Access package codes
 */
require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

async function updatePlans() {
  const client = await pool.connect();

  try {
    console.log('Updating plans with eSIM Access package codes...\n');

    // Add provider_package_id column if not exists
    await client.query(`
      ALTER TABLE plans ADD COLUMN IF NOT EXISTS provider_package_id VARCHAR(100)
    `);

    // Update existing plans with provider package codes
    const updates = [
      { id: 'plan_3d_5gb', providerCode: 'CKH693', name: 'UAE 5GB - 30 Days', dataGb: 5, days: 30, price: 14.99 },
      { id: 'plan_7d_10gb', providerCode: 'CKH694', name: 'UAE 10GB - 60 Days', dataGb: 10, days: 60, price: 29.99 },
      { id: 'plan_15d_20gb', providerCode: 'CKH031', name: 'UAE 3GB - 30 Days', dataGb: 3, days: 30, price: 9.99 },
    ];

    for (const plan of updates) {
      await client.query(`
        UPDATE plans SET
          provider_package_id = $1,
          name = $2,
          data_gb = $3,
          duration_days = $4,
          price_usd = $5
        WHERE id = $6
      `, [plan.providerCode, plan.name, plan.dataGb, plan.days, plan.price, plan.id]);
      console.log(`✅ Updated ${plan.id} -> ${plan.providerCode}`);
    }

    // Insert new UAE plans
    const newPlans = [
      { id: 'plan_uae_1gb_7d', code: 'CKH527', name: 'UAE 1GB - 7 Days', desc: 'Perfect for short trips', gb: 1, days: 7, price: 4.99 },
    ];

    for (const p of newPlans) {
      await client.query(`
        INSERT INTO plans (id, name, description, data_gb, duration_days, price_usd, currency, coverage, speed, fair_usage_gb, provider_package_id, active)
        VALUES ($1, $2, $3, $4, $5, $6, 'USD', ARRAY['Dubai', 'UAE'], '4G/5G', $4, $7, true)
        ON CONFLICT (id) DO NOTHING
      `, [p.id, p.name, p.desc, p.gb, p.days, p.price, p.code]);
      console.log(`✅ Added ${p.id}`);
    }

    // Show final plans
    const result = await client.query('SELECT id, name, data_gb, duration_days, price_usd, provider_package_id FROM plans ORDER BY price_usd');
    console.log('\nFinal plans:');
    console.table(result.rows);

  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    client.release();
    await pool.end();
  }
}

updatePlans();

-- Migration: eSIM Access Integration
-- Adds provider package mapping and retry support

-- Add provider package ID mapping to plans
ALTER TABLE plans ADD COLUMN IF NOT EXISTS provider_package_id VARCHAR(100);

-- Add retry count to orders
ALTER TABLE orders ADD COLUMN IF NOT EXISTS retry_count INTEGER DEFAULT 0;

-- Add provider order reference to esim_profiles
ALTER TABLE esim_profiles ADD COLUMN IF NOT EXISTS provider_order_id VARCHAR(100);

-- Create index for failed orders retry
CREATE INDEX IF NOT EXISTS idx_orders_failed_retry 
ON orders (status, created_at, retry_count) 
WHERE status = 'FAILED';

-- Update existing plans with eSIM Access package IDs
-- These IDs should match actual eSIM Access package IDs
UPDATE plans SET provider_package_id = 'esimaccess_uae_3d_5gb' WHERE id = 'plan_3d_5gb';
UPDATE plans SET provider_package_id = 'esimaccess_uae_7d_10gb' WHERE id = 'plan_7d_10gb';
UPDATE plans SET provider_package_id = 'esimaccess_uae_15d_20gb' WHERE id = 'plan_15d_20gb';

-- Add comment
COMMENT ON COLUMN plans.provider_package_id IS 'eSIM Access package ID for this plan';

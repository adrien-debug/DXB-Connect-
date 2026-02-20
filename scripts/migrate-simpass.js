#!/usr/bin/env node
/**
 * SimPass Migration Script
 *
 * Usage:
 *   DATABASE_URL="postgresql://postgres.[ref]:[password]@aws-0-[region].pooler.supabase.com:6543/postgres" node scripts/migrate-simpass.js
 *
 * Get DATABASE_URL from: Supabase Dashboard > Settings > Database > Connection string (URI)
 */

const { Client } = require('pg')

const MIGRATION_SQL = `
-- PARTNER_OFFERS
CREATE TABLE IF NOT EXISTS public.partner_offers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_name TEXT NOT NULL,
  partner_slug TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'activity',
  title TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  discount_percent INTEGER,
  discount_type TEXT DEFAULT 'percent',
  affiliate_url_template TEXT,
  country_codes JSONB DEFAULT '[]'::jsonb,
  city TEXT,
  is_global BOOLEAN DEFAULT false,
  tier_required TEXT,
  is_active BOOLEAN DEFAULT true,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.partner_offers ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'partner_offers_read' AND tablename = 'partner_offers') THEN
    CREATE POLICY partner_offers_read ON public.partner_offers FOR SELECT USING (true);
  END IF;
END $$;

-- OFFER_CLICKS
CREATE TABLE IF NOT EXISTS public.offer_clicks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  offer_id UUID REFERENCES public.partner_offers(id) ON DELETE CASCADE,
  country TEXT,
  city TEXT,
  source TEXT DEFAULT 'app',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.offer_clicks ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'offer_clicks_insert' AND tablename = 'offer_clicks') THEN
    CREATE POLICY offer_clicks_insert ON public.offer_clicks FOR INSERT WITH CHECK (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'offer_clicks_read_own' AND tablename = 'offer_clicks') THEN
    CREATE POLICY offer_clicks_read_own ON public.offer_clicks FOR SELECT USING (user_id = auth.uid());
  END IF;
END $$;

-- OFFER_REDEMPTIONS
CREATE TABLE IF NOT EXISTS public.offer_redemptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  offer_id UUID REFERENCES public.partner_offers(id) ON DELETE CASCADE,
  partner_order_id TEXT,
  commission_amount DECIMAL(10,2),
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.offer_redemptions ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'offer_redemptions_own' AND tablename = 'offer_redemptions') THEN
    CREATE POLICY offer_redemptions_own ON public.offer_redemptions FOR ALL USING (user_id = auth.uid());
  END IF;
END $$;

-- SUBSCRIPTIONS
CREATE TABLE IF NOT EXISTS public.subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  plan TEXT NOT NULL DEFAULT 'privilege',
  status TEXT NOT NULL DEFAULT 'active',
  billing_period TEXT NOT NULL DEFAULT 'monthly',
  stripe_subscription_id TEXT,
  stripe_customer_id TEXT,
  apple_original_transaction_id TEXT,
  current_period_start TIMESTAMPTZ,
  current_period_end TIMESTAMPTZ,
  cancel_at_period_end BOOLEAN DEFAULT false,
  discount_percent INTEGER NOT NULL DEFAULT 15,
  monthly_discount_cap_usd DECIMAL(10,2),
  discounts_used_this_period INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_subscriptions_user ON public.subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_stripe ON public.subscriptions(stripe_subscription_id);

ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'subscriptions_own' AND tablename = 'subscriptions') THEN
    CREATE POLICY subscriptions_own ON public.subscriptions FOR SELECT USING (user_id = auth.uid());
  END IF;
END $$;

-- SUBSCRIPTION_USAGE
CREATE TABLE IF NOT EXISTS public.subscription_usage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subscription_id UUID REFERENCES public.subscriptions(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id),
  order_id TEXT,
  discount_applied_usd DECIMAL(10,2),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.subscription_usage ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'sub_usage_own' AND tablename = 'subscription_usage') THEN
    CREATE POLICY sub_usage_own ON public.subscription_usage FOR SELECT USING (user_id = auth.uid());
  END IF;
END $$;

-- USER_WALLET
CREATE TABLE IF NOT EXISTS public.user_wallet (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  xp_total INTEGER DEFAULT 0,
  level INTEGER DEFAULT 1,
  points_balance INTEGER DEFAULT 0,
  points_earned_total INTEGER DEFAULT 0,
  points_spent_total INTEGER DEFAULT 0,
  tickets_balance INTEGER DEFAULT 0,
  tier TEXT DEFAULT 'bronze',
  streak_days INTEGER DEFAULT 0,
  last_checkin TIMESTAMPTZ,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.user_wallet ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'wallet_own' AND tablename = 'user_wallet') THEN
    CREATE POLICY wallet_own ON public.user_wallet FOR ALL USING (user_id = auth.uid());
  END IF;
END $$;

-- WALLET_TRANSACTIONS
CREATE TABLE IF NOT EXISTS public.wallet_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL DEFAULT 'points',
  delta INTEGER NOT NULL,
  reason TEXT NOT NULL,
  source_id TEXT,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_wallet_tx_user ON public.wallet_transactions(user_id);

ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'wallet_tx_own' AND tablename = 'wallet_transactions') THEN
    CREATE POLICY wallet_tx_own ON public.wallet_transactions FOR SELECT USING (user_id = auth.uid());
  END IF;
END $$;

-- MISSIONS
CREATE TABLE IF NOT EXISTS public.missions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT NOT NULL DEFAULT 'daily',
  title TEXT NOT NULL,
  description TEXT,
  xp_reward INTEGER DEFAULT 0,
  points_reward INTEGER DEFAULT 0,
  tickets_reward INTEGER DEFAULT 0,
  condition_type TEXT NOT NULL,
  condition_value INTEGER DEFAULT 1,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.missions ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'missions_read' AND tablename = 'missions') THEN
    CREATE POLICY missions_read ON public.missions FOR SELECT USING (true);
  END IF;
END $$;

-- USER_MISSION_PROGRESS
CREATE TABLE IF NOT EXISTS public.user_mission_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  mission_id UUID REFERENCES public.missions(id) ON DELETE CASCADE,
  progress INTEGER DEFAULT 0,
  completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMPTZ,
  period_start TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_mission_progress_user ON public.user_mission_progress(user_id);

ALTER TABLE public.user_mission_progress ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'mission_progress_own' AND tablename = 'user_mission_progress') THEN
    CREATE POLICY mission_progress_own ON public.user_mission_progress FOR ALL USING (user_id = auth.uid());
  END IF;
END $$;

-- RAFFLES
CREATE TABLE IF NOT EXISTS public.raffles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  prize_description TEXT NOT NULL,
  draw_date TIMESTAMPTZ NOT NULL,
  status TEXT DEFAULT 'active',
  winner_user_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.raffles ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'raffles_read' AND tablename = 'raffles') THEN
    CREATE POLICY raffles_read ON public.raffles FOR SELECT USING (true);
  END IF;
END $$;

-- RAFFLE_ENTRIES
CREATE TABLE IF NOT EXISTS public.raffle_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  raffle_id UUID REFERENCES public.raffles(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  tickets_used INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_raffle_entries_user ON public.raffle_entries(user_id);

ALTER TABLE public.raffle_entries ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'raffle_entries_own' AND tablename = 'raffle_entries') THEN
    CREATE POLICY raffle_entries_own ON public.raffle_entries FOR ALL USING (user_id = auth.uid());
  END IF;
END $$;

-- CRYPTO_INVOICES
CREATE TABLE IF NOT EXISTS public.crypto_invoices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  amount_usd DECIMAL(10,2) NOT NULL,
  asset TEXT NOT NULL DEFAULT 'USDC',
  network TEXT NOT NULL DEFAULT 'POLYGON',
  deposit_address TEXT,
  status TEXT DEFAULT 'pending',
  fireblocks_ref TEXT,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_crypto_invoices_user ON public.crypto_invoices(user_id);

ALTER TABLE public.crypto_invoices ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'crypto_invoices_own' AND tablename = 'crypto_invoices') THEN
    CREATE POLICY crypto_invoices_own ON public.crypto_invoices FOR SELECT USING (user_id = auth.uid());
  END IF;
END $$;

-- CRYPTO_PAYMENTS
CREATE TABLE IF NOT EXISTS public.crypto_payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id UUID REFERENCES public.crypto_invoices(id) ON DELETE CASCADE,
  tx_hash TEXT,
  amount_received DECIMAL(18,8),
  confirmations INTEGER DEFAULT 0,
  status TEXT DEFAULT 'pending',
  raw_event JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.crypto_payments ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'crypto_payments_read' AND tablename = 'crypto_payments') THEN
    CREATE POLICY crypto_payments_read ON public.crypto_payments FOR SELECT USING (
      EXISTS (SELECT 1 FROM public.crypto_invoices WHERE id = invoice_id AND user_id = auth.uid())
    );
  END IF;
END $$;

-- EVENT_LOGS
CREATE TABLE IF NOT EXISTS public.event_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  event_type TEXT NOT NULL,
  event_data JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_event_logs_user ON public.event_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_event_logs_type ON public.event_logs(event_type);

ALTER TABLE public.event_logs ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'event_logs_own' AND tablename = 'event_logs') THEN
    CREATE POLICY event_logs_own ON public.event_logs FOR SELECT USING (user_id = auth.uid());
  END IF;
END $$;
`

async function main() {
  const dbUrl = process.env.DATABASE_URL
  if (!dbUrl) {
    console.error('ERROR: DATABASE_URL not set')
    console.log('')
    console.log('Usage:')
    console.log('  DATABASE_URL="postgresql://postgres.[ref]:[password]@aws-0-[region].pooler.supabase.com:6543/postgres" node scripts/migrate-simpass.js')
    console.log('')
    console.log('Get the connection string from: Supabase Dashboard > Settings > Database > Connection string (URI)')
    process.exit(1)
  }

  const client = new Client({ connectionString: dbUrl, ssl: { rejectUnauthorized: false } })

  try {
    console.log('Connecting to database...')
    await client.connect()
    console.log('Connected.')

    console.log('Running SimPass migration...')
    await client.query(MIGRATION_SQL)
    console.log('Migration completed successfully!')

    const { rows } = await client.query(`
      SELECT tablename FROM pg_tables
      WHERE schemaname = 'public'
      AND tablename IN (
        'partner_offers', 'offer_clicks', 'offer_redemptions',
        'subscriptions', 'subscription_usage', 'user_wallet',
        'wallet_transactions', 'missions', 'user_mission_progress',
        'raffles', 'raffle_entries', 'crypto_invoices', 'crypto_payments', 'event_logs'
      )
      ORDER BY tablename
    `)

    console.log(`\nVerification: ${rows.length}/14 SimPass tables created:`)
    rows.forEach(r => console.log(`  ✓ ${r.tablename}`))

    if (rows.length < 14) {
      console.log(`\n⚠ Missing ${14 - rows.length} tables`)
    } else {
      console.log('\n✅ All 14 SimPass tables are ready!')
    }
  } catch (err) {
    console.error('Migration error:', err.message)
    process.exit(1)
  } finally {
    await client.end()
  }
}

main()

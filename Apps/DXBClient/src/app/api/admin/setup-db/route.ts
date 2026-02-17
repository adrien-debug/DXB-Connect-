import { createClient } from '@supabase/supabase-js'
import { NextResponse } from 'next/server'

const SETUP_SQL = `
-- PROFILES
DROP TABLE IF EXISTS public.profiles CASCADE;
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  full_name TEXT,
  role TEXT DEFAULT 'client',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all for authenticated" ON public.profiles FOR ALL USING (true);

-- SUPPLIERS
DROP TABLE IF EXISTS public.suppliers CASCADE;
CREATE TABLE public.suppliers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  email TEXT,
  company TEXT,
  category TEXT,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all suppliers" ON public.suppliers FOR ALL USING (true);

-- PRODUCTS
DROP TABLE IF EXISTS public.products CASCADE;
CREATE TABLE public.products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10,2),
  category TEXT,
  supplier_id UUID REFERENCES public.suppliers(id),
  stock INTEGER DEFAULT 0,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all products" ON public.products FOR ALL USING (true);

-- CUSTOMERS
DROP TABLE IF EXISTS public.customers CASCADE;
CREATE TABLE public.customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  first_name TEXT,
  last_name TEXT,
  email TEXT,
  segment TEXT,
  value DECIMAL(10,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all customers" ON public.customers FOR ALL USING (true);

-- AD_CAMPAIGNS
DROP TABLE IF EXISTS public.ad_campaigns CASCADE;
CREATE TABLE public.ad_campaigns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  status TEXT DEFAULT 'draft',
  budget DECIMAL(10,2) DEFAULT 0,
  spent DECIMAL(10,2) DEFAULT 0,
  impressions INTEGER DEFAULT 0,
  clicks INTEGER DEFAULT 0,
  conversions INTEGER DEFAULT 0,
  start_date DATE,
  end_date DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.ad_campaigns ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all campaigns" ON public.ad_campaigns FOR ALL USING (true);

-- CART_ITEMS
DROP TABLE IF EXISTS public.cart_items CASCADE;
CREATE TABLE public.cart_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
  quantity INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all cart_items" ON public.cart_items FOR ALL USING (true);

-- ORDERS
DROP TABLE IF EXISTS public.orders CASCADE;
CREATE TABLE public.orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  status TEXT DEFAULT 'pending',
  total DECIMAL(10,2) DEFAULT 0,
  payment_intent_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all orders" ON public.orders FOR ALL USING (true);

-- ESIM_ORDERS
DROP TABLE IF EXISTS public.esim_orders CASCADE;
CREATE TABLE public.esim_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  order_no TEXT,
  package_code TEXT,
  iccid TEXT,
  lpa_code TEXT,
  qr_code_url TEXT,
  status TEXT DEFAULT 'PENDING',
  total_volume BIGINT,
  expired_time TIMESTAMPTZ,
  raw_response JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.esim_orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all esim_orders" ON public.esim_orders FOR ALL USING (true);

-- FUNCTION get_user_role
CREATE OR REPLACE FUNCTION public.get_user_role(user_id UUID)
RETURNS TEXT LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN (SELECT role FROM public.profiles WHERE id = user_id);
END;
$$;
`

import { requireAdmin } from '@/lib/auth-middleware'

export async function POST(request: Request) {
  const { user, error } = await requireAdmin(request)
  if (error) return error

  // 🔴 SÉCURITÉ: Bloquer en production (contient DROP TABLE)
  if (process.env.NODE_ENV !== 'development') {
    return NextResponse.json({ error: 'Not available in production' }, { status: 403 })
  }

  try {
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
    const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY

    if (!supabaseUrl || !serviceRoleKey) {
      return NextResponse.json({ error: 'Missing credentials' }, { status: 500 })
    }

    // Use service role client
    const supabase = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false }
    })

    // Execute SQL statements one by one
    const statements = SETUP_SQL
      .split(';')
      .map(s => s.trim())
      .filter(s => s.length > 0 && !s.startsWith('--'))

    const results = []
    for (const stmt of statements) {
      try {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const { error } = await (supabase as any).rpc('exec', { sql: stmt })
        if (error) {
          results.push({ stmt: stmt.slice(0, 50), error: error.message })
        } else {
          results.push({ stmt: stmt.slice(0, 50), success: true })
        }
      } catch (e) {
        results.push({ stmt: stmt.slice(0, 50), error: String(e) })
      }
    }

    // Insert admin profile directly
    const { error: profileError } = await supabase
      .from('profiles')
      .upsert({
        id: 'd6e91327-cc9b-4f81-ac27-a46cc8da84ab',
        email: 'demo@dxb.com',
        full_name: 'Demo Admin',
        role: 'admin'
      }, { onConflict: 'id' })

    return NextResponse.json({
      success: true,
      results,
      profileInsert: profileError ? profileError.message : 'ok'
    })
  } catch (error) {
    console.error('[setup-db] Error:', error)
    return NextResponse.json({ error: String(error) }, { status: 500 })
  }
}

export async function GET() {
  return NextResponse.json({
    endpoint: '/api/admin/setup-db',
    method: 'POST',
    description: 'Creates all required database tables'
  })
}

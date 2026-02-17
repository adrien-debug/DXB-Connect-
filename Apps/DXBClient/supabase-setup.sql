-- ============================================
-- DXB Connect - Supabase Setup SQL
-- À exécuter dans Supabase SQL Editor
-- ============================================

-- 1. Table profiles (utilisateurs)
-- ============================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    full_name TEXT,
    role TEXT NOT NULL DEFAULT 'client',
    avatar_url TEXT,
    phone TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour recherche rapide
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);

-- 2. Table esim_orders (commandes eSIM)
-- ============================================
CREATE TABLE IF NOT EXISTS public.esim_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    order_no TEXT NOT NULL UNIQUE,
    package_code TEXT NOT NULL,
    package_name TEXT,
    iccid TEXT,
    lpa_code TEXT,
    qr_code_url TEXT,
    status TEXT DEFAULT 'PENDING',
    total_volume BIGINT, -- en bytes
    purchase_price NUMERIC(10,2),
    currency TEXT DEFAULT 'USD',
    expired_time TEXT,
    raw_response JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour recherche rapide
CREATE INDEX IF NOT EXISTS idx_esim_orders_user_id ON public.esim_orders(user_id);
CREATE INDEX IF NOT EXISTS idx_esim_orders_status ON public.esim_orders(status);
CREATE INDEX IF NOT EXISTS idx_esim_orders_iccid ON public.esim_orders(iccid);

-- 3. Activer RLS (Row Level Security)
-- ============================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.esim_orders ENABLE ROW LEVEL SECURITY;

-- 4. Policies pour profiles
-- ============================================

-- Users can view their own profile
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
CREATE POLICY "Users can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

-- Users can update their own profile
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

-- Service role can do everything (pour Railway backend)
DROP POLICY IF EXISTS "Service role full access profiles" ON public.profiles;
CREATE POLICY "Service role full access profiles" ON public.profiles
    FOR ALL USING (
        auth.jwt() ->> 'role' = 'service_role'
        OR auth.uid() = id
    );

-- Allow insert for authenticated users (création profil à l'inscription)
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
CREATE POLICY "Users can insert own profile" ON public.profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- 5. Policies pour esim_orders
-- ============================================

-- Users can view their own orders
DROP POLICY IF EXISTS "Users can view own orders" ON public.esim_orders;
CREATE POLICY "Users can view own orders" ON public.esim_orders
    FOR SELECT USING (auth.uid() = user_id);

-- Service role can do everything (pour Railway backend)
DROP POLICY IF EXISTS "Service role full access orders" ON public.esim_orders;
CREATE POLICY "Service role full access orders" ON public.esim_orders
    FOR ALL USING (
        auth.jwt() ->> 'role' = 'service_role'
    );

-- Users can insert their own orders (via Railway)
DROP POLICY IF EXISTS "Users can insert own orders" ON public.esim_orders;
CREATE POLICY "Users can insert own orders" ON public.esim_orders
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 6. Fonctions helper
-- ============================================

-- Fonction pour vérifier si un utilisateur est admin
CREATE OR REPLACE FUNCTION public.is_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = user_id AND role = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour obtenir le rôle d'un utilisateur
CREATE OR REPLACE FUNCTION public.get_user_role(user_id UUID)
RETURNS TEXT AS $$
DECLARE
    user_role TEXT;
BEGIN
    SELECT role INTO user_role FROM public.profiles WHERE id = user_id;
    RETURN COALESCE(user_role, 'client');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Trigger pour auto-update updated_at
-- ============================================

CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger sur profiles
DROP TRIGGER IF EXISTS on_profiles_updated ON public.profiles;
CREATE TRIGGER on_profiles_updated
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Trigger sur esim_orders
DROP TRIGGER IF EXISTS on_esim_orders_updated ON public.esim_orders;
CREATE TRIGGER on_esim_orders_updated
    BEFORE UPDATE ON public.esim_orders
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 8. Trigger pour créer automatiquement un profil à l'inscription
-- ============================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', ''),
        'client'
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Supprimer l'ancien trigger s'il existe
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Créer le trigger
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- FIN DU SCRIPT
-- ============================================

-- Pour vérifier que tout est en place:
-- SELECT * FROM public.profiles LIMIT 5;
-- SELECT * FROM public.esim_orders LIMIT 5;

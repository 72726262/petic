-- ============================================================================
-- Supabase RLS Policies Fix - Infinite Recursion Fix (42P17)
-- Run this ENTIRE script in Supabase Dashboard → SQL Editor
-- ============================================================================

-- Step 1: Drop ALL existing policies on users table
DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN
        SELECT policyname FROM pg_policies WHERE tablename = 'users' AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.users', pol.policyname);
    END LOOP;
END $$;

-- Step 2: Make sure RLS is enabled
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- KEY RULE: NEVER query public.users inside a policy ON public.users
-- Always use auth.uid() or auth.jwt() or auth.users (not public.users)
-- ============================================================================

-- Step 3: Any authenticated user can read ALL profiles (no recursion)
CREATE POLICY "users_select_policy"
ON public.users
FOR SELECT
TO authenticated
USING (true);

-- Step 4: User can insert their own profile during signup
CREATE POLICY "users_insert_policy"
ON public.users
FOR INSERT
TO authenticated
WITH CHECK (id = auth.uid());

-- Step 5: User can update their OWN profile
CREATE POLICY "users_update_own_policy"
ON public.users
FOR UPDATE
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Step 6: Admin can update ANY profile
-- Uses auth.jwt() metadata to avoid recursive lookup into public.users
CREATE POLICY "users_update_admin_policy"
ON public.users
FOR UPDATE
TO authenticated
USING (
    -- Check from JWT app_metadata (set via Supabase dashboard or trigger)
    (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
    OR
    -- Check from user_metadata stored in auth.users (NOT public.users)
    (SELECT raw_user_meta_data ->> 'role' FROM auth.users WHERE id = auth.uid()) = 'admin'
)
WITH CHECK (
    (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
    OR
    (SELECT raw_user_meta_data ->> 'role' FROM auth.users WHERE id = auth.uid()) = 'admin'
);

-- Step 7: Admin can delete profiles
CREATE POLICY "users_delete_admin_policy"
ON public.users
FOR DELETE
TO authenticated
USING (
    (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
    OR
    (SELECT raw_user_meta_data ->> 'role' FROM auth.users WHERE id = auth.uid()) = 'admin'
);

-- ============================================================================
-- Create users table if not exists
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT DEFAULT '',
    avatar_url TEXT,
    role TEXT DEFAULT 'user' CHECK (role IN ('admin', 'user', 'hr', 'it')),
    department TEXT,
    job_title TEXT,
    phone TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- Fix the trigger that auto-creates user profile on signup
-- This avoids RLS issues during profile creation
-- ============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER  -- Runs as superuser, bypasses RLS
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.users (id, email, full_name, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data ->> 'full_name', ''),
        COALESCE(NEW.raw_user_meta_data ->> 'role', 'user')
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$;

-- Re-attach trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

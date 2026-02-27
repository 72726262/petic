-- ============================================================
-- Mood Table RLS Policies
-- Run this SQL in Supabase Dashboard → SQL Editor
-- This allows employees to insert/select their own moods
-- ============================================================

-- Enable RLS on moods table (if not already enabled)
ALTER TABLE public.moods ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Users can insert own moods" ON public.moods;
DROP POLICY IF EXISTS "Users can select own moods" ON public.moods;
DROP POLICY IF EXISTS "Users can update own moods" ON public.moods;
DROP POLICY IF EXISTS "Admins can view all moods" ON public.moods;
DROP POLICY IF EXISTS "Allow all authenticated users to insert moods" ON public.moods;

-- Policy 1: Users can insert their own moods
CREATE POLICY "Users can insert own moods"
  ON public.moods
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Policy 2: Users can select their own moods
CREATE POLICY "Users can select own moods"
  ON public.moods
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Policy 3: Users can update their own moods
CREATE POLICY "Users can update own moods"
  ON public.moods
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

-- Policy 4: Admins and HR can view all moods
CREATE POLICY "Admins can view all moods"
  ON public.moods
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid()
        AND role IN ('admin', 'hr')
    )
  );

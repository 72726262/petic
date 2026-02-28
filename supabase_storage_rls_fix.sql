-- ============================================================================
-- Fix Storage Policies for 'avatars' bucket
-- Run this in the Supabase SQL Editor to resolve the 403 Unauthorized error
-- ============================================================================

-- Ensure the avatars bucket is PUBLIC so images can be loaded without auth tokens
UPDATE storage.buckets SET public = true WHERE id = 'avatars';

-- Drop existing policies if they exist to avoid conflicts
DROP POLICY IF EXISTS "Avatar images are publicly accessible." ON storage.objects;
DROP POLICY IF EXISTS "Users can upload their own avatar." ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own avatar." ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own avatar." ON storage.objects;

-- 1. Allow everyone to view avatars
CREATE POLICY "Avatar images are publicly accessible."
ON storage.objects FOR SELECT
USING ( bucket_id = 'avatars' );

-- 2. Allow authenticated users to upload avatars
-- Removed the strict folder name check since we upload to the root of the bucket
CREATE POLICY "Users can upload their own avatar."
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK ( bucket_id = 'avatars' );

-- 3. Allow authenticated users to update their avatars
CREATE POLICY "Users can update their own avatar."
ON storage.objects FOR UPDATE
TO authenticated
USING ( bucket_id = 'avatars' )
WITH CHECK ( bucket_id = 'avatars' );

-- 4. Allow authenticated users to delete their avatars
CREATE POLICY "Users can delete their own avatar."
ON storage.objects FOR DELETE
TO authenticated
USING ( bucket_id = 'avatars' );

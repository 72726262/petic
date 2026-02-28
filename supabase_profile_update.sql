-- ============================================================================
-- Profile Update RPC
-- Bypasses RLS to allow users to update their own profiles
-- ============================================================================

CREATE OR REPLACE FUNCTION update_user_profile(
    p_user_id UUID,
    p_full_name TEXT,
    p_department TEXT,
    p_avatar_url TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user RECORD;
    v_update_record JSONB;
BEGIN
    -- Only allow the user to update their own profile OR an admin
    IF auth.uid() != p_user_id AND (auth.jwt() -> 'app_metadata' ->> 'role') != 'admin' THEN
        RAISE EXCEPTION 'Not authorized to update this profile';
    END IF;

    -- Update the users table
    UPDATE public.users
    SET 
        full_name = COALESCE(p_full_name, full_name),
        department = COALESCE(p_department, department),
        avatar_url = COALESCE(p_avatar_url, avatar_url),
        updated_at = NOW()
    WHERE id = p_user_id
    RETURNING * INTO v_user;

    -- Also try to update the auth.users metadata for full_name
    IF p_full_name IS NOT NULL THEN
       UPDATE auth.users
       SET raw_user_meta_data = 
           COALESCE(raw_user_meta_data, '{}'::jsonb) || 
           jsonb_build_object('full_name', p_full_name)
       WHERE id = p_user_id;
    END IF;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'User profile not found';
    END IF;

    RETURN to_jsonb(v_user);
END;
$$;


-- ============================================================================
-- Storage Policies for 'avatars' bucket
-- ============================================================================

-- Ensure the avatars bucket is PUBLIC
UPDATE storage.buckets SET public = true WHERE id = 'avatars';

-- Drop existing policies if they exist to avoid conflicts
DROP POLICY IF EXISTS "Avatar images are publicly accessible." ON storage.objects;
DROP POLICY IF EXISTS "Users can upload their own avatar." ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own avatar." ON storage.objects;

-- Create policies for the avatars bucket
CREATE POLICY "Avatar images are publicly accessible."
ON storage.objects FOR SELECT
USING ( bucket_id = 'avatars' );

CREATE POLICY "Users can upload their own avatar."
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'avatars' 
    AND (storage.foldername(name))[1] = auth.uid()::text -- Enforce folder matches UID if we use folders, but we aren't, so we just check auth
);

CREATE POLICY "Users can update their own avatar."
ON storage.objects FOR UPDATE
TO authenticated
USING (
    bucket_id = 'avatars'
)
WITH CHECK (
    bucket_id = 'avatars'
);

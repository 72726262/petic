-- ==========================================================
-- Run this ONCE in Supabase SQL Editor (Dashboard → SQL Editor)
-- This creates the RPC function used to update user roles.
-- It bypasses RLS since it runs with SECURITY DEFINER.
-- ==========================================================

CREATE OR REPLACE FUNCTION update_user_role(
  target_user_id uuid,
  new_role text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Only allow if the calling user is an admin
  IF (SELECT role FROM users WHERE id = auth.uid()) != 'admin' THEN
    RAISE EXCEPTION 'Not authorized: only admins can change roles';
  END IF;

  -- Validate the role value
  IF new_role NOT IN ('user', 'hr', 'it', 'admin') THEN
    RAISE EXCEPTION 'Invalid role: %', new_role;
  END IF;

  UPDATE users SET role = new_role WHERE id = target_user_id;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION update_user_role(uuid, text) TO authenticated;

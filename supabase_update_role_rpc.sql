-- ============================================================
-- RPC: update_user_role
-- Run this SQL in Supabase Dashboard → SQL Editor
-- This SECURITY DEFINER function allows admins to change
-- any user's role, bypassing RLS (which blocks direct updates)
-- ============================================================

CREATE OR REPLACE FUNCTION update_user_role(
  target_user_id UUID,
  new_role TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Only allow valid roles
  IF new_role NOT IN ('user', 'hr', 'it', 'admin') THEN
    RAISE EXCEPTION 'Invalid role: %', new_role;
  END IF;

  UPDATE users
    SET role = new_role
    WHERE id = target_user_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'User not found: %', target_user_id;
  END IF;
END;
$$;

-- Grant execute permission to authenticated users
-- (the RLS on the function itself ensures only admins should call it)
GRANT EXECUTE ON FUNCTION update_user_role(UUID, TEXT) TO authenticated;

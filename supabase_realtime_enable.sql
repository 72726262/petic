-- ==========================================================
-- Run this ONCE in Supabase SQL Editor
-- Enables Realtime for HR, IT, and CEO messages tables
-- so that all online users receive real-time toast notifications.
--
-- After running this SQL, also go to:
-- Supabase Dashboard → Database → Replication → Supabase Realtime
-- and toggle ON: hr_content, it_content, ceo_messages
-- ==========================================================

ALTER TABLE hr_content REPLICA IDENTITY FULL;
ALTER TABLE it_content REPLICA IDENTITY FULL;
ALTER TABLE ceo_messages REPLICA IDENTITY FULL;

-- Verify Realtime is enabled on these tables:
SELECT schemaname, tablename 
FROM pg_publication_tables
WHERE pubname = 'supabase_realtime';

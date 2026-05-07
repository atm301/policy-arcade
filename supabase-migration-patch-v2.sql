-- ============================================================
-- POLICY ARCADE · Patch V2
-- 新增：班級排行榜（前 10 名 + 名字 mask 避免羞辱後段）
-- 在 Supabase SQL Editor 跑這份（不會動到既有資料）
-- ============================================================

CREATE OR REPLACE FUNCTION public.pa_public_leaderboard()
RETURNS jsonb
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(jsonb_agg(jsonb_build_object(
    'nick', CASE
      WHEN char_length(name) >= 2
        THEN LEFT(name, 1) || repeat('*', LEAST(char_length(name) - 1, 2))
      ELSE COALESCE(name, '???')
    END,
    'role',    COALESCE(class_role, ''),
    'team',    COALESCE(team, ''),
    'exp_log', COALESCE(exp_log, '{}'::jsonb)
  )), '[]'::jsonb)
  FROM pa_attendees
  WHERE exp_log IS NOT NULL
    AND jsonb_typeof(exp_log) = 'object'
$$;

REVOKE ALL ON FUNCTION public.pa_public_leaderboard() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.pa_public_leaderboard() TO anon;

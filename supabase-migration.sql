-- ============================================================
-- Policy Arcade（遊戲化 × AI × 公共政策 課程輔助站）— Supabase Migration
-- 表前綴：pa_
-- 目標：100 位學員報到 + Octalysis 設計器 + 小組任務提交 + 提問
-- ============================================================

-- 1. 學員 + 報到 + 個人 Octalysis + 小組任務（單表 JSONB）
CREATE TABLE IF NOT EXISTS public.pa_attendees (
  id                BIGSERIAL PRIMARY KEY,
  name              TEXT NOT NULL,
  student_id        TEXT,             -- 學號
  team              TEXT,             -- 小組
  class_role        TEXT,             -- 自選職業（賢者/騎士/吟遊/工匠/賽手/守護）
  contact           TEXT,
  client_token      TEXT,

  octalysis_design  JSONB,            -- Octalysis 設計器：{topic, drives[], notes}
  group_quest       JSONB,            -- 小組任務：{topic, problem, behavior, mechanic, drives[], risks}
  exp_log           JSONB,            -- EXP 累積記錄 {key:earned_at}

  user_agent        TEXT,
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS pa_attendees_token_idx ON public.pa_attendees (client_token);
CREATE INDEX IF NOT EXISTS pa_attendees_team_idx ON public.pa_attendees (team);
CREATE INDEX IF NOT EXISTS pa_attendees_created_idx ON public.pa_attendees (created_at DESC);

ALTER TABLE public.pa_attendees ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "pa_anon_insert" ON public.pa_attendees;
CREATE POLICY "pa_anon_insert"
  ON public.pa_attendees
  FOR INSERT TO anon
  WITH CHECK (true);

-- 2. 課堂提問
CREATE TABLE IF NOT EXISTS public.pa_questions (
  id              BIGSERIAL PRIMARY KEY,
  attendee_name   TEXT,
  team            TEXT,
  question        TEXT NOT NULL,
  is_anonymous    BOOLEAN DEFAULT FALSE,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.pa_questions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "pa_questions_anon_insert" ON public.pa_questions;
CREATE POLICY "pa_questions_anon_insert"
  ON public.pa_questions
  FOR INSERT TO anon
  WITH CHECK (true);

-- 3. 公開報到人數（首頁 LIVE 顯示）
CREATE OR REPLACE FUNCTION public.pa_attendee_count()
RETURNS int
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$ SELECT COUNT(*)::int FROM pa_attendees $$;

REVOKE ALL ON FUNCTION public.pa_attendee_count() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.pa_attendee_count() TO anon;

-- 4. 公開「已提交小組任務」清單（讓學員看到別組進度）
CREATE OR REPLACE FUNCTION public.pa_public_quests()
RETURNS jsonb
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(jsonb_agg(jsonb_build_object(
    'team', team,
    'name', name,
    'topic', group_quest->>'topic',
    'submitted_at', updated_at
  ) ORDER BY updated_at DESC), '[]'::jsonb)
  FROM pa_attendees
  WHERE group_quest IS NOT NULL
$$;

REVOKE ALL ON FUNCTION public.pa_public_quests() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.pa_public_quests() TO anon;

-- 5. 修改學員資料 / 更新各區塊
CREATE OR REPLACE FUNCTION public.pa_update_attendee(
  p_token text,
  p_field text,
  p_data  jsonb
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  updated_id bigint;
BEGIN
  IF p_token IS NULL OR length(p_token) < 8 THEN
    RAISE EXCEPTION 'invalid token';
  END IF;

  IF p_field = 'basic' THEN
    UPDATE pa_attendees SET
      name       = COALESCE(p_data->>'name', name),
      student_id = p_data->>'student_id',
      team       = p_data->>'team',
      class_role = p_data->>'class_role',
      contact    = p_data->>'contact',
      updated_at = now()
    WHERE client_token = p_token
    RETURNING id INTO updated_id;
  ELSIF p_field IN ('octalysis_design','group_quest','exp_log') THEN
    EXECUTE format(
      'UPDATE pa_attendees SET %I = $1, updated_at = now() WHERE client_token = $2 RETURNING id',
      p_field
    )
      INTO updated_id
      USING p_data, p_token;
  ELSE
    RAISE EXCEPTION 'invalid field: %', p_field;
  END IF;

  IF updated_id IS NULL THEN
    RAISE EXCEPTION 'no matching record';
  END IF;

  RETURN jsonb_build_object('id', updated_id);
END;
$$;

REVOKE ALL ON FUNCTION public.pa_update_attendee(text,text,jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.pa_update_attendee(text,text,jsonb) TO anon;

-- 6. 後台統計（密碼 angle301）
CREATE OR REPLACE FUNCTION public.pa_admin_stats(secret text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  expected_secret text := 'angle301';
  result jsonb;
BEGIN
  IF secret IS NULL OR secret <> expected_secret THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  SELECT jsonb_build_object(
    'attendees', COALESCE((
      SELECT jsonb_agg(to_jsonb(a) ORDER BY a.id DESC)
      FROM (SELECT id, name, student_id, team, class_role, contact,
                   octalysis_design, group_quest, exp_log,
                   created_at, updated_at
            FROM pa_attendees) a
    ), '[]'::jsonb),
    'questions', COALESCE((
      SELECT jsonb_agg(to_jsonb(q) ORDER BY q.id DESC)
      FROM (SELECT id, attendee_name, team, question, is_anonymous, created_at FROM pa_questions) q
    ), '[]'::jsonb),
    'summary', jsonb_build_object(
      'attendees_count',  (SELECT COUNT(*) FROM pa_attendees),
      'questions_count',  (SELECT COUNT(*) FROM pa_questions),
      'octalysis_count',  (SELECT COUNT(*) FROM pa_attendees WHERE octalysis_design IS NOT NULL),
      'quest_count',      (SELECT COUNT(*) FROM pa_attendees WHERE group_quest IS NOT NULL),
      'teams', (SELECT jsonb_agg(DISTINCT team) FROM pa_attendees WHERE team IS NOT NULL AND team <> '')
    )
  ) INTO result;

  RETURN result;
END;
$$;

REVOKE ALL ON FUNCTION public.pa_admin_stats(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.pa_admin_stats(text) TO anon;

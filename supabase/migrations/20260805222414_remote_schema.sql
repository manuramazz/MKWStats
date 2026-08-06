-- Migration unit 1: schema_changes
-- Transaction mode: transactional
-- Boundary reason: default

SET check_function_bodies = false;

DROP EXTENSION pg_net;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT DELETE, INSERT, SELECT, UPDATE ON TABLES TO anon;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT, USAGE ON SEQUENCES TO anon;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON ROUTINES TO anon;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT DELETE, INSERT, SELECT, UPDATE ON TABLES TO authenticated;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT, USAGE ON SEQUENCES TO authenticated;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON ROUTINES TO authenticated;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT DELETE, INSERT, SELECT, UPDATE ON TABLES TO service_role;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT, USAGE ON SEQUENCES TO service_role;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON ROUTINES TO service_role;

CREATE SEQUENCE public.tracks_id_seq AS integer;

CREATE SEQUENCE public.world_records_id_seq AS integer;

CREATE FUNCTION public.handle_new_user()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'public'
  AS $function$
begin
  insert into public.profiles (id, username)
  values (new.id, new.raw_user_meta_data ->> 'username');
  return new;
end;
$function$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

GRANT ALL ON FUNCTION public.handle_new_user() TO anon;

GRANT ALL ON FUNCTION public.handle_new_user() TO authenticated;

GRANT ALL ON FUNCTION public.handle_new_user() TO service_role;

CREATE TABLE public.online_sessions (
  id           uuid                     DEFAULT gen_random_uuid() NOT NULL,
  user_id      uuid                     NOT NULL,
  session_date timestamp with time zone DEFAULT now() NOT NULL,
  rating_start integer                  NOT NULL,
  rating_end   integer                  NOT NULL,
  notes        text,
  created_at   timestamp with time zone DEFAULT now() NOT NULL,
  duration     integer
);

ALTER TABLE public.online_sessions
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.online_sessions
  ADD CONSTRAINT online_sessions_pkey PRIMARY KEY (id);

ALTER TABLE public.online_sessions
  ADD CONSTRAINT online_sessions_rating_end_check CHECK (rating_end >= 0);

ALTER TABLE public.online_sessions
  ADD CONSTRAINT online_sessions_rating_start_check CHECK (rating_start >= 0);

GRANT ALL ON public.online_sessions TO anon;

GRANT ALL ON public.online_sessions TO authenticated;

GRANT ALL ON public.online_sessions TO service_role;

CREATE INDEX online_sessions_user_idx ON public.online_sessions (user_id);

CREATE POLICY online_sessions_delete_own ON public.online_sessions
  FOR DELETE
  USING ((auth.uid() = user_id));

CREATE POLICY online_sessions_insert_own ON public.online_sessions
  FOR INSERT
  WITH CHECK ((auth.uid() = user_id));

CREATE POLICY online_sessions_select_own ON public.online_sessions
  FOR SELECT
  USING ((auth.uid() = user_id));

CREATE POLICY online_sessions_update_own ON public.online_sessions
  FOR UPDATE
  USING ((auth.uid() = user_id))
  WITH CHECK ((auth.uid() = user_id));

CREATE TABLE public.personal_times (
  id          uuid                     DEFAULT gen_random_uuid() NOT NULL,
  user_id     uuid                     NOT NULL,
  track_id    integer                  NOT NULL,
  time_ms     integer                  NOT NULL,
  record_date date                     DEFAULT CURRENT_DATE NOT NULL,
  video_url   text,
  created_at  timestamp with time zone DEFAULT now() NOT NULL,
  notes       text
);

ALTER TABLE public.personal_times
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.personal_times
  ADD CONSTRAINT personal_times_pkey PRIMARY KEY (id);

ALTER TABLE public.personal_times
  ADD CONSTRAINT personal_times_time_ms_check CHECK (time_ms > 0);

GRANT ALL ON public.personal_times TO anon;

GRANT ALL ON public.personal_times TO authenticated;

GRANT ALL ON public.personal_times TO service_role;

CREATE INDEX personal_times_user_track_idx ON public.personal_times (user_id, track_id);

CREATE POLICY personal_times_delete_own ON public.personal_times
  FOR DELETE
  USING ((auth.uid() = user_id));

CREATE POLICY personal_times_insert_own ON public.personal_times
  FOR INSERT
  WITH CHECK ((auth.uid() = user_id));

CREATE POLICY personal_times_select_own ON public.personal_times
  FOR SELECT
  USING ((auth.uid() = user_id));

CREATE POLICY personal_times_update_own ON public.personal_times
  FOR UPDATE
  USING ((auth.uid() = user_id))
  WITH CHECK ((auth.uid() = user_id));

CREATE TABLE public.profiles (
  id         uuid                     NOT NULL,
  username   text                     NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE public.profiles
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);

ALTER TABLE public.online_sessions
  ADD CONSTRAINT online_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.personal_times
  ADD CONSTRAINT personal_times_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_username_key UNIQUE (username);

GRANT ALL ON public.profiles TO anon;

GRANT ALL ON public.profiles TO authenticated;

GRANT ALL ON public.profiles TO service_role;

CREATE POLICY profiles_select_own ON public.profiles
  FOR SELECT
  USING ((auth.uid() = id));

CREATE POLICY profiles_update_own ON public.profiles
  FOR UPDATE
  USING ((auth.uid() = id))
  WITH CHECK ((auth.uid() = id));

CREATE TABLE public.tracks (
  id          integer DEFAULT nextval('public.tracks_id_seq'::regclass) NOT NULL,
  name        text    NOT NULL,
  track_order integer NOT NULL,
  cup         text
);

ALTER SEQUENCE public.tracks_id_seq OWNED BY public.tracks.id;

GRANT ALL ON SEQUENCE public.tracks_id_seq TO anon;

GRANT ALL ON SEQUENCE public.tracks_id_seq TO authenticated;

GRANT ALL ON SEQUENCE public.tracks_id_seq TO service_role;

ALTER TABLE public.tracks
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.tracks
  ADD CONSTRAINT tracks_name_key UNIQUE (name);

ALTER TABLE public.tracks
  ADD CONSTRAINT tracks_pkey PRIMARY KEY (id);

ALTER TABLE public.personal_times
  ADD CONSTRAINT personal_times_track_id_fkey FOREIGN KEY (track_id) REFERENCES public.tracks(id) ON DELETE CASCADE;

ALTER TABLE public.tracks
  ADD CONSTRAINT tracks_track_order_key UNIQUE (track_order);

GRANT ALL ON public.tracks TO anon;

GRANT ALL ON public.tracks TO authenticated;

GRANT ALL ON public.tracks TO service_role;

CREATE POLICY tracks_select_all ON public.tracks
  FOR SELECT
  USING (true);

CREATE TABLE public.world_records (
  id          integer                  DEFAULT nextval('public.world_records_id_seq'::regclass) NOT NULL,
  track_id    integer                  NOT NULL,
  player_name text                     NOT NULL,
  time_ms     integer                  NOT NULL,
  record_date date                     NOT NULL,
  video_url   text,
  updated_at  timestamp with time zone DEFAULT now() NOT NULL
);

ALTER SEQUENCE public.world_records_id_seq OWNED BY public.world_records.id;

GRANT ALL ON SEQUENCE public.world_records_id_seq TO anon;

GRANT ALL ON SEQUENCE public.world_records_id_seq TO authenticated;

GRANT ALL ON SEQUENCE public.world_records_id_seq TO service_role;

ALTER TABLE public.world_records
  ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.world_records
  ADD CONSTRAINT world_records_pkey PRIMARY KEY (id);

ALTER TABLE public.world_records
  ADD CONSTRAINT world_records_time_ms_check CHECK (time_ms > 0);

ALTER TABLE public.world_records
  ADD CONSTRAINT world_records_track_id_fkey FOREIGN KEY (track_id) REFERENCES public.tracks(id) ON DELETE CASCADE;

ALTER TABLE public.world_records
  ADD CONSTRAINT world_records_track_id_key UNIQUE (track_id);

GRANT ALL ON public.world_records TO anon;

GRANT ALL ON public.world_records TO authenticated;

GRANT ALL ON public.world_records TO service_role;

CREATE POLICY world_records_select_all ON public.world_records
  FOR SELECT
  USING (true);

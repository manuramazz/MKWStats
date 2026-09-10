-- Migration unit 1: schema_changes
-- Transaction mode: transactional
-- Boundary reason: default

SET check_function_bodies = false;

CREATE OR REPLACE FUNCTION public.handle_new_user()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'public'
  AS $function$
begin
  insert into public.profiles (id, username)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'username', split_part(new.email, '@', 1))
  );
  return new;
end;
$function$;

ALTER TABLE public.tracks
  ADD COLUMN track_img text;

ALTER TABLE public.tracks
  ADD COLUMN cup_img text;

ALTER TABLE public.world_records
  ADD COLUMN "character" text;

ALTER TABLE public.world_records
  ADD COLUMN kart text;

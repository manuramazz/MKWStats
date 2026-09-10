create or replace function public.is_username_taken(check_username text)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (select 1 from public.profiles where username = check_username);
$$;

grant execute on function public.is_username_taken(text) to anon, authenticated;

-- Who wants to do a suggested activity or meal.
-- Run this in the Supabase SQL editor. The site keeps working on this
-- phone if the table is not there yet; other phones see the names after this runs.

create table if not exists public.activity_interest (
  activity_id text not null,
  person_id text not null,
  created_at timestamptz not null default now(),
  primary key (activity_id, person_id)
);

alter table public.activity_interest enable row level security;

drop policy if exists "activity interest is readable" on public.activity_interest;
create policy "activity interest is readable"
  on public.activity_interest
  for select
  to anon, authenticated
  using (true);

drop policy if exists "activity interest is writable" on public.activity_interest;
create policy "activity interest is writable"
  on public.activity_interest
  for insert
  to anon, authenticated
  with check (true);

drop policy if exists "activity interest is removable" on public.activity_interest;
create policy "activity interest is removable"
  on public.activity_interest
  for delete
  to anon, authenticated
  using (true);

grant select, insert, delete on table public.activity_interest to anon, authenticated;

do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    begin
      alter publication supabase_realtime add table public.activity_interest;
    exception
      when duplicate_object then
        null;
    end;
  end if;
end $$;

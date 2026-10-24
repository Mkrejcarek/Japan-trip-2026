-- Shared reminders for the Japan 2026 trip hub.
-- Run this once in the Supabase SQL editor.
-- A reminder added on one phone shows up for everyone else.
-- The site still stores a reminder on this phone if the table is not there yet.

create table if not exists public.reminders (
  id text primary key,
  person text not null,
  body text not null,
  created_at timestamptz not null default now(),
  constraint reminders_person_not_blank check (char_length(btrim(person)) > 0),
  constraint reminders_person_len check (char_length(person) <= 80),
  constraint reminders_body_not_blank check (char_length(btrim(body)) > 0),
  constraint reminders_body_len check (char_length(body) <= 240)
);

alter table public.reminders enable row level security;
alter table public.reminders replica identity full;

drop policy if exists "reminders_select" on public.reminders;
drop policy if exists "reminders_insert" on public.reminders;
drop policy if exists "reminders_delete" on public.reminders;

create policy "reminders_select"
  on public.reminders
  for select
  to anon, authenticated
  using (true);

create policy "reminders_insert"
  on public.reminders
  for insert
  to anon, authenticated
  with check (true);

create policy "reminders_delete"
  on public.reminders
  for delete
  to anon, authenticated
  using (true);

grant select, insert, delete on table public.reminders to anon, authenticated;

do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    begin
      alter publication supabase_realtime add table public.reminders;
    exception
      when duplicate_object then
        null;
    end;
  end if;
end $$;

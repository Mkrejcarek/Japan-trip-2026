-- Per-person packing lists for the Japan 2026 trip hub.
-- Run this once in the Supabase SQL editor after packing.sql.
--
-- Each traveler gets their own rows. Adding, editing, or removing an item
-- changes that person's list only. The shared packing_items rows stay the
-- starting list. Checkmarks stay on each phone and are not stored here.
-- Anyone who can open the public site and pick a name can change that list.

create table if not exists public.packing_personal (
  id text primary key,
  person text not null,
  category text not null,
  name text not null,
  note text not null default '',
  position integer not null default 0,
  source_id text,
  constraint packing_personal_person_not_blank check (char_length(btrim(person)) > 0),
  constraint packing_personal_person_len check (char_length(person) <= 80),
  constraint packing_personal_category_not_blank check (char_length(btrim(category)) > 0),
  constraint packing_personal_category_len check (char_length(category) <= 80),
  constraint packing_personal_name_not_blank check (char_length(btrim(name)) > 0),
  constraint packing_personal_name_len check (char_length(name) <= 160),
  constraint packing_personal_note_len check (char_length(note) <= 400)
);

create index if not exists packing_personal_person_idx
  on public.packing_personal (person, position);

alter table public.packing_personal enable row level security;
alter table public.packing_personal replica identity full;

drop policy if exists "packing_personal_select" on public.packing_personal;
drop policy if exists "packing_personal_insert" on public.packing_personal;
drop policy if exists "packing_personal_update" on public.packing_personal;
drop policy if exists "packing_personal_delete" on public.packing_personal;

create policy "packing_personal_select"
  on public.packing_personal
  for select
  to anon, authenticated
  using (true);

create policy "packing_personal_insert"
  on public.packing_personal
  for insert
  to anon, authenticated
  with check (true);

create policy "packing_personal_update"
  on public.packing_personal
  for update
  to anon, authenticated
  using (true)
  with check (true);

create policy "packing_personal_delete"
  on public.packing_personal
  for delete
  to anon, authenticated
  using (true);

grant select, insert, update, delete on table public.packing_personal to anon, authenticated;

do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    begin
      alter publication supabase_realtime add table public.packing_personal;
    exception
      when duplicate_object then
        null;
    end;
  end if;
end $$;

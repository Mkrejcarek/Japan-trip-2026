-- Shared packing suggestions for the Japan 2026 trip hub.
-- Run this once in the Supabase SQL editor.
--
-- The page uses the anon public key. Anyone who can open the public site
-- can add, edit, and remove suggestions. Checkmarks stay on each phone
-- and are not stored here.
-- Do not put the service_role key in the page.

create table if not exists public.packing_items (
  id text primary key,
  category text not null,
  name text not null,
  note text not null default '',
  position integer not null default 0,
  constraint packing_items_category_not_blank check (char_length(btrim(category)) > 0),
  constraint packing_items_category_len check (char_length(category) <= 80),
  constraint packing_items_name_not_blank check (char_length(btrim(name)) > 0),
  constraint packing_items_name_len check (char_length(name) <= 160),
  constraint packing_items_note_len check (char_length(note) <= 400)
);

alter table public.packing_items enable row level security;
alter table public.packing_items replica identity full;

drop policy if exists "packing_items_select" on public.packing_items;
drop policy if exists "packing_items_insert" on public.packing_items;
drop policy if exists "packing_items_update" on public.packing_items;
drop policy if exists "packing_items_delete" on public.packing_items;

create policy "packing_items_select"
  on public.packing_items
  for select
  to anon, authenticated
  using (true);

create policy "packing_items_insert"
  on public.packing_items
  for insert
  to anon, authenticated
  with check (true);

create policy "packing_items_update"
  on public.packing_items
  for update
  to anon, authenticated
  using (true)
  with check (true);

create policy "packing_items_delete"
  on public.packing_items
  for delete
  to anon, authenticated
  using (true);

grant select, insert, update, delete on table public.packing_items to anon, authenticated;

insert into public.packing_items (id, category, name, note, position) values
  ('gp-1', '🛂 Documents, Passes & Entry', 'Valid Passports ( + Backup Copy in Shared Google Drive)', 'Carry physical passport at all times in Japan for tax-free shopping & train pass checks.', 100),
  ('gp-2', '🛂 Documents, Passes & Entry', 'Physical Student ID Cards (For Rose, Ella, Myles, Mary, Francis, James Timothy)', 'Saves ~$15/student for FREE entry at Himeji Castle on 11/20.', 101),
  ('gp-3', '🛂 Documents, Passes & Entry', 'Visit Japan Web QR Codes (Immigration & Customs)', 'Screenshot QR codes for offline arrival at KIX on 11/19.', 102),
  ('gp-4', '🛂 Documents, Passes & Entry', 'JR Pass Exchange Orders & IC Transit Cards (Suica / Pasmo)', 'Kids 11 & under (Francis 11, James Timothy 9) qualify for 50% off Child fares!', 103),
  ('gp-5', '🛂 Documents, Passes & Entry', 'Japanese Yen Cash (¥) + No-Foreign-Fee Credit Cards', 'Cash needed for 11/21 Miyajima ferry dock, Otemae Park food stalls, and temple entries.', 104),
  ('gp-6', '🎒 Smart Luggage Strategy (Crucial for 11/20–11/22)', 'Packable 2-Night Duffle / Backpack (For Hiroshima & Miyajima)', 'On 11/20 AM, ship heavy suitcases from Hilton Osaka to Hilton Garden Inn Kyoto. Take only a 2-night bag to Himeji/Hiroshima/Miyajima!', 200),
  ('gp-7', '🎒 Smart Luggage Strategy (Crucial for 11/20–11/22)', 'Luggage AirTags & Color-Coded Straps', 'Makes spotting our 15-person group bags easy on the Hotel Makoto van (11/21) & Shinkansen racks.', 201),
  ('gp-8', '🎒 Smart Luggage Strategy (Crucial for 11/20–11/22)', 'Packable Tote Bag for Souvenirs / Kojima Jeans / Ginza', 'Great for carrying denim from Kojima (11/20) or Tokyo shopping (11/25–11/26).', 202),
  ('gp-9', '🧥 Late-November Clothing & Activity Gear', 'Broken-In Slip-On Walking Shoes (15,000–20,000 steps/day)', 'Easy slip-on/off for Himeji Castle, tea ceremonies, and hotel lobbies.', 300),
  ('gp-10', '🧥 Late-November Clothing & Activity Gear', 'Warm Crew Socks (No holes!)', 'Himeji Castle (11/20) and tea ceremonies require removing shoes on cold wooden/tatami floors.', 301),
  ('gp-11', '🧥 Late-November Clothing & Activity Gear', 'Pants/Shorts That Roll Above the Knee (For TeamLab Planets Tokyo)', 'TeamLab Planets (11/25) has knee-deep water rooms and mirrored floors.', 302),
  ('gp-12', '🧥 Late-November Clothing & Activity Gear', 'Packable Down Jacket + Breathable Layers', 'Late November is 45°F–62°F outside (chilly in Hakone mountains & Miyajima ferry), but trains are warmly heated.', 303),
  ('gp-13', '🧥 Late-November Clothing & Activity Gear', 'Soft Baby Carrier for Olive (No Strollers in Himeji Castle)', 'Required for steep stairs inside Himeji Castle (11/20), Miyajima Tea Ceremony (11/21), and Fushimi Inari.', 304),
  ('gp-14', '🔌 Tech, Power & Daily Essentials', 'Portable Power Bank (10,000–20,000mAh) + Cables', 'Essential for Google Maps, WhatsApp group coordination, and photos all day.', 400),
  ('gp-15', '🔌 Tech, Power & Daily Essentials', '2-Prong (Type A) Multi-Port Wall Charger per Room', 'Japan uses standard US 2-prong flat plugs.', 401),
  ('gp-16', '🔌 Tech, Power & Daily Essentials', 'Small Trash Bag + Pocket Hand Towel / Sanitizer', 'Public trash cans are rare in Japan, and many public restrooms do not have paper towels.', 402)
on conflict (id) do nothing;

do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    begin
      alter publication supabase_realtime add table public.packing_items;
    exception
      when duplicate_object then
        null;
    end;
  end if;
end $$;

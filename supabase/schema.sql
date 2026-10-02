create table categories (
  id bigint generated always as identity primary key,
  name text not null,
  description text not null default '',
  active boolean not null default true,
  created_at timestamptz not null default now()
);
create table items (
  id bigint generated always as identity primary key,
  category_id bigint not null references categories(id),
  finder_name text not null,
  title text not null,
  description text not null,
  contact text not null,
  image_path text,
  status smallint not null default 0 check (status in (0,1,2)), -- 0 pending, 1 published, 2 claimed
  created_at timestamptz not null default now()
);
create table inquiries (
  id bigint generated always as identity primary key,
  fullname text not null,
  contact text not null,
  email text not null,
  message text not null,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);
create table site_settings (key text primary key, value text not null);
create table admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'staff' check (role in ('admin','staff'))
);

create function is_staff() returns boolean language sql security definer set search_path = public stable
  as $$ select exists (select 1 from admins where user_id = auth.uid()) $$;
create function is_admin() returns boolean language sql security definer set search_path = public stable
  as $$ select exists (select 1 from admins where user_id = auth.uid() and role = 'admin') $$;

alter table categories enable row level security;
alter table items enable row level security;
alter table inquiries enable row level security;
alter table site_settings enable row level security;
alter table admins enable row level security;

create policy "public reads active categories" on categories for select using (active or is_staff());
create policy "admins manage categories" on categories for all using (is_admin()) with check (is_admin());

create policy "public reads published items" on items for select using (status = 1 or is_staff());
create policy "anyone submits pending items" on items for insert with check (status = 0);
create policy "staff update items" on items for update using (is_staff()) with check (is_staff());
create policy "staff delete items" on items for delete using (is_staff());

create policy "anyone sends inquiries" on inquiries for insert with check (is_read = false);
create policy "staff read inquiries" on inquiries for select using (is_staff());
create policy "staff update inquiries" on inquiries for update using (is_staff());
create policy "staff delete inquiries" on inquiries for delete using (is_staff());

create policy "public reads settings" on site_settings for select using (true);
create policy "admins write settings" on site_settings for all using (is_admin()) with check (is_admin());

create policy "staff read own role" on admins for select using (user_id = auth.uid());

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('items', 'items', true, 3145728, array['image/jpeg','image/png','image/webp']);
create policy "anyone uploads item images" on storage.objects for insert with check (bucket_id = 'items');
create policy "staff delete item images" on storage.objects for delete using (bucket_id = 'items' and is_staff());

insert into categories (name, description) values ('Mobile Phones',''),('Keys',''),('Watches',''),('Bags & Wallets',''),('Other','');
insert into site_settings (key, value) values
  ('name','Lost and Found'),('phone','903-436-9356'),('email','info@simpleorganization.org'),
  ('address','4226 Florence Street, Arlington, Texas, 76011');

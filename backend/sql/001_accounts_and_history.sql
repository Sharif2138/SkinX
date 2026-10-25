create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  account_type text not null default 'individual'
    check (account_type in ('individual', 'chw')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.screening_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  client_record_id text not null,
  result text not null check (result in ('Suspicious', 'Less suspicious')),
  created_at timestamptz not null default now(),
  unique (user_id, client_record_id)
);

create index if not exists screening_records_user_time
  on public.screening_records (user_id, created_at desc);

alter table public.profiles enable row level security;
alter table public.screening_records enable row level security;

revoke all on public.profiles from anon;
revoke all on public.screening_records from anon;
grant select, insert on public.profiles to authenticated;
grant update (full_name, account_type) on public.profiles to authenticated;
grant select, insert, delete on public.screening_records to authenticated;

drop policy if exists "Read own profile" on public.profiles;
create policy "Read own profile"
  on public.profiles for select to authenticated
  using ((select auth.uid()) = id);
drop policy if exists "Insert own profile" on public.profiles;
create policy "Insert own profile"
  on public.profiles for insert to authenticated
  with check ((select auth.uid()) = id);
drop policy if exists "Update own profile" on public.profiles;
create policy "Update own profile"
  on public.profiles for update to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

drop policy if exists "Read own screening records" on public.screening_records;
create policy "Read own screening records"
  on public.screening_records for select to authenticated
  using ((select auth.uid()) = user_id);
drop policy if exists "Insert own screening records" on public.screening_records;
create policy "Insert own screening records"
  on public.screening_records for insert to authenticated
  with check ((select auth.uid()) = user_id);
drop policy if exists "Delete own screening records" on public.screening_records;
create policy "Delete own screening records"
  on public.screening_records for delete to authenticated
  using ((select auth.uid()) = user_id);

create or replace function public.create_skinx_profile()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name, account_type)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    case
      when new.raw_user_meta_data->>'account_type' in ('individual', 'chw')
        then new.raw_user_meta_data->>'account_type'
      when new.raw_user_meta_data->>'role' = 'communityHealthWorker' then 'chw'
      else 'individual' end
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_skinx_user_created on auth.users;
create trigger on_skinx_user_created
  after insert on auth.users
  for each row execute function public.create_skinx_profile();

insert into public.profiles (id, full_name, account_type)
select id, coalesce(raw_user_meta_data->>'full_name', ''),
  case
    when raw_user_meta_data->>'account_type' in ('individual', 'chw') then raw_user_meta_data->>'account_type'
    when raw_user_meta_data->>'role' = 'communityHealthWorker' then 'chw'
    else 'individual' end
from auth.users
on conflict (id) do nothing;

alter table public.screening_records
  add column if not exists patient_name text;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conrelid = 'public.screening_records'::regclass
      and conname = 'screening_patient_name_length'
  ) then
    alter table public.screening_records
      add constraint screening_patient_name_length
        check (patient_name is null or char_length(btrim(patient_name)) between 1 and 120);
  end if;
end;
$$;

create or replace function public.validate_screening_patient_name()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  profile_type text;
begin
  select p.account_type into profile_type
  from public.profiles p
  where p.id = new.user_id;

  if profile_type is null then
    raise exception 'Screening account profile was not found.';
  end if;

  if profile_type = 'chw' then
    if new.patient_name is null or btrim(new.patient_name) = '' then
      raise exception 'A patient name is required for community health worker screenings.';
    end if;
    new.patient_name := btrim(new.patient_name);
  else
    if new.patient_name is not null then
      raise exception 'Individual screening records cannot contain patient names.';
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists validate_screening_patient_name on public.screening_records;
create trigger validate_screening_patient_name
  before insert or update of patient_name, user_id
  on public.screening_records
  for each row execute function public.validate_screening_patient_name();

create or replace function public.prevent_role_change_after_screening()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.account_type is distinct from old.account_type and exists (
    select 1 from public.screening_records where user_id = old.id
  ) then
    raise exception 'Account type cannot change after screening records have been saved.';
  end if;
  return new;
end;
$$;

drop trigger if exists prevent_role_change_after_screening on public.profiles;
create trigger prevent_role_change_after_screening
  before update of account_type
  on public.profiles
  for each row execute function public.prevent_role_change_after_screening();

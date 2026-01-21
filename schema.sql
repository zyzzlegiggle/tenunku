-- Create profiles table
create table public.profiles (
  id uuid references auth.users not null primary key,
  full_name text,
  username text unique,
  shop_name text,
  phone text,
  role text,
  avatar_url text,
  banner_url text,
  bio text,       -- Short header description
  description text, -- "Kisah"
  hope text,
  daily_activity text,
  age int,
  birth_date date, -- Added
  nik text,        -- Added
  shop_address text, -- Added
  shop_description text, -- Added
  updated_at timestamp with time zone default timezone('utc'::text, now())
);

-- Enable RLS on profiles
alter table public.profiles enable row level security;

-- Create profiles policy
create policy "Public profiles are viewable by everyone."
  on profiles for select
  using ( true );

create policy "Users can insert their own profile."
  on profiles for insert
  with check ( auth.uid() = id );

create policy "Users can update own profile."
  on profiles for update
  using ( auth.uid() = id );

-- Create products table
create table public.products (
  id uuid default gen_random_uuid() primary key,
  seller_id uuid references public.profiles(id) not null,
  name text not null,
  description text,
  price numeric not null,
  image_url text,
  category text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS on products
alter table public.products enable row level security;

-- Create products policy
create policy "Products are viewable by everyone."
  on products for select
  using ( true );

create policy "Sellers can insert their own products."
  on products for insert
  with check ( auth.uid() = seller_id );

create policy "Sellers can update their own products."
  on products for update
  using ( auth.uid() = seller_id );
  
create policy "Sellers can delete their own products."
  on products for delete
  using ( auth.uid() = seller_id );

-- Trigger to create profile on signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (
    id, 
    full_name, 
    phone, 
    role, 
    username, 
    birth_date, 
    nik
  )
  values (
    new.id,
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'phone',
    new.raw_user_meta_data->>'role',
    new.raw_user_meta_data->>'username',
    (new.raw_user_meta_data->>'birth_date')::date,
    new.raw_user_meta_data->>'nik'
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

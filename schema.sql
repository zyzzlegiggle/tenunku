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
  stock int default 0,
  sold_count int default 0,
  view_count int default 0,
  average_rating numeric default 0,
  total_reviews int default 0,
  color_meaning text,
  pattern_meaning text,
  usage text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create reviews table
create table public.reviews (
  id uuid default gen_random_uuid() primary key,
  product_id uuid references public.products(id) not null,
  user_id uuid references public.profiles(id) not null,
  rating int check (rating >= 1 and rating <= 5),
  comment text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS on reviews
alter table public.reviews enable row level security;

-- Create reviews policies
create policy "Reviews are viewable by everyone."
  on reviews for select
  using ( true );

create policy "Authenticated users can create reviews."
  on reviews for insert
  with check ( auth.role() = 'authenticated' );

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

-- Create orders table
create table public.orders (
  id uuid default gen_random_uuid() primary key,
  buyer_id uuid references public.profiles(id) not null,
  seller_id uuid references public.profiles(id) not null,
  product_id uuid references public.products(id) not null,
  quantity int default 1 not null,
  total_price numeric not null,
  status text default 'pending' not null, -- pending (Masuk), shipping (Dikirim), completed (Diterima), cancelled (Ditolak)
  tracking_number text,
  shipping_evidence_url text,
  rejection_reason text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now())
);

-- Enable RLS on orders
alter table public.orders enable row level security;

-- Create orders policies
create policy "Users can view their own orders (as buyer or seller)."
  on orders for select
  using ( auth.uid() = buyer_id or auth.uid() = seller_id );

create policy "Buyers can create orders."
  on orders for insert
  with check ( auth.uid() = buyer_id );

create policy "Sellers can update orders assigned to them."
  on orders for update
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

-- Make shop_name unique to allow login by shop name
alter table public.profiles add constraint profiles_shop_name_key unique (shop_name);

-- Function to get email by identity (username or shop_name)
-- SECURITY DEFINER allows this function to access tables even if RLS would normally block it
-- But here we are just querying public.profiles which is effectively public, 
-- however we need to join with auth.users to get the email, which IS restricted.
-- So we definitely need SECURITY DEFINER to read auth.users.email.
create or replace function public.get_email_by_identity(
  p_username text default null, 
  p_shop_name text default null
)
returns text
language plpgsql
security definer
set search_path = public, auth 
as $$
declare
  v_email text;
begin
  if p_username is not null then
    select u.email into v_email
    from auth.users u
    join public.profiles p on p.id = u.id
    where p.username = p_username;
  elsif p_shop_name is not null then
    select u.email into v_email
    from auth.users u
    join public.profiles p on p.id = u.id
    where p.shop_name = p_shop_name;
  end if;
  
  return v_email;
end;
$$;

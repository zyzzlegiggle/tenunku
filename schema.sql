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
  image_urls text[],
  category text,
  stock int default 0,
  sold_count int default 0,
  view_count int default 0,
  average_rating numeric default 0,
  total_reviews int default 0,
  color_meaning text, -- Legacy, keeping for now
  pattern_meaning text, -- Legacy
  usage text, -- Legacy
  pattern_id uuid references public.benang_patterns(id), -- New Benang Membumi
  color_id uuid references public.benang_colors(id),     -- New Benang Membumi
  usage_id uuid references public.benang_usages(id),     -- New Benang Membumi
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create reviews table
create table public.reviews (
  id uuid default gen_random_uuid() primary key,
  product_id uuid references public.products(id) not null,
  user_id uuid references public.profiles(id) not null,
  order_id uuid references public.orders(id),  -- Link review to specific order
  rating int check (rating >= 1 and rating <= 5),
  comment text,
  image_url text,  -- Photo review support for "Dengan Foto" filter
  video_url text,  -- Video review support
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

-- Create conversations table for chat feature
create table public.conversations (
  id uuid default gen_random_uuid() primary key,
  buyer_id uuid references public.profiles(id) not null,
  seller_id uuid references public.profiles(id) not null,
  last_message text,
  last_message_at timestamp with time zone default timezone('utc'::text, now()),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(buyer_id, seller_id)
);

-- Create messages table
create table public.messages (
  id uuid default gen_random_uuid() primary key,
  conversation_id uuid references public.conversations(id) not null,
  sender_id uuid references public.profiles(id) not null,
  content text not null,
  is_read boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS on conversations
alter table public.conversations enable row level security;

-- Enable RLS on messages
alter table public.messages enable row level security;

-- Conversation policies
-- Allow users to insert if they are either the buyer OR the seller in the new row
create policy "Users can create conversations."
  on conversations for insert
  with check (auth.uid() = buyer_id or auth.uid() = seller_id);

-- Allow users to view if they are participant
create policy "Users can view their own conversations."
  on conversations for select
  using (auth.uid() = buyer_id or auth.uid() = seller_id);

-- Allow users to update (e.g. last_message) if participant
create policy "Users can update their own conversations."
  on conversations for update
  using (auth.uid() = buyer_id or auth.uid() = seller_id);

-- Message policies
-- Allow insert if user is sender AND they are part of the conversation
create policy "Users can send messages to their conversations."
  on messages for insert
  with check (
    auth.uid() = sender_id and
    exists (
      select 1 from conversations c 
      where c.id = messages.conversation_id 
      and (c.buyer_id = auth.uid() or c.seller_id = auth.uid())
    )
  );

-- Allow view if participant in conversation
create policy "Users can view messages in their conversations."
  on messages for select
  using (
    exists (
      select 1 from conversations c 
      where c.id = conversation_id 
      and (c.buyer_id = auth.uid() or c.seller_id = auth.uid())
    )
  );

-- Allow update own messages
create policy "Users can update their own messages."
  on messages for update
  using (auth.uid() = sender_id);

-- Create favorites table for "Favorit Saya" feature
create table public.favorites (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) not null,
  product_id uuid references public.products(id) not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(user_id, product_id)
);

-- Enable RLS on favorites
alter table public.favorites enable row level security;

-- Favorites policies
create policy "Users can view their own favorites."
  on favorites for select
  using (auth.uid() = user_id);

create policy "Users can add favorites."
  on favorites for insert
  with check (auth.uid() = user_id);

create policy "Users can remove their own favorites."
  on favorites for delete
  using (auth.uid() = user_id);

-- Create recently_viewed table for "Terakhir Dilihat" feature
create table public.recently_viewed (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) not null,
  product_id uuid references public.products(id) not null,
  viewed_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(user_id, product_id)
);

-- Enable RLS on recently_viewed
alter table public.recently_viewed enable row level security;

-- Recently viewed policies
create policy "Users can view their own recently viewed."
  on recently_viewed for select
  using (auth.uid() = user_id);

create policy "Users can track viewed products."
  on recently_viewed for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own recently viewed."
  on recently_viewed for update
  using (auth.uid() = user_id);

create policy "Users can delete their own recently viewed."
  on recently_viewed for delete
  using (auth.uid() = user_id);

-- Create addresses table for multiple buyer addresses
create table public.addresses (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) not null,
  label text not null, -- e.g., "Rumah Bandung", "Kantor Bandung"
  recipient_name text not null,
  phone text not null,
  full_address text not null,
  is_primary boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now())
);

-- Enable RLS on addresses
alter table public.addresses enable row level security;

-- Addresses policies
create policy "Users can view their own addresses."
  on addresses for select
  using (auth.uid() = user_id);

create policy "Users can create their own addresses."
  on addresses for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own addresses."
  on addresses for update
  using (auth.uid() = user_id);

create policy "Users can delete their own addresses."
  on addresses for delete
  using (auth.uid() = user_id);

-- Create user_settings table for preferences like language
create table public.user_settings (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) not null unique,
  language text default 'id', -- 'id' for Indonesian, 'en' for English
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now())
);

-- Enable RLS on user_settings
alter table public.user_settings enable row level security;

-- User settings policies
create policy "Users can view their own settings."
  on user_settings for select
  using (auth.uid() = user_id);

create policy "Users can create their own settings."
  on user_settings for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own settings."
  on user_settings for update
  using (auth.uid() = user_id);

-- Create cart_items table for shopping cart feature
create table public.cart_items (
  id uuid default gen_random_uuid() primary key,
  buyer_id uuid references public.profiles(id) not null,
  product_id uuid references public.products(id) not null,
  seller_id uuid references public.profiles(id) not null,
  quantity int default 1 not null check (quantity > 0),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()),
  unique(buyer_id, product_id)
);

-- Enable RLS on cart_items
alter table public.cart_items enable row level security;

-- Cart items policies
create policy "Users can view their own cart items."
  on cart_items for select
  using (auth.uid() = buyer_id);

create policy "Users can add items to their cart."
  on cart_items for insert
  with check (auth.uid() = buyer_id);

create policy "Users can update their own cart items."
  on cart_items for update
  using (auth.uid() = buyer_id);

create policy "Users can remove items from their cart."
  on cart_items for delete
  using (auth.uid() = buyer_id);

-- Functions to safely update product counters (bypassing RLS)
create or replace function public.increment_view_count(p_product_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.products
  set view_count = view_count + 1
  where id = p_product_id;
end;
$$;

create or replace function public.increment_sold_count(p_product_id uuid, p_quantity int)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.products
  set sold_count = sold_count + p_quantity
  where id = p_product_id;
end;
$$;

create or replace function public.decrement_stock(p_product_id uuid, p_quantity int)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.products
  set stock = stock - p_quantity
  where id = p_product_id;
end;
$$;

create or replace function public.update_product_rating(p_product_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_avg_rating numeric;
  v_total_reviews int;
begin
  -- Calculate new stats
  select coalesce(avg(rating), 0), count(*)
  into v_avg_rating, v_total_reviews
  from public.reviews
  where product_id = p_product_id;

  -- Update product
  update public.products
  set average_rating = v_avg_rating,
      total_reviews = v_total_reviews
  where id = p_product_id;
end;
$$;

-- BENANG MEMBUMI TABLES

-- Create benang_patterns table
create table public.benang_patterns (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  meaning text not null,
  image_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create benang_colors table
create table public.benang_colors (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  meaning text not null,
  hex_code text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create benang_usages table
create table public.benang_usages (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  meaning text not null,
  icon_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for Benang Membumi tables
alter table public.benang_patterns enable row level security;
alter table public.benang_colors enable row level security;
alter table public.benang_usages enable row level security;

-- Policies (Public read)
create policy "Patterns are viewable by everyone." on benang_patterns for select using (true);
create policy "Colors are viewable by everyone." on benang_colors for select using (true);
create policy "Usages are viewable by everyone." on benang_usages for select using (true);

-- Update products table to include references (This command is for reference, 
-- in a fresh schema these columns should be added to the create table public.products definition directly
-- but we append ALTER here for migration context if running sequentially)
-- alter table public.products add column pattern_id uuid references public.benang_patterns(id);
-- alter table public.products add column color_id uuid references public.benang_colors(id);
-- alter table public.products add column usage_id uuid references public.benang_usages(id);

ALTER TABLE public.profiles 
ADD COLUMN qris_url text;


-- 1. Add an expiry timestamp to the orders table
ALTER TABLE public.orders 
ADD COLUMN payment_expires_at timestamp with time zone;

-- 2. Create a database function that automatically calculates the expiry
-- time upon creation (for instance, setting it to 24 hours into the future)
CREATE OR REPLACE FUNCTION set_payment_expiration()
RETURNS trigger AS $$
BEGIN
  IF NEW.status = 'pending' AND NEW.payment_expires_at IS NULL THEN
    NEW.payment_expires_at := now() + interval '24 hours';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Set a trigger on the orders table to fire that logic automatically
CREATE TRIGGER tr_set_payment_expiration
BEFORE INSERT ON public.orders
FOR EACH ROW
EXECUTE FUNCTION set_payment_expiration();

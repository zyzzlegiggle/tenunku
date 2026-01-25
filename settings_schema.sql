-- Create user_settings table for storing preferences
create table public.user_settings (
  user_id uuid references public.profiles(id) not null primary key,
  language text default 'id',
  notification_preferences jsonb default '{"app": true, "email": true, "whatsapp": false, "surat": false, "orders": true, "chat": true}'::jsonb,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now())
);

-- Enable RLS
alter table public.user_settings enable row level security;

-- Policies
create policy "Users can view own settings" 
  on public.user_settings for select 
  using (auth.uid() = user_id);

create policy "Users can insert own settings" 
  on public.user_settings for insert 
  with check (auth.uid() = user_id);

create policy "Users can update own settings" 
  on public.user_settings for update 
  using (auth.uid() = user_id);

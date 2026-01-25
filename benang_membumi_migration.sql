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
  icon_url text, -- SVG or image URL
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS
alter table public.benang_patterns enable row level security;
alter table public.benang_colors enable row level security;
alter table public.benang_usages enable row level security;

-- Policies (Public read)
create policy "Patterns are viewable by everyone." on benang_patterns for select using (true);
create policy "Colors are viewable by everyone." on benang_colors for select using (true);
create policy "Usages are viewable by everyone." on benang_usages for select using (true);

-- Update products table to include references
alter table public.products add column pattern_id uuid references public.benang_patterns(id);
alter table public.products add column color_id uuid references public.benang_colors(id);
alter table public.products add column usage_id uuid references public.benang_usages(id);

-- Seeding some initial data (Optional, useful for testing)
insert into public.benang_colors (name, meaning, hex_code) values 
('Merah', 'Melambangkan keberanian dan semangat yang membara dalam kehidupan masyarakat adat.', '#FF0000'),
('Hitam', 'Melambangkan ketegasan, kekuatan bumi, dan perlindungan leluhur.', '#000000'),
('Putih', 'Melambangkan kesucian, kedamaian, dan spiritualitas.', '#FFFFFF');

insert into public.benang_patterns (name, meaning) values 
('Fauna', 'Motif hewan yang melambangkan hubungan harmonis manusia dengan alam liar.'),
('Flora', 'Motif tumbuhan yang menggambarkan kesuburan dan kehidupan yang terus tumbuh.'),
('Geometris', 'Garis-garis tegas yang melambangkan keteraturan dan keseimbangan hidup.');

insert into public.benang_usages (name, meaning) values 
('Harian', 'Cocok digunakan untuk kegiatan sehari-hari karena bahannya yang nyaman dan motif yang kasual.'),
('Adat', 'Digunakan khusus untuk upacara adat dan perayaan budaya sebagai simbol penghormatan.');

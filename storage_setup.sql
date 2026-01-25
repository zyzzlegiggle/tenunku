-- Create storage buckets
insert into storage.buckets (id, name, public)
values 
  ('products', 'products', true),
  ('avatars', 'avatars', true),
  ('shipping_evidence', 'shipping_evidence', true),
  ('reviews', 'reviews', true)
on conflict (id) do nothing;

-- Policy: Products are viewable by everyone
create policy "Products Images are viewable by everyone"
  on storage.objects for select
  using ( bucket_id = 'products' );

-- Policy: Sellers can upload product images
create policy "Authenticated users can upload product images"
  on storage.objects for insert
  with check ( bucket_id = 'products' and auth.role() = 'authenticated' );

-- Policy: Avatars are viewable by everyone
create policy "Avatar images are viewable by everyone"
  on storage.objects for select
  using ( bucket_id = 'avatars' );

-- Policy: Users can upload their own avatar
create policy "Users can upload their own avatar"
  on storage.objects for insert
  with check ( bucket_id = 'avatars' and auth.uid() = (storage.foldername(name))[1]::uuid );

-- Policy: Shipping evidence is viewable by everyone (or maybe restricted? sticking to public for simplicity as per code)
create policy "Shipping evidence is viewable by everyone"
  on storage.objects for select
  using ( bucket_id = 'shipping_evidence' );

-- Policy: Sellers can upload shipping evidence
create policy "Sellers can upload shipping evidence"
  on storage.objects for insert
  with check ( bucket_id = 'shipping_evidence' and auth.role() = 'authenticated' );

-- Policy: Reviews are viewable by everyone
create policy "Review images are viewable by everyone"
  on storage.objects for select
  using ( bucket_id = 'reviews' );

-- Policy: Buyers can upload review images
create policy "Buyers can upload review images"
  on storage.objects for insert
  with check ( bucket_id = 'reviews' and auth.role() = 'authenticated' );

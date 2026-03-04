-- Add sizes and variants columns to products table
ALTER TABLE public.products 
ADD COLUMN sizes text[] DEFAULT '{}',
ADD COLUMN variants text[] DEFAULT '{}';

-- Update cart_items to include selected size and variant
ALTER TABLE public.cart_items
ADD COLUMN selected_size text,
ADD COLUMN selected_variant text;

-- Update orders to include selected size and variant
ALTER TABLE public.orders
ADD COLUMN selected_size text,
ADD COLUMN selected_variant text;

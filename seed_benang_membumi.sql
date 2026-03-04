-- Clear existing data to avoid duplicates if re-running
truncate table public.benang_patterns cascade;
truncate table public.benang_colors cascade;
truncate table public.benang_usages cascade;

-- Seed Patterns
insert into public.benang_patterns (name, meaning) values 
('Suat Songket', 'Suat Songket merupakan salah satu motif yang paling banyak diproduksi dan dipasarkan saat ini. Motif ini lebih fleksibel dalam penggunaannya dibandingkan motif sakral.'),
('Adu Mancung', 'Motif Adu Mancung melambangkan keseimbangan antara wilayah Baduy Dalam dan Baduy Luar. Motif ini umumnya digunakan oleh laki-laki.'),
('Janggawari', 'Janggawari merupakan motif tertua dalam tradisi tenun Badui sekaligus yang paling rumit dan sakral.'),
('Poleng', 'Motif Poleng digunakan oleh perempuan dan memiliki variasi makna sesuai dengan jenisnya.');

-- Seed Usages (mapped 1:1 with patterns as per requirement)
insert into public.benang_usages (name, meaning) values 
('Suat Songket', 'Motif ini adalah salah satu yang paling terkenal dan fleksibel karena banyak diproduksi dan dipasarkan saat ini.'),
('Adu Mancung', 'Motif ini memiliki makna penting dalam kehidupan sosial Baduy, biasanya dipakai pada upacara adat besar seperti Kawalu, Seba, serta ritual pernikahan dan pertanian.'),
('Janggawari', 'Motif ini sangat sakral and secara tradisional hanya diperuntukkan bagi pemimpin adat tertinggi (Pu''un) karena proses pembuatannya disertai ritual khusus.'),
('Poleng', 'Motif Poleng identik dengan pola kotak-kotak dan umumnya digunakan oleh perempuan Baduy.');

-- Seed Colors
insert into public.benang_colors (name, meaning, hex_code) values 
('Biru', 'Warna biru berasal dari daun tarum, tanaman yang sejak lama digunakan sebagai pewarna tradisional.', '#39598E'),
('Kuning', 'Warna kuning diperoleh dari kayu nangka yang direbus hingga mengeluarkan pigmen alaminya.', '#FFE14F'),
('Coklat', 'Warna coklat pada tenun Badui berasal dari kulit kayu mahoni.', '#AE5715'),
('Merah', 'Warna merah dihasilkan dari kombinasi bahan alami tertentu dengan kulit kayu mahoni.', '#FA3030'),
('Hitam', 'Warna hitam diperoleh dari kulit buah jengkol yang diolah secara alami.', '#000000');

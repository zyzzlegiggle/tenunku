-- Delete existing data to avoid duplicates/confusion
DELETE FROM public.benang_colors;
DELETE FROM public.benang_patterns;
DELETE FROM public.benang_usages;

-- Correct seeding for benang_colors
INSERT INTO public.benang_colors (name, meaning, hex_code) VALUES 
('Warna Biru', 'Warna biru berasal dari <b>daun tarum</b>, tanaman yang sejak lama digunakan sebagai pewarna tradisional. Proses fermentasi daun tarum menghasilkan warna biru yang lembut dan alami. Warna Biru ini juga menjadi salah satu ciri khas dari masyarakat Badui disana.', '#39598E'),
('Warna Kuning', 'Warna kuning diperoleh dari <b>kayu nangka</b> yang direbus hingga mengeluarkan pigmen alaminya. Proses ini membutuhkan ketelatenan karena intensitas warna bergantung pada lama perendaman benang. Kuning dalam tenun Baduy sering memberi kesan cerah namun tetap alami.', '#FFE14F'),
('Warna Coklat', 'Warna coklat pada tenun Badui berasal dari <b>kulit kayu mahoni</b>. Pewarna alami ini diolah melalui proses perebusan hingga menghasilkan warna hangat yang khas. Warna ini mencerminkan kedekatan masyarakat Baduy dengan alam serta penggunaan sumber daya yang bijaksana.', '#AE5715'),
('Warna Merah', 'Warna merah dihasilkan dari <b>kombinasi bahan alami tertentu dengan kulit kayu mahoni.</b> Warna ini tidak hanya mencerminkan teknik pewarnaan tradisional, tetapi juga menunjukkan keterampilan dalam mencampur bahan hingga menghasilkan warna yang diinginkan.', '#FA3030'),
('Warna Hitam', 'Warna hitam diperoleh dari <b>kulit buah jengkol</b> yang diolah secara alami. Warna ini memiliki karakter kuat dan sering digunakan sebagai dasar motif dalam tenun Baduy.', '#000000');

-- Correct seeding for benang_patterns
INSERT INTO public.benang_patterns (name, meaning, image_url) VALUES 
('Suat Songket', 'Suat Songket merupakan salah satu motif yang paling banyak diproduksi dan dipasarkan saat ini. Motif ini lebih fleksibel dalam penggunaannya dibandingkan motif sakral, sehingga dapat digunakan dalam berbagai kesempatan.

Karena sifatnya yang tidak terikat aturan adat yang ketat, Suat Songket menjadi salah satu motif yang paling dikenal oleh masyarakat luar.', 'assets/benangmembumi/suatsongket.png'),
('Adu Mancung', 'Motif Adu Mancung melambangkan keseimbangan antara wilayah Baduy Dalam dan Baduy Luar. Motif ini umumnya digunakan oleh laki-laki, baik dalam kegiatan sehari-hari maupun dalam upacara adat. Adu Mancung sering dikenakan dalam ritual penting seperti Kawalu, Seba Baduy, pernikahan, hingga kegiatan pertanian adat.', 'assets/benangmembumi/adumancung.png'),
('Janggawari', 'Janggawari merupakan motif tertua dalam tradisi tenun Badui sekaligus yang paling rumit dan sakral. Proses pembuatannya tidak hanya membutuhkan keterampilan tinggi, tetapi juga disertai ritual khusus seperti puasa dan doa-doa tertentu. Motif ini tidak dapat digunakan sembarang orang dan secara adat hanya diperuntukkan bagi pemimpin tertinggi Baduy, yaitu Pu''un. Untuk keperluan komersial, motif ini dibuat dalam versi yang telah disederhanakan dengan pengurangan elemen tertentu, agar tidak menyerupai bentuk sakral aslinya.', 'assets/benangmembumi/janggawara.png'),
('Poleng', 'Motif Poleng digunakan oleh perempuan dan memiliki variasi makna sesuai dengan jenisnya.', 'assets/benangmembumi/poleng.png');

-- Correct seeding for benang_usages
INSERT INTO public.benang_usages (name, meaning, icon_url) VALUES 
('Suat Songket', 'Motif ini adalah salah satu yang paling terkenal dan fleksibel karena banyak diproduksi dan dipasarkan saat ini. Suat Songket dapat dipakai oleh masyarakat luas sekaligus membantu promosi budaya.', 'assets/benangmembumi/suatsongket.png'),
('Adu Mancung', 'Motif ini memiliki makna penting dalam kehidupan sosial Baduy, biasanya dipakai pada upacara adat besar seperti Kawalu, Seba, serta ritual pernikahan dan pertanian. Motif ini mewakili nilai komitmen dan keseimbangan dalam komunitas.', 'assets/benangmembumi/adumancung.png'),
('Janggawari', 'Motif ini sangat sakral dan secara tradisional hanya diperuntukkan bagi pemimpin adat tertinggi (Pu''un) karena proses pembuatannya disertai ritual khusus. Untuk penggunaan umum, versi motif ini disederhanakan agar tetap menghormati makna aslinya.', 'assets/benangmembumi/janggawara.png'),
('Poleng', 'Motif Poleng identik dengan pola kotak-kotak dan umumnya digunakan oleh perempuan Baduy. Motif ini memiliki makna yang berkaitan dengan keseimbangan hidup, tanggung jawab, serta hubungan manusia dengan alam.', 'assets/benangmembumi/poleng.png');

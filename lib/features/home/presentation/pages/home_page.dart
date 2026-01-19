import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/onboarding_single_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _showWelcomeDialog();
      if (!mounted) return;
      // Modal 1: Biografi Penenun (Standard transition or fade)
      await showDialog(
        context: context,
        builder: (context) => OnboardingSingleDialog(
          title: 'Biografi Penenun',
          description:
              'Kenali kisah inspiratif para perempuan penenun di balik setiap karya!',
          onNext: () => Navigator.of(context).pop(),
        ),
      );
      if (!mounted) return;

      // Modal 2: Benang Membumi
      await showDialog(
        context: context,
        builder: (context) => OnboardingSingleDialog(
          title: 'Benang Membumi',
          description:
              'Pelajari teknik menenun, makna, hingga bahan-bahan setiap tenun yang dihasilkan',
          onNext: () => Navigator.of(context).pop(),
        ),
      );
      if (!mounted) return;

      // Modal 3: Untaian Setiap Tenunan
      await showDialog(
        context: context,
        builder: (context) => OnboardingSingleDialog(
          title: 'Untaian Setiap Tenunan',
          description:
              'Pelajari proses menenun, filosofi, adat istiadat, hingga sejarah dari setiap karya',
          onNext: () => Navigator.of(context).pop(),
        ),
      );
    });
  }

  Future<void> _showWelcomeDialog() async {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, color: Colors.grey),
                ),
              ),
              Text(
                'Lestarikan\nBudaya, Dukung\nPengrajin Lokal',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Mengapa Harus Tenun?',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildCheckItem(
                '100% handmade oleh penenun\nperempuan Indonesia',
              ),
              const SizedBox(height: 12),
              _buildCheckItem(
                'Menggunakan bahan alami\ndan pewarna dari tumbuhan',
              ),
              const SizedBox(height: 12),
              _buildCheckItem(
                'Setiap produk penuh akan\ncerita dan makna filosofis',
              ),
              const SizedBox(height: 12),
              _buildCheckItem(
                'Mendukung ekonomi\nmasyarakat Indonesia secara\nlangsung',
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check, color: Colors.grey, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows body to extend behind the bottom bar
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFBDBDBD)],
          ),
        ),
        child: SafeArea(
          bottom: false, // Don't add padding for bottom safe area in body
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              24,
              20,
              24,
              100,
            ), // Add bottom padding for content
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Telusuri...',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(height: 20),

                // Categories
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildHighlightCard('Desa Kanekes'),
                      const SizedBox(width: 16),
                      _buildHighlightCard('Kegiatan Tenun'),
                      const SizedBox(width: 16),
                      _buildHighlightCard('Hasil Tenunan'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Marketplace Budaya
                Text(
                  'Marketplace Budaya',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rekomendasi Produk Unggulan',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return _buildProductCard();
                  },
                ),
                const SizedBox(height: 24),

                // Banner
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Yuk, Kenali Budaya Tenun\nIndonesia Lebih Lanjut!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent, // Ensure no background color behind
        padding: const EdgeInsets.only(bottom: 16, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem('Beranda', 0, Icons.home),
            _buildNavItem('Tokoku', 1, Icons.store),
            _buildNavItem('Keranjang', 2, Icons.shopping_cart),
            _buildNavItem('Akun Saya', 3, Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightCard(String title) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'foto',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Foto Produk',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, int index, IconData icon) {
    final bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF757575) : Colors.white,
              shape: BoxShape.circle,
            ),
            child: isActive ? Icon(icon, color: Colors.white, size: 24) : null,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.white,
              // Make text bold if active?
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

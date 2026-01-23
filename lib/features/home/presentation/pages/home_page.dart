import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
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
          child: Column(
            children: [
              // Fixed Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF757575), // Dark grey
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.push('/buyer/settings'),
                      child: const Icon(
                        Icons.settings_outlined,
                        color: Color(0xFF757575),
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    0,
                    24,
                    100,
                  ), // Content padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Telusuri...',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[500],
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Banner
                      Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Categories
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCategoryItem(),
                          _buildCategoryItem(),
                          _buildCategoryItem(),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Marketplace Budaya
                      Text(
                        'Marketplace Budaya',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF757575),
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

                      // Products Horizontal List
                      SizedBox(
                        height: 220,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: 4,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            return _buildProductCard();
                          },
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Vertical Highlights Section
                      _buildVerticalHighlightCard('Desa Kanekes'),
                      const SizedBox(height: 16),
                      _buildVerticalHighlightCard('Kegiatan Tenun'),
                      const SizedBox(height: 16),
                      _buildVerticalHighlightCard('Hasil Tenunan'),
                      const SizedBox(height: 40),

                      // Bottom "Yuk Kenali" Section
                      Column(
                        children: [
                          Text(
                            'Yuk, Kenali Budaya Tenun\nIndonesia Lebih Lanjut!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF757575),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Card 1: Benang Membumi
                          _buildFeatureCard(
                            title: 'Benang Membumi',
                            description:
                                'Pelajari teknik menenun, makna, hingga bahan-bahan setiap tenun yang dihasilkan',
                          ),
                          const SizedBox(height: 16),
                          // Card 2: Untaian Setiap Tenunan
                          _buildFeatureCard(
                            title: 'Untaian Setiap Tenunan',
                            description:
                                'Pelajari proses menenun, filosofi, adat istiadat, hingga sejarah dari setiap karya',
                          ),
                          const SizedBox(height: 16),
                          // Card 3: Marketplace Budaya
                          _buildFeatureCard(
                            title: 'Marketplace Budaya',
                            description:
                                'Jelajahi dan beli produk tenun asli dari para penenun di Indonesia',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFFBDBDBD), // Solid grey background
        padding: const EdgeInsets.only(bottom: 16, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem('Beranda', 0),
            _buildNavItem('Telusuri', 1),
            _buildNavItem('Keranjang', 2),
            _buildNavItem('Akun Saya', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0), // Light grey base
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / Top darker area
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF9E9E9E), // Darker grey image placeholder
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            alignment: Alignment.center,
            child: Text(
              'Foto Produk',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF616161),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF757575), // Button Dark Grey
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Telusuri',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem() {
    return Container(
      width: 100, // Fixed size for squares
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Empty content as per screenshot wireframe
    );
  }

  Widget _buildVerticalHighlightCard(String title) {
    return Container(
      width: double.infinity,
      height: 180, // Large vertical card
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0), // Light grey background
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Centered "foto" placeholder
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text(
                'foto',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ),
          ),
          // Title at bottom left
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF616161),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      width: 140, // Fixed width for horizontal list items
      decoration: BoxDecoration(
        color: const Color(
          0xFFE0E0E0,
        ), // Light grey background like screenshot placeholder
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                'Foto Produk',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          // Grey darker area at bottom similar to screenshot
          Container(
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFAAAAAA), // Darker grey footer
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, int index) {
    final bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        // Navigate to Akun Saya page when tapped
        if (index == 3) {
          context.push('/buyer/account');
        } else {
          setState(() => _currentIndex = index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF616161) : Colors.white,
              shape: BoxShape.circle,
            ),
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

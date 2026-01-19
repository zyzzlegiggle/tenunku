import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialog();
    });
  }

  void _showWelcomeDialog() {
    showDialog(
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
                    fontWeight:
                        FontWeight.bold, // Italic in sketch? Usually emphasis.
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFBDBDBD)], // Gradient effect
          ),
        ),
        child: Center(
          child: Text(
            'Konten Beranda',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors
            .transparent, // Making it sit on gradient? Usually needs container.
        // Actually, normally BottomNavBar needs solid color or it overlays content.
        elevation: 0,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        // The screenshot shows circles for nav items.
        // Implementing custom row for nav bar to match design perfectly
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Tokoku'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Keranjang',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun Saya'),
        ],
      ),
      // Replacing standard navbar with custom one to match the circle design
      bottomSheet: Container(
        color: const Color(0xFFBDBDBD), // Match bottom gradient
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem('Beranda', true),
            _buildNavItem('Tokoku', false),
            _buildNavItem('Keranjang', false),
            _buildNavItem('Akun Saya', false, isDark: true),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, bool isActive, {bool isDark = false}) {
    // The design has white circles for standard items and a dark circle for the last one?
    // Or maybe "Active" state.
    // Screenshot shows: White, White, White, Dark Grey.
    // Labels below.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF757575) : Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.white),
        ),
      ],
    );
  }
}

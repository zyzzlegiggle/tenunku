import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/onboarding_single_dialog.dart';
import '../widgets/home_view_body.dart';
import 'explore_page.dart';
import 'cart_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  static const String _onboardingKey = 'buyer_onboarding_completed';

  @override
  void initState() {
    super.initState();
    _checkAndShowOnboarding();
  }

  Future<void> _checkAndShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool(_onboardingKey) ?? false;

    if (onboardingCompleted || !mounted) return;

    // Show onboarding dialogs
    await _showWelcomeDialog();
    if (!mounted) return;

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

    await showDialog(
      context: context,
      builder: (context) => OnboardingSingleDialog(
        title: 'Untaian Setiap Tenunan',
        description:
            'Pelajari proses menenun, filosofi, adat istiadat, hingga sejarah dari setiap karya',
        onNext: () => Navigator.of(context).pop(),
      ),
    );

    // Mark onboarding as completed
    await prefs.setBool(_onboardingKey, true);
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
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    // Index 0: Home Body
                    HomeViewBody(
                      onSearchTap: () => setState(() => _currentIndex = 1),
                    ),
                    // Index 1: Explore Page
                    const ExplorePage(),
                    // Index 2: Keranjang
                    const CartPage(),
                    // Index 3: Akun Saya (Handled by navigation, but placeholder here for safety)
                    const Center(child: Text("Akun Saya")),
                  ],
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

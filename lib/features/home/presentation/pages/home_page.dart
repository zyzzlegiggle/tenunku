import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    // Check user role first
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final role = user.userMetadata?['role'];
      // If user is a seller, do NOT show onboarding, they have their own flow
      if (role == 'penjual') return;
    }

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
        imagePath: 'assets/onboardDialog/BiografiPenenun.png',
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
        imagePath: 'assets/onboardDialog/BenangMembumi.png',
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
        imagePath: 'assets/onboardDialog/UntaianSetiapTenunan.png',
        onNext: () => Navigator.of(context).pop(),
      ),
    );

    // Mark onboarding as completed
    await prefs.setBool(_onboardingKey, true);
  }

  Future<void> _showWelcomeDialog() async {
    const yellow = Color(0xFFFFE14F);
    const darkOrange = Color(0xFFF5793B);
    const navyBlue = Color(0xFF31476C);

    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.white, yellow],
                  stops: [0.0, 0.7, 1.0],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    'Lestarikan\nBudaya, Dukung\nPengrajin Lokal',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: navyBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Yellow rounded-square badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: yellow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: darkOrange,
                        ),
                        children: [
                          TextSpan(
                            text: 'Mengapa ',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                              color: darkOrange,
                            ),
                          ),
                          const TextSpan(text: 'Harus Tenun?'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Check items
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
                  const SizedBox(height: 16),
                ],
              ),
            ),
            // Close button positioned on top-right corner of dialog
            Positioned(
              top: -15,
              right: -15,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: darkOrange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    const darkOrange = Color(0xFFF5793B);
    const navyBlue = Color(0xFF31476C);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.check, color: darkOrange, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: navyBlue,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const cyanBlue = Color(0xFF54B7C2);
    const yellow = Color(0xFFFFE14F);

    return Scaffold(
      extendBody: true,
      body: Container(
        color: Colors.white,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Fixed Header - Cyan blue background
              Container(
                color: cyanBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Image.asset('assets/logo.png', width: 36, height: 36),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.push('/buyer/settings'),
                      child: const Icon(
                        Icons.settings,
                        color: yellow,
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
                    // Index 3: Akun Saya
                    const Center(child: Text("Akun Saya")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF54B7C2), // Cyan blue background
        padding: const EdgeInsets.only(bottom: 16, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem('Beranda', 0, Icons.home),
            _buildNavItem('Telusuri', 1, Icons.search),
            _buildNavItem('Keranjang', 2, Icons.shopping_cart),
            _buildNavItem('Akun Saya', 3, Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, int index, IconData icon) {
    const yellow = Color(0xFFFFE14F);
    const navyBlue = Color(0xFF31476C);
    final bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
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
              color: isActive ? yellow : navyBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? navyBlue : Colors.grey[400],
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.white,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

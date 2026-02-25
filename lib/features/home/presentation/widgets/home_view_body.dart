import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/buyer_repository.dart';
import '../../data/models/product_model.dart';

class HomeViewBody extends StatefulWidget {
  final VoidCallback? onSearchTap;

  const HomeViewBody({super.key, this.onSearchTap});

  @override
  State<HomeViewBody> createState() => _HomeViewBodyState();
}

class _HomeViewBodyState extends State<HomeViewBody> {
  static const _yellow = Color(0xFFFFE14F);
  static const _darkOrange = Color(0xFFF5793B);
  static const _navyBlue = Color(0xFF31476C);

  final ProductRepository _productRepository = ProductRepository();
  final BuyerRepository _buyerRepository = BuyerRepository();
  List<Product> _products = [];
  Set<String> _favoriteIds = {};
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = Supabase.instance.client.auth.currentUser?.id;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final products = await _productRepository.getRecommendedProducts();

      Set<String> favIds = {};
      if (_userId != null) {
        final favProducts = await _buyerRepository.getFavorites(_userId!);
        favIds = favProducts.map((p) => p.id).toSet();
      }

      setState(() {
        _products = products;
        _favoriteIds = favIds;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite(String productId) async {
    if (_userId == null) return;

    final isFav = _favoriteIds.contains(productId);
    setState(() {
      if (isFav) {
        _favoriteIds.remove(productId);
      } else {
        _favoriteIds.add(productId);
      }
    });

    try {
      if (isFav) {
        await _buyerRepository.removeFavorite(_userId!, productId);
      } else {
        await _buyerRepository.addFavorite(_userId!, productId);
      }
    } catch (e) {
      // Revert on error
      setState(() {
        if (isFav) {
          _favoriteIds.add(productId);
        } else {
          _favoriteIds.remove(productId);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top gradient section ──
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFB0E0E6), Color(0xFFF5FBFC)],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                Text(
                  'Hai, Tenunity!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _navyBlue,
                    shadows: [
                      Shadow(
                        color: Colors.white.withOpacity(0.7),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Cari apa hari ini?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: _navyBlue,
                    shadows: [
                      Shadow(
                        color: Colors.white.withOpacity(0.7),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Search bar
                GestureDetector(
                  onTap: widget.onSearchTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Telusuri..',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                        Icon(Icons.search, color: Colors.grey[500], size: 22),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 3 Feature Cards ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              children: [
                // Card 1: Shopping cart
                Expanded(child: _buildFeatureCard1()),
                const SizedBox(width: 10),
                // Card 2: Two tilted images
                Expanded(child: _buildFeatureCard2()),
                const SizedBox(width: 10),
                // Card 3: Image
                Expanded(child: _buildFeatureCard3()),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Marketplace Budaya ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Products Horizontal List
          SizedBox(
            height: 220,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _products.isEmpty ? 4 : _products.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        if (_products.isEmpty) {
                          return _buildEmptyProductCard();
                        }
                        return _buildProductCard(_products[index]);
                      },
                    ),
                  ),
          ),
          const SizedBox(height: 32),

          // ── Full-width Image Section ──
          Column(
            children: [
              _buildHighlightImage('assets/homepage/kain.png'),
              const SizedBox(height: 16),
              _buildHighlightImage(
                'assets/homepage/sungai.png',
                subtitle: 'Sungai ...',
              ),
              const SizedBox(height: 16),
              _buildHighlightImage('assets/homepage/menenun.png'),
            ],
          ),
          const SizedBox(height: 40),

          // ── Bottom "Yuk Kenali" Section ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
            child: Column(
              children: [
                Text(
                  'Yuk, Kenali Budaya Tenun\nIndonesia Lebih Lanjut!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _navyBlue,
                  ),
                ),
                const SizedBox(height: 16),
                _buildBottomFeatureCard(
                  context: context,
                  title: 'Benang Membumi',
                  description:
                      'Pelajari teknik menenun, makna, hingga bahan-bahan setiap tenun yang dihasilkan',
                  imagePath: 'assets/homepage/benangmenenun.png',
                  isBenangMembumi: true,
                ),
                const SizedBox(height: 16),
                _buildBottomFeatureCard(
                  context: context,
                  title: 'Untaian Setiap Tenunan',
                  description:
                      'Pelajari proses menenun, filosofi, adat istiadat, hingga sejarah dari setiap karya',
                  imagePath: 'assets/homepage/untaiansetiaptenunan.png',
                  isUntaianTenunan: true,
                ),
                const SizedBox(height: 16),
                _buildBottomFeatureCard(
                  context: context,
                  title: 'Marketplace Budaya',
                  description:
                      'Jelajahi dan beli produk tenun asli dari para penenun di Indonesia',
                  imagePath: 'assets/homepage/marketplacebudaya.png',
                  isMarketplace: true,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Feature Card 1: Shopping cart icon ──
  Widget _buildFeatureCard1() {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart, color: _navyBlue, size: 36),
          const SizedBox(height: 8),
          Text(
            'Temukan Kain Tenun\nPilihanmu disini!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: _navyBlue,
            ),
          ),
        ],
      ),
    );
  }

  // ── Feature Card 2: Two tilted images ──
  Widget _buildFeatureCard2() {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 50,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left tilted image
                Transform.rotate(
                  angle: -0.15,
                  child: Image.asset(
                    'assets/homepage/selamiProses.png',
                    width: 38,
                    height: 38,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 6),
                // Right tilted image (slightly smaller)
                Transform.rotate(
                  angle: 0.15,
                  child: Image.asset(
                    'assets/homepage/selamiProses.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selami Proses, Makna,\ndan Bahan Tenun\nPilihanmu!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: _navyBlue,
            ),
          ),
        ],
      ),
    );
  }

  // ── Feature Card 3: Image ──
  Widget _buildFeatureCard3() {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/homepage/kenaliFilosofi.png',
            width: 36,
            height: 36,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          Text(
            'Kenali Filosofi dan\nAdat yang Hidup\ndalam Setiap Tenunan!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 7,
              fontWeight: FontWeight.w600,
              color: _navyBlue,
            ),
          ),
        ],
      ),
    );
  }

  // ── Product Card with star favorite ──
  Widget _buildProductCard(Product product) {
    final isFav = _favoriteIds.contains(product.id);

    return GestureDetector(
      onTap: () {
        // Navigate to product detail if needed
      },
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Product Image with star
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child:
                        product.imageUrl != null && product.imageUrl!.isNotEmpty
                        ? Image.network(
                            product.imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                alignment: Alignment.center,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                  size: 30,
                                ),
                              );
                            },
                          )
                        : Container(
                            alignment: Alignment.center,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image,
                              color: Colors.grey,
                              size: 30,
                            ),
                          ),
                  ),
                  // Star favorite icon
                  Positioned(
                    top: 6,
                    left: 6,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(product.id),
                      child: Icon(
                        isFav ? Icons.star : Icons.star_border,
                        color: isFav ? _yellow : Colors.white,
                        size: 24,
                        shadows: const [
                          Shadow(color: Colors.black38, blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Product name (yellow container, navy text, no price)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: const BoxDecoration(
                color: _yellow,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _navyBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyProductCard() {
    return Container(
      width: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: const Icon(Icons.image, color: Colors.grey, size: 30),
            ),
          ),
          Container(
            height: 44,
            decoration: const BoxDecoration(
              color: _yellow,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightImage(String assetPath, {String? subtitle}) {
    return SizedBox(
      width: double.infinity,
      height: 160,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          Image.asset(
            assetPath,
            width: double.infinity,
            height: 160,
            fit: BoxFit.cover,
          ),
          // White glow on left edge
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 40,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.white.withOpacity(0.6),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // White glow on right edge
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 40,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Colors.white.withOpacity(0.6),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // Subtitle for sungai
          if (subtitle != null)
            Positioned(
              left: 16,
              bottom: 20,
              child: Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  shadows: [const Shadow(color: Colors.black54, blurRadius: 6)],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomFeatureCard({
    required BuildContext context,
    required String title,
    required String description,
    required String imagePath,
    bool isMarketplace = false,
    bool isBenangMembumi = false,
    bool isUntaianTenunan = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _navyBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with navy fog at bottom
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.asset(
                  imagePath,
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // Navy fog gradient at bottom of image
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 60,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(0),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        _navyBlue.withOpacity(0.9),
                        _navyBlue.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Title & description container
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      if (isMarketplace) {
                        widget.onSearchTap?.call();
                      } else if (isBenangMembumi) {
                        context.push('/benang-membumi');
                      } else if (isUntaianTenunan) {
                        context.push('/untaian-tenunan');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _darkOrange,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/models/product_model.dart';

class HomeViewBody extends StatefulWidget {
  final VoidCallback? onSearchTap;

  const HomeViewBody({super.key, this.onSearchTap});

  @override
  State<HomeViewBody> createState() => _HomeViewBodyState();
}

class _HomeViewBodyState extends State<HomeViewBody> {
  final ProductRepository _productRepository = ProductRepository();
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _productRepository.getRecommendedProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          GestureDetector(
            onTap: widget.onSearchTap,
            child: AbsorbPointer(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Telusuri...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
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
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // Products Horizontal List
          SizedBox(
            height: 220,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _products.isEmpty ? 4 : _products.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      if (_products.isEmpty) {
                        return _buildEmptyProductCard();
                      }
                      return _buildProductCard(_products[index]);
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
                context: context,
                title: 'Benang Membumi',
                description:
                    'Pelajari teknik menenun, makna, hingga bahan-bahan setiap tenun yang dihasilkan',
                isBenangMembumi: true,
              ),
              const SizedBox(height: 16),
              // Card 2: Untaian Setiap Tenunan
              _buildFeatureCard(
                context: context,
                title: 'Untaian Setiap Tenunan',
                description:
                    'Pelajari proses menenun, filosofi, adat istiadat, hingga sejarah dari setiap karya',
                isUntaianTenunan: true,
              ),
              const SizedBox(height: 16),
              // Card 3: Marketplace Budaya
              _buildFeatureCard(
                context: context,
                title: 'Marketplace Budaya',
                description:
                    'Jelajahi dan beli produk tenun asli dari para penenun di Indonesia',
                isMarketplace: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required String description,
    bool isMarketplace = false,
    bool isBenangMembumi = false,
    bool isUntaianTenunan = false,
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
      width: 100,
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
    );
  }

  Widget _buildVerticalHighlightCard(String title) {
    return Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text(
                'foto',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ),
          ),
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

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        // Navigate to product detail if needed
      },
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? Image.network(
                        product.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            alignment: Alignment.center,
                            color: const Color(0xFFE0E0E0),
                            child: Text(
                              'Foto Produk',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
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
            ),
            // Product Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFAAAAAA),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Rp${_formatPrice(product.price)}',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyProductCard() {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
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
          Container(
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFAAAAAA),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }
}

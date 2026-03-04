import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/product_model.dart';

class SellerProductDetailPage extends StatefulWidget {
  final Product product;

  const SellerProductDetailPage({super.key, required this.product});

  @override
  State<SellerProductDetailPage> createState() =>
      _SellerProductDetailPageState();
}

class _SellerProductDetailPageState extends State<SellerProductDetailPage> {
  int _likesCount = 0;
  bool _isLoadingLikes = true;

  @override
  void initState() {
    super.initState();
    _loadLikesCount();
  }

  Future<void> _loadLikesCount() async {
    try {
      final count = await Supabase.instance.client
          .from('favorites')
          .select('id')
          .eq('product_id', widget.product.id)
          .count(CountOption.exact);
      if (mounted) {
        setState(() {
          _likesCount = count.count;
          _isLoadingLikes = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingLikes = false);
    }
  }

  void _navigateToTab(int index) {
    if (index == 1) return; // already on product detail/view
    context.go('/seller-home', extra: index);
  }

  void _showOptionsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductOptionsModal(product: widget.product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.product.name;
    final displayTitle = name;
    final imagePath = widget.product.imageUrls.isNotEmpty
        ? widget.product.imageUrls.first
        : widget.product.imageUrl ?? '';
    final description =
        widget.product.description ??
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip.';

    final screenWidth = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    // Image on the right, bridging cyan and white
    final imageWidth = screenWidth * 0.45;
    final imageHeight = imageWidth * 1.1;

    final topSectionHeight = topPad + 260; // Pushed down considerably
    final imageTop = topSectionHeight - (imageHeight * 0.55);
    final imageLeft = screenWidth - imageWidth - 24;

    return Scaffold(
      backgroundColor: const Color(0xFFC3D3D5),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF54B7C2), Color(0xFFC3D3D5)],
          ),
        ),
        child: Stack(
          children: [
            // ---- BOTTOM SECTION (White Card) ----
            Positioned(
              top: topSectionHeight,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
              ),
            ),

            // ---- IMAGE ----
            Positioned(
              top: imageTop,
              left: imageLeft,
              child: Container(
                width: imageWidth,
                height: imageHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: imagePath.isNotEmpty
                          ? Image.network(imagePath, fit: BoxFit.cover)
                          : Container(color: Colors.grey),
                    ),
                    if (imagePath.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ---- BACK BUTTON (Yellow) ----
            Positioned(
              top: topPad + 8,
              left: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFFFFE14F),
                  size: 28,
                ),
                onPressed: () => context.pop(),
              ),
            ),

            // ---- TITLE ----
            Positioned(
              top: topPad + 60,
              left: 24,
              right: imageWidth + 32, // Prevent overlap
              child: Text(
                displayTitle,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF31476C), // Navy Blue text
                  height: 1.3,
                ),
                maxLines: 3,
              ),
            ),

            // ---- LIKES (HEART AND TEXT) ----
            Positioned(
              top: topPad + 150,
              left: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.favorite,
                    color: Color(0xFFF5793B),
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Disukai oleh ${_isLoadingLikes ? "..." : _likesCount}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF31476C),
                    ),
                  ),
                ],
              ),
            ),

            // ---- SCROLLABLE CONTENT ----
            Positioned(
              top: topSectionHeight,
              left: 0,
              right: 0,
              bottom: 85 + MediaQuery.of(context).padding.bottom,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: (imageTop + imageHeight) > topSectionHeight
                      ? (imageTop + imageHeight) - topSectionHeight + 16
                      : 16,
                  bottom: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price
                    Text(
                      'Rp ${_formatPrice(widget.product.price)}',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF757575), // Dark grey
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFFAFAFAF), // Lighter grey
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Ukuran & Varian
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _showOptionsModal,
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ukuran',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF727272),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Color(0xFF727272),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                        Expanded(
                          child: GestureDetector(
                            onTap: _showOptionsModal,
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Varian',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF727272),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Color(0xFF727272),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Stats Box (F0F0F0)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          _buildStatRow(
                            'Terjual',
                            _formatPrice(widget.product.soldCount.toDouble()),
                            'Helai',
                            hasDropdown: false,
                          ),
                          const SizedBox(height: 12),
                          _buildStatRow(
                            'Dilihat',
                            _formatPrice(widget.product.viewCount.toDouble()),
                            'Kali',
                            hasDropdown: false,
                          ),
                          const SizedBox(height: 12),
                          _buildStatRow(
                            'Ulasan',
                            _formatPrice(
                              widget.product.totalReviews.toDouble(),
                            ),
                            'Ulasan',
                            hasDropdown: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Edit Produk Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          context.push(
                            '/seller/product/add',
                            extra: widget.product,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5793B), // Orange
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            'Edit Produk',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---- BOTTOM NAVIGATION BAR (FIXED) ----
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: 85 + MediaQuery.of(context).padding.bottom,
                    decoration: const BoxDecoration(
                      color: Color(0xFF54B7C2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: MediaQuery.of(context).padding.bottom + 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildNavItem('Beranda', Icons.home_rounded, 0),
                        _buildNavItem('Produk', Icons.inventory_2_rounded, 1),
                        _buildNavItem(
                          'Pesanan',
                          Icons.shopping_cart_rounded,
                          2,
                        ),
                        _buildNavItem('Obrolan', Icons.chat_rounded, 3),
                      ],
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

  String _formatPrice(double val) {
    if (val == 0) return '0';
    return val.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Widget _buildStatRow(
    String title,
    String numText,
    String unitText, {
    required bool hasDropdown,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF31476C), // Navy blue
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (hasDropdown) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFFFFE14F),
                  size: 20,
                ),
              ],
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                numText,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFE14F), // Yellow
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unitText,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, int index) {
    final bool isActive = index == 1; // Always "Produk" active

    final double buttonSize = isActive ? 72 : 56;
    final double iconSize = isActive ? 42 : 32;

    return GestureDetector(
      onTap: () => _navigateToTab(index),
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFFFE14F)
                    : const Color(0xFF31476C),
                shape: BoxShape.circle,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: isActive
                    ? const Color(0xFF31476C)
                    : const Color(0xFFFFE14F).withOpacity(0.5),
                size: iconSize,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductOptionsModal extends StatelessWidget {
  final Product product;

  const _ProductOptionsModal({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Pilihan Produk',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF31476C),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Ukuran Tersedia',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF757575),
            ),
          ),
          const SizedBox(height: 12),
          if (product.sizes.isEmpty)
            Text(
              'Tidak ada pilihan ukuran',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: product.sizes
                  .map((size) => _buildOptionChip(size))
                  .toList(),
            ),
          const SizedBox(height: 24),
          Text(
            'Varian Tersedia',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF757575),
            ),
          ),
          const SizedBox(height: 12),
          if (product.variants.isEmpty)
            Text(
              'Tidak ada pilihan varian',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: product.variants
                  .map((variant) => _buildOptionChip(variant, hasImage: true))
                  .toList(),
            ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF54B7C2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Tutup',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionChip(String title, {bool hasImage = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasImage) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: product.imageUrls.isNotEmpty
                  ? Image.network(
                      product.imageUrls.first,
                      width: 20,
                      height: 20,
                      fit: BoxFit.cover,
                    )
                  : product.imageUrl != null
                  ? Image.network(
                      product.imageUrl!,
                      width: 20,
                      height: 20,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 20,
                      height: 20,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 12),
                    ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF31476C),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

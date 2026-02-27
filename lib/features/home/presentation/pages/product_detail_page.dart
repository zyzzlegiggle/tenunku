import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/product_model.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final name = product.name;
    final displayTitle = name;
    final imagePath = product.imageUrl ?? '';
    final description = product.description ?? 'Tidak ada deskripsi.';

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;
    final topSectionHeight = screenHeight * 0.45;
    final imageWidth = screenWidth * 0.5;
    final imageHeight = imageWidth * 1.3;

    // Position the image higher — most of it in the top section
    final imageTop = topSectionHeight - (imageHeight * 0.75);
    // The image is aligned to the right at ~3/4 width
    final imageLeft = screenWidth * 0.5 - (imageWidth * 0.25);

    // Scrollable content starts below the image bottom
    final contentTopOffset = imageTop + imageHeight + 12;

    return Scaffold(
      backgroundColor: const Color(0xFFC3D3D5),
      body: Stack(
        children: [
          // ---- TOP SECTION with gradient (fixed) ----
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topSectionHeight,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF54B7C2), Color(0xFFC3D3D5)],
                ),
              ),
            ),
          ),

          // ---- BOTTOM SECTION with white bg and rounded top (fixed) ----
          Positioned(
            top: topSectionHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          // ---- IMAGE bridging both sections (fixed, does NOT scroll) ----
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
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: imagePath.isNotEmpty
                        ? Image.network(
                            imagePath,
                            width: imageWidth,
                            height: imageHeight,
                            fit: BoxFit.cover,
                          )
                        : Container(color: Colors.grey),
                  ),
                  if (imagePath.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ---- BACK BUTTON (fixed) ----
          Positioned(
            top: topPad + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),

          // ---- TITLE (fixed) ----
          Positioned(
            top: topPad + 80, // Moved down for more space
            left: 40,
            right: 40,
            child: Text(
              displayTitle,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF31476C),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // ---- LIKED SECTION (fixed to gradient outside container) ----
          Positioned(
            top: topSectionHeight - 64, // Moved higher
            left: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.favorite,
                  color: Color(0xFFF5793B), // Orange heart
                  size: 20,
                ),
                Text(
                  'Disukai oleh ${product.viewCount}',
                  style: GoogleFonts.poppins(
                    fontSize: 10, // Slightly smaller since stacked
                    color: const Color(0xFF31476C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // ---- PRICE SECTION (fixed beside image) ----
          Positioned(
            top: contentTopOffset - 40, // Moved higher
            left: 28,
            width: imageLeft - 36, // Constrain so it does not overlap the image
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'Rp ${product.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF727272),
                ),
              ),
            ),
          ),

          // ---- SCROLLABLE DESCRIPTION (only this scrolls) ----
          Positioned(
            top: contentTopOffset + 12, // Pushed down to avoid price
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 28,
                right: 28,
                top: 8,
                bottom: 80, // More bottom padding for scroll space
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF5A5A5A),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Variants Section (Mockup sizes and variants)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ukuran',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF727272),
                                  fontSize: 14,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xFF727272),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Varian',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF727272),
                                  fontSize: 14,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xFF727272),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Metrics Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        _buildMetricCard('Terjual', product.soldCount, 'Helai'),
                        const SizedBox(height: 12),
                        _buildMetricCard('Dilihat', product.viewCount, 'Kali'),
                        const SizedBox(height: 12),
                        _buildMetricCard(
                          'Ulasan',
                          product.totalReviews,
                          'Ulasan',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Edit Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/seller/product/add', extra: product);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5793B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        'Edit Produk',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, int value, String suffix) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF31476C), // Navy Blue
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$value ',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFFFE14F), // Yellow
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  suffix,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

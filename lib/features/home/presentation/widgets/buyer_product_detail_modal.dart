import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/product_model.dart';

void showBuyerProductDetailModal(BuildContext context, Product product) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BuyerProductDetailModal(product: product),
  );
}

class BuyerProductDetailModal extends StatefulWidget {
  final Product product;

  const BuyerProductDetailModal({super.key, required this.product});

  @override
  State<BuyerProductDetailModal> createState() =>
      _BuyerProductDetailModalState();
}

class _BuyerProductDetailModalState extends State<BuyerProductDetailModal> {
  @override
  Widget build(BuildContext context) {
    final name = widget.product.name;
    final displayTitle = name;
    final imagePath = widget.product.imageUrl ?? '';
    final description = widget.product.description ?? 'Tidak ada deskripsi.';

    final screenHeight =
        MediaQuery.of(context).size.height *
        0.95; // 95% height for slide-up sheet
    final screenWidth = MediaQuery.of(context).size.width;
    final topSectionHeight = screenHeight * 0.45;
    final imageWidth = screenWidth * 0.5;
    final imageHeight = imageWidth * 1.3;

    final imageTop = topSectionHeight - (imageHeight * 0.75);
    final imageLeft = screenWidth * 0.5 - (imageWidth * 0.25);
    final contentTopOffset = imageTop + imageHeight + 12;

    return Container(
      height: screenHeight,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        color: Color(0xFFC3D3D5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          // ---- TOP SECTION with gradient ----
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

          // ---- BOTTOM SECTION with white bg & rounded top ----
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
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                    spreadRadius: 2,
                  ),
                ],
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

          // ---- BACK BUTTON / CLOSE MODAL ----
          Positioned(
            top: 24,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),

          // ---- TITLE ----
          Positioned(
            top: 80,
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

          // ---- LIKED SECTION ----
          Positioned(
            top: topSectionHeight - 64,
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
                  'Disukai oleh ${widget.product.viewCount}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF31476C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // ---- PRICE SECTION ----
          Positioned(
            top: contentTopOffset - 40,
            left: 28,
            width: imageLeft - 36,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'Rp ${widget.product.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF727272),
                ),
              ),
            ),
          ),

          // ---- SCROLLABLE DESCRIPTION ----
          Positioned(
            top: contentTopOffset + 12,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 28,
                right: 28,
                top: 8,
                bottom: 80, // bottom padding
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

                  // Variants Section
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

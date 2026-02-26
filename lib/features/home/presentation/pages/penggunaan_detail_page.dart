import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class PenggunaanDetailPage extends StatelessWidget {
  final Map<String, dynamic> usageData;

  const PenggunaanDetailPage({super.key, required this.usageData});

  @override
  Widget build(BuildContext context) {
    final name = usageData['name'] as String? ?? 'Penggunaan';
    final displayTitle = usageData['displayTitle'] as String? ?? name;
    final imagePath =
        usageData['image'] as String? ?? 'assets/benangmembumi/suatsongket.png';
    final description = usageData['description'] as String? ?? '';

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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  imagePath,
                  width: imageWidth,
                  height: imageHeight,
                  fit: BoxFit.cover,
                ),
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
            top: topPad + 56,
            left: 40,
            child: Text(
              displayTitle,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF31476C),
              ),
            ),
          ),

          // ---- SCROLLABLE DESCRIPTION (only this scrolls) ----
          Positioned(
            top: contentTopOffset,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 28,
                right: 28,
                top: 8,
                bottom: 60,
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
                  const SizedBox(height: 32),

                  // ---- SARAN PEMAKAIAN SECTION ----
                  Text(
                    'Saran Pemakaian Produk',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5E5E5E),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dynamic columns of rounded squares
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (usageData['checkmarks'] as List<String>? ?? [])
                        .map(
                          (label) =>
                              Expanded(child: _buildSuggestionSquare(label)),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 32),

                  // ---- MARKETPLACE BUTTON ----
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // Assuming the marketplace route is /marketplace, update as necessary
                        context.push('/marketplace');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF31476C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                          children: const [
                            TextSpan(text: 'Lihat Produk di '),
                            TextSpan(
                              text: 'Marketplace Budaya',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
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

  Widget _buildSuggestionSquare(String label) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF5793B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.check,
                color: Color(0xFFFFE14F),
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF969696),
          ),
        ),
      ],
    );
  }
}

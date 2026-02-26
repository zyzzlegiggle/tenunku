import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class PolaDetailPage extends StatelessWidget {
  final Map<String, String> polaData;

  const PolaDetailPage({super.key, required this.polaData});

  @override
  Widget build(BuildContext context) {
    final name = polaData['name'] ?? 'Pola';
    final displayTitle = polaData['displayTitle'] ?? 'Pola $name';
    final imagePath = polaData['image'] ?? '';
    final description =
        polaData['description'] ??
        'Pola ini merupakan salah satu motif tenun khas yang memiliki makna mendalam dalam budaya masyarakat.';

    final isPoleng = name == 'Poleng';
    final needsZoom = (name == 'Janggawari' || name == 'Poleng');

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
                child: needsZoom
                    ? Transform.scale(
                        scale: 1.8,
                        child: Image.asset(
                          imagePath,
                          width: imageWidth,
                          height: imageHeight,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
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
                bottom: 40,
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

                  // ---- POLENG-SPECIFIC 2-COLUMN CONTENT ----
                  if (isPoleng) ...[
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column - Poleng Capi Turang
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/benangmembumi/polengicon.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Poleng Capi Turang',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        fontStyle: FontStyle.italic,
                                        color: const Color(0xFF31476C),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Melambangkan kekayaan alam wilayah sungai Baduy. Motif ini biasanya digunakan dalam upacara pernikahan sebagai simbol kesejahteraan dan keberlimpahan.',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF5A5A5A),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Right column - Poleng Pepetikan
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/benangmembumi/polengicon.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Poleng Pepetikan',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        fontStyle: FontStyle.italic,
                                        color: const Color(0xFF31476C),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Melambangkan tugas dan kewajiban perempuan dalam menjalankan ritual adat. Motif ini digunakan dalam kegiatan seperti nombok padi, yang berkaitan dengan siklus pertanian dan kehidupan masyarakat Baduy.',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF5A5A5A),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

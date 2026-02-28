import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/profile_model.dart';

class SellerBiographyPage extends StatelessWidget {
  final Profile seller;

  const SellerBiographyPage({super.key, required this.seller});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header: Back icon
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(top: topPadding + 20, left: 16),
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.grey,
                    size: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // App Logo
            Image.asset('assets/logo.png', height: 48),
            const SizedBox(height: 20),
            // Title
            Text(
              'Biografi Penenun',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF616161),
              ),
            ),
            const SizedBox(height: 120), // More space for the circle overlap
            // Card Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  // Gradient Card Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      top: 50, // Space for the inside part of the circle
                      left: 24,
                      right: 24,
                      bottom: 32,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFE0F7FA), // Very light blue
                          Colors.white,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Name
                        Text(
                          seller.fullName ?? 'Nama Penenun',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF31476C),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Age
                        Text(
                          '${seller.age ?? "X"} Tahun',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF31476C),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Description
                        Text(
                          seller.bio ??
                              seller.description ??
                              'Deskripsi biografi penenun akan ditampilkan di sini. Penenun ini memiliki keahlian khusus dalam membuat kain tenun tradisional.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF969696),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Button
                        ElevatedButton(
                          onPressed: () {
                            context.push(
                              '/seller/biography/detail',
                              extra: seller,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF31476C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Lihat Detail',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Circle Profile picture (3/4 outside)
                  Positioned(
                    top: -90, // 3/4 outside (diameter 120)
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: seller.avatarUrl != null
                            ? Image.network(
                                seller.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/profile_model.dart';

class SellerProfileDetailPage extends StatefulWidget {
  final Profile seller;

  const SellerProfileDetailPage({super.key, required this.seller});

  @override
  State<SellerProfileDetailPage> createState() =>
      _SellerProfileDetailPageState();
}

class _SellerProfileDetailPageState extends State<SellerProfileDetailPage> {
  int _activeTabIndex = 0;

  final List<String> _tabs = ['Kisah', 'Harapan', 'Keseharian'];

  String _getTabTitle(int index) {
    switch (index) {
      case 0:
        return 'Perjalanan Hidup';
      case 1:
        return 'Impian & Harapan';
      case 2:
        return 'Kehidupan Sehari-hari';
      default:
        return '';
    }
  }

  String _getTabDescription(int index) {
    switch (index) {
      case 0:
        return widget.seller.bio ??
            'Saya telah menenun selama lebih dari 20 tahun, warisan dari nenek saya. Setiap motif memiliki cerita tersendiri yang mencerminkan kearifan lokal desa kami.';
      case 1:
        return widget.seller.hope ??
            'Saya berharap generasi muda tetap mau belajar menenun agar tradisi ini tidak punah dimakan waktu.';
      case 2:
        return widget.seller.dailyActivity ??
            'Pagi hari saya menyiapkan benang alam, siang hari menenun di teras rumah sambil bercengkerama dengan tetangga.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: EdgeInsets.only(
                top: topPadding + 16,
                left: 16,
                right: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.grey,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Seller Image Card
                  Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      Container(
                        height: 280,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: widget.seller.avatarUrl != null
                              ? Image.network(
                                  widget.seller.avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Container(color: Colors.grey[300]),
                                )
                              : Container(color: Colors.grey[300]),
                        ),
                      ),
                      // White Gradient Overlay at bottom of image
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                      // Text Info Inside Image
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  widget.seller.fullName ?? 'Nama Penenun',
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      const Shadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${widget.seller.age ?? "X"} Tahun',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Color(0xFFF5793B),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Desa Kanekes',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    shadows: [
                                      const Shadow(
                                        color: Colors.black26,
                                        blurRadius: 2,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Tabs Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5793B),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  children: List.generate(_tabs.length, (index) {
                    final isActive = _activeTabIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTabIndex = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFFFE14F)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Text(
                            _tabs[index],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: isActive ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tab Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/smallstar.png',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getTabTitle(_activeTabIndex),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF424242),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getTabDescription(_activeTabIndex),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

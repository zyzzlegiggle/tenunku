import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SellerSettingsLayout extends StatelessWidget {
  final String title;
  final Widget body;

  const SellerSettingsLayout({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white, // White background to match buyer settings
      appBar: AppBar(
        backgroundColor: const Color(0xFF54B7C2), // Cyan header
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFFFFE14F),
          ), // Yellow back button
          onPressed: () => context.pop(),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(bottom: false, child: body),
      bottomNavigationBar: Stack(
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
                _buildNavItem(context, 'Beranda', Icons.home_rounded, 0, true),
                _buildNavItem(
                  context,
                  'Produk',
                  Icons.inventory_2_rounded,
                  1,
                  false,
                ),
                _buildNavItem(
                  context,
                  'Pesanan',
                  Icons.shopping_cart_rounded,
                  2,
                  false,
                ),
                _buildNavItem(context, 'Obrolan', Icons.chat_rounded, 3, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String label,
    IconData icon,
    int index,
    bool isActive,
  ) {
    final double buttonSize = isActive ? 72 : 56;
    final double iconSize = isActive ? 42 : 32;

    return GestureDetector(
      onTap: () {
        context.go('/seller-home', extra: index);
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
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
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

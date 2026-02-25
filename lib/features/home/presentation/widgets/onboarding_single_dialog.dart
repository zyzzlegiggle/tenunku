import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingSingleDialog extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final VoidCallback onNext;

  const OnboardingSingleDialog({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.onNext,
  });

  static const _yellow = Color(0xFFFFE14F);
  static const _darkOrange = Color(0xFFF5793B);
  static const _navyBlue = Color(0xFF31476C);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.white, _yellow],
                stops: [0.0, 0.7, 1.0],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                // Title
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Dialog image
                Image.asset(imagePath, width: 120, height: 120),
                const SizedBox(height: 24),
                // Description
                Text(
                  description,
                  style: GoogleFonts.poppins(fontSize: 14, color: _navyBlue),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Button
                ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _darkOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Jelajahi Fitur ->',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Close button on top-right corner
          Positioned(
            top: -15,
            right: -15,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: _darkOrange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingCarouselDialog extends StatefulWidget {
  const OnboardingCarouselDialog({super.key});

  @override
  State<OnboardingCarouselDialog> createState() =>
      _OnboardingCarouselDialogState();
}

class _OnboardingCarouselDialogState extends State<OnboardingCarouselDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'Biografi Penenun',
      'description':
          'Kenali kisah inspiratif para perempuan penenun di balik setiap karya!',
      'image': '', // Placeholder
    },
    {
      'title': 'Benang Membumi',
      'description':
          'Pelajari teknik menenun, makna, hingga bahan-bahan setiap tenun yang dihasilkan',
      'image': '',
    },
    {
      'title': 'Untaian Setiap Tenunan',
      'description':
          'Pelajari proses menenun, filosofi, adat istiadat, hingga sejarah dari setiap karya',
      'image': '',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: 500, // Fixed height for carousel
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header with Page Indicator? Or simple Close button
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close, color: Colors.grey),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _slides[index]['title']!,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      // Image Placeholder
                      Container(
                        width: 150,
                        height: 150,
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text(
                          'Foto',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        _slides[index]['description']!,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // "Jelajahi Fitur" Button on all slides? Screenshot shows it.
            ElevatedButton(
              onPressed: () {
                if (_currentPage < _slides.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF757575),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                minimumSize: const Size(
                  0,
                  40,
                ), // Shrink to fit content? No, screenshot is wide.
              ),
              child: Text(
                'Jelajahi Fitur ->',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class WarnaDetailPage extends StatelessWidget {
  final Map<String, dynamic> colorData;

  const WarnaDetailPage({super.key, required this.colorData});

  /// Parse simple HTML-like bold tags into TextSpans.
  List<TextSpan> _parseSubtitle(String text) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'<b>(.*?)</b>', caseSensitive: false);
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      // Text before the bold tag
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      // Bold text
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      );
      lastEnd = match.end;
    }
    // Remaining text after last bold tag
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final color = colorData['color'] as Color? ?? const Color(0xFFE0E0E0);
    final name = colorData['name'] as String? ?? 'Warna';
    final subtitle = colorData['subtitle'] as String? ?? '';
    final imagePath = colorData['image'] as String? ?? '';
    final screenHeight = MediaQuery.of(context).size.height;
    final topHeight = screenHeight / 3;
    final bottomHeight = screenHeight / 5;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ---- TOP: Color block — 1/4 of screen ----
          Stack(
            children: [
              Container(
                height: topHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(72),
                    bottomRight: Radius.circular(72),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              // Back button on top of color
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 8,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              // App logo on top-right
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                right: 16,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Image.asset('assets/logo.png'),
                ),
              ),
            ],
          ),

          // ---- MIDDLE: Title + Subtitle ----
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: const Color(0xFF5E5E5E),
                        height: 1.6,
                      ),
                      children: _parseSubtitle(subtitle),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---- BOTTOM: Image with color fog — 1/4 of screen ----
          SizedBox(
            height: bottomHeight,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // The half-circle image
                if (imagePath.isNotEmpty)
                  Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                // Color fog overlay on top of image
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: const [0.0, 0.5, 1.0],
                      colors: [
                        color.withValues(alpha: 0.7),
                        color.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

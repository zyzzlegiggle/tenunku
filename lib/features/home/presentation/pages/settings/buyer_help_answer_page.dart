import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class BuyerHelpAnswerPage extends StatelessWidget {
  const BuyerHelpAnswerPage({super.key});

  @override
  Widget build(BuildContext context) {
    const cyanBlue = Color(0xFF54B7C2);
    const yellow = Color(0xFFFFE14F);
    const navyBlue = Color(0xFF31476C);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: cyanBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: yellow),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Jawaban Bantuan',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildMessageBubble(
                  isMe: true,
                  text: 'Apakah saya dapat mengubah username saya?',
                  time: '14:27',
                  bgColor: cyanBlue,
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: navyBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          'T',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMessageBubble(
                        isMe: false,
                        text:
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua minim ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                        time: '14:31',
                        bgColor: navyBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: cyanBlue,
        padding: const EdgeInsets.only(bottom: 16, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(context, 'Beranda', 0, Icons.home),
            _buildNavItem(context, 'Telusuri', 1, Icons.search),
            _buildNavItem(context, 'Keranjang', 2, Icons.shopping_cart),
            _buildNavItem(context, 'Akun Saya', 3, Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble({
    required bool isMe,
    required String text,
    required String time,
    required Color bgColor,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: isMe
                ? const Radius.circular(16)
                : const Radius.circular(0),
            topRight: const Radius.circular(16),
            bottomLeft: const Radius.circular(16),
            bottomRight: isMe
                ? const Radius.circular(0)
                : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String label,
    int index,
    IconData icon,
  ) {
    const yellow = Color(0xFFFFE14F);
    const navyBlue = Color(0xFF31476C);
    final bool isActive = index == 3;

    return GestureDetector(
      onTap: () {
        if (isActive) {
          context.pop();
        } else {
          context.go('/buyer', extra: index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isActive ? yellow : navyBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? navyBlue : Colors.grey[400],
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.white,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

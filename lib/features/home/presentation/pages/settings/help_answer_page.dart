import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'seller_settings_layout.dart';

class HelpAnswerPage extends StatelessWidget {
  const HelpAnswerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SellerSettingsLayout(
      title: 'Jawaban Bantuan',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildMessageBubble(
              isMe: true,
              text: 'Apakah Saya dapat mengubah\nusername saya?',
              time: '12:51',
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFF31476C), // Dark blue
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'T',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMessageBubble(
                    isMe: false,
                    text:
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                    time: '12:52',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 120), // Padding for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble({
    required bool isMe,
    required String text,
    required String time,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isMe
              ? const Color(0xFF54B7C2)
              : const Color(0xFF31476C), // Cyan or Dark Blue
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white,
                height: 1.5,
              ),
              textAlign: isMe ? TextAlign.right : TextAlign.left,
            ),
            const SizedBox(height: 8),
            Text(
              time,
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

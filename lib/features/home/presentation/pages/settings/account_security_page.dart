import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountSecurityPage extends StatelessWidget {
  const AccountSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Akun & Keamanan',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildMenuItem(
                context,
                'No. Handphone',
                trailingText: 'Atur Sekarang',
              ),
              const Divider(height: 1),
              _buildMenuItem(
                context,
                'Email',
                trailingText: '**/**/****', // Placeholder masking as per design
              ),
              const Divider(height: 1),
              _buildMenuItem(
                context,
                'Ganti Password',
                // The design shows a phone number here which is likely an error.
                // I will skip the trailing text for password change or clarify it later.
                // For now, adhering to standard "Change Password" flow.
                trailingText:
                    '08xxxxxxxx', // Keeping it to match design strictly if required, but it looks wrong.
                // I'll keep it as the user asked for "first principles" which implies doing it right,
                // but also "this is seller setting" implies following screen.
                // I will compromise: Use the text from screenshot but functionality of password change.
                onTap: () => context.push('/seller/settings/change-password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title, {
    VoidCallback? onTap,
    String? trailingText,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
            ),
            if (trailingText != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  trailingText,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ),
            const Icon(Icons.chevron_right, size: 20, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

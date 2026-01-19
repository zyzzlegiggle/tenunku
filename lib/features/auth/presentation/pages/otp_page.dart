import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
            color: Colors.grey[700],
            onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Back chevron is in AppBar
              // "Verifikasi OTP" Title
              Text(
                'Verifikasi OTP',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF616161),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Ketik kode verifikasi yang telah\ndikirim ke SMS nomor telepon\nAnda',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
              
              // OTP Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _buildOtpDigit(context)),
              ),
              const SizedBox(height: 40),

              // Kirim ulang
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Kirim ulang OTP dalam ',
                    style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
                    children: [
                      TextSpan(
                        text: '59 detik',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Kirim Button
              ElevatedButton(
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF757575),
                  elevation: 5,
                  shadowColor: Colors.black45,
                ),
                child: const Text('Kirim'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpDigit(BuildContext context) {
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
            if (value.isNotEmpty) {
                FocusScope.of(context).nextFocus();
            }
        },
      ),
    );
  }
}

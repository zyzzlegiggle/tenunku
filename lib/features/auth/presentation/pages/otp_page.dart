import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpPage extends StatefulWidget {
  final String email;
  const OtpPage({super.key, required this.email});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

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
                'Ketik kode verifikasi yang telah\ndikirim ke Email ${widget.email}',
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
                children: List.generate(
                  6,
                  (index) => _buildOtpDigit(context, index),
                ),
              ),
              const SizedBox(height: 40),

              // Kirim ulang
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Kirim ulang OTP dalam ',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
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
                onPressed: () async {
                  String otp = _controllers.map((c) => c.text).join();
                  if (otp.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Masukkan kode 6 digit')),
                    );
                    return;
                  }

                  try {
                    final authRepo = AuthRepository();
                    await authRepo.verifyEmailOtp(
                      email: widget.email,
                      token: otp,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Verifikasi Berhasil')),
                    );

                    // Check Role
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user != null) {
                      // We need to fetch the role from profiles table because auth metadata might be stale or just to be sure
                      final data = await Supabase.instance.client
                          .from('profiles')
                          .select('role')
                          .eq('id', user.id)
                          .single();
                      final role = data['role'] as String?;

                      if (role == 'penjual') {
                        context.go('/seller-setup');
                      } else {
                        context.go('/home');
                      }
                    } else {
                      context.go('/home');
                    }
                  } catch (e) {
                    if (mounted) {
                      final message = e is AuthException
                          ? e.message
                          : e.toString();
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(message)));
                    }
                  }
                },
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

  Widget _buildOtpDigit(BuildContext context, int index) {
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _controllers[index],
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
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }
}

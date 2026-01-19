import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 0 -> Pembeli, 1 -> Penjual
  int _selectedRoleIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'Login ${_selectedRoleIndex == 0 ? 'Pembeli' : 'Penjual'}',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              // Logo Placeholder
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD9D9D9),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Logo',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Role Toggle
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRoleIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedRoleIndex == 0
                                ? const Color(0xFF757575)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Pembeli',
                            style: GoogleFonts.poppins(
                              color: _selectedRoleIndex == 0
                                  ? Colors.white
                                  : Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRoleIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedRoleIndex == 1
                                ? const Color(0xFF757575)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Penjual',
                            style: GoogleFonts.poppins(
                              color: _selectedRoleIndex == 1
                                  ? Colors.white
                                  : Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Username Field
              Text(
                'Username',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Masukkan Nama Lengkap',
                  hintStyle: TextStyle(color: Colors.grey[300]),
                ),
              ),
              const SizedBox(height: 20),
              // Password Field
              Text(
                'Kata Sandi',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Masukkan Kata Sandi',
                  hintStyle: TextStyle(color: Colors.grey[300]),
                ),
              ),
              const SizedBox(height: 10),
              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Lupa Kata Sandi?',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Login Button
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement login logic
                  // For now, assume successful login to Home
                  // context.go('/home'); // Or go to OTP manually if needed, but usually login -> home
                  // Per user flow, let's just go to Home
                  context.go('/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF757575),
                  elevation: 5,
                  shadowColor: Colors.black45,
                ),
                child: const Text('Masuk'),
              ),
              const SizedBox(height: 30),
              // Register Link
              Center(
                child: GestureDetector(
                  onTap: () => context.push('/register'),
                  child: RichText(
                    text: TextSpan(
                      text: 'Belum punya akun? ',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text: 'Daftar disini',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

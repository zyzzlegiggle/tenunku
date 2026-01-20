import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository.dart';
import 'package:google_fonts/google_fonts.dart';
// import '../../../../core/api_client.dart'; // Removed ApiClient

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int _selectedRoleIndex = 0; // 0: Pembeli, 1: Penjual
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // final ApiClient _apiClient = ApiClient(); // Removed

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
                'Daftar ${_selectedRoleIndex == 0 ? 'Pembeli' : 'Penjual'}',
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
              const SizedBox(height: 20),
              // Fields
              _buildLabel('Nama Lengkap'),
              const SizedBox(height: 8),
              _buildTextField('Masukkan Nama Lengkap', _nameController),
              const SizedBox(height: 20),

              _buildLabel('Nomor Telepon'),
              const SizedBox(height: 8),
              _buildTextField('Masukkan Nomor Telepon', _phoneController),
              const SizedBox(height: 20),

              _buildLabel('E-mail'),
              const SizedBox(height: 8),
              _buildTextField('Masukkan E-mail', _emailController),
              const SizedBox(height: 20),

              _buildLabel('Kata Sandi'),
              const SizedBox(height: 8),
              _buildTextField(
                'Masukkan Kata Sandi',
                _passwordController,
                isObscure: true,
              ),
              const SizedBox(height: 30),

              // Step Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepCircle(1, true),
                  _buildStepLine(),
                  _buildStepCircle(2, false),
                  _buildStepLine(),
                  _buildStepCircle(3, false),
                ],
              ),
              const SizedBox(height: 30),

              // Selanjutnya Button
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Basic Validation
                    if (_emailController.text.isEmpty ||
                        _passwordController.text.isEmpty) {
                      throw 'Harap isi semua kolom';
                    }

                    // Call Supabase SignUp
                    // We instantiate AuthRepository directly for now
                    final authRepo = AuthRepository();
                    await authRepo.signUp(
                      email: _emailController.text,
                      password: _passwordController.text,
                      fullName: _nameController.text,
                      phone: _phoneController.text,
                      role: _selectedRoleIndex == 0 ? 'pembeli' : 'penjual',
                    );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Registrasi Berhasil. Silakan cek kode OTP di email Anda.',
                          ),
                        ),
                      );
                      // Navigate to OTP page with email as extra
                      context.push('/otp', extra: _emailController.text);
                    }
                  } catch (e) {
                    if (mounted) {
                      // Extract error message if it's a Supabase AuthException
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
                child: const Text('Selanjutnya'),
              ),
              const SizedBox(height: 20),

              // Login Link
              Center(
                child: GestureDetector(
                  onTap: () => context.push('/login'),
                  child: RichText(
                    text: TextSpan(
                      text: 'Sudah punya akun? ',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text: 'Masuk disini',
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    bool isObscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[300]),
      ),
    );
  }

  Widget _buildStepCircle(int step, bool isActive) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.grey[400] : Colors.transparent,
        border: Border.all(color: Colors.grey[400]!),
      ),
      alignment: Alignment.center,
      child: Text(
        step.toString(),
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: isActive ? Colors.white : Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildStepLine() {
    return Container(width: 20, height: 1, color: Colors.grey[400]);
  }
}

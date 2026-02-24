import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _kBluePrimary = Color(0xFF54B7C2);
// import '../../../../core/api_client.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 0 -> Pembeli, 1 -> Penjual
  int _selectedRoleIndex = 0;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _shopNameController =
      TextEditingController(); // Added for Seller Login
  // final ApiClient _apiClient = ApiClient(); // Removed

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _shopNameController.dispose();
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
                'Login ${_selectedRoleIndex == 0 ? 'Pembeli' : 'Penjual'}',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              // Logo Placeholder
              Center(child: Image.asset('logo.png', width: 120, height: 120)),
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
                                ? _kBluePrimary
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
                                ? _kBluePrimary
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
              // Fields based on role
              if (_selectedRoleIndex == 0) ...[
                // Pembeli: Username & Password
                _buildLabel('Username'),
                const SizedBox(height: 8),
                _buildTextField('Masukkan Username', _usernameController),
                const SizedBox(height: 20),
              ] else ...[
                // Penjual: Nama Lengkap & Nama Toko
                _buildLabel('Nama Lengkap'),
                const SizedBox(height: 8),
                _buildTextField('Masukkan Nama Lengkap', _fullNameController),
                const SizedBox(height: 20),

                _buildLabel('Nama Toko'),
                const SizedBox(height: 8),
                _buildTextField('Masukkan Nama Toko', _shopNameController),
                const SizedBox(height: 20),
              ],

              // Password Field (Common)
              _buildLabel('Kata Sandi'),
              const SizedBox(height: 8),
              _buildTextField(
                'Masukkan Kata Sandi',
                _passwordController,
                isObscure: true,
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
                onPressed: () async {
                  try {
                    final authRepo = AuthRepository();
                    if (_selectedRoleIndex == 0) {
                      // Login Pembeli
                      if (_usernameController.text.isEmpty ||
                          _passwordController.text.isEmpty) {
                        throw 'Harap isi username dan kata sandi';
                      }

                      await authRepo.signInWithUsername(
                        username: _usernameController.text,
                        password: _passwordController.text,
                      );
                    } else {
                      // Login Penjual
                      if (_fullNameController.text.isEmpty ||
                          _shopNameController.text.isEmpty ||
                          _passwordController.text.isEmpty) {
                        throw 'Harap isi semua kolom';
                      }

                      await authRepo.signInSeller(
                        fullName: _fullNameController.text,
                        shopName: _shopNameController.text,
                        password: _passwordController.text,
                      );
                    }

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Login Berhasil')),
                      );
                      if (_selectedRoleIndex == 1) {
                        context.go('/seller-home');
                      } else {
                        context.go('/home');
                      }
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
                  backgroundColor: _kBluePrimary,
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}

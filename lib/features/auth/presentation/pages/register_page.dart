import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _kBluePrimary = Color(0xFF54B7C2);
const Color _kYellowAccent = Color(0xFFFFE14F);

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int _selectedRoleIndex = 0; // 0: Pembeli, 1: Penjual
  int _currentStep = 1; // 1 or 2

  // Common
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Buyer Specific
  final TextEditingController _usernameController = TextEditingController();

  // Seller Specific
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _birthDateController.dispose();
    _nikController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 1) {
      bool isValid = false;
      if (_selectedRoleIndex == 0) {
        // Pembeli Step 1: Name, Phone, Email
        isValid =
            _nameController.text.isNotEmpty &&
            _phoneController.text.isNotEmpty &&
            _emailController.text.isNotEmpty;
      } else {
        // Penjual Step 1: Name, BirthDate, NIK
        isValid =
            _nameController.text.isNotEmpty &&
            _birthDateController.text.isNotEmpty &&
            _nikController.text.isNotEmpty;
      }

      if (!isValid) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Harap isi semua kolom')));
        return;
      }
      setState(() {
        _currentStep = 2;
      });
    } else {
      _register();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  bool _isValidUsername(String username) {
    return RegExp(r'^[a-zA-Z0-9_]{4,}$').hasMatch(username);
  }

  bool _isValidPassword(String password) {
    // Min 8 chars, at least one letter and one number
    return RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$').hasMatch(password);
  }

  Future<void> _register() async {
    try {
      bool isFieldsFilled = false;
      if (_selectedRoleIndex == 0) {
        // Pembeli Step 2: Username, Password
        isFieldsFilled =
            _usernameController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty;

        if (isFieldsFilled) {
          if (!_isValidUsername(_usernameController.text)) {
            throw 'Username minimal 4 karakter dan hanya boleh mengandung huruf, angka, atau underscore';
          }
        }
      } else {
        // Penjual Step 2: Phone, Email, Password
        isFieldsFilled =
            _phoneController.text.isNotEmpty &&
            _emailController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty;
      }

      if (!isFieldsFilled) {
        throw 'Harap isi semua kolom';
      }

      if (!_isValidPassword(_passwordController.text)) {
        throw 'Kata sandi minimal 8 karakter, harus mengandung huruf dan angka';
      }

      final authRepo = AuthRepository();
      final response = await authRepo.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        fullName: _nameController.text,
        phone: _phoneController.text,
        role: _selectedRoleIndex == 0 ? 'pembeli' : 'penjual',
        username: _selectedRoleIndex == 0 ? _usernameController.text : null,
        birthDate: _selectedRoleIndex == 1 ? _birthDateController.text : null,
        nik: _selectedRoleIndex == 1 ? _nikController.text : null,
      );

      if (mounted) {
        if (response.session != null) {
          // If auto-confirm is enabled in Supabase, we get a session immediately
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registrasi Berhasil. Selamat Datang!')),
          );
          if (_selectedRoleIndex == 1) {
            context.go('/seller-setup');
          } else {
            context.go('/home');
          }
        } else {
          // If email verification is enabled, session will be null
          _showEmailConfirmationDialog(_emailController.text);
        }
      }
    } catch (e) {
      if (mounted) {
        final message = e is AuthException ? e.message : e.toString();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  void _showEmailConfirmationDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Verifikasi Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.email_outlined, size: 60, color: _kBluePrimary),
            const SizedBox(height: 16),
            Text(
              'Tautan verifikasi telah dikirim ke:',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            Text(
              email,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Silakan periksa kotak masuk atau spam email Anda untuk mengaktifkan akun.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                context.go('/login'); // Redirect to login
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _kBluePrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Ke Halaman Masuk'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isPembeli = _selectedRoleIndex == 0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              // Header with Back Button logic
              Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      if (_currentStep == 2) {
                        setState(() => _currentStep = 1);
                      } else {
                        context.pop();
                      }
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    // Logo Placeholder
                    Center(
                      child: Image.asset('assets/logo.png', width: 120, height: 120),
                    ),
                    const SizedBox(height: 20),

                    // Step 1: Role Toggle
                    if (_currentStep == 1) ...[
                      // Role Selector
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => setState(() => _selectedRoleIndex = 0),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedRoleIndex == 0
                                    ? _kBluePrimary
                                    : _kBluePrimary.withOpacity(0.1),
                                foregroundColor: _selectedRoleIndex == 0
                                    ? Colors.black
                                    : Colors.black.withOpacity(0.5),
                                elevation: _selectedRoleIndex == 0 ? 5 : 0,
                                shadowColor: _selectedRoleIndex == 0
                                    ? Colors.black26
                                    : Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text('Pembeli'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => setState(() => _selectedRoleIndex = 1),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedRoleIndex == 1
                                    ? _kBluePrimary
                                    : _kBluePrimary.withOpacity(0.1),
                                foregroundColor: _selectedRoleIndex == 1
                                    ? Colors.black
                                    : Colors.black.withOpacity(0.5),
                                elevation: _selectedRoleIndex == 1 ? 5 : 0,
                                shadowColor: _selectedRoleIndex == 1
                                    ? Colors.black26
                                    : Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text('Penjual'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Fields
                      _buildLabel('Nama Lengkap'),
                      const SizedBox(height: 8),
                      _buildTextField('Masukkan Nama Lengkap', _nameController),
                      const SizedBox(height: 20),

                      if (isPembeli) ...[
                        _buildLabel('Nomor Telepon'),
                        const SizedBox(height: 8),
                        _buildTextField('Masukkan Nomor Telepon', _phoneController),
                        const SizedBox(height: 20),

                        _buildLabel('E-mail'),
                        const SizedBox(height: 8),
                        _buildTextField('Masukkan E-mail', _emailController),
                        const SizedBox(height: 20),
                      ] else ...[
                        // Penjual Step 1: Tanggal Lahir, NIK
                        _buildLabel('Tanggal Lahir'),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: IgnorePointer(
                            child: _buildTextField(
                              'YYYY-MM-DD',
                              _birthDateController,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildLabel('NIK'),
                        const SizedBox(height: 8),
                        _buildTextField('Masukkan NIK', _nikController),
                        const SizedBox(height: 20),
                      ],
                    ] else ...[
                      // Step 2 Fields
                      if (isPembeli) ...[
                        _buildLabel('Username'),
                        const SizedBox(height: 8),
                        _buildTextField('Masukkan Username', _usernameController),
                        const SizedBox(height: 20),
                      ] else ...[
                        // Penjual Step 2: Phone, Email, Password
                        _buildLabel('Nomor Telepon'),
                        const SizedBox(height: 8),
                        _buildTextField('Masukkan Nomor Telepon', _phoneController),
                        const SizedBox(height: 20),

                        _buildLabel('E-mail'),
                        const SizedBox(height: 8),
                        _buildTextField('Masukkan E-mail', _emailController),
                        const SizedBox(height: 20),
                      ],

                      _buildLabel('Kata Sandi'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        'Masukkan Kata Sandi',
                        _passwordController,
                        isObscure: true,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Step Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStepCircle(1, _currentStep >= 1),
                        _buildStepLine(),
                        _buildStepCircle(2, _currentStep >= 2),
                        if (_selectedRoleIndex == 1) ...[
                          _buildStepLine(),
                          _buildStepCircle(3, false),
                        ],
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Button
                    ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kBluePrimary,
                        elevation: 5,
                        shadowColor: Colors.black45,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _currentStep == 1 ? 'Selanjutnya' : 'Daftar',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    // Login Link
                    if (_currentStep == 1)
                      Center(
                        child: GestureDetector(
                          onTap: () => context.push('/login'),
                          child: RichText(
                            text: TextSpan(
                              text: 'Sudah punya akun? ',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Masuk disini',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[400],
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

  Widget _buildStepCircle(int step, bool isActive) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? _kYellowAccent : Colors.transparent,
        border: Border.all(
          color: isActive ? _kYellowAccent : Colors.grey[400]!,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        step.toString(),
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: isActive ? Colors.black87 : Colors.grey[400],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStepLine() {
    return Container(width: 40, height: 2, color: _kYellowAccent);
  }
}

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

  Future<void> _register() async {
    try {
      bool isValid = false;
      if (_selectedRoleIndex == 0) {
        // Pembeli Step 2: Username, Password
        isValid =
            _usernameController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty;
      } else {
        // Penjual Step 2: Phone, Email, Password
        isValid =
            _phoneController.text.isNotEmpty &&
            _emailController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty;
      }

      if (!isValid) {
        throw 'Harap isi semua kolom';
      }

      final authRepo = AuthRepository();
      await authRepo.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        fullName: _nameController.text,
        phone: _phoneController.text,
        role: _selectedRoleIndex == 0 ? 'pembeli' : 'penjual',
        username: _selectedRoleIndex == 0 ? _usernameController.text : null,
        birthDate: _selectedRoleIndex == 1 ? _birthDateController.text : null,
        nik: _selectedRoleIndex == 1 ? _nikController.text : null,
      );

      // Auto-login to establish session
      await authRepo.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Registrasi Berhasil. Silakan masuk dengan akun Anda.',
            ),
          ),
        );
        // OTP temporarily disabled
        // context.push('/otp', extra: _emailController.text);

        // Logic routing based on role
        if (_selectedRoleIndex == 1) {
          // Penjual -> Step 3
          context.go('/seller-setup');
        } else {
          // Pembeli -> Login
          context.go('/login');
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

  @override
  Widget build(BuildContext context) {
    bool isPembeli = _selectedRoleIndex == 0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Header with Back Button logic if on Step 2
              Row(
                children: [
                  if (_currentStep == 2)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => setState(() => _currentStep = 1),
                    ),
                ],
              ),
              Text(
                'Daftar ${_selectedRoleIndex == 0 ? 'Pembeli' : 'Penjual'}',
                textAlign: TextAlign.center,
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

              // Step 1: Role Toggle
              if (_currentStep == 1) ...[
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
                  _buildStepLine(),
                  _buildStepCircle(3, false),
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
              const SizedBox(height: 20),

              // Login Link
              if (_currentStep == 1)
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

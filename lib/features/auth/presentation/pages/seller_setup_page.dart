import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _kBluePrimary = Color(0xFF54B7C2);
const Color _kYellowAccent = Color(0xFFFFE14F);

class SellerSetupPage extends StatefulWidget {
  const SellerSetupPage({super.key});

  @override
  State<SellerSetupPage> createState() => _SellerSetupPageState();
}

class _SellerSetupPageState extends State<SellerSetupPage> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopAddressController = TextEditingController();
  final TextEditingController _shopDescriptionController =
      TextEditingController();

  @override
  void dispose() {
    _shopNameController.dispose();
    _shopAddressController.dispose();
    _shopDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_shopNameController.text.isEmpty ||
        _shopAddressController.text.isEmpty ||
        _shopDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Harap isi semua kolom')));
      return;
    }

    try {
      final authRepo = AuthRepository();
      await authRepo.updateShopDetails(
        shopName: _shopNameController.text,
        shopAddress: _shopAddressController.text,
        shopDescription: _shopDescriptionController.text,
      );

      if (mounted) {
        context.go('/seller-home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
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
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Text(
                'Daftar Penjual',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              Center(child: Image.asset('logo.png', width: 120, height: 120)),
              const SizedBox(height: 30),

              // Pembeli / Penjual Tab (Penjual selected, non-interactive)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Pembeli',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _kBluePrimary,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Penjual',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildLabel('Nama Toko'),
              const SizedBox(height: 8),
              _buildTextField('Masukkan Nama Toko', _shopNameController),
              const SizedBox(height: 20),

              _buildLabel('Alamat Toko'),
              const SizedBox(height: 8),
              _buildTextField('Masukkan Alamat Toko', _shopAddressController),
              const SizedBox(height: 20),

              _buildLabel('Deskripsi'),
              const SizedBox(height: 8),
              _buildTextField(
                'Masukkan Deskripsi',
                _shopDescriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: 30),

              // Step Indicator (1 - 2 - 3, step 3 active)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepCircle(1, true),
                  _buildStepLine(),
                  _buildStepCircle(2, true),
                  _buildStepLine(),
                  _buildStepCircle(3, true),
                ],
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kBluePrimary,
                  elevation: 5,
                  shadowColor: Colors.black45,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Selesai',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
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

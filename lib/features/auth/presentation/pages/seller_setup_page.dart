import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository.dart';
import 'package:google_fonts/google_fonts.dart';

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
              const SizedBox(height: 40),
              Text(
                'Masukan Identitas Toko',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 40),

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
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF757575),
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
}

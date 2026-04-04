import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'seller_settings_layout.dart';
import '../../../../auth/data/repositories/auth_repository.dart';
import '../../../data/repositories/seller_repository.dart';
import '../../../data/models/profile_model.dart';

class MyAddressPage extends StatefulWidget {
  const MyAddressPage({super.key});

  @override
  State<MyAddressPage> createState() => _MyAddressPageState();
}

class _MyAddressPageState extends State<MyAddressPage> {
  final _sellerRepo = SellerRepository();
  final _authRepo = AuthRepository();
  Profile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final user = _authRepo.currentUser;
    if (user != null) {
      final profile = await _sellerRepo.getProfile(user.id);
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateAddress(String value) async {
    if (_profile == null) return;
    try {
      setState(() => _isLoading = true);
      final json = _profile!.toJson();
      json['shop_address'] = value;
      final updated = Profile.fromJson(json);
      await _sellerRepo.updateProfile(updated);
      await _fetchProfile();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Alamat berhasil diperbarui')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memperbarui: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showEditDialog({
    required String title,
    String? currentValue,
    required Function(String) onSave,
  }) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title', style: GoogleFonts.poppins()),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Masukkan $title',
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF54B7C2)),
            ),
          ),
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text.trim());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF54B7C2)),
            child: Text('Simpan', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SellerSettingsLayout(
      title: 'Alamat Saya',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _showEditDialog(
                      title: 'Alamat Toko',
                      currentValue: _profile?.shopAddress,
                      onSave: (val) => _updateAddress(val),
                    ),
                    child: Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _profile?.fullName ?? 'Nama Penenun',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: const Color(
                                      0xFF31476C,
                                    ), // matching dark blue
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _profile?.phone ?? 'Belum mengatur no HP',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _profile?.shopAddress ??
                                      'Belum mengatur alamat',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.black54,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xFF54B7C2), // Cyan arrow
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 120), // Padding for bottom nav
                ],
              ),
            ),
    );
  }
}

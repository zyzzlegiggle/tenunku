import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'seller_settings_layout.dart';
import '../../../../auth/data/repositories/auth_repository.dart';
import '../../../data/repositories/seller_repository.dart';
import '../../../data/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountSecurityPage extends StatefulWidget {
  const AccountSecurityPage({super.key});

  @override
  State<AccountSecurityPage> createState() => _AccountSecurityPageState();
}

class _AccountSecurityPageState extends State<AccountSecurityPage> {
  final _sellerRepo = SellerRepository();
  final _authRepo = AuthRepository();
  Profile? _profile;
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final user = _authRepo.currentUser;
    if (user != null) {
      final profile = await _sellerRepo.getProfile(user.id);
      if (mounted) {
        setState(() {
          _user = user;
          _profile = profile;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfileField(String field, String value) async {
    if (_profile == null) return;
    try {
      setState(() => _isLoading = true);
      final json = _profile!.toJson();
      json[field] = value;
      final updated = Profile.fromJson(json);
      await _sellerRepo.updateProfile(updated);
      await _fetchData();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Berhasil diperbarui')));
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
    bool isPhone = false,
  }) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title', style: GoogleFonts.poppins()),
        content: TextField(
          controller: controller,
          keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
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
      title: 'Akun & Keamanan',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        _buildMenuItem(
                          context,
                          'No. Handphone',
                          trailingText: _profile?.phone ?? 'Belum diatur',
                          onTap: () => _showEditDialog(
                            title: 'No. Handphone',
                            currentValue: _profile?.phone,
                            onSave: (val) => _updateProfileField('phone', val),
                            isPhone: true,
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFF5793B)),
                        _buildMenuItem(
                          context,
                          'Email',
                          trailingText: _user?.email ?? 'Belum diatur',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Email tidak dapat diubah secara langsung.',
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFF5793B)),
                        _buildMenuItem(
                          context,
                          'Ganti Kata Sandi',
                          onTap: () =>
                              context.push('/seller/settings/change-password'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 120), // Padding for bottom nav
                ],
              ),
            ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title, {
    VoidCallback? onTap,
    String? trailingText,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
            ),
            if (trailingText != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  trailingText,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFF54B7C2)),
          ],
        ),
      ),
    );
  }
}

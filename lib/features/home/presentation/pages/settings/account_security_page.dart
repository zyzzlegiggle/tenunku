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
                        ),
                        const Divider(height: 1, color: Color(0xFFF5793B)),
                        _buildMenuItem(
                          context,
                          'Email',
                          trailingText: _user?.email ?? 'Belum diatur',
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repositories/buyer_repository.dart';
import '../../../data/models/profile_model.dart';

class BuyerAccountSecurityPage extends StatefulWidget {
  const BuyerAccountSecurityPage({super.key});

  @override
  State<BuyerAccountSecurityPage> createState() =>
      _BuyerAccountSecurityPageState();
}

class _BuyerAccountSecurityPageState extends State<BuyerAccountSecurityPage> {
  final BuyerRepository _buyerRepo = BuyerRepository();
  bool _isLoading = true;
  Profile? _profile;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _email = user.email;
      _profile = await _buyerRepo.getProfile(user.id);
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Mask string to show only start and end characters
  String _maskEmail(String? email) {
    if (email == null || !email.contains('@')) return 'Atur Sekarang';
    final parts = email.split('@');
    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 2) return '${name.substring(0, 1)}***@$domain';
    return '${name.substring(0, 1)}***@$domain';
  }

  String _maskPhone(String? phone) {
    if (phone == null || phone.isEmpty) return 'Atur Sekarang';
    if (phone.length <= 4) return phone;
    return '${phone.substring(0, 4)}********';
  }

  Future<void> _updateProfileField(String field, String value) async {
    if (_profile == null) return;
    try {
      setState(() => _isLoading = true);
      final json = _profile!.toJson();
      json[field] = value;
      final updated = Profile.fromJson(json);
      await _buyerRepo.updateProfile(updated);
      await _loadUserData();
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
    const cyanBlue = Color(0xFF54B7C2);
    const yellow = Color(0xFFFFE14F);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: cyanBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: yellow),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Akun & Keamanan',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFF4F4F4),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          context,
                          'Profil Saya',
                          onTap: () => context.push('/buyer/settings/edit-profile'),
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          context,
                          'Username',
                          trailingText: _profile?.username ?? 'Atur Sekarang',
                          onTap: () => _showEditDialog(
                            title: 'Username',
                            currentValue: _profile?.username,
                            onSave: (val) => _updateProfileField('username', val),
                          ),
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          context,
                          'No. Handphone',
                          trailingText: _maskPhone(_profile?.phone),
                          onTap: () => _showEditDialog(
                            title: 'No. Handphone',
                            currentValue: _profile?.phone,
                            onSave: (val) => _updateProfileField('phone', val),
                            isPhone: true,
                          ),
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          context,
                          'Email',
                          trailingText: _maskEmail(_email),
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
                        _buildDivider(),
                        _buildMenuItem(
                          context,
                          'Ganti Password',
                          trailingText: 'Atur Sekarang',
                          onTap: () =>
                              context.push('/buyer/settings/change-password'),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        color: cyanBlue,
        padding: const EdgeInsets.only(bottom: 16, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(context, 'Beranda', 0, Icons.home),
            _buildNavItem(context, 'Telusuri', 1, Icons.search),
            _buildNavItem(context, 'Keranjang', 2, Icons.shopping_cart),
            _buildNavItem(context, 'Akun Saya', 3, Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF5793B));
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title, {
    VoidCallback? onTap,
    String? trailingText,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B6B6B),
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
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const Icon(Icons.chevron_right, size: 24, color: Color(0xFF54B7C2)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String label,
    int index,
    IconData icon,
  ) {
    const yellow = Color(0xFFFFE14F);
    const navyBlue = Color(0xFF31476C);
    final bool isActive = index == 3;

    return GestureDetector(
      onTap: () {
        if (isActive) {
          context.pop();
        } else {
          context.go('/buyer', extra: index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isActive ? yellow : navyBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? navyBlue : Colors.grey[400],
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.white,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

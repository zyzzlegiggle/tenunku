import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repositories/user_settings_repository.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  final UserSettingsRepository _settingsRepo = UserSettingsRepository();
  String _selectedLanguage = 'id';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      final language = await _settingsRepo.getLanguage(userId);
      if (mounted) {
        setState(() {
          _selectedLanguage = language;
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveLanguage(String language) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isSaving = true);
    try {
      await _settingsRepo.saveLanguage(userId, language);
      setState(() => _selectedLanguage = language);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Bahasa berhasil disimpan',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyimpan bahasa',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const cyanBlue = Color(0xFF54B7C2);
    const yellow = Color(0xFFFFE14F);
    const orange = Color(0xFFF5793B);

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
          'Bahasa / Language',
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
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 24,
                            top: 20,
                            bottom: 8,
                          ),
                          child: Text(
                            'Pilih Bahasa',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF6B6B6B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        _buildLanguageOption(
                          context,
                          id: 'id',
                          title: 'Bahasa Indonesia',
                          isSelected: _selectedLanguage == 'id',
                          orange: orange,
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors
                              .white, // Separator if needed, although mostly relies on bg
                        ),
                        _buildLanguageOption(
                          context,
                          id: 'en',
                          title: 'English',
                          isSelected: _selectedLanguage == 'en',
                          orange: orange,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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

  Widget _buildLanguageOption(
    BuildContext context, {
    required String id,
    required String title,
    required bool isSelected,
    required Color orange,
  }) {
    return InkWell(
      onTap: _isSaving ? null : () => _saveLanguage(id),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        color: isSelected ? orange : const Color(0xFFF4F4F4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF6B6B6B),
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: Colors.white, size: 20),
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

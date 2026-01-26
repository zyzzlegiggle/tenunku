import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../../data/repositories/seller_repository.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/models/profile_model.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Controllers
  final SellerRepository _sellerRepo = SellerRepository();
  final StorageService _storageService = StorageService();
  final String _userId = Supabase.instance.client.auth.currentUser!.id;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _storyController = TextEditingController();
  final TextEditingController _hopeController = TextEditingController();
  final TextEditingController _dailyController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  File? _avatarFile;
  String? _avatarUrl;
  File? _bannerFile;
  String? _bannerUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _sellerRepo.getProfile(_userId);
      if (profile != null) {
        _nameController.text = profile.fullName ?? '';
        _shopNameController.text = profile.shopName ?? '';
        _descriptionController.text = profile.bio ?? '';
        _storyController.text = profile.description ?? '';
        _hopeController.text = profile.hope ?? '';
        _dailyController.text = profile.dailyActivity ?? '';
        _fullNameController.text = profile.fullName ?? '';
        _ageController.text = profile.age?.toString() ?? '';
        _avatarUrl = profile.avatarUrl;
        _bannerUrl = profile.bannerUrl;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat profil: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAvatar() async {
    try {
      final File? image = await _storageService.pickImage();
      if (image != null) {
        setState(() {
          _avatarFile = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengambil gambar: $e')));
      }
    }
  }

  Future<void> _pickBanner() async {
    try {
      final File? image = await _storageService.pickImage();
      if (image != null) {
        setState(() {
          _bannerFile = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengambil banner: $e')));
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      // proper upload if avatar file exists
      if (_avatarFile != null) {
        final url = await _storageService.uploadImage(
          'avatars',
          _avatarFile!,
          path: '$_userId/avatar.jpg',
        );
        _avatarUrl = url;
      }

      // proper upload if banner file exists
      if (_bannerFile != null) {
        final url = await _storageService.uploadImage(
          'banners',
          _bannerFile!,
          path: '$_userId/banner.jpg',
        );
        _bannerUrl = url;
      }

      final updatedProfile = Profile(
        id: _userId,
        fullName: _fullNameController.text,
        shopName: _shopNameController.text,
        bio: _descriptionController.text,
        description: _storyController.text,
        hope: _hopeController.text,
        dailyActivity: _dailyController.text,
        age: int.tryParse(_ageController.text),
        avatarUrl: _avatarUrl,
        bannerUrl: _bannerUrl,
      );

      await _sellerRepo.updateProfile(updatedProfile);

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan profil: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Text(
          'TENUNKu',
          style: GoogleFonts.poppins(
            color: const Color(0xFF212121),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF757575)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  // Profile Header Section
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFAAAAAA),
                      image: _bannerFile != null
                          ? DecorationImage(
                              image: FileImage(_bannerFile!),
                              fit: BoxFit.cover,
                            )
                          : (_bannerUrl != null && _bannerUrl!.isNotEmpty)
                          ? DecorationImage(
                              image: NetworkImage(_bannerUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar
                            GestureDetector(
                              onTap: _pickAvatar,
                              child: Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF616161),
                                      image: _avatarFile != null
                                          ? DecorationImage(
                                              image: FileImage(_avatarFile!),
                                              fit: BoxFit.cover,
                                            )
                                          : _avatarUrl != null
                                          ? DecorationImage(
                                              image: NetworkImage(_avatarUrl!),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child:
                                        (_avatarFile == null &&
                                            _avatarUrl == null)
                                        ? const Center(
                                            child: Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Colors.white,
                                            ),
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeaderInput(
                                    _nameController,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    hintText: 'Nama Penenun',
                                  ),
                                  _buildHeaderInput(
                                    _shopNameController,
                                    fontSize: 14,
                                    hintText: 'Nama Toko',
                                  ),
                                  const SizedBox(height: 8),
                                  _buildHeaderInput(
                                    _descriptionController,
                                    fontSize: 10,
                                    maxLines: 5,
                                    hintText:
                                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit...',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _pickBanner,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF616161),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Masukan Gambar Banner',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sections
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    'Kisah',
                    _storyController,
                    'Saya mulai belajar menenun sejak usia 9 tahun dari ibu saya. Menenun bukan hanya pekerjaan, tetapi juga cara saya berkontribusi untuk keluarga...',
                  ),
                  _buildSectionCard(
                    'Harapan',
                    _hopeController,
                    'Saya berharap tenun, khususnya tenun Badui, dapat dikenal di seluruh dunia...',
                  ),
                  _buildSectionCard(
                    'Keseharian',
                    _dailyController,
                    'Pagi hari saya mulai dengan berdoa, lalu mengumpulkan benang dan mempersiapkan alat tenun...',
                  ),

                  // Data Diri Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors
                            .transparent, // Wrapper is transparent, inner is styled
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          children: [
                            // Header
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              color: const Color(
                                0xFF616161,
                              ), // Dark Grey Header
                              child: Text(
                                'Data Diri',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            // Body
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              color: const Color(0xFFEEEEEE), // Light Grey Body
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Nama Lengkap', isDarkText: true),
                                  _buildRoundedInput(_fullNameController),
                                  const SizedBox(height: 12),
                                  _buildLabel('Umur', isDarkText: true),
                                  _buildRoundedInput(_ageController),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF616161),
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD6D6D6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Simpan',
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInput(
    TextEditingController controller, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    int maxLines = 1,
    String hintText = 'Edit...',
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE), // Light Greyish like Keseharian
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Colors.black87, // Dark Text
        ),
        maxLines: maxLines,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: Colors.black38, // Dark Hint
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    String title,
    TextEditingController controller,
    String placeholder,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF616161), // Dark Grey Header
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            // Body
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFEEEEEE), // Light Grey Body
              child: TextField(
                controller: controller,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.black87, // Black text on light body
                  height: 1.5,
                ),
                maxLines: null,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: placeholder,
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isDarkText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 4),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: isDarkText ? Colors.black87 : Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRoundedInput(TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE), // Light Greyish like Keseharian
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(color: Colors.black87), // Dark Text
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }
}

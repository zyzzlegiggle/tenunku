import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../../data/repositories/buyer_repository.dart';
import '../../data/models/profile_model.dart';
import '../../../../core/services/storage_service.dart';

class BuyerEditProfilePage extends StatefulWidget {
  const BuyerEditProfilePage({super.key});

  @override
  State<BuyerEditProfilePage> createState() => _BuyerEditProfilePageState();
}

class _BuyerEditProfilePageState extends State<BuyerEditProfilePage> {
  final BuyerRepository _repository = BuyerRepository();
  final StorageService _storageService = StorageService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  String? _selectedGender;
  DateTime? _birthDate;
  Profile? _profile;
  File? _avatarFile;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final profile = await _repository.getProfile(userId);
    final email = Supabase.instance.client.auth.currentUser?.email;

    if (mounted) {
      setState(() {
        _profile = profile;
        _nameController.text = profile?.fullName ?? '';
        _bioController.text =
            profile?.description ??
            ''; // using description as bio based on previous page logic
        _phoneController.text = profile?.phone ?? '';
        _emailController.text = email ?? '';
        _isLoading = false;
      });
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      String? avatarUrl = _profile?.avatarUrl;

      // Upload new avatar if selected
      if (_avatarFile != null) {
        avatarUrl = await _storageService.uploadImage(
          'avatars',
          _avatarFile!,
          path: '$userId/avatar.jpg',
        );
      }

      final updatedProfile = Profile(
        id: userId,
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        description: _bioController.text.trim(),
        age: _profile?.age,
        avatarUrl: avatarUrl,
        dailyActivity: _profile?.dailyActivity,
        hope: _profile?.hope,
        role: _profile?.role,
        shopName: _profile?.shopName,
      );

      await _repository.updateProfile(updatedProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil disimpan')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _showEditDialog(
    String title,
    TextEditingController controller,
    VoidCallback onSave,
  ) async {
    final tempController = TextEditingController(text: controller.text);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Ubah $title',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: TextField(
            controller: tempController,
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
              onPressed: () => context.pop(),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                controller.text = tempController.text;
                onSave();
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF54B7C2),
              ),
              child: Text(
                'Simpan',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showGenderDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Pilih Jenis Kelamin',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Laki-laki', 'Perempuan'].map((gender) {
              return ListTile(
                title: Text(gender, style: GoogleFonts.poppins()),
                leading: Radio<String>(
                  value: gender,
                  groupValue: _selectedGender,
                  activeColor: const Color(0xFF54B7C2),
                  onChanged: (value) {
                    setState(() => _selectedGender = value);
                    context.pop();
                    _saveProfile();
                  },
                ),
                onTap: () {
                  setState(() => _selectedGender = gender);
                  context.pop();
                  _saveProfile();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF54B7C2)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white, // Inner background
      appBar: AppBar(
        backgroundColor: const Color(0xFF54B7C2), // Cyan blue background
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFFFFE14F),
          ), // Yellow arrow
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Edit Profil',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Loading Overlay Trigger
          if (_isSaving)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                color: Color(0xFFFFE14F),
                backgroundColor: Color(0xFF54B7C2),
              ),
            ),
          SingleChildScrollView(
            child: Column(
              children: [
                // Navy Banner Section with Profile PIC
                Container(
                  width: double.infinity,
                  color: const Color(0xFF31476C), // Navy Background
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await _pickAvatar();
                          if (_avatarFile != null) {
                            _saveProfile();
                          }
                        },
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(
                              0xFFF5793B,
                            ), // Orange circular background
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _avatarFile != null
                              ? ClipOval(
                                  child: Image.file(
                                    _avatarFile!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : _profile?.avatarUrl != null &&
                                    _profile!.avatarUrl!.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    _profile!.avatarUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 70, // White person icon
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          await _pickAvatar();
                          if (_avatarFile != null) {
                            _saveProfile();
                          }
                        },
                        child: Text(
                          'Ubah',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Form List Container
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      // Group 1: Nama, Bio
                      _buildFormRow(
                        label: 'Nama',
                        value: _nameController.text,
                        placeholder: 'Atur Sekarang',
                        hasBottomBorder: true,
                        onTap: () => _showEditDialog(
                          'Nama',
                          _nameController,
                          _saveProfile,
                        ),
                      ),
                      _buildFormRow(
                        label: 'Bio',
                        value: _bioController.text,
                        placeholder: 'Atur Sekarang',
                        hasBottomBorder: false,
                        onTap: () => _showEditDialog(
                          'Bio',
                          _bioController,
                          _saveProfile,
                        ),
                      ),

                      const SizedBox(height: 16), // Separation space
                      // Group 2: Jenis Kelamin, Tanggal Lahir
                      _buildFormRow(
                        label: 'Jenis Kelamin',
                        value: _selectedGender,
                        placeholder: 'Atur Sekarang',
                        hasBottomBorder: true,
                        onTap: _showGenderDialog,
                      ),
                      _buildFormRow(
                        label: 'Tanggal lahir',
                        value: _birthDate != null
                            ? '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}'
                            : null,
                        placeholder: '**/**/****',
                        hasBottomBorder: false,
                        onTap: () async {
                          await _selectDate();
                          _saveProfile();
                        },
                      ),

                      const SizedBox(height: 16), // Separation space
                      // Group 3: No Handphone, Email
                      _buildFormRow(
                        label: 'No. Handphone',
                        value: _phoneController.text,
                        placeholder: '08xxxxxxxxx',
                        hasBottomBorder: true,
                        onTap: () => _showEditDialog(
                          'No. Handphone',
                          _phoneController,
                          _saveProfile,
                        ),
                      ),
                      _buildFormRow(
                        label: 'Email',
                        value: _emailController.text,
                        placeholder: 'user@gmail.com',
                        hasBottomBorder: false,
                        onTap: () {
                          // Standard edit profile email logic (usually locked)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Email tidak bisa diubah.'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80), // Padding above nav bar
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF54B7C2), // Cyan blue background
        padding: const EdgeInsets.only(bottom: 16, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              'Beranda',
              Icons.home,
              false,
              () => context.go('/buyer'),
            ),
            _buildNavItem('Telusuri', Icons.search, false, () {}),
            _buildNavItem('Keranjang', Icons.shopping_cart, false, () {}),
            _buildNavItem('Akun Saya', Icons.person, true, () => context.pop()),
          ],
        ),
      ),
    );
  }

  Widget _buildFormRow({
    required String label,
    required String? value,
    required String placeholder,
    required bool hasBottomBorder,
    required VoidCallback onTap,
  }) {
    final bool isEmpty = value == null || value.trim().isEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5), // Light Gray Row
          border: hasBottomBorder
              ? const Border(
                  bottom: BorderSide(color: Color(0xFFF5793B), width: 1),
                ) // Orange line border
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF696969), // Dark Gray labels
              ),
            ),
            Row(
              children: [
                Text(
                  isEmpty ? placeholder : value,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFA0A0A0), // Light Gray value
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF54B7C2), // Cyan Chevron
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    String label,
    IconData icon,
    bool isActive,
    VoidCallback onTap,
  ) {
    const yellow = Color(0xFFFFE14F);
    const navyBlue = Color(0xFF31476C);

    return GestureDetector(
      onTap: onTap,
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
              color: isActive ? navyBlue : Colors.white70,
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

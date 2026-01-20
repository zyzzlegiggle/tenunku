import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Controllers
  final TextEditingController _nameController = TextEditingController(
    text: 'Nama Penenun',
  );
  final TextEditingController _shopNameController = TextEditingController(
    text: 'Nama Toko',
  );
  final TextEditingController _descriptionController = TextEditingController(
    text:
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud',
  );
  final TextEditingController _storyController = TextEditingController(
    text:
        'Saya mulai belajar menenun sejak usia 9 tahun dari ibu saya. Menenun bukan hanya pekerjaan, tetapi juga cara saya berkontribusi untuk keluarga dan melestarikan budaya nenek moyang. Setiap pagi, setelah mengurus rumah, saya duduk di depan alat tenun dan merasakan kedamaian yang luar biasa.',
  );
  final TextEditingController _hopeController = TextEditingController(
    text:
        'Saya berharap tenun, khususnya tenun Badui, dapat dikenal di seluruh dunia dan anak cucu saya nantinya dapat tetap menjaga tradisi ini. Melalui TenunKu, saya ingin lebih banyak orang mengenal kerja keras dan nilai-nilai yang terkandung dalam setiap helai kain yang saya buat.',
  );
  final TextEditingController _dailyController = TextEditingController(
    text: 'Ceritakan keseharian anda disini...',
  );
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

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
                    color: const Color(0xFFAAAAAA),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar
                            Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF616161),
                                  ),
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
                                  ),
                                  _buildHeaderInput(
                                    _shopNameController,
                                    fontSize: 14,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildHeaderInput(
                                    _descriptionController,
                                    fontSize: 10,
                                    maxLines: 5,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
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
                      ],
                    ),
                  ),

                  // Sections
                  const SizedBox(height: 16),
                  _buildSectionCard('Kisah', _storyController),
                  _buildSectionCard('Harapan', _hopeController),
                  _buildSectionCard('Keseharian', _dailyController),

                  // Data Diri Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF757575),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data Diri',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Nama Lengkap'),
                          _buildRoundedInput(_fullNameController),
                          const SizedBox(height: 12),
                          _buildLabel('Umur'),
                          _buildRoundedInput(_ageController),
                        ],
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
                    onPressed: () {
                      // Save logic here
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD6D6D6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
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
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Colors.black87,
        ),
        maxLines: maxLines,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF757575), // Dark grey from screenshots
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFE0E0E0,
                ), // Light grey text area background
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: controller,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                maxLines: null, // Allow multiline
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 4),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRoundedInput(TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFAAAAAA),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(color: Colors.black87),
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }
}

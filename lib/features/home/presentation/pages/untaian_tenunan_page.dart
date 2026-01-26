import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class UntaianTenunanPage extends StatefulWidget {
  const UntaianTenunanPage({super.key});

  @override
  State<UntaianTenunanPage> createState() => _UntaianTenunanPageState();
}

class _UntaianTenunanPageState extends State<UntaianTenunanPage> {
  int _selectedTabIndex = 0;

  final List<String> _tabs = ['Proses', 'Filosofi', 'Adat Istiadat', 'Sejarah'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            floating: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF424242)),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Untaian Setiap Tenunan',
              style: GoogleFonts.poppins(
                color: const Color(0xFF333333),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            centerTitle: true,
          ),
          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                _buildHeaderSection(),
                const SizedBox(height: 24),
                // Intro Cards (Replaces Banner/Video)
                _buildIntroCards(),
                const SizedBox(height: 24),
                // Tabs (2 Columns)
                _buildTabGrid(),
                const SizedBox(height: 16),
                // Carousel
                _buildImageCarousel(),
                const SizedBox(height: 16),
                // Tab content
                _buildTabContent(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Centered
        children: [
          // Logo Placeholder
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFFE0E0E0),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'Logo',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Untaian Setiap Tenunan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Big Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Perjalanan\nBenang Menjadi\nKarya',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF616161),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Setiap kain tenun adalah hasil dari\ndedikasi, kepercayaan, dan warisan\nbudaya yang telah dijaga selama\nberabad-abad. Mari kita telusuri\nkisah di balik setiap helai\nbenangnya.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Two Feature Cards
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF757575),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Ikon',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '100% Alami',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF616161),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pewarna dari tumbuhan tanpa bahan kimia',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF757575),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Ikon',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '500+ (?) Tahun',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF616161),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tradisi yang dijaga turun-temurun',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5, // Buttons
        ),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTabIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = index),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF424242) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : const Color(0xFFE0E0E0),
                ),
              ),
              child: Text(
                _tabs[index],
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageCarousel() {
    String placeholderText = '';
    switch (_selectedTabIndex) {
      case 0:
        placeholderText = 'foto kolase proses';
        break;
      case 1:
        placeholderText = 'foto para suku badui';
        break;
      case 2:
        placeholderText = 'foto para penenun saat berkegiatan';
        break;
      case 3:
        placeholderText = 'foto para suku badui';
        break;
      default:
        placeholderText = 'foto kolase proses';
    }

    return Container(
      width: double.infinity,
      height: 180, // Adjust height as needed
      color: const Color(0xFFE0E0E0), // Light grey background
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {}, // No action yet
              icon: const Icon(Icons.chevron_left, color: Color(0xFF757575)),
            ),
            Text(
              placeholderText,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF757575),
              ),
              textAlign: TextAlign.center,
            ),
            IconButton(
              onPressed: () {}, // No action yet
              icon: const Icon(Icons.chevron_right, color: Color(0xFF757575)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildTahapanMenenunTab();
      case 1:
        return _buildFilosofiTab();
      case 2:
        return _buildAdatIstiadatTab();
      case 3:
        return _buildSejarahTab();
      default:
        return _buildTahapanMenenunTab();
    }
  }

  Widget _buildTahapanMenenunTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _buildContentCard(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF757575),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  'Ikon',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tahapan Menenun\nTradisional',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF616161),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Proses pembuatan kain tenun Badui adalah sebuah ritual yang penuh makna dan kesabaran. Setiap tahapan dilakukan dengan penuh kehati-hatian dan doa.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            leading: const Icon(Icons.check, color: Color(0xFF424242)),
            title: 'Pemilihan Benang',
            description:
                'Benang kapas dipilih dengan teliti, biasanya yang berwarna putih alami atau biru indigo',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            leading: const Icon(Icons.check, color: Color(0xFF424242)),
            title: 'Pewarnaan Alami',
            description:
                'Menggunakan pewarna dari tumbuhan seperti tarum untuk warna biru, mengkudu untuk merah, dan kunyit untuk kuning',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            leading: const Icon(Icons.check, color: Color(0xFF424242)),
            title: 'Persiapan Lungsi',
            description:
                'Benang lungsi (benang vertikal) ditata pada alat tenun tradisional yang disebut "Cukrik"',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            leading: const Icon(Icons.check, color: Color(0xFF424242)),
            title: 'Penyelesaian',
            description:
                'Kain yang sudah jadi dicuci dan dijemur dengan cara tradisional',
          ),
        ],
      ),
    );
  }

  Widget _buildFilosofiTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildContentCard(
            children: [
              Text(
                'Makna Spiritual Menenun',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF616161),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bagi masyarakat Badui, menenun adalah bentuk ibadah dan meditasi.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                leading: const Icon(Icons.check, color: Color(0xFF424242)),
                title: 'Kesabaran dan Ketekunan',
                description:
                    'Proses menenun yang lama mengajarkan kesabaran dan ketekunan.',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                leading: const Icon(Icons.check, color: Color(0xFF424242)),
                title: 'Harmoni dengan Alam',
                description:
                    'Pewarnaan alami menciptakan kain cerah yang unik.',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                leading: const Icon(Icons.check, color: Color(0xFF424242)),
                title: 'Warisan Leluhur',
                description:
                    'Setiap motif merupakan warisan yang tidak boleh diubah.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContentCard(
            children: [
              Text(
                'Simbolisme Warna',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF616161),
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                leading: const Icon(
                  Icons.circle,
                  color: Colors.white,
                  size: 14,
                ), // White circle for Putih? Need contrasting background or border? Icon is just symbol.
                title: 'Putih',
                description: 'Kesucian dan kemurnian, hanya untuk Badui Dalam.',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                leading: const Icon(
                  Icons.circle,
                  color: Colors.black,
                  size: 14,
                ),
                title: 'Biru/Hitam',
                description: 'Kebijaksanaan untuk Badui Luar.',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                leading: const Icon(Icons.circle, color: Colors.red, size: 14),
                title: 'Merah',
                description: 'Keberanian (Simbolis).',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildQuestionCardWithButtons(
            title: 'Tertarik Memiliki Karya Tenun Asli?',
            description:
                'Setelah memahami makna dan proses pembuatannya, kini saatnya untuk memiliki dan melestarikan warisan budaya ini.',
            buttons: [
              'Katalog Marketplace Budaya',
              'Kenali Para Penenun',
              'Lihat Koleksi Tenun',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdatIstiadatTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildContentCard(
            children: [
              Text(
                'Kewajiban Perempuan Badui',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF616161),
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                leading: const Icon(Icons.check, color: Color(0xFF424242)),
                title: 'Pendidikan Dini',
                description:
                    'Anak perempuan sudah mulai belajar menenun sejak usia dini.',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                leading: const Icon(Icons.check, color: Color(0xFF424242)),
                title: 'Simbol Kedewasaan',
                description:
                    'Menenun merupakan simbol kedewasaan dan kesiapan menikah.',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                leading: const Icon(Icons.check, color: Color(0xFF424242)),
                title: 'Upacara Adat',
                description:
                    'Kain hasil tenunan digunakan untuk upacara adat penting.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContentCard(
            children: [
              Text(
                'Ritual dan Tradisi',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF616161),
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                leading: const Icon(Icons.check, color: Color(0xFF424242)),
                title: 'Doa Sebelum Menenun',
                description: 'Doa dan ritual harus dilakukan sebelum menenun.',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                leading: const Icon(Icons.check, color: Color(0xFF424242)),
                title: 'Hari Sakral',
                description:
                    'Terdapat hari-hari tertentu yang dianggap sakral untuk menenun.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildQuestionCard(
            title: 'Tertarik Memiliki Karya Tenun Asli?',
            description:
                'Jelajahi koleksi tenun tradisional asli dari para penenun Badui dan daerah lainnya di Indonesia.',
          ),
        ],
      ),
    );
  }

  Widget _buildSejarahTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildContentCard(
            children: [
              Text(
                "Alat Tenun 'Cukrik'",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF616161),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Alat tenun yang digunakan disebut 'Cukrik' atau 'Gedogan'.",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                leading: const Icon(Icons.check, color: Color(0xFF424242)),
                title: 'Bahan Alami',
                description:
                    'Dibuat dari kayu pilihan seperti kayu nangka atau kayu asem.',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                leading: const Icon(Icons.check, color: Color(0xFF424242)),
                title: 'Tanpa Logam',
                description:
                    'Tidak menggunakan paku atau baut logam, hanya ikatan tali dan rotan.',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                leading: const Icon(Icons.check, color: Color(0xFF424242)),
                title: 'Desain Warisan',
                description:
                    'Diwariskan antargenerasi tenun secara alami tanpa mengubah teknik.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContentCard(
            children: [
              Text(
                'Generasi ke Generasi',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF616161),
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                leading: const Icon(Icons.check, color: Color(0xFF424242)),
                title: 'Pendidikan Lisan',
                description:
                    'Tidak ada sekolah formal, semua pembelajaran dilakukan dari ibu ke anak.',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                leading: const Icon(Icons.check, color: Color(0xFF424242)),
                title: 'Milik Keluarga',
                description:
                    'Setiap keluarga memiliki alat tenun sendiri yang diwariskan.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Question card with buttons
          _buildQuestionCardWithButtons(
            title: 'Tertarik Memiliki Karya Tenun Asli?',
            description:
                'Setelah memahami makna dan proses pembuatannya, kini saatnya untuk memiliki dan melestarikan warisan budaya ini.',
            buttons: [
              'Katalog Marketplace Budaya',
              'Kenali Para Penenun',
              'Lihat Koleksi Tenun',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoCard({
    required Widget leading,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            // Checkmark or Number wrapper if needed, but leading can handle it.
            // If the leading is just an icon, we might want to wrap it here or pass the wrapped widget.
            // In usage, I'm passing Icon.
            // But aligned to top.
            alignment: Alignment.topCenter,
            child: leading,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF424242),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard({
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF424242),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[300],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Pelajari Lebih Lanjut',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF424242),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // _buildCategoryGridItem Removed

  Widget _buildQuestionCardWithButtons({
    required String title,
    required String description,
    required List<String> buttons,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          // Action buttons
          ...buttons.map(
            (button) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF424242),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  button,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

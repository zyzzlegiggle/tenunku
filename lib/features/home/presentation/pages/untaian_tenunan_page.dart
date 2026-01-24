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

  final List<String> _tabs = [
    'Tahapan Menenun',
    'Filosofi',
    'Adat Istiadat',
    'Sejarah',
  ];

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
                // Main banner
                _buildMainBanner(),
                const SizedBox(height: 16),
                // Video section
                _buildVideoSection(),
                const SizedBox(height: 24),
                // Tabs
                _buildTabBar(),
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
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFE0E0E0),
            child: Icon(Icons.person, size: 30, color: Colors.grey[600]),
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

  Widget _buildMainBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Perjalanan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF424242),
            ),
          ),
          Text(
            'Benang Menjadi',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF424242),
            ),
          ),
          Text(
            'Karya',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF424242),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'foto desa',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'foto desa',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF424242),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '10.0 K Tenun',
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.play_circle_outline,
              size: 50,
              color: Colors.grey[600],
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Text(
              'Video Proses Menenun',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final isSelected = _selectedTabIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = index),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF424242)
                      : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _tabs[index],
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            );
          }),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            'Tahapan Menenun Tradisional',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          // Step cards
          _buildStepCard(
            number: '1',
            title: 'Persiapan Bahan',
            description:
                'Menyiapkan benang, pewarna alami, dan alat tenun tradisional.',
          ),
          const SizedBox(height: 12),
          _buildStepCard(
            number: '2',
            title: 'Pewarnaan Benang',
            description:
                'Proses mewarnai benang dengan pewarna alami dari tumbuhan.',
          ),
          const SizedBox(height: 12),
          _buildStepCard(
            number: '3',
            title: 'Proses Menenun',
            description:
                'Menenun benang menjadi kain dengan teknik tradisional turun temurun.',
          ),
          const SizedBox(height: 24),
          // Warna dan Dedikasi section
          _buildSectionCard(
            title: 'Warna dan Dedikasi',
            description:
                'Setiap warna dalam tenun memiliki makna mendalam yang diwariskan dari generasi ke generasi. Proses pewarnaan alami membutuhkan kesabaran dan dedikasi tinggi.',
          ),
          const SizedBox(height: 16),
          // Identity question card
          _buildQuestionCard(
            title: 'Terbuak Identitas Karya Tenun Anda?',
            description:
                'Pelajari lebih lanjut tentang makna di balik setiap karya tenun dan temukan identitas unik Anda.',
          ),
        ],
      ),
    );
  }

  Widget _buildFilosofiTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category grid at top
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _buildCategoryGridItem(
                icon: Icons.settings,
                title: 'Proses\nPembuatan Tenun',
              ),
              _buildCategoryGridItem(
                icon: Icons.auto_stories,
                title: 'Adat Istiadat\nMenenun',
              ),
              _buildCategoryGridItem(
                icon: Icons.psychology_outlined,
                title: 'Kepercayaan &\nFilosofi Tenun',
              ),
              _buildCategoryGridItem(
                icon: Icons.history,
                title: 'Sejarah Tenun',
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Label section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF424242),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Arti pada suku\nBadui',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Makna Spiritual Menenun section
          _buildDetailSectionCard(
            title: 'Makna Spiritual Menenun',
            description:
                'Bagi masyarakat Badui, menenun adalah bentuk ibadah dan meditasi. Setiap gerakan memiliki makna spiritual yang dalam.',
            checkItems: [
              'Kesabaran dan Ketekunan - Proses menenun yang lama mengajarkan kesabaran dan ketekunan, nilai-nilai luhur yang diagungkan',
              'Harmoni dengan Alam - Pewarnaan alami menciptakan kain cerah yang unik, perpaduan sempurna bahan-bahan alami',
              'Warisan Leluhur - Setiap motif merupakan warisan yang tidak boleh diubah atau dikombinasikan sembarangan',
            ],
          ),
          const SizedBox(height: 16),
          // Simbolisme Warna section
          _buildDetailSectionCard(
            title: 'Simbolisme Warna',
            description:
                'Setiap warna dalam tenun Badui memiliki makna filosofis yang mendalam.',
            checkItems: [
              'Putih - Kesucian dan kemurnian, hanya untuk Badui Dalam',
              'Biru/Hitam - Kebijaksanaan untuk Badui Luar',
              'Merahhanahan untuk Badui Luar',
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

  Widget _buildAdatIstiadatTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category grid at top
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _buildCategoryGridItem(
                icon: Icons.settings,
                title: 'Proses\nPembuatan Tenun',
              ),
              _buildCategoryGridItem(
                icon: Icons.star_border,
                title: 'Karakteristik\nTenun',
              ),
              _buildCategoryGridItem(
                icon: Icons.people_outline,
                title: 'Kegunaan dalam\nKonteks Sosial',
              ),
              _buildCategoryGridItem(
                icon: Icons.history,
                title: 'Sejarah Tenun',
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Adat dalam Pencelupan section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF424242),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Adat dalam\nPencelupan Tekstil',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Kewajiban Perempuan Badui section
          _buildDetailSectionCard(
            title: 'Kewajiban Perempuan Badui',
            description:
                'Dalam masyarakat Badui, tenun bukan sekadar kerajinan, tetapi kewajiban sakral yang diwariskan dari generasi ke generasi dengan aturan ketat.',
            checkItems: [
              'Anak perempuan sudah mulai belajar menenun sejak usia dini',
              'Menenun merupakan simbol kedewasaan dan kesiapan menikah',
              'Kain hasil tenunan digunakan untuk upacara adat penting',
            ],
          ),
          const SizedBox(height: 16),
          // Ritual dan Tradisi section
          _buildDetailSectionCard(
            title: 'Ritual dan Tradisi',
            description:
                'Aktivitas menenun di kalangan Badui penuh upacara ritual dan pelepasan yang mengikat secara spiritual.',
            checkItems: [
              'Doa dan ritual harus dilakukan sebelum menenun',
              'Terdapat hari-hari tertentu yang dianggap sakral untuk menenun',
              'Hasil tenunan yang cacat dianggap sebagai pertanda tertentu',
            ],
          ),
          const SizedBox(height: 16),
          // Question card
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category grid at top
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _buildCategoryGridItem(
                icon: Icons.settings,
                title: 'Proses\nPembuatan Tenun',
              ),
              _buildCategoryGridItem(
                icon: Icons.auto_stories,
                title: 'Adat Istiadat\nMenenun',
              ),
              _buildCategoryGridItem(
                icon: Icons.psychology_outlined,
                title: 'Kepercayaan &\nFilosofi Tenun',
              ),
              _buildCategoryGridItem(
                icon: Icons.history,
                title: 'Sejarah Tenun',
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Label section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF424242),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Alat tenun suku\nBadui',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Alat Tenun Tradisional section
          _buildDetailSectionCard(
            title: "Alat Tenun Tradisional Badui 'Cukrik'",
            description:
                "Alat tenun yang digunakan masyarakat Badui disebut 'Cukrik' atau 'Gedogan'. Alat ini telah digunakan secara turun-temurun selama bertahun-tahun tanpa perubahan desain yang signifikan.",
            checkItems: [
              'Dibuat dari kayu pilihan seperti kayu nangka atau kayu asem',
              'Tidak menggunakan paku atau baut logam, hanya ikatan tali dan rotan',
              'Diwariskan antargenerasi tenun secara alami tanpa mengubah teknik tradisional',
              'Dapat disimpan dengan mudah sehingga mudah dibawa',
            ],
          ),
          const SizedBox(height: 16),
          // Generasi ke Generasi section
          _buildDetailSectionCard(
            title: 'Generasi ke Generasi',
            description:
                'Pengetahuan tentang pembuatan dan penggunaan alat tenun diwariskan secara lisan dan praktik langsung.',
            checkItems: [
              'Tidak ada sekolah formal, semua pembelajaran dilakukan dari ibu ke anak',
              'Setiap keluarga memiliki alat tenun sendiri yang diwariskan',
              'Tradisi ini telah bertahan selama lebih dari 500 tahun tanpa perubahan berarti',
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

  Widget _buildStepCard({
    required String number,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF424242),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
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

  Widget _buildSectionCard({
    required String title,
    required String description,
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
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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

  Widget _buildCategoryGridItem({
    required IconData icon,
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.grey[600]),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSectionCard({
    required String title,
    required String description,
    required List<String> checkItems,
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
          // Header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF424242),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Description
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          // Check items
          ...checkItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    child: Icon(Icons.check, size: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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

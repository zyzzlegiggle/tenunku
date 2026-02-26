import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class BenangMembumiPage extends StatefulWidget {
  const BenangMembumiPage({super.key});

  @override
  State<BenangMembumiPage> createState() => _BenangMembumiPageState();
}

class _BenangMembumiPageState extends State<BenangMembumiPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ---- CUSTOM HEADER ----
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 16, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF424242),
                    ),
                    onPressed: () => context.pop(),
                  ),
                  Image.asset('assets/logo.png', width: 32, height: 32),
                ],
              ),
            ),
            // Title — less top padding, some bottom padding
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: Text(
                'Benang Membumi',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF5A5A5A),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            // Tabs
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTab('Arti Warna', 0),
                  _buildTab('Jenis Pola', 1),
                  _buildTab('Penggunaan', 2),
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 12,
                bottom: 24,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: _tabController.index == 1
                        ? 'Cari Arti Pola..'
                        : 'Cari Nama Warna..',
                    hintStyle: GoogleFonts.poppins(
                      color: const Color(0xFFBDBDBD),
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            // Tab content with fade overlay at top
            Expanded(
              child: Stack(
                children: [
                  _buildTabContent(),
                  // Gradient fade at top for smooth scroll transition
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 18,
                    child: IgnorePointer(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white, Color(0x00FFFFFF)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_tabController.index) {
      case 0:
        return _ArtiWarnaTab(searchQuery: _searchQuery);
      case 1:
        return _ArtiPolaTab();
      case 2:
        return _PenggunaanTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTab(String label, int index) {
    final isActive = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isActive
                  ? const Color(0xFF54B7C2)
                  : const Color(0xFFBDBDBD),
              fontSize: isActive ? 15 : 13,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          if (isActive)
            Container(
              height: 2.5,
              width: label.length * 5.4,
              decoration: BoxDecoration(
                color: const Color(0xFF54B7C2),
                borderRadius: BorderRadius.circular(2),
              ),
            )
          else
            const SizedBox(height: 2.5),
        ],
      ),
    );
  }
}

// ==================== ARTI WARNA TAB ====================

class _ArtiWarnaTab extends StatelessWidget {
  final String searchQuery;

  const _ArtiWarnaTab({this.searchQuery = ''});

  static const List<Map<String, dynamic>> _allColors = [
    {
      'name': 'Warna Biru',
      'color': Color(0xFF39598E),
      'description':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      'subtitle':
          'Warna biru berasal dari <b>daun tarum</b>, tanaman yang sejak lama digunakan sebagai pewarna tradisional. Proses fermentasi daun tarum menghasilkan warna biru yang lembut dan alami. Warna Biru ini juga menjadi salah satu ciri khas dari masyarakat Badui disana.',
      'image': 'assets/benangmembumi/biru.png',
    },
    {
      'name': 'Warna Kuning',
      'color': Color(0xFFFFE14F),
      'description':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      'subtitle':
          'Warna kuning diperoleh dari <b>kayu nangka</b> yang direbus hingga mengeluarkan pigmen alaminya. Proses ini membutuhkan ketelatenan karena intensitas warna bergantung pada lama perendaman benang. Kuning dalam tenun Baduy sering memberi kesan cerah namun tetap alami.',
      'image': 'assets/benangmembumi/kuning.png',
    },
    {
      'name': 'Warna Coklat',
      'color': Color(0xFFAE5715),
      'description':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      'subtitle':
          'Warna coklat pada tenun Badui berasal dari <b>kulit kayu mahoni</b>. Pewarna alami ini diolah melalui proses perebusan hingga menghasilkan warna hangat yang khas. Warna ini mencerminkan kedekatan masyarakat Baduy dengan alam serta penggunaan sumber daya yang bijaksana.',
      'image': 'assets/benangmembumi/coklat.png',
    },
    {
      'name': 'Warna Merah',
      'color': Color(0xFFFA3030),
      'description':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      'subtitle':
          'Warna merah dihasilkan dari <b>kombinasi bahan alami tertentu dengan kulit kayu mahoni.</b> Warna ini tidak hanya mencerminkan teknik pewarnaan tradisional, tetapi juga menunjukkan keterampilan dalam mencampur bahan hingga menghasilkan warna yang diinginkan.',
      'image': 'assets/benangmembumi/merah.png',
    },
    {
      'name': 'Warna Hitam',
      'color': Color(0xFF000000),
      'description':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      'subtitle':
          'Warna hitam diperoleh dari <b>kulit buah jengkol</b> yang diolah secara alami. Warna ini memiliki karakter kuat dan sering digunakan sebagai dasar motif dalam tenun Baduy.',
      'image': 'assets/benangmembumi/hitam.png',
    },
  ];

  List<Map<String, dynamic>> get _filteredColors {
    if (searchQuery.isEmpty) return _allColors;
    return _allColors
        .where(
          (c) => (c['name'] as String).toLowerCase().contains(
            searchQuery.toLowerCase(),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _filteredColors;

    if (colors.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada warna ditemukan',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: const Color(0xFF9E9E9E),
          ),
        ),
      );
    }

    // Layout constants
    const double itemSpacing = 36.0;
    const double cardHeight = 120.0; // taller cards
    const double textWidth = 185.0;
    const double gapWidth = 38.0;
    const double containerPadV = 20.0;
    const double cardPadH = 20.0;
    const double sectionPadTop = 24.0;
    const double sectionPadBottom = 24.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth - 24;
        final containerWidth = contentWidth - textWidth - gapWidth + 8;

        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            top: sectionPadTop,
            bottom: sectionPadBottom,
          ),
          child: Stack(
            children: [
              // Force Stack to take full content width
              SizedBox(width: contentWidth),
              // ---- BACKGROUND CONTAINER ----
              Positioned(
                right: 0,
                top: 0,
                bottom: -containerPadV,
                width: containerWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                    ),
                    border: Border(
                      left: BorderSide(
                        color: const Color(0xFFD0D0D0),
                        width: 1.2,
                      ),
                      top: BorderSide(
                        color: const Color(0xFFD0D0D0),
                        width: 1.2,
                      ),
                      bottom: BorderSide(
                        color: const Color(0xFFD0D0D0),
                        width: 1.2,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(-2, 3),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              // ---- CONTENT ROWS (with top padding to sit inside container) ----
              Padding(
                padding: EdgeInsets.only(top: sectionPadTop),
                child: Column(
                  children: colors.asMap().entries.map((entry) {
                    final i = entry.key;
                    final c = entry.value;
                    final isLast = i == colors.length - 1;

                    return GestureDetector(
                      onTap: () {
                        context.push('/benang-membumi/warna', extra: c);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: isLast ? 0 : itemSpacing,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // LEFT: title + description
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: SizedBox(
                                width: textWidth,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c['name'] as String,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF727272),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      c['description'] as String,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10.5,
                                        color: const Color(0xFFAAAAAA),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: gapWidth),
                            // RIGHT: taller card inside the container area
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: cardPadH,
                                ),
                                child: Container(
                                  height: cardHeight,
                                  padding: const EdgeInsets.all(22),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFD0D0D0),
                                      width: 1.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: c['color'] as Color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==================== ARTI POLA TAB ====================

class _ArtiPolaTab extends StatelessWidget {
  static const List<Map<String, dynamic>> _patterns = [
    {
      'name': 'Suat Songket',
      'displayTitle': 'Pola Suat\nSungket',
      'image': 'assets/benangmembumi/suatsongket.png',
      'description':
          'Suat Songket merupakan salah satu motif yang paling banyak diproduksi dan dipasarkan saat ini. Motif ini lebih fleksibel dalam penggunaannya dibandingkan motif sakral, sehingga dapat digunakan dalam berbagai kesempatan.\n\nKarena sifatnya yang tidak terikat aturan adat yang ketat, Suat Songket menjadi salah satu motif yang paling dikenal oleh masyarakat luar.',
    },
    {
      'name': 'Adu Mancung',
      'displayTitle': 'Pola Adu\nMancung',
      'image': 'assets/benangmembumi/adumancung.png',
      'description':
          'Motif Adu Mancung melambangkan keseimbangan antara wilayah Baduy Dalam dan Baduy Luar. Motif ini umumnya digunakan oleh laki-laki, baik dalam kegiatan sehari-hari maupun dalam upacara adat. Adu Mancung sering dikenakan dalam ritual penting seperti Kawalu, Seba Baduy, pernikahan, hingga kegiatan pertanian adat.',
    },
    {
      'name': 'Janggawari',
      'displayTitle': 'Pola\nJanggawari',
      'image': 'assets/benangmembumi/janggawara.png',
      'description':
          'Janggawari merupakan motif tertua dalam tradisi tenun Badui sekaligus yang paling rumit dan sakral. Proses pembuatannya tidak hanya membutuhkan keterampilan tinggi, tetapi juga disertai ritual khusus seperti puasa dan doa-doa tertentu. Motif ini tidak dapat digunakan sembarang orang dan secara adat hanya diperuntukkan bagi pemimpin tertinggi Baduy, yaitu Pu\'un. Untuk keperluan komersial, motif ini dibuat dalam versi yang telah disederhanakan dengan pengurangan elemen tertentu, agar tidak menyerupai bentuk sakral aslinya.',
    },
    {
      'name': 'Poleng',
      'displayTitle': 'Pola\nPoleng',
      'image': 'assets/benangmembumi/poleng.png',
      'description':
          'Motif Poleng digunakan oleh perempuan dan memiliki variasi makna sesuai dengan jenisnya.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- 4 MAIN POLA CARDS (2x2 grid) ----
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
            ),
            itemCount: _patterns.length,
            itemBuilder: (context, index) {
              final pola = _patterns[index];
              return _GridCard(data: pola, route: '/benang-membumi/pola');
            },
          ),
          const SizedBox(height: 32),
          // ---- COMING SOON SECTION ----
          Center(
            child: Text(
              'Coming Soon!',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4A4A4A),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    left: index == 0 ? 0 : 6,
                    right: index == 2 ? 0 : 6,
                  ),
                  height: 160,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E8E8),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'Nama Pola',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF7A7A7A),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ---- Reusable Grid Card Widget ----
class _GridCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String route;

  const _GridCard({required this.data, required this.route});

  String get name => data['name'] as String? ?? '';
  String get imagePath =>
      (data['image'] as String?) ?? 'assets/benangmembumi/poleng.png';
  bool get _needsZoom =>
      name == 'Janggawari' || name == 'Poleng' || name == 'Dekorasi Rumah';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(route, extra: data);
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF31476C),
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // ---- IMAGE AREA (5/6 of card) ----
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image with rounded bottom corners
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                    child: _needsZoom
                        ? Transform.scale(
                            scale: 1.6,
                            child: Image.asset(imagePath, fit: BoxFit.cover),
                          )
                        : Image.asset(imagePath, fit: BoxFit.cover),
                  ),
                  // Gradient fog overlay on BOTTOM of image
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                          colors: [
                            const Color(0xFF31476C).withValues(alpha: 0.85),
                            const Color(0xFF31476C).withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Name text on bottom-left of image
                  Positioned(
                    left: 10,
                    bottom: 8,
                    child: Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ---- BUTTON AREA (1/6 of card) ----
            SizedBox(
              height: 36,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF54B7C2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Lihat',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== PENGGUNAAN TAB ====================

class _PenggunaanTab extends StatelessWidget {
  static const List<Map<String, dynamic>> _usages = [
    {
      'name': 'Suat Songket',
      'displayTitle': 'Pola\nSuat Sungket',
      'image': 'assets/benangmembumi/suatsongket.png',
      'description':
          'Motif ini adalah salah satu yang paling terkenal dan fleksibel karena banyak diproduksi dan dipasarkan saat ini. Suat Songket dapat dipakai oleh masyarakat luas sekaligus membantu promosi budaya.',
      'checkmarks': [
        'Aktivitas\nsehari-hari',
        'Busana etnik\nmodern',
        'Merchandise',
      ],
    },
    {
      'name': 'Adu Mancung',
      'displayTitle': 'Pola\nAdu Mancung',
      'image': 'assets/benangmembumi/adumancung.png',
      'description':
          'Motif ini memiliki makna penting dalam kehidupan sosial Baduy, biasanya dipakai pada upacara adat besar seperti Kawalu, Seba, serta ritual pernikahan dan pertanian. Motif ini mewakili nilai komitmen dan keseimbangan dalam komunitas.',
      'checkmarks': [
        'Upacara\nadat',
        'Tradisi\nKegiatan Budaya',
        'Pameran\netnik',
      ],
    },
    {
      'name': 'Janggawari',
      'displayTitle': 'Pola\nJanggawari',
      'image': 'assets/benangmembumi/janggawara.png',
      'description':
          'Motif ini sangat sakral dan secara tradisional hanya diperuntukkan bagi pemimpin adat tertinggi (Pu\'un) karena proses pembuatannya disertai ritual khusus. Untuk penggunaan umum, versi motif ini disederhanakan agar tetap menghormati makna aslinya.',
      'checkmarks': ['Tradisi\nKegiatan budaya', 'Koleksi\nEdukatif'],
    },
    {
      'name': 'Poleng',
      'displayTitle': 'Pola\nPoleng',
      'image': 'assets/benangmembumi/poleng.png',
      'description':
          'Motif Poleng identik dengan pola kotak-kotak dan umumnya digunakan oleh perempuan Baduy. Motif ini memiliki makna yang berkaitan dengan keseimbangan hidup, tanggung jawab, serta hubungan manusia dengan alam.',
      'checkmarks': [
        'Upacara\nadat',
        'Kegiatan\nBudaya',
        'Busana\nsehari-hari',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- 4 MAIN PENGGUNAAN CARDS (2x2 grid) ----
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
            ),
            itemCount: _usages.length,
            itemBuilder: (context, index) {
              final usage = _usages[index];
              return _GridCard(
                data: usage,
                route: '/benang-membumi/penggunaan',
              );
            },
          ),
          const SizedBox(height: 32),
          // ---- COMING SOON SECTION ----
          Center(
            child: Text(
              'Coming Soon!',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4A4A4A),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Expanded(
                child: Container(
                  height: 160,
                  margin: EdgeInsets.only(
                    left: index == 0 ? 0 : 8,
                    right: index == 2 ? 0 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E8E8),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'Nama Pola',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF7A7A7A),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

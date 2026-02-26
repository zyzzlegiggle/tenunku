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
                    icon: const Icon(Icons.arrow_back,
                        color: Color(0xFF424242)),
                    onPressed: () => context.pop(),
                  ),
                  Image.asset(
                    'assets/logo.png',
                    width: 32,
                    height: 32,
                  ),
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                  left: 24, right: 24, top: 12, bottom: 24),
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
                    hintText: 'Cari Nama Warna..',
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
                            colors: [
                              Colors.white,
                              Color(0x00FFFFFF),
                            ],
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
        .where((c) => (c['name'] as String)
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
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
                          color: const Color(0xFFD0D0D0), width: 1.2),
                      top: BorderSide(
                          color: const Color(0xFFD0D0D0), width: 1.2),
                      bottom: BorderSide(
                          color: const Color(0xFFD0D0D0), width: 1.2),
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
                        padding:
                            EdgeInsets.only(bottom: isLast ? 0 : itemSpacing),
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
                                    horizontal: cardPadH),
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
                                        color: Colors.black
                                            .withValues(alpha: 0.05),
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
  final List<Map<String, dynamic>> _patterns = const [
    {'name': 'Bintik Kecil', 'icon': Icons.circle_outlined},
    {'name': 'Garis Horizontal', 'icon': Icons.horizontal_rule},
    {'name': 'Belah Ketupat', 'icon': Icons.crop_square},
    {'name': 'Bintik Besar', 'icon': Icons.circle},
    {'name': 'Garis Silang', 'icon': Icons.close},
    {'name': 'Motif Fauna', 'icon': Icons.pets},
    {'name': 'Motif Flora', 'icon': Icons.local_florist},
    {'name': 'Garis Vertikal', 'icon': Icons.more_vert},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Berbagai Jenis Pola',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _patterns.length,
              itemBuilder: (context, index) {
                final pattern = _patterns[index];
                return GestureDetector(
                  onTap: () {
                    context.push('/benang-membumi/pola', extra: pattern);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          pattern['icon'] as IconData,
                          size: 32,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          pattern['name'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== PENGGUNAAN TAB ====================

class _PenggunaanTab extends StatelessWidget {
  final List<Map<String, dynamic>> _usages = const [
    {'name': 'Pakaian Adat', 'description': 'Untuk upacara tradisional'},
    {'name': 'Aksesoris', 'description': 'Tas, ikat kepala, dll'},
    {'name': 'Dekorasi Rumah', 'description': 'Taplak, hiasan dinding'},
    {'name': 'Fashion Modern', 'description': 'Pakaian kasual dan formal'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _usages.length,
      itemBuilder: (context, index) {
        final usage = _usages[index];
        return GestureDetector(
          onTap: () {
            context.push('/benang-membumi/penggunaan', extra: usage);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.image, color: Colors.grey[400]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usage['name'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        usage['description'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        );
      },
    );
  }
}

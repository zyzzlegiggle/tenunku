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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF424242)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Benang Membumi',
          style: GoogleFonts.poppins(
            color: const Color(0xFF333333),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[700],
              labelStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              indicator: BoxDecoration(
                color: const Color(0xFF424242),
                borderRadius: BorderRadius.circular(20),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Arti Warna'),
                Tab(text: 'Arti Pola'),
                Tab(text: 'Penggunaan'),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_ArtiWarnaTab(), _ArtiPolaTab(), _PenggunaanTab()],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== ARTI WARNA TAB ====================

class _ArtiWarnaTab extends StatelessWidget {
  // Sample color data
  final List<Map<String, dynamic>> _colors = const [
    {
      'name': 'Warna 1',
      'color': Color(0xFF8B4513),
      'description':
          'Lorem ipsum dolor sit amet consectetur. Id arcu ut adipiscing. Mauris eleifend et tincidunt non. Id arcu ut adipiscing. Mauris eleifend et tincidunt non. Id arcu ut adipiscing. Mauris eleifend et tincidunt non.',
    },
    {
      'name': 'Warna 2',
      'color': Color(0xFF4A4A4A),
      'description':
          'Warna ini melambangkan ketenangan dan kebijaksanaan dalam tradisi tenun.',
    },
    {
      'name': 'Warna 3',
      'color': Color(0xFFD4AF37),
      'description':
          'Melambangkan kemakmuran dan kemuliaan dalam budaya tenun tradisional.',
    },
    {
      'name': 'Warna 4',
      'color': Color(0xFF800020),
      'description':
          'Warna merah marun melambangkan keberanian dan kekuatan spiritual.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _colors.length,
      itemBuilder: (context, index) {
        final color = _colors[index];
        return GestureDetector(
          onTap: () {
            context.push('/benang-membumi/warna', extra: color);
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
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color['color'] as Color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    color['name'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
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

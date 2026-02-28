import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/models/product_model.dart';
import 'dart:math';
import 'dart:async';

class UntaianTenunanPage extends StatefulWidget {
  const UntaianTenunanPage({super.key});

  @override
  State<UntaianTenunanPage> createState() => _UntaianTenunanPageState();
}

class _UntaianTenunanPageState extends State<UntaianTenunanPage> {
  int _tahapanIndex = 0;
  int _waktuIndex = 0;
  final ProductRepository _productRepository = ProductRepository();

  late PageController _tahapanController;
  late PageController _waktuController;
  Timer? _tahapanTimer;
  Timer? _waktuTimer;

  @override
  void initState() {
    super.initState();
    _tahapanController = PageController();
    _waktuController = PageController();

    // Auto slide every 5 seconds for tahapan
    _tahapanTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_tahapanController.hasClients) {
        int nextPage = (_tahapanIndex + 1) % 5;
        _tahapanController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });

    // Auto slide every 7 seconds for waktu
    _waktuTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (_waktuController.hasClients) {
        int nextPage = (_waktuIndex + 1) % 5;
        _waktuController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _tahapanTimer?.cancel();
    _waktuTimer?.cancel();
    _tahapanController.dispose();
    _waktuController.dispose();
    super.dispose();
  }

  final List<String> _tahapanTitles = [
    '',
    'Pemilihan Benang',
    'Pewarnaan Alami',
    'Persiapan Lungsi',
    'Penyelesaian',
  ];

  final List<String> _tahapanImages = [
    'assets/tenun/tahapan.png',
    'assets/tenun/tahapan2.png',
    'assets/tenun/tahapan3.png',
    'assets/tenun/tahapan4.png',
    'assets/tenun/tahapan5.png',
  ];

  final List<String> _tahapanBodys = [
    'Proses pembuatan kain tenun Badui adalah sebuah ritual yang penuh makna dan kesabaran. Setiap tahapan dilakukan dengan penuh kehati-hatian dan doa.',
    'Benang kapas dipilih dengan teliti, biasanya yang berwarna putih alami atau biru indigo',
    'Menggunakan pewarna dari tumbuhan seperti tarum untuk warna biru, mengkudu untuk merah, dan kunyit untuk kuning',
    'Benang lungsi (benang vertikal) ditata pada alat tenun tradisional yang disebut "Cukrik"',
    'Kain yang sudah jadi dicuci dan dijemur dengan cara tradisional',
  ];

  final List<String> _waktuTitles = [
    '',
    'Kain sarung sederhana:',
    'Kain dengan motif rumit:',
    'Selendang panjang:',
    'Pewarnaan:',
  ];

  final List<String> _waktuBodys = [
    'Sehelai kain tenun berukuran sedang membutuhkan waktu 2-4 minggu untuk diselesaikan. Ini belum termasuk waktu untuk pewarnaan alami yang bisa memakan waktu berhari-hari.',
    '1-2 minggu',
    '3-4 minggu',
    '1 bulan',
    '3-7 hari proses perendaman',
  ];

  final List<String> _waktuImages = [
    'assets/waktu/waktu.png',
    'assets/waktu/waktu2.png',
    'assets/waktu/waktu3.png',
    'assets/waktu/waktu4.png',
    'assets/waktu/waktu5.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            backgroundColor: const Color(0xFF54B7C2),
            elevation: 0,
            pinned: true,
            floating: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFFFFE14F)),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                onPressed: () => context.push('/buyer/settings'),
                icon: const Icon(Icons.settings, color: Color(0xFFFFE14F)),
              ),
              const SizedBox(width: 8),
            ],
            centerTitle: false,
            titleSpacing: 0,
          ),
          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Image.asset('assets/logo.png', width: 60, height: 60),
                      const SizedBox(height: 8),
                      Text(
                        'Untaian Setiap Tenunan',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF31476C),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Intro Cards (Replaces Banner/Video)
                _buildIntroCards(),
                const SizedBox(height: 32),
                // New Image Section
                _buildProcessHeader(),
                const SizedBox(height: 24),
                // Carousel Section 1
                _buildCarouselSection(
                  title: 'Tahapan Menenun Tradisional',
                  imagePaths: _tahapanImages,
                  titles: _tahapanTitles,
                  bodys: _tahapanBodys,
                  index: _tahapanIndex,
                  controller: _tahapanController,
                  onPageChanged: (i) => setState(() => _tahapanIndex = i),
                  titleIconPath: 'assets/tenun/titleicon.png',
                  descIconPaths: const {
                    1: 'assets/tenun/descicon.png',
                    2: 'assets/tenun/pewarnaanicon.png',
                    3: 'assets/tenun/descicon.png',
                    4: 'assets/tenun/descicon.png',
                  },
                ),
                const SizedBox(height: 24),
                // Carousel Section 2
                _buildCarouselSection(
                  title: 'Waktu dan Dedikasi',
                  imagePaths: _waktuImages,
                  titles: _waktuTitles,
                  bodys: _waktuBodys,
                  index: _waktuIndex,
                  controller: _waktuController,
                  onPageChanged: (i) => setState(() => _waktuIndex = i),
                  titleIconPath: 'assets/waktu/titleicon.png',
                  descIconPaths: const {
                    1: 'assets/waktu/sarungicon.png',
                    2: 'assets/waktu/motificon.png',
                    3: 'assets/waktu/selendangicon.png',
                    4: 'assets/waktu/pewarnaanicon.png',
                  },
                ),
                const SizedBox(height: 48),
                // CTA Section
                _buildCTASection(),
                const SizedBox(height: 100),
              ],
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
              gradient: const RadialGradient(
                colors: [Colors.white, Color(0xFF54B7C2)],
                center: Alignment.center,
                radius: 1.0,
              ),
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
                    color: const Color(0xFF31476C),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Setiap kain tenun adalah hasil dari\ndedikasi, kepercayaan, dan warisan\nbudaya yang telah dijaga selama\nberabad-abad. Mari kita telusuri\nkisah di balik setiap helai\nbenangnya.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF31476C),
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
              gradient: const RadialGradient(
                colors: [Colors.white, Color(0xFF54B7C2)],
                center: Alignment.center,
                radius: 1.5,
              ),
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
                    color: const Color(0xFFF5793B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pewarna dari tumbuhan tanpa bahan kimia',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF31476C),
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
              gradient: const RadialGradient(
                colors: [Colors.white, Color(0xFF54B7C2)],
                center: Alignment.center,
                radius: 1.5,
              ),
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
                    color: const Color(0xFFF5793B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tradisi yang dijaga turun-temurun',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF31476C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessHeader() {
    return Column(
      children: [
        Stack(
          children: [
            SizedBox(
              height: 350, // Increased size
              width: double.infinity,
              child: Image.asset(
                'assets/tenun/prosespembuatantenun.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.white.withOpacity(0.8)],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 24,
              child: Text(
                'Proses\nPembuatan\nTenun',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCarouselSection({
    required String title,
    required List<String> imagePaths,
    required List<String> titles,
    required List<String> bodys,
    required int index,
    required PageController controller,
    required Function(int) onPageChanged,
    String? titleIconPath,
    Map<int, String>? descIconPaths,
  }) {
    String currentImagePath = imagePaths.length == 1
        ? imagePaths[0]
        : (index < imagePaths.length ? imagePaths[index] : imagePaths[0]);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage(currentImagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withOpacity(0.35),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  titleIconPath != null
                      ? Image.asset(titleIconPath, width: 40, height: 40)
                      : Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'ikon',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: const Color(0xFF31476C),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 120,
                    child: PageView.builder(
                      controller: controller,
                      onPageChanged: onPageChanged,
                      itemCount: 5,
                      itemBuilder: (context, i) {
                        String? descIcon = descIconPaths?[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: RichText(
                                    textAlign: TextAlign.left,
                                    text: TextSpan(
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 12,
                                        height: 1.4,
                                      ),
                                      children: [
                                        if (titles[i].isNotEmpty)
                                          TextSpan(
                                            text: '${titles[i]}\n',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        TextSpan(text: bodys[i]),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (descIcon != null) ...[
                                const SizedBox(width: 12),
                                Image.asset(descIcon, width: 40, height: 40),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (dotIndex) {
                      final isActive = index == dotIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 10 : 8,
                        height: isActive ? 10 : 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFFF5793B)
                              : Colors.white,
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTASection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'Sudah Punya Karya Tenun Asli?',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFF5793B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Setelah memahami makna dan proses pembuatannya, kini saatnya Anda memiliki dan melestarikan warisan budaya ini.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF31476C),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _showMarketplaceModal(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF54B7C2),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                'Yuk, jelajah lebih lanjut!',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMarketplaceModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(24),
            child: FutureBuilder<List<Product>>(
              future: _productRepository.getRecommendedProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                Product? product;
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  product =
                      snapshot.data![Random().nextInt(snapshot.data!.length)];
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Marketplace Budaya',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: product?.imageUrl != null
                          ? Image.network(
                              product!.imageUrl!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                    'assets/tenun/tahapan.png',
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                            )
                          : Image.asset(
                              'assets/tenun/tahapan.png',
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Jelajahi berbagai macam produk kain tenun berkualitas dan original',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF31476C),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

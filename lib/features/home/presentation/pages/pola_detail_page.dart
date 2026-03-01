import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../data/models/product_model.dart';

class PolaDetailPage extends StatefulWidget {
  final Map<String, dynamic> polaData;

  const PolaDetailPage({super.key, required this.polaData});

  @override
  State<PolaDetailPage> createState() => _PolaDetailPageState();
}

class _PolaDetailPageState extends State<PolaDetailPage> {
  Future<List<Product>>? _productsFuture;

  @override
  void initState() {
    super.initState();
    final name = widget.polaData['name'] ?? 'Pola';
    _productsFuture = _fetchProductsForPattern(name);
  }

  Future<List<Product>> _fetchProductsForPattern(String patternName) async {
    try {
      final supabase = Supabase.instance.client;

      // Try fetching by legacy text field first
      final legacyRes = await supabase
          .from('products')
          .select('*, benang_patterns(*), benang_colors(*), benang_usages(*)')
          .ilike('pattern_meaning', '%$patternName%')
          .limit(10);

      if ((legacyRes as List).isNotEmpty) {
        return legacyRes.map((e) => Product.fromJson(e)).toList();
      }

      // If no results, try fetching via pattern_id relation
      final patternRes = await supabase
          .from('benang_patterns')
          .select('id')
          .ilike('name', '%$patternName%')
          .maybeSingle();

      if (patternRes != null) {
        final relRes = await supabase
            .from('products')
            .select('*, benang_patterns(*), benang_colors(*), benang_usages(*)')
            .eq('pattern_id', patternRes['id'])
            .limit(10);
        return (relRes as List).map((e) => Product.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.polaData['name'] ?? 'Pola';
    final displayTitle = widget.polaData['displayTitle'] ?? 'Pola $name';
    final imagePath = widget.polaData['image'] ?? '';
    final description =
        widget.polaData['description'] ??
        'Pola ini merupakan salah satu motif tenun khas yang memiliki makna mendalam dalam budaya masyarakat.';

    final isPoleng = name == 'Poleng';
    final needsZoom = (name == 'Janggawari' || name == 'Poleng');

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;
    final topSectionHeight = screenHeight * 0.45;
    final imageWidth = screenWidth * 0.5;
    final imageHeight = imageWidth * 1.3;

    // Position the image higher — most of it in the top section
    final imageTop = topSectionHeight - (imageHeight * 0.75);
    // The image is aligned to the right at ~3/4 width
    final imageLeft = screenWidth * 0.5 - (imageWidth * 0.25);

    // Scrollable content starts below the image bottom
    final contentTopOffset = imageTop + imageHeight + 12;

    return Scaffold(
      backgroundColor: const Color(0xFFC3D3D5),
      body: Stack(
        children: [
          // ---- TOP SECTION with gradient (fixed) ----
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topSectionHeight,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF54B7C2), Color(0xFFC3D3D5)],
                ),
              ),
            ),
          ),

          // ---- BOTTOM SECTION with white bg and rounded top (fixed) ----
          Positioned(
            top: topSectionHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          // ---- IMAGE bridging both sections (fixed, does NOT scroll) ----
          Positioned(
            top: imageTop,
            left: imageLeft,
            child: Container(
              width: imageWidth,
              height: imageHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: needsZoom
                    ? Transform.scale(
                        scale: 1.8,
                        child: Image.asset(
                          imagePath,
                          width: imageWidth,
                          height: imageHeight,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        imagePath,
                        width: imageWidth,
                        height: imageHeight,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),

          // ---- BACK BUTTON (fixed) ----
          Positioned(
            top: topPad + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),

          // ---- TITLE (fixed) ----
          Positioned(
            top: topPad + 56,
            left: 40,
            child: Text(
              displayTitle,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF31476C),
              ),
            ),
          ),

          // ---- SCROLLABLE DESCRIPTION (only this scrolls) ----
          Positioned(
            top: contentTopOffset,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 28,
                right: 28,
                top: 8,
                bottom: 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF5A5A5A),
                      height: 1.6,
                    ),
                  ),

                  // ---- POLENG-SPECIFIC 2-COLUMN CONTENT ----
                  if (isPoleng) ...[
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column - Poleng Capi Turang
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/benangmembumi/polengicon.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Poleng Capi Turang',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        fontStyle: FontStyle.italic,
                                        color: const Color(0xFF31476C),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Melambangkan kekayaan alam wilayah sungai Baduy. Motif ini biasanya digunakan dalam upacara pernikahan sebagai simbol kesejahteraan dan keberlimpahan.',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF5A5A5A),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Right column - Poleng Pepetikan
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/benangmembumi/polengicon.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Poleng Pepetikan',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        fontStyle: FontStyle.italic,
                                        color: const Color(0xFF31476C),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Melambangkan tugas dan kewajiban perempuan dalam menjalankan ritual adat. Motif ini digunakan dalam kegiatan seperti nombok padi, yang berkaitan dengan siklus pertanian dan kehidupan masyarakat Baduy.',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF5A5A5A),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],

                  // ---- REKOMENDASI PRODUK ----
                  const SizedBox(height: 32),
                  Text(
                    'Rekomendasi Produk dengan Pola Ini',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5A5A5A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Product>>(
                    future: _productsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF54B7C2),
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            'Belum ada produk untuk pola ini.',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xFF9E9E9E),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        );
                      }

                      final products = snapshot.data!;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        child: Row(
                          children: products.map((product) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: _RekomendasiCard(product: product),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RekomendasiCard extends StatelessWidget {
  final Product product;
  const _RekomendasiCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return GestureDetector(
      onTap: () {
        context.push('/product/detail', extra: product);
      },
      child: Container(
        width: 140, // slightly wider to fit real names
        decoration: BoxDecoration(
          color: const Color(0xFF31476C),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 130,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0F0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              'Foto Produk',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: const Color(0xFFD0D0D0),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          'Foto Produk',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFFD0D0D0),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          formatCurrency.format(product.price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF54B7C2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Lihat',
                          style: GoogleFonts.poppins(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

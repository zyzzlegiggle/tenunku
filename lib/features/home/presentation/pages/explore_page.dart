import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final ProductRepository _productRepository = ProductRepository();
  final TextEditingController _searchController = TextEditingController();

  bool _isSearchActive = false;
  bool _isFilterActive = false;
  String? _selectedCategory;
  String _selectedSort = 'Nama A-Z';
  int? _selectedMinRating;
  List<Product> _searchResults = [];
  List<Product> _recommendedProducts = [];
  List<Product> _bestSellingProducts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDefaultData();
  }

  Future<void> _fetchDefaultData() async {
    setState(() => _isLoading = true);
    try {
      final recommended = await _productRepository.getRecommendedProducts();
      final bestSelling = await _productRepository.getBestSellingProducts();
      setState(() {
        _recommendedProducts = recommended;
        _bestSellingProducts = bestSelling;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _performSearch() async {
    setState(() => _isLoading = true);
    try {
      final results = await _productRepository.searchProducts(
        query: _searchController.text,
        category: _selectedCategory,
        sort: _selectedSort,
      );

      var filtered = results;
      if (_selectedMinRating != null) {
        filtered = filtered
            .where((p) => p.averageRating >= _selectedMinRating!.toDouble())
            .toList();
      }

      setState(() {
        _searchResults = filtered;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: _buildSearchBar(),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isSearchActive ? _buildSearchView() : _buildDefaultView(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: [
          if (_isSearchActive)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isSearchActive = false;
                    _isFilterActive = false;
                    _searchController.clear();
                    _selectedCategory = null;
                  });
                },
                child: const Icon(Icons.arrow_back, color: Color(0xFF757575)),
              ),
            ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  if (val.isNotEmpty && !_isSearchActive) {
                    setState(() => _isSearchActive = true);
                  }
                  _performSearch();
                },
                decoration: InputDecoration(
                  hintText: 'Telusuri...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _showFilterBottomSheet,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isFilterActive ? const Color(0xFFF5793B) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.tune,
                color: _isFilterActive
                    ? Colors.yellow
                    : const Color(0xFF757575),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    String tempSort = _selectedSort;
    int? tempMinRating = _selectedMinRating;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const SizedBox(width: 32), // balance for close icon
                        Expanded(
                          child: Text(
                            'Pilih Filter Produk',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF727272),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF5793B),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.yellow,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Batas Harga
                          Text(
                            'Batas Harga',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      tempSort = 'Harga Terendah';
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: tempSort == 'Harga Terendah'
                                          ? const Color(0xFFF5793B)
                                          : const Color(0xFFF0F0F0),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Harga Terendah',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: tempSort == 'Harga Terendah'
                                            ? Colors.white
                                            : const Color(0xFF727272),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      tempSort = 'Harga Tertinggi';
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: tempSort == 'Harga Tertinggi'
                                          ? const Color(0xFFF5793B)
                                          : const Color(0xFFF0F0F0),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Harga Tertinggi',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: tempSort == 'Harga Tertinggi'
                                            ? Colors.white
                                            : const Color(0xFF727272),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Penilaian
                          Text(
                            'Penilaian',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(5, (index) {
                              int starCount = 5 - index;
                              bool isSelected = tempMinRating == starCount;
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    if (isSelected) {
                                      tempMinRating = null;
                                    } else {
                                      tempMinRating = starCount;
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFF5793B)
                                        : const Color(0xFFF0F0F0),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        starCount.toString(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.star,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.yellow,
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Buttons
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(ctx);
                              setState(() {
                                _isFilterActive = false;
                                _selectedSort = 'Nama A-Z';
                                _selectedMinRating = null;
                              });
                              _performSearch();
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFFB8B8B8),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Batal',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFB8B8B8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(ctx);
                              setState(() {
                                _selectedSort = tempSort;
                                _selectedMinRating = tempMinRating;
                                _isSearchActive = true;
                                _isFilterActive = true;
                              });
                              _performSearch();
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5793B),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Simpan',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
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
            );
          },
        );
      },
    );
  }

  Widget _buildDefaultView() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final random = math.Random();
    int mungkinKamuSukaCount = 2 + random.nextInt(3); // 2 to 4 randomly
    if (mungkinKamuSukaCount > _recommendedProducts.length) {
      mungkinKamuSukaCount = _recommendedProducts.length;
    }
    final mungkinKamuSukaProducts = _recommendedProducts
        .take(mungkinKamuSukaCount)
        .toList();

    int rekomendasiCount = 5;
    final rekomendasiProducts =
        _recommendedProducts.length > mungkinKamuSukaCount
        ? _recommendedProducts
              .skip(mungkinKamuSukaCount)
              .take(rekomendasiCount)
              .toList()
        : _recommendedProducts.take(rekomendasiCount).toList();

    final terjualTerbanyakProducts = List<Product>.from(_bestSellingProducts)
      ..sort((a, b) => b.soldCount.compareTo(a.soldCount));
    final top10Terjual = terjualTerbanyakProducts.take(10).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mungkin Kamu Suka Section
          Text(
            'Mungkin Kamu Suka',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color(0xFF757575),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...mungkinKamuSukaProducts.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => context.push('/product/detail', extra: p),
                child: _buildMungkinKamuSukaCard(p),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Filter Kategori Produk Section
          Text(
            'Filter Kategori Produk',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color(0xFF757575),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildCategoryFilterCard('Kain')),
              const SizedBox(width: 16),
              Expanded(child: _buildCategoryFilterCard('Aksesori')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildCategoryFilterCard('Pakaian')),
              const SizedBox(width: 16),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 24),

          // Rekomendasi Untukmu Section
          if (rekomendasiProducts.isNotEmpty) ...[
            Text(
              'Rekomendasi Untukmu',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: const Color(0xFF757575),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...rekomendasiProducts.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => context.push('/product/detail', extra: p),
                  child: _buildRekomendasiCard(p),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Terjual Terbanyak Section
          Text(
            'Terjual Terbanyak Bulan Ini',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color(0xFF757575),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120, // Size for nice square cards
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: top10Terjual.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => context.push(
                    '/product/detail',
                    extra: top10Terjual[index],
                  ),
                  child: _buildTerjualTerbanyakCard(
                    top10Terjual[index],
                    index + 1,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 180),
        ],
      ),
    );
  }

  Widget _buildSearchView() {
    return Column(
      children: [
        // Filters
        _buildFilterRow(),
        const SizedBox(height: 16),

        // Results
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada produk ditemukan',
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  )
                : _buildProductGrid(_searchResults, isScrollable: true),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(color: Color(0xFFE9E9E9)),
      alignment: Alignment.center,
      child: Text(
        'Kategori Produk: ${_selectedCategory ?? 'Semua'}',
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildProductGrid(
    List<Product> products, {
    bool isScrollable = false,
  }) {
    return GridView.builder(
      shrinkWrap: !isScrollable,
      physics: isScrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columns like screenshot
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => context.push('/product/detail', extra: products[index]),
          child: _buildProductItem(products[index]),
        );
      },
    );
  }

  Widget _buildProductItem(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(
          0xFF31476C,
        ), // Navy blue similar to "Mungkin Kamu Suka"
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: product.imageUrl != null
                  ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Text(
                          'Foto Produk',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp',
                      decimalDigits: 0,
                    ).format(product.price),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${product.soldCount} Terjual',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: Colors.white70,
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

  Widget _buildMungkinKamuSukaCard(Product product) {
    return Container(
      height: 230,
      decoration: BoxDecoration(
        color: const Color(0xFF31476C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: product.imageUrl != null
                  ? Image.network(
                      product.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: Center(
                        child: Text(
                          'Foto Produk',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF54B7C2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Rating',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

  Widget _buildRekomendasiCard(Product product) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
            ),
            child: product.imageUrl != null
                ? Image.network(
                    product.imageUrl!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: Center(
                      child: Text(
                        'Foto',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp',
                      decimalDigits: 0,
                    ).format(product.price),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF54B7C2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Lihat',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTerjualTerbanyakCard(Product product, int rank) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: product.imageUrl != null
                ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                : Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Text(
                        'Foto',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Text(
              '#$rank',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 1),
                    blurRadius: 3.0,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilterCard(String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSearchActive = true;
          // Subtitle maps to existing categories
          _selectedCategory = title == 'Aksesori' ? 'Aksesoris' : title;
          _searchController.clear();
        });
        _performSearch();
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF31476C), // Navy Blue
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

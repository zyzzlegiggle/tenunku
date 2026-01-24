import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
  String? _selectedCategory;
  String _selectedSort = 'Nama A-Z';
  List<Product> _searchResults = [];
  List<Product> _recommendedProducts = [];
  List<Product> _bestSellingProducts = [];
  bool _isLoading = false;

  final List<String> _categories = [
    'Semua Kategori',
    'Kain',
    'Aksesoris',
    'Pakaian',
  ];

  final List<String> _sortOptions = [
    'Nama A-Z',
    'Nama Z-A',
    'Harga Terendah',
    'Harga Tertinggi',
  ];

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
      setState(() {
        _searchResults = results;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String value) {
    if (value.isNotEmpty) {
      if (!_isSearchActive) setState(() => _isSearchActive = true);
      _performSearch();
    } else {
      if (value.isEmpty) {
        setState(() {
          _isSearchActive = false;
          _searchResults = [];
        });
      } else {
        _performSearch();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 0.0,
        ), // Vertical handled by parent/spacer
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add some top spacing if needed, but HomePage might handle it.
            // Homepage header has 20 vertical padding.
            // Content starts immediately.
            _buildSearchBar(),
            const SizedBox(height: 24),
            Expanded(
              child: _isSearchActive ? _buildSearchView() : _buildDefaultView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        if (_isSearchActive)
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isSearchActive = false;
                  _searchController.clear();
                  _selectedCategory = null;
                });
              },
              child: const Icon(Icons.arrow_back, color: Color(0xFF757575)),
            ),
          ),
        Expanded(
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
              fillColor: const Color(0xFFE0E0E0),
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              // Removed suffixIcon as it's in the main header
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultView() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recommended Section
          Text(
            'Rekomendasi Untukmu',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF757575),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          _buildProductGrid(_recommendedProducts, isScrollable: false),
          const SizedBox(height: 24),

          // Best Selling Section
          Text(
            'Terjual Terbanyak Bulan Ini',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF757575),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _bestSellingProducts.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return _buildBestSellerCard(
                  _bestSellingProducts[index],
                  index + 1,
                );
              },
            ),
          ),
          const SizedBox(height: 100), // Bottom padding
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
      ],
    );
  }

  Widget _buildFilterRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Dropdown
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              hint: Text(
                'Semua Kategori',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              isExpanded: true,
              items: _categories.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: GoogleFonts.poppins(fontSize: 12)),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
                _performSearch();
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Sort Dropdown
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSort,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items: _sortOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: GoogleFonts.poppins(fontSize: 12)),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedSort = newValue;
                  });
                  _performSearch();
                }
              },
            ),
          ),
        ),
      ],
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
        return _buildProductItem(products[index]);
      },
    );
  }

  Widget _buildProductItem(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: product.imageUrl != null
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Center(
                        child: Text(
                          'Foto Produk',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    )
                  : Center(
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
          Container(
            height: 60, // Fixed height for footer area
            padding: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
              color: Color(
                0xFFF5F5F5,
              ), // Lighter grey for text area? Screenshot shows generic card.
              // Actually screenshot 2 shows Dark Grey card with text overlay?
              // Let's follow the Home Page style: Light grey card, text inside.
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp',
                    decimalDigits: 0,
                  ).format(product.price),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestSellerCard(Product product, int rank) {
    return Stack(
      children: [
        Container(
          width: 140,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  alignment: Alignment.center,
                  child: product.imageUrl != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Text(
                          'Foto',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                ),
              ),
              Container(
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFAAAAAA),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          left: 12,
          child: Text(
            '#$rank',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}

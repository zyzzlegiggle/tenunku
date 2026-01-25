import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/seller_repository.dart';
import '../../data/models/profile_model.dart';
import '../../data/models/product_model.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import 'seller_orders_page.dart';
import 'seller_chat_page.dart';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({super.key});

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  int _currentIndex = 0;
  final SellerRepository _sellerRepo = SellerRepository();
  final AuthRepository _authRepo = AuthRepository();

  Profile? _profile;
  List<Product> _products = [];
  Map<String, int> _stats = {
    'totalSold': 0,
    'totalViews': 0,
    'totalReviews': 0,
  };
  bool _isLoading = true;
  String _selectedSort = 'Terbaru'; // Default sort

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final user = _authRepo.currentUser;
    if (user != null) {
      final profile = await _sellerRepo.getProfile(user.id);
      final products = await _sellerRepo.getSellerProducts(user.id);
      final stats = await _sellerRepo.getSellerStats(user.id);

      if (mounted) {
        setState(() {
          _profile = profile;
          _products = products;
          _stats = stats;
          _isLoading = false;
        });
        _sortProducts(); // Sort initially
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _sortProducts() {
    setState(() {
      switch (_selectedSort) {
        case 'Terbaru':
          _products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case 'Terlaris':
          _products.sort((a, b) => b.soldCount.compareTo(a.soldCount));
          break;
        case 'Ulasan Terbanyak':
          _products.sort((a, b) => b.totalReviews.compareTo(a.totalReviews));
          break;
        case 'Dilihat Terbanyak':
          _products.sort((a, b) => b.viewCount.compareTo(a.viewCount));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _currentIndex == 1 ? 'Produkmu' : 'TENUNKu',
          style: GoogleFonts.poppins(
            color: const Color(0xFF212121),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF757575)),
            onPressed: () {
              context.push('/seller/settings');
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem('Beranda', 0),
            _buildNavItem('Produk', 1),
            _buildNavItem('Pesanan', 2),
            _buildNavItem('Obrolan', 3),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () async {
                await context.push('/seller/product/add');
                _fetchData();
              },
              backgroundColor: const Color(0xFF616161),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildProductView();
      case 2:
        return const SellerOrdersPage();
      case 3:
        return const SellerChatPage();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Section
          Container(
            width: double.infinity,
            color: const Color(0xFF9E9E9E), // Darker grey like screenshot
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF616161),
                    image: _profile?.avatarUrl != null
                        ? DecorationImage(
                            image: NetworkImage(_profile!.avatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _profile?.avatarUrl == null
                      ? const Icon(Icons.person, color: Colors.white, size: 50)
                      : null,
                ),
                const SizedBox(width: 20),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _profile?.fullName ?? 'Nama Penenun',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        _profile?.shopName ?? 'Nama Toko',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _profile?.description ??
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.black54,
                          height: 1.2,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons - Overlapping slightly or just below?
          // Screenshot shows them clearly separated below the dark header.
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Edit Profil',
                    () => context.push('/seller/edit-profile'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildActionButton('Bagikan Profil')),
              ],
            ),
          ),

          // Stats
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildStatCard(
                  'Total Produk Terjual',
                  _formatNumber(_stats['totalSold'] ?? 0),
                  isLarge: true,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Total Kunjungan',
                  _formatNumber(_stats['totalViews'] ?? 0),
                  isLarge: true,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Total Ulasan',
                  _formatNumber(_stats['totalReviews'] ?? 0),
                  isLarge: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sort Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildSortChip('Terbaru'),
                const SizedBox(width: 12), // Wider gap
                _buildSortChip('Terlaris'),
                const SizedBox(width: 12),
                _buildSortChip('Ulasan Terbanyak'),
                const SizedBox(width: 12),
                _buildSortChip('Dilihat Terbanyak'),
              ],
            ),
          ),
          const SizedBox(height: 24), // More spacing
          // Performance Product List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: _products
                  .map((product) => _buildPerformanceCard(product))
                  .toList(),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Helper to format numbers like 1K+, 20K+
  String _formatNumber(int item) {
    if (item >= 1000) {
      return '${(item / 1000).toStringAsFixed(item >= 10000 ? 0 : 1).replaceAll(RegExp(r'\.0$'), '')}K+';
    }
    return item.toString();
  }

  // Helper to format currency like Rp2,7jt
  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return 'Rp${(amount / 1000000).toStringAsFixed(1).replaceAll('.', ',')}jt';
    } else if (amount >= 1000) {
      return 'Rp${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return 'Rp${amount.toInt()}';
  }

  Widget _buildSortChip(String label) {
    final bool isSelected = _selectedSort == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSort = label;
        });
        _sortProducts();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: Colors.black87, width: 2)
              : Border.all(
                  color: Colors.transparent,
                  width: 2,
                ), // Keep layout stable
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(Product product) {
    // Calculate simulated revenue for display if real data isn't enough,
    // but we'll use price * soldCount from the model.
    final double revenue = product.price * product.soldCount;
    final bool showRating =
        _selectedSort == 'Ulasan Terbanyak' ||
        _selectedSort == 'Dilihat Terbanyak';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0), // Light grey background like screenshot
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Part: Name and Big Metric
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatNumber(product.soldCount), // e.g. 1,2K+
                  style: GoogleFonts.poppins(
                    fontSize: 56, // Huge font size
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Bottom Part: Revenue Strip OR Rating Strip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFBDBDBD), // Darker grey strip (Material Grey 400)
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (showRating)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Penilaian',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 20,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.averageRating.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${product.totalReviews})',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pendapatan',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatCurrency(revenue), // e.g. Rp2,7jt
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800, // Very bold
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                GestureDetector(
                  onTap: () async {
                    await context.push(
                      '/seller/product/detail',
                      extra: product,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE), // Very light grey button
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Rincian',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
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

  // Kept original methods below for reference/reuse if needed,
  // but revised _buildDashboard replaces most usage.
  // We retain _buildProductView and others for other tabs.

  Widget _buildProductView() {
    return Column(
      children: [
        // Filter Bar - Keep original design for Product Tab
        Container(
          width: double.infinity,
          color: const Color(0xFF757575),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0E0E0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.filter_list, color: Colors.black87),
                ),
                const SizedBox(width: 12),
                _buildFilterChip('Aktif', isSelected: true),
                const SizedBox(width: 8),
                _buildFilterChip('Disembunyikan'),
                const SizedBox(width: 8),
                _buildFilterChip('Ulasan Terbanyak'),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Search Bar & Grid Icon
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari Produk',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(bottom: 2),
                    ),
                    style: GoogleFonts.poppins(color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.grid_view_rounded, size: 32, color: Colors.grey),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Product List
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                if (_products.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Text(
                      'Belum ada produk',
                      style: GoogleFonts.poppins(),
                    ),
                  )
                else
                  ..._products.map(
                    (product) => Column(
                      children: [
                        _buildProductCard(product),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, [VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(24),
          // border: Border.all(color: Colors.black12), // No border in screenshot for these buttons
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, {bool isLarge = false}) {
    // Screenshot has larger cards for stats
    return Container(
      width: isLarge ? 170 : 140, // Wider
      height: isLarge ? 120 : 100, // Taller
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.black87,
            ), // Darker, slightly bigger
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 32, // Huge
              fontWeight: FontWeight.normal, // Regular weight, but big
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    // This is for the Product Tab filter chips, kept separate for now or reused?
    // The screenshot re-uses the style.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Container(
              color: const Color(0xFFE0E0E0),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          product.description ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (product.averageRating > 0)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.averageRating.toStringAsFixed(1),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Container(
              color: const Color(0xFFAAAAAA),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        _formatCurrency(product.price),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(width: 1.5, height: 20, color: Colors.black54),
                      const SizedBox(width: 8),
                      Text(
                        'Stok ${product.stock} Helai',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      await context.push(
                        '/seller/product/detail',
                        extra: product,
                      );
                      _fetchData();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF616161),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Lihat',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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

  Widget _buildNavItem(String label, int index) {
    final bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFF9E9E9E),
                shape: BoxShape.circle,
                border: isActive
                    ? Border.all(color: Colors.black54, width: 2)
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

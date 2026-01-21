import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/seller_repository.dart';
import '../../data/models/profile_model.dart';
import '../../data/models/product_model.dart';
import '../../../auth/data/repositories/auth_repository.dart';

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
  bool _isLoading = true;

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

      if (mounted) {
        setState(() {
          _profile = profile;
          _products = products;
          _isLoading = false;
        });
      }
    } else {
      // Handle not logged in edge case?
      setState(() => _isLoading = false);
    }
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
          'TENUNKu',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            Container(
              color: const Color(0xFFAAAAAA),
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 50,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _profile?.fullName ?? 'Nama Penenun',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
                          _profile?.description ?? 'Belum ada deskripsi.',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.black45,
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

            // Action Buttons
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
                    '0',
                  ), // TODO: Real stats
                  const SizedBox(width: 12),
                  _buildStatCard('Total Kunjungan', '0'),
                  const SizedBox(width: 12),
                  _buildStatCard('Total Ulasan', '0'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip('Terbaru', isSelected: true),
                  const SizedBox(width: 8),
                  _buildFilterChip('Terlaris'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Ulasan Terbanyak'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Dibuat Terlama'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Product List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  if (_products.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Belum ada produk'),
                    )
                  else
                    ..._products.map(
                      (product) => Column(
                        children: [
                          _buildProductPerformanceCard(
                            product.name,
                            '0', // Sales count placeholder
                            'Rp${product.price.toStringAsFixed(0)}',
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          color: Colors
              .white, // Matches the lighter/white background in screenshot
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
          border: Border.all(color: Colors.black12),
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

  Widget _buildStatCard(String title, String value) {
    return Container(
      width: 140,
      height: 100,
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
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.black87 : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildProductPerformanceCard(
    String name,
    String sales,
    String revenue,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            sales,
            style: GoogleFonts.poppins(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pendapatan',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    revenue,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6D6D6), // Slightly darker button
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Rincian',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, int index) {
    final bool isActive = _currentIndex == index;
    // In the screenshot, all circles are solid grey.
    // We'll mimic that, maybe making the active one slightly darker or just relying on text/user perception.
    // The screenshot shows large grey circles.

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        color: Colors.transparent, // Hit test target
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 55, // Slightly larger to match the dominant look
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFF9E9E9E), // Standard solid grey circle
                shape: BoxShape.circle,
                border: isActive
                    ? Border.all(color: Colors.black54, width: 2)
                    : null, // Subtle active indicator
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12, // Slightly larger text
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

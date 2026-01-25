import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/product_model.dart';
import '../../data/models/profile_model.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/repositories/buyer_repository.dart';

/// Shows a bottom sheet modal with product details
void showBuyerProductDetailModal(BuildContext context, Product product) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BuyerProductDetailModal(product: product),
  );
}

class BuyerProductDetailModal extends StatefulWidget {
  final Product product;

  const BuyerProductDetailModal({super.key, required this.product});

  @override
  State<BuyerProductDetailModal> createState() =>
      _BuyerProductDetailModalState();
}

class _BuyerProductDetailModalState extends State<BuyerProductDetailModal> {
  final BuyerRepository _buyerRepository = BuyerRepository();
  Profile? _sellerProfile;
  bool _isLoading = true;
  bool _isFavorite = false;
  int _selectedTabIndex = 0; // 0 = Biografi Penenun, 1 = Benang Membumi
  String _selectedSize = 'Ukuran';
  String _selectedVariant = 'Varian';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    // Load seller profile
    final productData = await _buyerRepository.getProductWithSeller(
      widget.product.id,
    );
    if (productData != null && productData['profiles'] != null) {
      if (mounted) {
        setState(() {
          _sellerProfile = Profile.fromJson(productData['profiles']);
        });
      }
    }

    // Check if favorite
    if (userId != null) {
      final isFav = await _buyerRepository.isFavorite(
        userId,
        widget.product.id,
      );
      if (mounted) {
        setState(() {
          _isFavorite = isFav;
        });
      }
      // Track view
      await _buyerRepository.trackProductView(userId, widget.product.id);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isFavorite = !_isFavorite);

    try {
      if (_isFavorite) {
        await _buyerRepository.addFavorite(userId, widget.product.id);
      } else {
        await _buyerRepository.removeFavorite(userId, widget.product.id);
      }
    } catch (e) {
      setState(() => _isFavorite = !_isFavorite);
    }
  }

  void _showAddToCartModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _CartModal(product: widget.product, isDirectPurchase: false),
    );
  }

  void _showBuyNowModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _CartModal(product: widget.product, isDirectPurchase: true),
    );
  }

  void _openChat() {
    if (_sellerProfile == null) return;

    context.push(
      '/buyer/chat',
      extra: {
        'sellerId': widget.product.sellerId,
        'shopName':
            _sellerProfile?.shopName ?? _sellerProfile?.fullName ?? 'Penenun',
        'sellerAvatarUrl': _sellerProfile?.avatarUrl,
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Stack(
        children: [
          // Main Content Column
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // White Sheet Content (Main Background for content)
                      Container(
                        margin: const EdgeInsets.only(top: 100),
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height * 0.7,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 80, 24, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Price
                            Text(
                              NumberFormat.currency(
                                locale: 'id_ID',
                                symbol: 'Rp',
                                decimalDigits: 0,
                              ).format(widget.product.price),
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF424242),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Description
                            Text(
                              widget.product.description ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                                height: 1.6,
                              ),
                              maxLines: 6,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 16),

                            // Dropdowns (Size/Variant)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDropdown(
                                    _selectedSize,
                                    'S',
                                    (val) =>
                                        setState(() => _selectedSize = val),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDropdown(
                                    _selectedVariant,
                                    'Varian 1',
                                    (val) =>
                                        setState(() => _selectedVariant = val),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Tabs
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0E0E0),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildTabButton(
                                      'Biografi Penenun',
                                      0,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildTabButton('Benang Membumi', 1),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Seller Profile Section
                            if (_selectedTabIndex == 0)
                              _buildSellerProfile()
                            else
                              _buildBenangMembumiInfo(),
                          ],
                        ),
                      ),

                      // Title Area
                      Positioned(
                        top: 16,
                        left: 24,
                        right: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 30),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Text(
                                widget.product.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF424242),
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Floating Image Card (Scrolled with content)
                      Positioned(
                        top: 30, // Adjusted higher as requested
                        right: 24,
                        child: Container(
                          width: 180,
                          height: 220,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: widget.product.imageUrl != null
                                    ? Image.network(
                                        widget.product.imageUrl!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      )
                                    : Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.image,
                                              color: Colors.grey,
                                            ),
                                            Text(
                                              'foto produk',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.chevron_left,
                                        color: Colors.black54,
                                      ),
                                      onPressed: () {},
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.chevron_right,
                                        color: Colors.black54,
                                      ),
                                      onPressed: () {},
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
                ),
              ),
              // Bottom Bar (Fixed at bottom of column)
              _buildBottomBar(),
            ],
          ),

          // Back Button (Fixed Overlay)
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back,
                size: 28,
                color: Color(0xFF424242),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for Back Button (outside build to keep it clean, but we can't easily return multiple widgets from build)
  // Actually, wait. The structure above puts Back Button and Bottom Bar OUTSIDE the Stack?
  // No, I need the Back Button to be fixed on top of everything.
  // So I need a wrapper Stack.

  Widget _buildDropdown(String value, String hint, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(21),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
              : null,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.black87 : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildSellerProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grey Profile Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                backgroundImage: _sellerProfile?.avatarUrl != null
                    ? NetworkImage(_sellerProfile!.avatarUrl!)
                    : null,
                child: _sellerProfile?.avatarUrl == null
                    ? const Icon(Icons.person, color: Colors.grey, size: 30)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _sellerProfile?.fullName ?? 'Nama Penenun',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF424242),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _sellerProfile?.shopName ?? 'Lokasi Penenun',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[700],
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
        const SizedBox(height: 24),

        Text(
          'Tentang Penenun',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.product.description ??
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          maxLines: 4,
        ),
        const SizedBox(height: 16),

        // Lihat Detail Button
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {
              if (_sellerProfile != null) {
                context.push('/seller/biography', extra: _sellerProfile);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF757575),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Lihat Detail',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenangMembumiInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBenangCard(
          label: 'Arti Warna',
          value:
              widget.product.benangColor?.name ??
              widget.product.colorMeaning ??
              '-',
          meaning:
              widget.product.benangColor?.meaning ??
              'Keterangan tidak tersedia.',
          icon: Icons.circle, // Placeholder icon or use hexCode if you want
        ),
        const SizedBox(height: 12),
        _buildBenangCard(
          label: 'Arti Pola',
          value:
              widget.product.benangPattern?.name ??
              widget.product.patternMeaning ??
              '-',
          meaning:
              widget.product.benangPattern?.meaning ??
              'Keterangan tidak tersedia.',
          icon: Icons.grid_on,
        ),
        const SizedBox(height: 12),
        _buildBenangCard(
          label: 'Penggunaan',
          value:
              widget.product.benangUsage?.name ?? widget.product.usage ?? '-',
          meaning:
              widget.product.benangUsage?.meaning ??
              'Keterangan tidak tersedia.',
          icon: Icons.accessibility_new,
        ),
      ],
    );
  }

  Widget _buildBenangCard({
    required String label,
    required String value,
    required String meaning,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: const Color(0xFF616161)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: const Color(0xFF616161),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showBenangDetailModal(label, value, meaning),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF757575),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Lihat Detail',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBenangDetailModal(String title, String subtitle, String content) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                content,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Tutup',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Legacy helper removed or replaced
  // Widget _buildInfoRow...

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFBDBDBD),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
      ),
      child: Row(
        children: [
          // Chat Icon
          GestureDetector(
            onTap: _openChat,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Buy Button
          Expanded(
            child: ElevatedButton(
              onPressed: _showBuyNowModal,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF757575),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Beli Langsung',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Cart Icon
          GestureDetector(
            onTap: _showAddToCartModal,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF757575),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartModal extends StatefulWidget {
  final Product product;
  final bool isDirectPurchase;

  const _CartModal({required this.product, required this.isDirectPurchase});

  @override
  State<_CartModal> createState() => _CartModalState();
}

class _CartModalState extends State<_CartModal> {
  final BuyerRepository _buyerRepository = BuyerRepository();
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.isDirectPurchase ? 'Beli Langsung' : 'Tambah Keranjang',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Image.network(
                widget.product.imageUrl ?? '',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.image),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Rp ${widget.product.price}',
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () =>
                    setState(() => _quantity > 1 ? _quantity-- : null),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                '$_quantity',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _quantity++),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final userId = Supabase.instance.client.auth.currentUser?.id;
                if (userId == null) return;

                if (widget.isDirectPurchase) {
                  // Direct buy logic
                  final cartItem = CartItem(
                    id: 'temp',
                    buyerId: userId,
                    productId: widget.product.id,
                    sellerId: widget.product.sellerId,
                    quantity: _quantity,
                    createdAt: DateTime.now(),
                    productName: widget.product.name,
                    productImageUrl: widget.product.imageUrl,
                    productPrice: widget.product.price,
                  );
                  Navigator.pop(context);
                  context.push('/buyer/payment', extra: [cartItem]);
                } else {
                  // Add to cart
                  await _buyerRepository.addToCart(
                    buyerId: userId,
                    productId: widget.product.id,
                    sellerId: widget.product.sellerId,
                    quantity: _quantity,
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Berhasil masuk keranjang')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF424242),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.isDirectPurchase
                    ? 'Lanjut Pembayaran'
                    : 'Tambah Keranjang',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

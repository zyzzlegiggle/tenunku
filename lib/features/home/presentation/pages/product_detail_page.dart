import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/product_model.dart';
import '../../data/models/profile_model.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/repositories/buyer_repository.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final BuyerRepository _buyerRepository = BuyerRepository();
  Profile? _sellerProfile;
  int _selectedTabIndex = 0; // 0 = Biografi Penenun, 1 = Benang Membumi

  @override
  void initState() {
    super.initState();
    _loadSellerProfile();
  }

  Future<void> _loadSellerProfile() async {
    try {
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
    } catch (e) {
      // Ignored
    }
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

  @override
  Widget build(BuildContext context) {
    final name = widget.product.name;
    final displayTitle = name;
    final imagePath = widget.product.imageUrl ?? '';
    final description = widget.product.description ?? 'Tidak ada deskripsi.';

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
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: imagePath.isNotEmpty
                        ? Image.network(
                            imagePath,
                            width: imageWidth,
                            height: imageHeight,
                            fit: BoxFit.cover,
                          )
                        : Container(color: Colors.grey),
                  ),
                  if (imagePath.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                  // Heart icon at bottom right of image
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        color: Color(0xFFF5793B),
                        size: 20,
                      ),
                    ),
                  ),
                ],
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
            top: topPad + 80, // Moved down for more space
            left: 40,
            right: 40,
            child: Text(
              displayTitle,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5E5E5E),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // ---- PRICE SECTION (fixed beside image) ----
          Positioned(
            top: contentTopOffset - 40, // Moved higher
            left: 28,
            width: imageLeft - 36, // Constrain so it does not overlap the image
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'Rp ${widget.product.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF727272),
                ),
              ),
            ),
          ),

          // ---- SCROLLABLE DESCRIPTION (only this scrolls) ----
          Positioned(
            top: contentTopOffset + 12, // Pushed down to avoid price
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 28,
                right: 28,
                top: 8,
                bottom:
                    120, // More bottom padding for scroll space above bottom bar
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF757575), // Updated to gray text
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Variants Section (Mockup sizes and variants)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ukuran',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF727272),
                                  fontSize: 14,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xFF727272),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Varian',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF727272),
                                  fontSize: 14,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xFF727272),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  const SizedBox(height: 24),

                  // Tabs Section
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5793B),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(child: _buildTabButton('Biografi Penenun', 0)),
                        Expanded(child: _buildTabButton('Benang Membumi', 1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tab Content
                  if (_selectedTabIndex == 0)
                    _buildBiografiPenenunContent()
                  else
                    const SizedBox(), // Placeholder for Benang Membumi
                ],
              ),
            ),
          ),

          // ---- BOTTOM NAVIGATION BAR (Overlaid text the bottom) ----
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(color: Color(0xFF54B7C2)),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Chat Button
                    GestureDetector(
                      onTap: _openChat,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          color: Color(0xFF757575),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Beli Langsung Button
                    Expanded(
                      child: GestureDetector(
                        onTap: _showBuyNowModal,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Beli Langsung',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF757575),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Cart Button
                    GestureDetector(
                      onTap: _showAddToCartModal,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shopping_cart_outlined,
                          color: Color(0xFF757575),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
          color: isSelected ? Colors.yellow : Colors.white,
          borderRadius: BorderRadius.circular(21),
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

  Widget _buildBiografiPenenunContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grey Profile Box - Left Aligned
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
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
                      _sellerProfile?.fullName ??
                          _sellerProfile?.shopName ??
                          'Nama Penenun',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF424242),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Color(0xFFF5793B), // Orange location icon
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Desa Kanekes',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600], // Gray text
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
            color: const Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _sellerProfile?.bio ??
              widget.product.description ??
              'Deskripsi tidak tersedia.',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF757575),
          ), // Gray text
        ),
        const SizedBox(height: 80), // extra padding for scrolling
      ],
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
  String? _selectedVariant = 'Garis';

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.product.imageUrl ?? '',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(width: 80, height: 80, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Rp ${widget.product.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF757575),
                      ),
                    ),
                    Text(
                      'Stok: ${widget.product.stock}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE9E9E9)),
          const SizedBox(height: 16),
          Text(
            'Varian',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF757575),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildVariantButton('Garis'),
              const SizedBox(width: 12),
              _buildVariantButton('Pola'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jumlah',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF757575),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFF0F0F0)),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          setState(() => _quantity > 1 ? _quantity-- : null),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF54B7C2),
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(8),
                          ),
                        ),
                        child: const Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      color: Colors.white,
                      child: Text(
                        '$_quantity',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF757575),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        if (_quantity < widget.product.stock) _quantity++;
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF54B7C2),
                          borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(8),
                          ),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
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
                backgroundColor: const Color(0xFFF5793B), // Orange color
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Slightly rounded
                ),
              ),
              child: Text(
                widget.isDirectPurchase
                    ? 'Beli Langsung'
                    : 'Masukkan Keranjang',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantButton(String title) {
    bool isActive = _selectedVariant == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedVariant = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF5793B) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                widget.product.imageUrl ?? '',
                width: 24,
                height: 24,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(width: 24, height: 24, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isActive ? Colors.white : const Color(0xFF757575),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/product_model.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/buyer_repository.dart';

/// Shows a bottom sheet modal with product details
/// Call this when a product is tapped from any listing page
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
  int _selectedTabIndex = 0; // 0 = Arti Filosofi, 1 = Barang Serupa
  String _selectedModality = 'Medium';

  final List<String> _modalities = ['Small', 'Medium', 'Large'];

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
      _sellerProfile = Profile.fromJson(productData['profiles']);
    }

    // Check if favorite
    if (userId != null) {
      _isFavorite = await _buyerRepository.isFavorite(
        userId,
        widget.product.id,
      );
      // Track view
      await _buyerRepository.trackProductView(userId, widget.product.id);
    }

    setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Halaman produk',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _toggleFavorite,
                      child: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.grey[600],
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProductImage(),
                            const SizedBox(height: 16),
                            _buildProductInfo(),
                            const SizedBox(height: 16),
                            _buildModalityDropdown(),
                            const SizedBox(height: 24),
                            _buildTabButtons(),
                            const SizedBox(height: 16),
                            _buildTabContent(),
                            const SizedBox(height: 100), // Bottom padding
                          ],
                        ),
                      ),
              ),
              // Bottom action bar
              _buildBottomBar(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Center(
            child: widget.product.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      widget.product.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (c, e, s) => _buildImagePlaceholder(),
                    ),
                  )
                : _buildImagePlaceholder(),
          ),
          // Image indicator dots
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[800],
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          // "Foto produk" button
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'foto produk',
                style: GoogleFonts.poppins(fontSize: 10, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.product.name,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.name,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp',
            decimalDigits: 0,
          ).format(widget.product.price),
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        if (widget.product.description != null) ...[
          const SizedBox(height: 12),
          Text(
            widget.product.description!,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildModalityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedModality,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: _modalities.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: GoogleFonts.poppins(fontSize: 14)),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() => _selectedModality = newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTabButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = 0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _selectedTabIndex == 0
                    ? const Color(0xFF424242)
                    : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                'Arti Filosofi',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _selectedTabIndex == 0
                      ? Colors.white
                      : Colors.grey[700],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = 1),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _selectedTabIndex == 1
                    ? const Color(0xFF424242)
                    : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                'Barang Serupa',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _selectedTabIndex == 1
                      ? Colors.white
                      : Colors.grey[700],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent() {
    if (_selectedTabIndex == 0) {
      return _buildPhilosophyTab();
    } else {
      return _buildSimilarProductsTab();
    }
  }

  Widget _buildPhilosophyTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Seller info header
        if (_sellerProfile != null) ...[
          _buildSellerHeader(),
          const SizedBox(height: 24),
        ],
        // Tentang Penenun section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tentang Penenun',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              // Arti Warna
              _buildPhilosophyItem(
                icon: Icons.palette_outlined,
                title: 'Arti Warna',
                description:
                    widget.product.colorMeaning ??
                    'Tidak ada informasi arti warna',
              ),
              const Divider(height: 24),
              // Arti Pola
              _buildPhilosophyItem(
                icon: Icons.grid_4x4_outlined,
                title: 'Arti Pola',
                description:
                    widget.product.patternMeaning ??
                    'Tidak ada informasi arti pola',
              ),
              const Divider(height: 24),
              // Penggunaan
              _buildPhilosophyItem(
                icon: Icons.info_outline,
                title: 'Penggunaan',
                description:
                    widget.product.usage ?? 'Tidak ada informasi penggunaan',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSellerHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFE0E0E0),
            backgroundImage: _sellerProfile?.avatarUrl != null
                ? NetworkImage(_sellerProfile!.avatarUrl!)
                : null,
            child: _sellerProfile?.avatarUrl == null
                ? Icon(Icons.person, color: Colors.grey[600])
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _sellerProfile?.fullName ?? 'Penenun',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _sellerProfile?.shopName ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhilosophyItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.grey[700]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarProductsTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          'Fitur barang serupa akan segera hadir',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cart icon button
          GestureDetector(
            onTap: _showAddToCartModal,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Buy now button
          Expanded(
            child: GestureDetector(
              onTap: _showBuyNowModal,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF424242),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Beli Langsung',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== CART / BUY NOW MODAL ====================

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
  bool _isLoading = false;

  double get _totalPrice => widget.product.price * _quantity;

  void _incrementQuantity() {
    if (_quantity < widget.product.stock || widget.product.stock == 0) {
      setState(() => _quantity++);
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  Future<void> _addToCart() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      await _buyerRepository.addToCart(
        buyerId: userId,
        productId: widget.product.id,
        sellerId: widget.product.sellerId,
        quantity: _quantity,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Berhasil ditambahkan ke keranjang',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menambahkan ke keranjang',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _buyNow() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      await _buyerRepository.createOrder(
        buyerId: userId,
        sellerId: widget.product.sellerId,
        productId: widget.product.id,
        quantity: _quantity,
        totalPrice: _totalPrice,
      );

      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context); // Also close the product detail modal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pesanan berhasil dibuat!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal membuat pesanan',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  widget.isDirectPurchase
                      ? 'Beli Langsung'
                      : 'Masukkan Keranjang',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 24),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Product preview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Product image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: widget.product.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.product.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Center(
                                child: Text(
                                  widget.product.name,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(fontSize: 8),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              widget.product.name,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(fontSize: 8),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Price and quantity
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp',
                          decimalDigits: 0,
                        ).format(_totalPrice),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Stok: ${widget.product.stock > 0 ? widget.product.stock : "Tersedia"}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Quantity controls
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _decrementQuantity,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.remove, size: 16),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '$_quantity',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _incrementQuantity,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Action button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: GestureDetector(
              onTap: _isLoading
                  ? null
                  : (widget.isDirectPurchase ? _buyNow : _addToCart),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _isLoading
                      ? Colors.grey[400]
                      : const Color(0xFF424242),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        widget.isDirectPurchase
                            ? 'Beli Langsung'
                            : 'Masukkan Keranjang',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

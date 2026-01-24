import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/repositories/buyer_repository.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final BuyerRepository _repository = BuyerRepository();
  List<CartItem> _cartItems = [];
  Set<String> _selectedItems = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final items = await _repository.getCartItems(userId);
    setState(() {
      _cartItems = items;
      _isLoading = false;
    });
  }

  // Group cart items by seller
  Map<String, List<CartItem>> get _groupedItems {
    final Map<String, List<CartItem>> grouped = {};
    for (final item in _cartItems) {
      grouped.putIfAbsent(item.sellerId, () => []).add(item);
    }
    return grouped;
  }

  double get _selectedTotal {
    double total = 0;
    for (final item in _cartItems) {
      if (_selectedItems.contains(item.id)) {
        total += (item.productPrice ?? 0) * item.quantity;
      }
    }
    return total;
  }

  bool get _allSelected =>
      _cartItems.isNotEmpty && _selectedItems.length == _cartItems.length;

  void _toggleSelectAll() {
    setState(() {
      if (_allSelected) {
        _selectedItems.clear();
      } else {
        _selectedItems = _cartItems.map((e) => e.id).toSet();
      }
    });
  }

  void _toggleItemSelection(String itemId) {
    setState(() {
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
      } else {
        _selectedItems.add(itemId);
      }
    });
  }

  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity < 1) return;

    setState(() {
      final index = _cartItems.indexWhere((e) => e.id == item.id);
      if (index != -1) {
        _cartItems[index] = item.copyWith(quantity: newQuantity);
      }
    });

    try {
      await _repository.updateCartItemQuantity(
        cartItemId: item.id,
        quantity: newQuantity,
      );
    } catch (e) {
      // Revert on error
      _loadCartItems();
    }
  }

  Future<void> _removeItem(CartItem item) async {
    setState(() {
      _cartItems.removeWhere((e) => e.id == item.id);
      _selectedItems.remove(item.id);
    });

    try {
      await _repository.removeFromCart(item.id);
    } catch (e) {
      _loadCartItems();
    }
  }

  void _goToPayment() {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pilih minimal satu produk',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
      return;
    }

    final selectedCartItems = _cartItems
        .where((item) => _selectedItems.contains(item.id))
        .toList();

    context.push('/buyer/payment', extra: selectedCartItems);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Keranjang',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push('/buyer/settings'),
                  child: Icon(Icons.settings_outlined, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _cartItems.isEmpty
                ? _buildEmptyState()
                : _buildCartList(),
          ),
          // Bottom bar
          if (_cartItems.isNotEmpty) _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Keranjang kosong',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai belanja dan tambahkan produk',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList() {
    final grouped = _groupedItems;
    final sellerIds = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sellerIds.length,
      itemBuilder: (context, index) {
        final sellerId = sellerIds[index];
        final items = grouped[sellerId]!;
        return _buildSellerGroup(sellerId, items);
      },
    );
  }

  Widget _buildSellerGroup(String sellerId, List<CartItem> items) {
    // Get seller name from first item (they're all from the same seller)
    // In real app, you'd fetch seller profile
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seller header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF424242),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Nama Toko',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Items
          ...items.map((item) => _buildCartItem(item)),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    final isSelected = _selectedItems.contains(item.id);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          GestureDetector(
            onTap: () => _toggleItemSelection(item.id),
            child: Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(right: 12, top: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF424242) : Colors.grey,
                  width: 2,
                ),
                color: isSelected
                    ? const Color(0xFF424242)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          // Product image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.productImageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.productImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => _buildProductPlaceholder(),
                    ),
                  )
                : _buildProductPlaceholder(),
          ),
          const SizedBox(width: 12),
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName ?? 'Produk',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Lorem ipsum dolor sit amet',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp',
                        decimalDigits: 0,
                      ).format(item.productPrice ?? 0),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    // Quantity controls
                    _buildQuantityControls(item),
                  ],
                ),
              ],
            ),
          ),
          // Delete button
          GestureDetector(
            onTap: () => _removeItem(item),
            child: Icon(
              Icons.delete_outline,
              size: 20,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductPlaceholder() {
    return Center(child: Icon(Icons.image, color: Colors.grey[400], size: 24));
  }

  Widget _buildQuantityControls(CartItem item) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _updateQuantity(item, item.quantity - 1),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.remove, size: 14, color: Colors.grey[600]),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${item.quantity}',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ),
          GestureDetector(
            onTap: () => _updateQuantity(item, item.quantity + 1),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.add, size: 14, color: Colors.grey[600]),
            ),
          ),
        ],
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
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Select all checkbox
            GestureDetector(
              onTap: _toggleSelectAll,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _allSelected ? const Color(0xFF424242) : Colors.grey,
                    width: 2,
                  ),
                  color: _allSelected
                      ? const Color(0xFF424242)
                      : Colors.transparent,
                ),
                child: _allSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Text('Semua', style: GoogleFonts.poppins(fontSize: 12)),
            const Spacer(),
            // Total
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp',
                    decimalDigits: 0,
                  ).format(_selectedTotal),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Pembayaran button
            GestureDetector(
              onTap: _goToPayment,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF424242),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Pembayaran',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

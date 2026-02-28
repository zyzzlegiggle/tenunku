import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/repositories/buyer_repository.dart';

class CartPage extends StatefulWidget {
  final Function(bool)? onSelectionChanged;

  const CartPage({super.key, this.onSelectionChanged});

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
    widget.onSelectionChanged?.call(_selectedItems.isNotEmpty);
  }

  void _toggleItemSelection(String itemId) {
    setState(() {
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
      } else {
        _selectedItems.add(itemId);
      }
    });
    widget.onSelectionChanged?.call(_selectedItems.isNotEmpty);
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
    widget.onSelectionChanged?.call(_selectedItems.isNotEmpty);

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
      color: Colors.white,
      child: Column(
        children: [
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _cartItems.isEmpty
                ? _buildEmptyState()
                : _buildCartList(),
          ),
          // Footer
          if (_selectedItems.isNotEmpty) _buildFooter(),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: sellerIds.length,
      itemBuilder: (context, index) {
        final sellerId = sellerIds[index];
        final items = grouped[sellerId]!;
        return _buildSellerCard(sellerId, items);
      },
    );
  }

  Widget _buildSellerCard(String sellerId, List<CartItem> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store Header
          Row(
            children: [
              Image.asset(
                'assets/homepage/namatoko.png',
                width: 24,
                height: 24,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.store, color: Color(0xFF757575), size: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF31476C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    items.first.sellerName ?? 'Nama Toko',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Products
          ...items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return Column(
              children: [
                _buildCartItem(item),
                if (idx < items.length - 1) const SizedBox(height: 16),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    final isSelected = _selectedItems.contains(item.id);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Checkbox
        _buildCheckbox(isSelected, () => _toggleItemSelection(item.id)),
        const SizedBox(width: 12),
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: item.productImageUrl != null
              ? Image.network(
                  item.productImageUrl!,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                )
              : Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
        ),
        const SizedBox(width: 16),
        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName ?? 'Produk',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF757575),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rp ${NumberFormat.decimalPattern('id').format(item.productPrice ?? 0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF757575),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => _updateQuantity(item, item.quantity - 1),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF54B7C2),
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(8),
                              ),
                            ),
                            child: const Icon(
                              Icons.remove,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          color: Colors.white,
                          child: Text(
                            '${item.quantity}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF757575),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _updateQuantity(item, item.quantity + 1),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF54B7C2),
                              borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(8),
                              ),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Delete
        GestureDetector(
          onTap: () => _removeItem(item),
          child: Icon(Icons.delete_outline, size: 20, color: Colors.grey[400]),
        ),
      ],
    );
  }

  Widget _buildCheckbox(
    bool isSelected,
    VoidCallback onTap, [
    bool isDarkBackground = false,
  ]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFF5793B)
              : (isDarkBackground ? Colors.transparent : Colors.white),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFF5793B)
                : (isDarkBackground ? Colors.white : const Color(0xFFE0E0E0)),
            width: 1,
          ),
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                size: 14,
                color: Color(0xFFFFE14F), // Yellow checkmark
              )
            : null,
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF54B7C2), // Cyan blue background
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(height: 1, color: Colors.white24),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildCheckbox(_allSelected, _toggleSelectAll, true),
                const SizedBox(width: 8),
                Text(
                  'Semua',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                ),
                const Spacer(),
                Text(
                  'Rp ${NumberFormat.decimalPattern('id').format(_selectedTotal)}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _goToPayment,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Pembayaran',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF54B7C2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

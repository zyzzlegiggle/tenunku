import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/repositories/buyer_repository.dart';

class PaymentPage extends StatefulWidget {
  final List<CartItem> cartItems;

  const PaymentPage({super.key, required this.cartItems});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final BuyerRepository _repository = BuyerRepository();
  bool _isLoading = false;
  late List<CartItem> _localCartItems;

  @override
  void initState() {
    super.initState();
    _localCartItems = List.from(widget.cartItems);
  }

  // Group cart items by seller
  Map<String, List<CartItem>> get _groupedItems {
    final Map<String, List<CartItem>> grouped = {};
    for (final item in _localCartItems) {
      grouped.putIfAbsent(item.sellerId, () => []).add(item);
    }
    return grouped;
  }

  double get _subtotal {
    double total = 0;
    for (final item in _localCartItems) {
      total += (item.productPrice ?? 0) * item.quantity;
    }
    return total;
  }

  // Fixed shipping cost for demo
  double get _shippingCost => 20000;

  double get _total => _subtotal + _shippingCost;

  int get _totalProducts => _localCartItems.length;

  Future<void> _checkout() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      // Validate stock first
      for (final item in _localCartItems) {
        final productData = await _repository.getProductWithSeller(
          item.productId,
        );
        if (productData == null) {
          throw Exception('Produk tidak ditemukan: ${item.productName}');
        }
        final currentStock = productData['stock'] as int;
        if (currentStock < item.quantity) {
          throw Exception('Stok tidak cukup untuk: ${item.productName}');
        }
      }

      // Create orders for each cart item
      for (final item in _localCartItems) {
        await _repository.createOrder(
          buyerId: userId,
          sellerId: item.sellerId,
          productId: item.productId,
          quantity: item.quantity,
          totalPrice: (item.productPrice ?? 0) * item.quantity,
        );
        // Decrement stock
        await _repository.decrementStock(item.productId, item.quantity);

        // Remove from cart after order created (skip for direct purchases)
        if (item.id != 'temp') {
          await _repository.removeFromCart(item.id);
        }
      }

      String? qris;
      try {
        if (_localCartItems.isNotEmpty) {
          final sellerProfile = await _repository.getProfile(
            _localCartItems.first.sellerId,
          );
          qris = sellerProfile?.qrisUrl;
        }
      } catch (e) {
        // Ignore
      }

      if (mounted) {
        context.go(
          '/buyer/payment/qris',
          extra: {'totalAmount': _total, 'qrisUrl': qris},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal membuat pesanan: $e',
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF54B7C2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8), // small white space
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$_totalProducts Produk',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF757575),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Products grouped by seller
                  ..._groupedItems.entries.map((entry) {
                    return _buildSellerGroup(entry.key, entry.value);
                  }),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
          // Bottom Payment Section
          _buildPaymentSummary(),
        ],
      ),
    );
  }

  Widget _buildSellerGroup(String sellerId, List<CartItem> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF31476C),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Nama Toko', // Extendable via join later
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(children: items.map((item) => _buildOrderItem(item)).toList()),
        ],
      ),
    );
  }

  Widget _buildOrderItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16), // Padding for individual cards
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    ),
                  )
                : Container(width: 70, height: 70, color: Colors.grey[300]),
          ),
          const SizedBox(width: 16),
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
                Text(
                  'Rp ${item.productPrice?.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.') ?? 0}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                            onTap: () {
                              if (item.quantity > 1) {
                                setState(() {
                                  final index = _localCartItems.indexWhere(
                                    (e) => e.id == item.id,
                                  );
                                  if (index != -1) {
                                    _localCartItems[index] = item.copyWith(
                                      quantity: item.quantity - 1,
                                    );
                                  }
                                });
                              }
                            },
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
                              '${item.quantity}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color(0xFF757575),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                final index = _localCartItems.indexWhere(
                                  (e) => e.id == item.id,
                                );
                                if (index != -1) {
                                  _localCartItems[index] = item.copyWith(
                                    quantity: item.quantity + 1,
                                  );
                                }
                              });
                            },
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ringkasan Belanja',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 16),
            // Subtotal
            _buildSummaryRow(
              'Subtotal ($_totalProducts produk)',
              'Rp ${_subtotal.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
            ),
            const SizedBox(height: 8),
            // Shipping
            _buildSummaryRow(
              'Ongkos Kirim',
              'Rp ${_shippingCost.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Color(0xFFE0E0E0)),
            ),
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF757575),
                  ),
                ),
                Text(
                  'Rp ${_total.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF5793B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Checkout button
            GestureDetector(
              onTap: _isLoading ? null : _checkout,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _isLoading
                      ? Colors.grey[400]
                      : const Color(0xFFF5793B),
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
                        'Lanjutkan Pembayaran',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            // Informasi Pengiriman Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE9E9E9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Pengiriman',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF757575),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Produk akan dikirim langsung dari penenun di Badui. Estimasi pengiriman 7-14 hari kerja.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.5,
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

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF757575),
          ),
        ),
      ],
    );
  }
}

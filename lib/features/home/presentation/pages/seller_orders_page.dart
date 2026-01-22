import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/seller_repository.dart';
import '../../data/models/order_model.dart';
import 'package:intl/intl.dart';

class SellerOrdersPage extends StatefulWidget {
  const SellerOrdersPage({super.key});

  @override
  State<SellerOrdersPage> createState() => _SellerOrdersPageState();
}

class _SellerOrdersPageState extends State<SellerOrdersPage> {
  final SellerRepository _sellerRepo = SellerRepository();
  final String _currentUserId = Supabase.instance.client.auth.currentUser!.id;

  String _selectedStatus =
      'pending'; // pending (Masuk), shipping (Dikirim), completed (Diterima)
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  // Mock counts for now, eventually could be fetched from DB
  int _incomingCount = 0;
  int _shippingCount = 0;
  int _completedCount = 0;

  // Mapping logic
  // 'pending' -> Pesanan Masuk
  // 'shipping' -> Dikirim
  // 'completed' -> Diterima

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);

    // In a real app we might want to fetch all counts at once or cache them
    // For this UI demo, we'll fetch the *selected* status list.
    // Ideally, we also want to know the counts for the tabs.
    // We can do separate small queries for counts if needed, or just fetch all active orders.
    // For simplicity and adherence to "First Principles" of just getting it working as requested:
    // We will just fetch the list for the current tab.
    // And maybe do a separate quick count if possible (or just fake the counts for the tabs if not critical, but let's try to be real).

    // Fetch current tab orders
    final orders = await _sellerRepo.getSellerOrders(
      _currentUserId,
      status: _selectedStatus,
    );

    // Quick separate fetches for counts (inefficient but works for MVP)
    // Optimization: create a db function to get counts. keeping it simple for now.
    final allOrders = await _sellerRepo.getSellerOrders(_currentUserId);
    final incoming = allOrders.where((o) => o.status == 'pending').length;
    final shipping = allOrders.where((o) => o.status == 'shipping').length;
    final completed = allOrders.where((o) => o.status == 'completed').length;

    if (mounted) {
      setState(() {
        _orders = orders;
        _incomingCount = incoming;
        _shippingCount = shipping;
        _completedCount = completed;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String orderId, String newStatus) async {
    await _sellerRepo.updateOrderStatus(orderId, newStatus);
    _fetchOrders(); // Refresh
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status Tabs/Dashboard
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  'Pesanan Masuk',
                  _incomingCount.toString(),
                  isSelected: _selectedStatus == 'pending',
                  onTap: () {
                    setState(() => _selectedStatus = 'pending');
                    _fetchOrders();
                  },
                ),
              ),
              const SizedBox(width: 4), // Small gap like in screenshot
              Expanded(
                child: _buildStatusCard(
                  'Dikirim',
                  _shippingCount.toString(),
                  isSelected: _selectedStatus == 'shipping',
                  onTap: () {
                    setState(() => _selectedStatus = 'shipping');
                    _fetchOrders();
                  },
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildStatusCard(
                  'Diterima',
                  _completedCount.toString(),
                  isSelected: _selectedStatus == 'completed',
                  onTap: () {
                    setState(() => _selectedStatus = 'completed');
                    _fetchOrders();
                  },
                ),
              ),
            ],
          ),
        ),

        // Orders List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(_orders[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    String title,
    String count, {
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    // Selected styles: White background, black border (or shadow/elevation to look distinct?)
    // Screenshot: "Pesanan Masuk 10" is white with border?
    // Wait, the screenshot shows "Pesanan Masuk" card is WHITE with rounded borders, while "Dikirim" and "Diterima" are DARK GREY.
    // This implies the standard "Selected vs Unselected" tab toggle pattern.

    final backgroundColor = isSelected ? Colors.white : const Color(0xFF757575);
    final textColor = isSelected ? Colors.black : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80, // Approximate height
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Colors.black12) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.black
                    : Colors
                          .white, // Explicitly black for selected, white for unselected
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFBDBDBD), // Grey background based on screenshot
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Buyer Name
          Text(
            order.buyerName ?? 'Nama Pembeli',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),

          // Product Name
          Text(
            order.productName ?? 'Nama barang yang dibeli',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
          ),

          const SizedBox(height: 12),

          // Quantity and Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.quantity} helai',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
              ),

              if (_selectedStatus == 'pending') ...[
                Row(
                  children: [
                    _buildActionButton(
                      'Tolak',
                      onTap: () {
                        _updateStatus(order.id, 'cancelled');
                      },
                      isPrimary: false,
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      'Terima',
                      onTap: () {
                        _updateStatus(order.id, 'shipping');
                      },
                      isPrimary: true,
                    ),
                  ],
                ),
              ] else ...[
                // If not pending, maybe show status or nothing?
                // Design only shows buttons on the cards in the screenshot.
                // Assuming the screenshot is of the "Pesanan Masuk" list where buttons are relevant.
                // For "Shipped" or "Received", maybe just status text?
                // I'll leave buttons hidden for other states for now, or maybe "Detail"?
                // Let's implement basics.
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label, {
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    // Accept = Dark Grey/Black, Reject = Outlined/White?
    // Screenshot: "Tolak" -> White Outline, White Text? No, background is grey.
    // "Tolak": Outline button, White border, White text? Or transparent bg?
    // "Terima": Dark button.

    // Looking closely at screenshot:
    // "Tolak": Transparent fill, White Border, White Text.
    // "Terima": Dark Grey fill (almost black), White Text.

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF616161) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isPrimary ? null : Border.all(color: Colors.white, width: 2),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

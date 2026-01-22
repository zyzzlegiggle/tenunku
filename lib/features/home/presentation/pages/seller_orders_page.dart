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

  // Filter for Diterima tab: Terbaru, Terlama, Dengan Foto, Harga Tertinggi
  String _selectedFilter = 'Terbaru';
  final List<String> _filters = [
    'Terbaru',
    'Terlama',
    'Dengan Foto',
    'Harga Tertinggi',
  ];

  // Counts for order tabs
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

  Future<void> _updateStatus(
    String orderId,
    String newStatus, {
    String? rejectionReason,
  }) async {
    await _sellerRepo.updateOrderStatus(
      orderId,
      newStatus,
      rejectionReason: rejectionReason,
    );
    _fetchOrders(); // Refresh
  }

  Future<void> _submitTrackingNumber(
    String orderId,
    String trackingNumber,
    String? shippingEvidenceUrl,
  ) async {
    await _sellerRepo.updateOrderTrackingNumber(
      orderId,
      trackingNumber,
      shippingEvidenceUrl: shippingEvidenceUrl,
    );
    // After adding tracking number, we might want to keep it in 'shipping' or move to another state?
    // Usually adding resi means it is definitely shipped.
    // Ensure status is shipping.
    // If it's already shipping, just update resi.
    _fetchOrders();
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

        // Filter buttons row - only for Diterima tab
        if (_selectedStatus == 'completed')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedFilter = filter);
                        _fetchOrders();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF757575)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF757575),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          filter,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF757575),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

        // Orders List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _orders.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada pesanan',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    // Use different card for Diterima tab
                    if (_selectedStatus == 'completed') {
                      return _buildDiterimaOrderCard(_orders[index]);
                    }
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

              if (_selectedStatus == 'pending')
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
                )
              else if (_selectedStatus == 'shipping')
                _buildActionButton(
                  'Masukan Resi',
                  onTap: () {
                    _showTrackingDialog(order);
                  },
                  isPrimary: false,
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build card for Diterima (completed) orders - shows product images, buyer name, rating, review
  Widget _buildDiterimaOrderCard(OrderModel order) {
    // Format timestamp
    final timeStr = DateFormat('HH:mm').format(order.createdAt.toLocal());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFBDBDBD), // Grey background
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product images row (grey circles as placeholders) - tappable to show photo modal
          Row(
            children: [
              // Multiple product image circles
              for (int i = 0; i < 4; i++) ...[
                GestureDetector(
                  onTap: () => _showPhotoModal(order, i),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF757575),
                      shape: BoxShape.circle,
                    ),
                    child: order.productImageUrl != null && i == 0
                        ? ClipOval(
                            child: Image.network(
                              order.productImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox(),
                            ),
                          )
                        : null,
                  ),
                ),
                if (i < 3) const SizedBox(width: 8),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // Buyer name and rating row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Buyer name
              Expanded(
                child: Text(
                  order.buyerName ?? 'Nama Pembeli',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Star rating (5 stars default for completed orders)
              Row(
                children: List.generate(5, (index) {
                  return Icon(Icons.star, size: 14, color: Colors.black54);
                }),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Review text and timestamp row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Review/description text
              Expanded(
                child: Text(
                  'Lorem ipsum dolor sit amet, consectetur',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Timestamp
              Text(
                timeStr,
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
              ),
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
    // "Masukan Resi" style check
    final isResiButton = label == 'Masukan Resi';

    // Colors
    // Primary (Terima): Dark Grey/Black fill (#616161), White Text
    // Secondary (Tolak): Transparent fill, White Border, White Text
    // Resi Button: Light Grey/White fill (#E0E0E0 or similar), Black Text

    Color bgColor;
    Color textColor;
    Border? border;

    if (isResiButton) {
      bgColor = const Color(0xFFE0E0E0).withOpacity(0.8); // Light greyish
      textColor = Colors.black87;
      border = null;
    } else if (isPrimary) {
      bgColor = const Color(0xFF616161);
      textColor = Colors.white;
      border = null;
    } else {
      bgColor = Colors.transparent;
      textColor = Colors.white;
      border = Border.all(color: Colors.white, width: 2);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: border,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  /// Show photo modal for viewing product/review images
  void _showPhotoModal(OrderModel order, int initialIndex) {
    // Collect available images (product image + any review images)
    final List<String?> images = [
      order.productImageUrl,
      null, // Placeholder for additional images
      null,
      null,
    ];

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) =>
          _PhotoModal(images: images, initialIndex: initialIndex),
    );
  }

  void _showRejectionDialog(String orderId) {
    showDialog(
      context: context,
      builder: (context) => _RejectionDialog(
        onSaved: (reason) {
          _updateStatus(orderId, 'cancelled', rejectionReason: reason);
        },
      ),
    );
  }

  void _showTrackingDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => _TrackingNumberDialog(
        order: order,
        onSaved: (trackingNumber, evidenceUrl) {
          _submitTrackingNumber(order.id, trackingNumber, evidenceUrl);
        },
      ),
    );
  }
}

class _TrackingNumberDialog extends StatefulWidget {
  final OrderModel order;
  final Function(String, String?) onSaved;

  const _TrackingNumberDialog({required this.order, required this.onSaved});

  @override
  State<_TrackingNumberDialog> createState() => _TrackingNumberDialogState();
}

class _TrackingNumberDialogState extends State<_TrackingNumberDialog> {
  final TextEditingController _controller = TextEditingController();
  // ignore: unused_field
  String? _evidenceUrl; // Placeholder for now

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(
        0xFFC4C4C4,
      ), // Lighter grey background match screenshot
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Text(
              widget.order.buyerName ?? 'Nama Pembeli',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              widget.order.productName ?? 'Nama barang yang dibeli',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.order.quantity} helai',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
            ),

            const SizedBox(height: 16),

            // Masukan Resi Input
            Text(
              'Masukan Resi',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _controller,
              style: GoogleFonts.poppins(color: Colors.black87),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE0E0E0),
                hintText: 'Nomor Resi',
                hintStyle: GoogleFonts.poppins(color: Colors.black38),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20), // Rounded pill shape
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Masukan Foto Bukti Pengiriman
            Text(
              'Masukan Foto Bukti Pengiriman',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                // TODO: Implement image picker
                // For now just show a snackbar or print
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur upload foto belum tersedia'),
                  ),
                );
              },
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 40,
                    color: Colors.black45,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'batal',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_controller.text.isNotEmpty) {
                        widget.onSaved(
                          _controller.text,
                          null, // TODO: Pass actual image URL
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Simpan',
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
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

class _RejectionDialog extends StatefulWidget {
  final Function(String) onSaved;

  const _RejectionDialog({required this.onSaved});

  @override
  State<_RejectionDialog> createState() => _RejectionDialogState();
}

class _RejectionDialogState extends State<_RejectionDialog> {
  String _selectedReason = '';

  final List<String> _reasons = [
    'Stok Habis',
    'Stok tidak akurat/selisih stok',
    'Produk Rusak/Cacat',
    'Terjadi Kesalahan Listing',
    'Kendala Operasional',
    'Lainnya',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFF616161),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Alasan Penolakan',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            // Mock items to match screenshot layout if needed, but simple text for now
            // Screenshot shows "Nama Pembeli", "Nama Barang", "2 helai" behind the modal?
            // Or inside? Ah, the modal is just the grey box.
            const SizedBox(height: 16),
            ..._reasons.map((reason) => _buildRadioOption(reason)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.white),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'batal',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_selectedReason.isNotEmpty) {
                        widget.onSaved(_selectedReason);
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Simpan',
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildRadioOption(String reason) {
    final isSelected = _selectedReason == reason;
    return GestureDetector(
      onTap: () => setState(() => _selectedReason = reason),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                color: isSelected ? Colors.white : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF616161),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(reason, style: GoogleFonts.poppins(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

/// Photo modal for viewing product/review images in fullscreen
class _PhotoModal extends StatefulWidget {
  final List<String?> images;
  final int initialIndex;

  const _PhotoModal({required this.images, required this.initialIndex});

  @override
  State<_PhotoModal> createState() => _PhotoModalState();
}

class _PhotoModalState extends State<_PhotoModal> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Photo container
            Container(
              height: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemCount: widget.images.length,
                itemBuilder: (context, index) {
                  final imageUrl = widget.images[index];
                  return Center(
                    child: imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.image_outlined,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                            ),
                          )
                        : Icon(
                            Icons.image_outlined,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Pagination dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (index) {
                final isActive = index == _currentIndex;
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? Colors.white : Colors.grey[600],
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            // "Sentuh Untuk Kembali" text
            Text(
              'Sentuh Untuk Kembali',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

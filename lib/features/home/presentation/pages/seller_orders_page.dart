import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/seller_repository.dart';
import '../../data/models/order_model.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../../../core/services/storage_service.dart';

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
    var orders = await _sellerRepo.getSellerOrders(
      _currentUserId,
      status: _selectedStatus,
    );

    // Apply filters if on Diterima tab
    if (_selectedStatus == 'completed') {
      if (_selectedFilter == 'Dengan Foto') {
        // Since we don't have actual review images in order model, we fall back to product image for demo
        orders = orders
            .where(
              (o) => o.productImageUrl != null && o.productImageUrl!.isNotEmpty,
            )
            .toList();
      }

      if (_selectedFilter == 'Terlama') {
        orders.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      } else if (_selectedFilter == 'Harga Tertinggi') {
        orders.sort((a, b) => b.totalPrice.compareTo(a.totalPrice));
      } else {
        // default to 'Terbaru'
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    }

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
        const SizedBox(height: 16),
        // Status Tabs/Dashboard
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFF5793B),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none, // Allow shadow to not be clipped
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedFilter = filter);
                        _fetchOrders();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFFE14F)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: !isSelected
                              ? [
                                  const BoxShadow(
                                    color:
                                        Colors.black26, // Thicker shadow color
                                    blurRadius: 6, // Thicker blur
                                    spreadRadius:
                                        1, // Add spread to ensure it's visible outside
                                    offset: Offset(
                                      0,
                                      3,
                                    ), // slightly deeper offset
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          filter,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
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
    final backgroundColor = isSelected ? const Color(0xFFFFE14F) : Colors.white;
    final textColor = isSelected ? Colors.black : const Color(0xFF969696);

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
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    if (_selectedStatus == 'shipping') {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF31476C), // Card background
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.buyerName ?? 'Nama Pembeli',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.productName ?? 'Nama barang yang dibeli',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.quantity} helai',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Product Image Container on right
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(12),
                    image:
                        order.productImageUrl != null &&
                            order.productImageUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(order.productImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child:
                      order.productImageUrl == null ||
                          order.productImageUrl!.isEmpty
                      ? const Icon(Icons.image, color: Colors.grey)
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Masukan Resi round button
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  _showTrackingDialog(order);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Masukan Resi',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF696969),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Pending state design
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
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
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
          ),

          const SizedBox(height: 8),

          Text(
            '${order.quantity} helai',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
          ),

          const SizedBox(height: 12),

          // Actions Row
          Align(
            alignment: Alignment.centerRight,
            child: _selectedStatus == 'pending'
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildActionButton(
                        'Tolak',
                        onTap: () {
                          _showRejectionDialog(order);
                        },
                        isPrimary: false,
                        customBorderColor: const Color(0xFFB3B3B3),
                        customTextColor: const Color(0xFFB3B3B3),
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        'Terima',
                        onTap: () {
                          _updateStatus(order.id, 'shipping');
                        },
                        isPrimary: true,
                        customBgColor: const Color(0xFF54B7C2),
                        customTextColor: Colors.white,
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  /// Build card for Diterima (completed) orders - comment layout
  Widget _buildDiterimaOrderCard(OrderModel order) {
    // Format timestamp
    final timeStr = DateFormat('HH:mm').format(order.createdAt.toLocal());

    // Generate random color for profile placeholder based on buyer name
    final buyerName = order.buyerName ?? 'Nama Pembeli';
    final colors = [
      const Color(0xFFF5793B),
      const Color(0xFF54B7C2),
      const Color(0xFF31476C),
      const Color(0xFFFFE14F),
    ];
    final colorIndex = buyerName.codeUnitAt(0) % colors.length;
    final profileColor = colors[colorIndex];

    // Dummy images since order model doesn't fetch review images natively in this slice
    List<String> images = [];
    if (order.productImageUrl != null && order.productImageUrl!.isNotEmpty) {
      images.add(order.productImageUrl!);
      images.add(order.productImageUrl!); // Added duplicate for demo layout
      images.add(order.productImageUrl!);
      images.add(order.productImageUrl!); // +1 left
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFC3C3C3), width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile image
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: profileColor,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.person, color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      buyerName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return const Icon(
                          Icons.star,
                          size: 14,
                          color: Color(0xFFFFE14F),
                        );
                      }),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Comment
                Text(
                  'Bahan kain yg dipakai sangat nyaman. Warna tidak luntur. Top banget deh!',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 12),

                // Images Row
                if (images.isNotEmpty)
                  Row(
                    children: [
                      for (int i = 0; i < images.length && i < 3; i++) ...[
                        GestureDetector(
                          onTap: () => _showPhotoModal(order, i, images),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFFE0E0E0),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    images[i],
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                if (i == 2 && images.length > 3)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '+${images.length - 3}',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (i < 2 && (i + 1) < images.length)
                          const SizedBox(width: 8),
                      ],
                    ],
                  ),

                const SizedBox(height: 8),

                // Upload time
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    timeStr,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.black45,
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

  Widget _buildActionButton(
    String label, {
    required VoidCallback onTap,
    required bool isPrimary,
    Color? customBgColor,
    Color? customTextColor,
    Color? customBorderColor,
  }) {
    final isResiButton = label == 'Masukan Resi';

    Color bgColor =
        customBgColor ??
        (isResiButton
            ? const Color(0xFFE0E0E0).withOpacity(0.8)
            : (isPrimary ? const Color(0xFF616161) : Colors.transparent));
    Color textColor =
        customTextColor ?? (isResiButton ? Colors.black87 : Colors.white);
    Border? border;

    if (customBorderColor != null) {
      border = Border.all(color: customBorderColor, width: 2);
    } else if (!isPrimary && !isResiButton) {
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
  void _showPhotoModal(
    OrderModel order,
    int initialIndex,
    List<String> images,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) =>
          _PhotoModal(images: images, initialIndex: initialIndex),
    );
  }

  void _showRejectionDialog(OrderModel order) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(
        0.5,
      ), // Semi black transparent background
      builder: (context) => _RejectionDialog(
        order: order,
        onSaved: (reason) {
          _updateStatus(order.id, 'cancelled', rejectionReason: reason);
        },
      ),
    );
  }

  void _showTrackingDialog(OrderModel order) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(
        0.5,
      ), // Semi black transparent background
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
  final StorageService _storageService = StorageService();
  File? _evidenceImage;
  String? _evidenceUrl;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    try {
      final File? image = await _storageService.pickImage();
      if (image != null) {
        setState(() {
          _evidenceImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengambil gambar: $e')));
      }
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      return await _storageService.uploadImage('shipping_evidence', image);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengupload gambar: $e')));
      }
      return null;
    }
  }

  Future<void> _submit() async {
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nomor Resi harus diisi')));
      return;
    }

    setState(() => _isUploading = true);

    try {
      if (_evidenceImage != null) {
        final url = await _uploadImage(_evidenceImage!);
        if (url == null) {
          setState(() => _isUploading = false);
          return;
        }
        _evidenceUrl = url;
      }

      widget.onSaved(_controller.text, _evidenceUrl);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFF31476C), // Dark blue background
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF54B7C2), // Cyan header
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.order.buyerName ?? 'Nama Pembeli',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.order.productName ?? 'Nama barang yang dibeli',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Jumlah: ${widget.order.quantity} helai',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),

          // Body Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Masukan Resi Input
                Text(
                  'Masukkan Resi',
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
                    fillColor: Colors.white,
                    hintText: 'Nomor Resi',
                    hintStyle: GoogleFonts.poppins(color: Colors.black38),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Masukan Foto Bukti Pengiriman
                Text(
                  'Masukkan Foto Bukti Pengiriman',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      image: _evidenceImage != null
                          ? DecorationImage(
                              image: FileImage(_evidenceImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _evidenceImage == null
                        ? const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 40,
                              color: Colors.black45,
                            ),
                          )
                        : null,
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
                            border: Border.all(color: Colors.white, width: 1.5),
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
                        onTap: _isUploading ? null : _submit,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF54B7C2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.center,
                          child: _isUploading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Simpan',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
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
        ],
      ),
    );
  }
}

class _RejectionDialog extends StatefulWidget {
  final OrderModel order;
  final Function(String) onSaved;

  const _RejectionDialog({required this.order, required this.onSaved});

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
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFF31476C), // Dark blue background
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF54B7C2), // Cyan header
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih Alasan Penolakan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.order.productName ?? 'Nama barang yang dibeli',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Jumlah: ${widget.order.quantity} helai',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),

          // Body Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._reasons.map((reason) => _buildRadioOption(reason)),
                const SizedBox(height: 24),

                // Action Buttons
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
                            border: Border.all(color: Colors.white, width: 1.5),
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
                            color: const Color(0xFF54B7C2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Simpan',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
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
        ],
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
                          color: Color(
                            0xFF31476C,
                          ), // Inner dot color matches card background
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                reason,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              ),
            ),
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

  void _nextPage() {
    if (_currentIndex < widget.images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Photo container
              Container(
                height: 350,
                width: double.infinity,
                decoration: BoxDecoration(
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
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.white,
                                child: const Icon(
                                  Icons.image_outlined,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.white,
                              child: const Icon(
                                Icons.image_outlined,
                                size: 60,
                                color: Colors.grey,
                              ),
                            ),
                    );
                  },
                ),
              ),

              // Left Arrow
              if (widget.images.length > 1)
                Positioned(
                  left: -15, // shifted more to be outside/on edge
                  child: GestureDetector(
                    onTap: _prevPage,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4),
                        ],
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF54B7C2),
                        size: 28,
                      ),
                    ),
                  ),
                ),

              // Right Arrow
              if (widget.images.length > 1)
                Positioned(
                  right: -15, // shifted more to be outside/on edge
                  child: GestureDetector(
                    onTap: _nextPage,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4),
                        ],
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF54B7C2),
                        size: 28,
                      ),
                    ),
                  ),
                ),

              // Close Button (Top right corner exactly middle)
              Positioned(
                top: -15,
                right: -15,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5793B),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFFFFE14F),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Pagination dots
          if (widget.images.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (index) {
                final isActive = index == _currentIndex;
                return Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? const Color(0xFFFFE14F) : Colors.white,
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}

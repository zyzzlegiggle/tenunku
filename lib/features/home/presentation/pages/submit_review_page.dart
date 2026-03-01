import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../../data/repositories/buyer_repository.dart';
import '../../data/models/order_model.dart';
import '../../../../core/services/storage_service.dart';

class SubmitReviewPage extends StatefulWidget {
  const SubmitReviewPage({super.key});

  @override
  State<SubmitReviewPage> createState() => _SubmitReviewPageState();
}

class _SubmitReviewPageState extends State<SubmitReviewPage> {
  final BuyerRepository _repository = BuyerRepository();
  final StorageService _storageService = StorageService();
  List<OrderModel> _ordersNeedingReview = [];
  bool _isLoading = true;

  // Review form state with map for multiple inputs
  final Map<String, int> _ratings = {};
  final Map<String, TextEditingController> _commentControllers = {};
  final Map<String, File?> _imageFiles = {};
  final Map<String, File?> _videoFiles = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadOrdersNeedingReview();
  }

  Future<void> _loadOrdersNeedingReview() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final orders = await _repository.getOrdersNeedingReview(userId);

    // Initialize form states to avoid null errors later
    for (var order in orders) {
      if (!_ratings.containsKey(order.id)) {
        _ratings[order.id] = 0;
        _commentControllers[order.id] = TextEditingController();
      }
    }

    setState(() {
      _ordersNeedingReview = orders;
      _isLoading = false;
    });
  }

  Future<void> _pickImage(String orderId) async {
    try {
      final File? image = await _storageService.pickImage();
      if (image != null) {
        setState(() {
          _imageFiles[orderId] = image;
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

  Future<void> _pickVideo(String orderId) async {
    try {
      final File? video = await _storageService.pickVideo();
      if (video != null) {
        setState(() {
          _videoFiles[orderId] = video;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengambil video: $e')));
      }
    }
  }

  Future<void> _submitReview() async {
    final validOrders = _ordersNeedingReview
        .where((o) => (_ratings[o.id] ?? 0) > 0)
        .toList();
    if (validOrders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih rating untuk minimal satu produk')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      for (var order in validOrders) {
        String? imageUrl;
        if (_imageFiles[order.id] != null) {
          imageUrl = await _storageService.uploadImage(
            'reviews',
            _imageFiles[order.id]!,
            path:
                '$userId/${DateTime.now().millisecondsSinceEpoch}_${order.id}.jpg',
          );
        }

        String? videoUrl;
        if (_videoFiles[order.id] != null) {
          final fileExt = _videoFiles[order.id]!.path.split('.').last;
          videoUrl = await _storageService.uploadVideo(
            'reviews',
            _videoFiles[order.id]!,
            path:
                '$userId/${DateTime.now().millisecondsSinceEpoch}_${order.id}.$fileExt',
          );
        }

        await _repository.submitReview(
          productId: order.productId,
          userId: userId,
          orderId: order.id,
          rating: _ratings[order.id]!,
          comment: _commentControllers[order.id]!.text.trim().isNotEmpty
              ? _commentControllers[order.id]!.text.trim()
              : null,
          imageUrl: imageUrl,
          videoUrl: videoUrl,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terima kasih atas penilaian Anda!')),
        );

        // Remove processed orders from tracking Maps
        for (var order in validOrders) {
          _ratings.remove(order.id);
          _commentControllers[order.id]?.dispose();
          _commentControllers.remove(order.id);
          _imageFiles.remove(order.id);
          _videoFiles.remove(order.id);
        }
        // Load the remaining unrated products
        await _loadOrdersNeedingReview();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    for (var controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFE0E0E0,
      ), // Outer gray background matching screenshot
      appBar: AppBar(
        backgroundColor: const Color(0xFF54B7C2), // Cyan background
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFFFFE14F),
          ), // Yellow arrow
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Beri Penilaian',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ordersNeedingReview.isEmpty
          ? _buildEmptyState()
          : _buildReviewForm(),
      bottomNavigationBar: Container(
        color: const Color(0xFF54B7C2), // Cyan blue background
        padding: const EdgeInsets.only(bottom: 16, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(context, 'Beranda', 0, Icons.home),
            _buildNavItem(context, 'Telusuri', 1, Icons.search),
            _buildNavItem(context, 'Keranjang', 2, Icons.shopping_cart),
            _buildNavItem(
              context,
              'Akun Saya',
              3,
              Icons.person,
              isActive:
                  true, // Beri penilaian context is mostly in user's profile
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String label,
    int index,
    IconData icon, {
    bool isActive = false,
  }) {
    const yellow = Color(0xFFFFE14F);
    const navyBlue = Color(0xFF31476C);

    return GestureDetector(
      onTap: () {
        context.go('/buyer', extra: index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isActive ? yellow : navyBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? navyBlue : Colors.grey[400],
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.white,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star_outline, size: 64, color: Color(0xFF9E9E9E)),
          const SizedBox(height: 16),
          Text(
            'Tidak ada pesanan yang perlu dinilai',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pesanan yang sudah selesai akan muncul disini',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFFBDBDBD),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewForm() {
    return Column(
      children: [
        // Info Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'Nilai produkmu agar kami dapat meningkatkan kualitas kami!',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: _ordersNeedingReview.length,
            itemBuilder: (context, index) {
              final order = _ordersNeedingReview[index];
              return _buildOrderCard(order);
            },
          ),
        ),

        // Submit Button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF5793B), // Orange button
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Kirim',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Shop Name Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF31476C), // Dark blue
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Text(
                order.sellerShopName ?? 'Nama Toko',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),

            // Card Content Section
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0F0), // Light grey background
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Sub-Info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image Wrapper
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: order.productImageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    order.productImageUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.image,
                                    color: Color(0xFF9E9E9E),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        // Titles and Rates
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.productName ?? 'Nama produk',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF333333),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp${_formatPrice(order.totalPrice)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: const Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Rating Block Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nilai Produk',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() => _ratings[order.id] = index + 1);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  index < (_ratings[order.id] ?? 0)
                                      ? Icons
                                            .star // Filled star look
                                      : Icons.star, // Unfilled/Grey star look
                                  size: 32,
                                  color: index < (_ratings[order.id] ?? 0)
                                      ? const Color(0xFFFFE14F) // Yellow
                                      : const Color(0xFF9E9E9E), // Grey
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Image Upload Area Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tambahkan Foto dan Video',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _imageFiles[order.id] != null
                                  ? Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        Container(
                                          height: 90,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            image: DecorationImage(
                                              image: FileImage(
                                                _imageFiles[order.id]!,
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          ),
                                          onPressed: () => setState(
                                            () => _imageFiles[order.id] = null,
                                          ),
                                        ),
                                      ],
                                    )
                                  : _buildMediaButton(
                                      icon: Icons.photo_camera_outlined,
                                      label: 'Foto',
                                      onTap: () => _pickImage(order.id),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _videoFiles[order.id] != null
                                  ? Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        Container(
                                          height: 90,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.black12,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.play_circle_fill,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => setState(
                                            () => _videoFiles[order.id] = null,
                                          ),
                                        ),
                                      ],
                                    )
                                  : _buildMediaButton(
                                      icon: Icons.videocam_outlined,
                                      label: 'Video',
                                      onTap: () => _pickVideo(order.id),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // User Experient/Comment
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ceritakan Pengalaman Kamu',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _commentControllers[order.id],
                            maxLines: 4,
                            maxLength: 250,
                            decoration: InputDecoration(
                              hintText: 'Bagikan pengalaman kamu disini',
                              hintStyle: GoogleFonts.poppins(
                                color: const Color(0xFFBDBDBD),
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(12),
                              counterText: "", // Replaced counter text display
                            ),
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: AnimatedBuilder(
                            animation: _commentControllers[order.id]!,
                            builder: (context, child) {
                              return Text(
                                '${_commentControllers[order.id]!.text.length}/250 Karakter',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: const Color(0xFF9E9E9E),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: const Color(0xFF9E9E9E)),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
  OrderModel? _selectedOrder;

  // Review form state
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadOrdersNeedingReview();
  }

  Future<void> _loadOrdersNeedingReview() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final orders = await _repository.getOrdersNeedingReview(userId);
    setState(() {
      _ordersNeedingReview = orders;
      if (orders.isNotEmpty) {
        _selectedOrder = orders.first;
      }
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    try {
      final File? image = await _storageService.pickImage();
      if (image != null) {
        setState(() {
          _imageFile = image;
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

  Future<void> _submitReview() async {
    if (_selectedOrder == null || _rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih rating terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _storageService.uploadImage(
          'reviews', // Ensure 'reviews' bucket exists
          _imageFile!,
          path: '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      await _repository.submitReview(
        productId: _selectedOrder!.productId,
        userId: userId,
        orderId: _selectedOrder!.id,
        rating: _rating,
        comment: _commentController.text.trim().isNotEmpty
            ? _commentController.text.trim()
            : null,
        imageUrl: imageUrl, // Pass image URL
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terima kasih atas penilaian Anda!')),
        );
        context.pop();
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
    _commentController.dispose();
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF616161),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ordersNeedingReview.isEmpty
          ? _buildEmptyState()
          : _buildReviewForm(),
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
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: const Color(0xFFF5F5F5),
                  child: Text(
                    'Nilai produkmu agar kami dapat meningkatkan kualitas kami!',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF666666),
                    ),
                  ),
                ),

                // Shop Name Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                  ),
                  child: Text(
                    _selectedOrder?.sellerShopName ?? 'Nama Toko',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF333333),
                    ),
                  ),
                ),

                // Product Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Product Image
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _selectedOrder?.productImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _selectedOrder!.productImageUrl!,
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
                      // Product Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedOrder?.productName ?? 'Nama produk',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF333333),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp${_formatPrice(_selectedOrder?.totalPrice ?? 0)}',
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

                // Rating Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nilai Produk',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() => _rating = index + 1);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                index < _rating
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 32,
                                color: index < _rating
                                    ? const Color(0xFF333333)
                                    : const Color(0xFFBDBDBD),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: Color(0xFFE0E0E0)),

                // Photo and Video Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tambahkan Foto dan Video',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Foto Button
                          Expanded(
                            child: _imageFile != null
                                ? Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Container(
                                        height: 100,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          image: DecorationImage(
                                            image: FileImage(_imageFile!),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        ),
                                        onPressed: () =>
                                            setState(() => _imageFile = null),
                                      ),
                                    ],
                                  )
                                : _buildMediaButton(
                                    icon: Icons.photo_camera_outlined,
                                    label: 'Foto',
                                    onTap: _pickImage,
                                  ),
                          ),
                          const SizedBox(width: 12),
                          // Video Button
                          Expanded(
                            child: _buildMediaButton(
                              icon: Icons.videocam_outlined,
                              label: 'Video',
                              onTap: () {
                                // TODO: Implement video picker
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: Color(0xFFE0E0E0)),

                // Experience Text Area
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ceritakan Pengalaman Kamu',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _commentController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Bagikan pengalaman kamu disini',
                            hintStyle: GoogleFonts.poppins(
                              color: const Color(0xFF9E9E9E),
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '0/1 Karakter',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF9E9E9E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Submit Button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF424242),
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

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: const Color(0xFF666666)),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

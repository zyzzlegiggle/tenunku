import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../../../core/services/storage_service.dart';
import '../../data/models/product_model.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/seller_repository.dart';

class SellerProductDetailPage extends StatefulWidget {
  final Product product;

  const SellerProductDetailPage({super.key, required this.product});

  @override
  State<SellerProductDetailPage> createState() =>
      _SellerProductDetailPageState();
}

class _SellerProductDetailPageState extends State<SellerProductDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SellerRepository _sellerRepo = SellerRepository();
  final StorageService _storageService = StorageService();

  List<String> _currentImageUrls = [];
  final List<File> _newImages = [];

  // Form Controllers
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _descriptionController;
  late TextEditingController _colorMeaningController;
  late TextEditingController _patternMeaningController;
  late TextEditingController _usageController;

  bool _isLoadingReviews = true;
  List<Review> _reviews = [];
  bool _isSaving = false;
  bool _isReviewsExpanded = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize image URLs
    if (widget.product.imageUrls.isNotEmpty) {
      _currentImageUrls = List.from(widget.product.imageUrls);
    } else if (widget.product.imageUrl != null) {
      _currentImageUrls = [widget.product.imageUrl!];
    }

    // Initialize controllers with product data
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(
      text: widget.product.price.toStringAsFixed(0),
    );
    _stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.product.description ?? '',
    );
    _colorMeaningController = TextEditingController(
      text: widget.product.colorMeaning ?? '',
    );
    _patternMeaningController = TextEditingController(
      text: widget.product.patternMeaning ?? '',
    );
    _usageController = TextEditingController(text: widget.product.usage ?? '');

    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    try {
      final reviews = await _sellerRepo.getProductReviews(widget.product.id);
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingReviews = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final File? image = await _storageService.pickImage();
      if (image != null) {
        setState(() {
          _newImages.add(image);
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

  void _removeDetailedImage(int index) {
    setState(() {
      if (index < _currentImageUrls.length) {
        _currentImageUrls.removeAt(index);
      } else {
        _newImages.removeAt(index - _currentImageUrls.length);
      }
    });
  }

  Future<List<String>> _uploadNewImages(List<File> images) async {
    List<String> urls = [];
    for (var image in images) {
      try {
        final url = await _storageService.uploadImage('products', image);
        urls.add(url);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengupload gambar: $e')),
          );
        }
      }
    }
    return urls;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    _colorMeaningController.dispose();
    _patternMeaningController.dispose();
    _usageController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_currentImageUrls.isEmpty && _newImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal satu gambar produk wajib diisi')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      // Upload new images
      List<String> newUrls = [];
      if (_newImages.isNotEmpty) {
        newUrls = await _uploadNewImages(_newImages);
        if (newUrls.length != _newImages.length) {
          // Some uploads might have failed, but we continue with what we have
          // or we could stop. For now continuing.
        }
      }

      final allImageUrls = [..._currentImageUrls, ...newUrls];
      final mainImageUrl = allImageUrls.isNotEmpty ? allImageUrls.first : null;

      final updatedProduct = Product(
        id: widget.product.id,
        sellerId: widget.product.sellerId,
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.tryParse(_priceController.text) ?? widget.product.price,
        imageUrl: mainImageUrl, // First image as main
        imageUrls: allImageUrls,
        category: widget.product.category,
        stock: int.tryParse(_stockController.text) ?? widget.product.stock,
        soldCount: widget.product.soldCount,
        viewCount: widget.product.viewCount,
        averageRating: widget.product.averageRating,
        totalReviews: widget.product.totalReviews,
        colorMeaning: _colorMeaningController.text,
        patternMeaning: _patternMeaningController.text,
        usage: _usageController.text,
        createdAt: widget.product.createdAt,
      );

      await _sellerRepo.updateProduct(updatedProduct);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perubahan berhasil disimpan')),
        );
        context.pop(); // Go back to refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAAAAAA), // Medium Grey Background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Produkmu',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Custom Tab Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 45,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF424242), // Dark Grey Container
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  color: Colors.white,
                ),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white,
                labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Informasi Produk'),
                  Tab(text: 'Performa Produk'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildProductInfoTab(), _buildProductPerformanceTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfoTab() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image List
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _currentImageUrls.length + _newImages.length + 1,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final totalImages =
                          _currentImageUrls.length + _newImages.length;
                      if (index == totalImages) {
                        return GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFF757575),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey[400]!),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_a_photo,
                                  color: Colors.white70,
                                  size: 30,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tambah',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      ImageProvider imageProvider;
                      if (index < _currentImageUrls.length) {
                        imageProvider = NetworkImage(_currentImageUrls[index]);
                      } else {
                        imageProvider = FileImage(
                          _newImages[index - _currentImageUrls.length],
                        );
                      }

                      return Stack(
                        children: [
                          Container(
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(color: Colors.grey[400]!),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeDetailedImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 4,
                  width: 100,
                  margin: const EdgeInsets.only(right: 150), // visual approx
                  decoration: BoxDecoration(
                    color: const Color(0xFF616161),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 16),

                _buildLabel('Nama Produk'),
                _buildTextField(_nameController),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Harga'),
                          _buildTextField(_priceController, isNumber: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Stok'),
                          _buildTextField(_stockController, isNumber: true),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildLabel('Deskripsi'),
                _buildTextField(_descriptionController, maxLines: 3),
                const SizedBox(height: 24),

                Text(
                  'Benang Membumi',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildBenangInfoItem(
                        'Arti Warna',
                        _colorMeaningController,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildBenangInfoItem(
                        'Arti Pola',
                        _patternMeaningController,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildBenangInfoItem(
                        'Penggunaan',
                        _usageController,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Bottom Actions
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    backgroundColor: const Color(0xFF757575),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBDBDBD), // Lighter grey
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Simpan',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBenangInfoItem(String title, TextEditingController controller) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 80,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFD6D6D6), // Grey content area
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.poppins(fontSize: 10),
            maxLines: null,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  Widget _buildProductPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildStatCard('Terjual', '${widget.product.soldCount} Helai'),
          _buildStatCard('Dilihat', '${widget.product.viewCount} Kali'),

          // Reviews Section
          Column(
            children: [
              // Header
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isReviewsExpanded = !_isReviewsExpanded;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF757575), // Dark grey
                    borderRadius: _isReviewsExpanded
                        ? const BorderRadius.vertical(top: Radius.circular(24))
                        : BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jumlah Ulasan',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${widget.product.totalReviews}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  'Ulasan',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Lihat Ulasan',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                _isReviewsExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Expanded List
              if (_isReviewsExpanded)
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEEEEE), // Light grey matching design
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                  ),
                  child: _isLoadingReviews
                      ? const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _reviews.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: Text(
                              'Belum ada ulasan',
                              style: GoogleFonts.poppins(color: Colors.black54),
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            for (int i = 0; i < _reviews.length; i++)
                              _buildReviewItem(
                                _reviews[i],
                                isLast: i == _reviews.length - 1,
                              ),
                          ],
                        ),
                ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF757575), // Dark grey
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Review review, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: !isLast
            ? const Border(bottom: BorderSide(color: Colors.black12))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFAAAAAA),
                  image: review.userAvatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(review.userAvatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          review.userName ?? 'Nama Pembeli',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              Icons.star,
                              size: 16,
                              color: index < review.rating
                                  ? const Color(0xFF424242) // Dark star
                                  : Colors.black12,
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
          const SizedBox(height: 12),
          Text(
            review.comment ?? '',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.multiline,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFE0E0E0), // Light grey input
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
    );
  }
}

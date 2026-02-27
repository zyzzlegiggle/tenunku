import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../../data/models/product_model.dart';
import '../../data/models/benang_membumi_model.dart';
import '../../data/repositories/seller_repository.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../../core/services/storage_service.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final SellerRepository _sellerRepo = SellerRepository();
  final AuthRepository _authRepo = AuthRepository();
  final StorageService _storageService = StorageService();

  final List<File> _selectedImages = [];
  final List<String> _uploadedImageUrls = [];

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _colorMeaningController = TextEditingController();
  final TextEditingController _patternMeaningController =
      TextEditingController();
  final TextEditingController _usageController = TextEditingController();

  // Benang Membumi Data
  List<BenangPattern> _patterns = [];
  List<BenangColor> _colors = [];
  List<BenangUsage> _usages = [];
  String? _selectedPatternId;
  String? _selectedColorId;
  String? _selectedUsageId;
  String _selectedCategory = 'Kain';

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    try {
      final patterns = await _sellerRepo.getBenangPatterns();
      final colors = await _sellerRepo.getBenangColors();
      final usages = await _sellerRepo.getBenangUsages();

      if (mounted) {
        setState(() {
          _patterns = patterns;
          _colors = colors;
          _usages = usages;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data Benang Membumi: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    _colorMeaningController.dispose();
    _patternMeaningController.dispose();
    _usageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final File? image = await _storageService.pickImage();
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
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

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<List<String>> _uploadImages(List<File> images) async {
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

  Future<void> _saveProductWithUpload() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan Harga produk wajib diisi')),
      );
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal satu gambar produk wajib diisi')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Upload images
      final urls = await _uploadImages(_selectedImages);
      if (urls.isEmpty) {
        setState(() => _isSaving = false);
        return; // Stop if upload fails for all images
      }
      _uploadedImageUrls.addAll(urls);

      final user = _authRepo.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Use the first image as the main thumbnail
      final mainImageUrl = _uploadedImageUrls.isNotEmpty
          ? _uploadedImageUrls.first
          : null;

      final newProduct = Product(
        id: const Uuid().v4(),
        sellerId: user.id,
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.tryParse(_priceController.text) ?? 0,
        imageUrl: mainImageUrl,
        imageUrls: _uploadedImageUrls,
        category: _selectedCategory,
        stock: int.tryParse(_stockController.text) ?? 0,
        soldCount: 0,
        viewCount: 0,
        averageRating: 0,
        totalReviews: 0,
        // Legacy fields filled with Name for fallback/display if join fails
        colorMeaning: _colors
            .where((e) => e.id == _selectedColorId)
            .firstOrNull
            ?.name,
        patternMeaning: _patterns
            .where((e) => e.id == _selectedPatternId)
            .firstOrNull
            ?.name,
        usage: _usages.where((e) => e.id == _selectedUsageId).firstOrNull?.name,
        // New IDs
        patternId: _selectedPatternId,
        colorId: _selectedColorId,
        usageId: _selectedUsageId,
        createdAt: DateTime.now(),
      );

      await _sellerRepo.createProduct(newProduct);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil ditambahkan')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menambahkan produk: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    int filledFields = 0;
    if (_nameController.text.isNotEmpty) filledFields++;
    if (_priceController.text.isNotEmpty) filledFields++;
    if (_stockController.text.isNotEmpty) filledFields++;
    if (_descriptionController.text.isNotEmpty) filledFields++;
    if (_selectedImages.isNotEmpty) filledFields++;

    double progress = filledFields / 5.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Custom Header
              Container(
                color: const Color(0xFF54B7C2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFFFFE14F),
                        size: 28,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Produkmu',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/seller/settings'),
                      child: const Icon(
                        Icons.settings,
                        color: Color(0xFFFFE14F),
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              // Title Section
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add,
                          color: Color(0xFF54B7C2),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tambah Produk Baru',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ini informasi lengkap tentang produk tenun Anda',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // Tabs Section
              Container(
                color: const Color(0xFFF5793B),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE14F),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Informasi Produk',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF464646),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Performa Produk',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF727272),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image List
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length + 1,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          if (index == _selectedImages.length) {
                            return GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 120,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFD7E2FF),
                                      Color(0xFF7585AA),
                                    ],
                                    stops: [0.0, 0.54],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add,
                                      color: Color(0xFFFFE14F),
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tambahkan',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Stack(
                            children: [
                              Container(
                                width: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: FileImage(_selectedImages[index]),
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
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

                    // Progress Bar
                    if (progress > 0) ...[
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFD9D9D9),
                          color: const Color(0xFF54B7C2),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    _buildLabel('Nama Produk', fontSize: 16),
                    _buildTextField(
                      _nameController,
                      hint: 'Lorem ipsum dolor sit amet',
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Harga', fontSize: 16),
                              _buildTextField(
                                _priceController,
                                isNumber: true,
                                hint: 'RpXXX.XXX',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Stok', fontSize: 16),
                              _buildTextField(
                                _stockController,
                                isNumber: true,
                                hint: '1',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Kategori', fontSize: 16),
                    _buildCategoryDropdown(),
                    const SizedBox(height: 16),

                    _buildLabel('Deskripsi', fontSize: 16),
                    _buildTextField(
                      _descriptionController,
                      maxLines: 4,
                      hint: 'Ceritakan tentang produk Anda...',
                    ),
                    const SizedBox(height: 24),

                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveProductWithUpload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5793B),
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
                                color: Colors.white,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: fontSize,
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
    String? hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.multiline,
        maxLines: maxLines,
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
        decoration: InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return PopupMenuButton<String>(
          position: PopupMenuPosition.under,
          color: const Color(0xFFFFE14F),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          constraints: BoxConstraints(
            minWidth: constraints.maxWidth,
            maxWidth: constraints.maxWidth,
          ),
          onSelected: (val) {
            setState(() {
              _selectedCategory = val;
            });
          },
          itemBuilder: (context) {
            return ['Kain', 'Aksesori', 'Pakaian'].map((item) {
              final isSelected = item == _selectedCategory;
              return PopupMenuItem<String>(
                value: item,
                padding: EdgeInsets.zero,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF727272),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check,
                          color: Color(0xFF54B7C2),
                          size: 18,
                        ),
                    ],
                  ),
                ),
              );
            }).toList();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCategory,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Color(0xFF54B7C2)),
              ],
            ),
          ),
        );
      },
    );
  }
}

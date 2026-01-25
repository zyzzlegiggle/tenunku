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
  bool _isLoadingMetadata = true;

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
          _isLoadingMetadata = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data Benang Membumi: $e')),
        );
        setState(() => _isLoadingMetadata = false);
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
        category: 'Tenun',
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Tambah Produk',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
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
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == _selectedImages.length) {
                    return GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_a_photo,
                              color: Colors.black54,
                              size: 30,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tambah',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.black54,
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
            const SizedBox(height: 24),

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
            _buildTextField(_descriptionController, maxLines: 4),
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

            if (_isLoadingMetadata)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  _buildDropdown<BenangColor>(
                    label: 'Arti Warna',
                    hint: 'Pilih Warna',
                    value: _selectedColorId,
                    items: _colors,
                    onChanged: (val) => setState(() => _selectedColorId = val),
                    itemLabel: (item) => item.name,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown<BenangPattern>(
                    label: 'Arti Pola',
                    hint: 'Pilih Pola',
                    value: _selectedPatternId,
                    items: _patterns,
                    onChanged: (val) =>
                        setState(() => _selectedPatternId = val),
                    itemLabel: (item) => item.name,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown<BenangUsage>(
                    label: 'Penggunaan',
                    hint: 'Pilih Penggunaan',
                    value: _selectedUsageId,
                    items: _usages,
                    onChanged: (val) => setState(() => _selectedUsageId = val),
                    itemLabel: (item) => item.name,
                  ),
                ],
              ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveProductWithUpload,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF616161),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.multiline,
        maxLines: maxLines,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required String hint,
    required String? value,
    required List<T> items,
    required Function(String?) onChanged,
    required String Function(T) itemLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(hint, style: GoogleFonts.poppins(fontSize: 14)),
              isExpanded: true,
              items: items.map((item) {
                // We assume items have an 'id' property, but T is generic.
                // We need to access id. casting to dynamic or using interface.
                // Since our models all have id, dynamic is easiest for this helper.
                final id = (item as dynamic).id;
                return DropdownMenuItem<String>(
                  value: id,
                  child: Text(
                    itemLabel(item),
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

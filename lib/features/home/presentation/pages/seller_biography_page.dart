import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/profile_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import '../widgets/buyer_product_detail_modal.dart';

class SellerBiographyPage extends StatefulWidget {
  final Profile seller;

  const SellerBiographyPage({super.key, required this.seller});

  @override
  State<SellerBiographyPage> createState() => _SellerBiographyPageState();
}

class _SellerBiographyPageState extends State<SellerBiographyPage> {
  final ProductRepository _productRepository = ProductRepository();
  int _selectedTabIndex = 0;
  List<Product> _sellerProducts = [];
  bool _isLoadingProducts = true;

  final List<String> _tabs = ['Kisah', 'Harapan', 'Keseharian'];

  @override
  void initState() {
    super.initState();
    _loadSellerProducts();
  }

  Future<void> _loadSellerProducts() async {
    try {
      final products = await _productRepository.getProductsBySeller(
        widget.seller.id,
      );
      setState(() {
        _sellerProducts = products;
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() => _isLoadingProducts = false);
    }
  }

  String get _currentTabContent {
    switch (_selectedTabIndex) {
      case 0:
        return widget.seller.description ??
            'Saya adalah seorang penenun yang telah menekuni seni tenun tradisional selama bertahun-tahun. Setiap karya yang saya hasilkan adalah cerminan dari warisan budaya leluhur yang ingin saya lestarikan untuk generasi mendatang.';
      case 1:
        return widget.seller.hope ??
            'Harapan saya adalah agar seni tenun tradisional Indonesia tetap lestari dan dikenal di seluruh dunia. Saya berharap dapat terus menciptakan karya-karya indah yang bermakna dan dapat membantu sesama penenun untuk berkembang.';
      case 2:
        return widget.seller.dailyActivity ??
            'Setiap hari saya memulai aktivitas dengan menenun di pagi hari. Proses menenun membutuhkan ketelitian dan kesabaran. Saya juga mengajarkan teknik menenun kepada generasi muda agar tradisi ini terus berlanjut.';
      default:
        return '';
    }
  }

  String get _currentTabTitle {
    switch (_selectedTabIndex) {
      case 0:
        return 'Perjalanan Hidup';
      case 1:
        return 'Impian & Harapan';
      case 2:
        return 'Kehidupan Sehari-hari';
      default:
        return '';
    }
  }

  int? get _sellerAge {
    return widget.seller.age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF424242)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Biografi Penenun',
          style: GoogleFonts.poppins(
            color: const Color(0xFF333333),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            _buildProfileSection(),
            const SizedBox(height: 16),
            // Tab Navigation
            _buildTabNavigation(),
            const SizedBox(height: 16),
            // Tab Content
            _buildTabContent(),
            const SizedBox(height: 24),
            // Seller Products
            _buildSellerProducts(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFFE0E0E0),
            backgroundImage: widget.seller.avatarUrl != null
                ? NetworkImage(widget.seller.avatarUrl!)
                : null,
            child: widget.seller.avatarUrl == null
                ? Icon(Icons.person, size: 40, color: Colors.grey[600])
                : null,
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            widget.seller.fullName ?? 'Penenun',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Age
          if (_sellerAge != null) ...[
            const SizedBox(height: 4),
            Text(
              '$_sellerAge Tahun',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
          // Shop info
          if (widget.seller.shopName != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store_outlined, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  widget.seller.shopName!,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = index),
              child: Container(
                margin: EdgeInsets.only(
                  left: index == 0 ? 0 : 4,
                  right: index == _tabs.length - 1 ? 0 : 4,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF424242)
                      : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _tabs[index],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title with icon
          Row(
            children: [
              Icon(_getTabIcon(), size: 18, color: const Color(0xFF424242)),
              const SizedBox(width: 8),
              Text(
                _currentTabTitle,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Content
          Text(
            _currentTabContent,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTabIcon() {
    switch (_selectedTabIndex) {
      case 0:
        return Icons.auto_stories_outlined;
      case 1:
        return Icons.lightbulb_outline;
      case 2:
        return Icons.wb_sunny_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildSellerProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Produk dari ${widget.seller.fullName ?? "Penenun"}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Products grid or loading
        _isLoadingProducts
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            : _sellerProducts.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Belum ada produk',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              )
            : SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _sellerProducts.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(_sellerProducts[index]);
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => showBuyerProductDetailModal(context, product),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: product.imageUrl != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Center(
                          child: Icon(Icons.image, color: Colors.grey[400]),
                        ),
                      ),
                    )
                  : Center(child: Icon(Icons.image, color: Colors.grey[400])),
            ),
            // Product info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(product.price),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF424242),
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
}

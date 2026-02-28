import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/buyer_repository.dart';
import '../../data/models/product_model.dart';
import '../widgets/buyer_product_detail_modal.dart';

class FavoritesPage extends StatefulWidget {
  final VoidCallback? onBack;
  const FavoritesPage({super.key, this.onBack});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final BuyerRepository _repository = BuyerRepository();
  List<Product> _favorites = [];
  List<Product> _filteredFavorites = [];
  bool _isLoading = true;
  String _selectedStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final favorites = await _repository.getFavorites(userId);
    setState(() {
      _favorites = favorites;
      _filteredFavorites = favorites;
      _isLoading = false;
    });
  }

  void _filterFavorites() {
    setState(() {
      _filteredFavorites = _favorites.where((product) {
        if (_selectedStatus == 'Semua') return true;
        if (_selectedStatus == 'Tersedia') return product.stock > 0;
        if (_selectedStatus == 'Tidak Tersedia') return product.stock == 0;
        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    const cyanBlue = Color(0xFF54B7C2);
    const yellow = Color(0xFFFFE14F);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Fixed Header - Cyan blue background
              Container(
                color: cyanBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: yellow,
                        size: 28,
                      ),
                      onPressed: () {
                        if (widget.onBack != null) {
                          widget.onBack!();
                        } else {
                          context.pop();
                        }
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Favorit Saya',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/buyer/settings'),
                      child: const Icon(
                        Icons.settings,
                        color: yellow,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Filter Section
              Container(
                color: const Color(0xFFF5793B),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    // "Semua" Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedStatus = 'Semua';
                            _filterFavorites();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _selectedStatus == 'Semua'
                                ? yellow
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _selectedStatus == 'Semua'
                                  ? Colors.transparent
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            'Semua',
                            style: GoogleFonts.poppins(
                              color: _selectedStatus == 'Semua'
                                  ? Colors.black
                                  : Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // "Status" Dropdown
                    Expanded(
                      child: PopupMenuButton<String>(
                        color: const Color(0xFFFFE14F),
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width - 32,
                          maxWidth: MediaQuery.of(context).size.width - 32,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        offset: const Offset(0, 45),
                        onSelected: (String result) {
                          setState(() {
                            if (result == 'Status') {
                              _selectedStatus = 'Semua';
                            } else {
                              _selectedStatus = result;
                            }
                            _filterFavorites();
                          });
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'Status',
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedStatus == 'Semua'
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Status',
                                    style: GoogleFonts.poppins(
                                      color: _selectedStatus == 'Semua'
                                          ? Colors.grey
                                          : Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'Tersedia',
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedStatus == 'Tersedia'
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Tersedia',
                                    style: GoogleFonts.poppins(
                                      color: _selectedStatus == 'Tersedia'
                                          ? Colors.grey
                                          : Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'Tidak Tersedia',
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedStatus == 'Tidak Tersedia'
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Tidak Tersedia',
                                    style: GoogleFonts.poppins(
                                      color: _selectedStatus == 'Tidak Tersedia'
                                          ? Colors.grey
                                          : Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedStatus != 'Semua'
                                ? yellow
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _selectedStatus != 'Semua'
                                  ? Colors.transparent
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedStatus == 'Semua'
                                      ? 'Status'
                                      : _selectedStatus,
                                  style: GoogleFonts.poppins(
                                    color: _selectedStatus != 'Semua'
                                        ? Colors.black
                                        : Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 20,
                                color: _selectedStatus != 'Semua'
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Products Grid
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredFavorites.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.favorite_outline,
                              size: 64,
                              color: Color(0xFF9E9E9E),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada favorit',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: const Color(0xFF9E9E9E),
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: _filteredFavorites.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => showBuyerProductDetailModal(
                              context,
                              _filteredFavorites[index],
                            ),
                            child: _buildProductCard(_filteredFavorites[index]),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF31476C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  child: product.imageUrl != null
                      ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                      : Container(
                          color: const Color(0xFFE0E0E0),
                          child: const Icon(
                            Icons.image,
                            size: 40,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        const Color(0xFF31476C).withOpacity(0.5),
                        const Color(0xFF31476C).withOpacity(0.9),
                        const Color(0xFF31476C),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Text(
                    product.name,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: 12,
              top: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Rp ${_formatPrice(product.price)}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF54B7C2), // Cyan blue background
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Lihat',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}

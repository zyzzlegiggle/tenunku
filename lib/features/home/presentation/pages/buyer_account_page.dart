import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/buyer_repository.dart';
import '../../data/models/profile_model.dart';

class BuyerAccountPage extends StatefulWidget {
  final VoidCallback? onFavoritesTap;
  const BuyerAccountPage({super.key, this.onFavoritesTap});

  @override
  State<BuyerAccountPage> createState() => _BuyerAccountPageState();
}

class _BuyerAccountPageState extends State<BuyerAccountPage> {
  final BuyerRepository _repository = BuyerRepository();
  Profile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final profile = await _repository.getProfile(userId);

    setState(() {
      _profile = profile;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF31476C), // Dark blue background
                  image: _profile?.bannerUrl != null
                      ? DecorationImage(
                          image: NetworkImage(_profile!.bannerUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF616161),
                        border: Border.all(
                          color: const Color(0xFFFFE14F),
                          width: 6,
                        ),
                        image: _profile?.avatarUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_profile!.avatarUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _profile?.avatarUrl == null
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 60,
                            )
                          : null,
                    ),
                    const SizedBox(width: 20),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _profile?.fullName ?? 'Nama User',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFFE14F),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _profile?.bio ?? 'Bio: -',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white70,
                              height: 1.2,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Jenis Kelamin: Laki-laki',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            'Alamat: ${_profile?.description ?? '-'}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Nomor Telepon: ${_profile?.phone ?? '-'}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Container(
                color: const Color(0xFF54B7C2), // Cyan blue background
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 24.0,
                  top: 16.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        'Edit Profil',
                        () => context.push('/buyer/edit-profile'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: _buildActionButton('Bagikan Profil')),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Pesanan Saya Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pesanan Saya',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black, // Left side in black
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildOrderCard(
                          image: 'assets/homepage/belumbayar.png',
                          label: 'Belum Bayar',
                        ),
                        _buildOrderCard(
                          image: 'assets/homepage/dikemas.png',
                          label: 'Dikemas',
                        ),
                        _buildOrderCard(
                          image: 'assets/homepage/dikirim.png',
                          label: 'Dikirim',
                        ),
                        _buildOrderCard(
                          image: 'assets/homepage/beripenilaian.png',
                          label: 'Beri Penilaian',
                          onTap: () => context.push('/buyer/submit-review'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Aktivitas Saya Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aktivitas Saya',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black, // Left side in black
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActivityCard(
                      icon: Icons.favorite,
                      label: 'Favorit Saya',
                      onTap: () {
                        if (widget.onFavoritesTap != null) {
                          widget.onFavoritesTap!();
                        } else {
                          context.push('/buyer/favorites');
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildActivityCard(
                      icon: Icons.shopping_cart,
                      label: 'Beli Lagi',
                      onTap: () => context.push('/buyer/buy-again'),
                    ),
                    const SizedBox(height: 12),
                    _buildActivityCard(
                      icon: null,
                      label: 'Terakhir Dilihat',
                      onTap: () => context.push('/buyer/recently-viewed'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 120), // Padding bottom for scroll view
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, [VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white, // Button is white
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard({
    required String image,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 100, // Added fixed height to force equal size
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, width: 32, height: 32),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: const Color(0xFF727272),
                  fontWeight: FontWeight.w500,
                  height:
                      1.1, // Added line height for better multi-line readability
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required IconData? icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: const Color(0xFFF5793B), size: 24),
              const SizedBox(width: 16),
            ] else ...[
              const SizedBox(
                width: 40,
              ), // Placeholder width if no icon for alignment
            ],
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFFFE14F), // Yellow right arrow
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repositories/buyer_repository.dart';
import '../../../data/models/address_model.dart';

class BuyerAddressPage extends StatefulWidget {
  const BuyerAddressPage({super.key});

  @override
  State<BuyerAddressPage> createState() => _BuyerAddressPageState();
}

class _BuyerAddressPageState extends State<BuyerAddressPage> {
  final BuyerRepository _buyerRepo = BuyerRepository();
  bool _isLoading = true;
  List<Map<String, dynamic>> _addresses = [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final addresses = await _buyerRepo.getAddresses(user.id);
      if (mounted) {
        setState(() {
          _addresses = addresses;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const cyanBlue = Color(0xFF54B7C2);
    const yellow = Color(0xFFFFE14F);
    const darkOrange = Color(0xFFF5793B);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: cyanBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: yellow),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Alamat Saya',
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
          : Column(
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: _addresses.isEmpty
                      ? Center(
                          child: Text(
                            'Belum ada alamat tersimpan.',
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: _addresses.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFF5793B), // orange divider
                          ),
                          itemBuilder: (context, index) {
                            final addressMap = _addresses[index];
                            final address = AddressModel.fromJson(addressMap);
                            return _buildAddressCard(
                              context,
                              label: address.label,
                              name: address.recipientName,
                              address: address.fullAddress,
                              isPrimary: address.isPrimary,
                              onTap: () => _showAddressDialog(address: address),
                            );
                          },
                        ),
                ),
                // Bottom button section
                Container(
                  width: double.infinity,
                  color: darkOrange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddressDialog(),
                    icon: const Icon(Icons.add, size: 20),
                    label: Text(
                      'Tambah Alamat Baru',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yellow,
                      foregroundColor: const Color(0xFF6B6B6B),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        color: cyanBlue,
        padding: const EdgeInsets.only(bottom: 16, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(context, 'Beranda', 0, Icons.home),
            _buildNavItem(context, 'Telusuri', 1, Icons.search),
            _buildNavItem(context, 'Keranjang', 2, Icons.shopping_cart),
            _buildNavItem(context, 'Akun Saya', 3, Icons.person),
          ],
        ),
      ),
    );
  }

  void _showAddressDialog({AddressModel? address}) {
    final labelController = TextEditingController(text: address?.label);
    final nameController = TextEditingController(text: address?.recipientName);
    final phoneController = TextEditingController(text: address?.phone);
    final addressController = TextEditingController(text: address?.fullAddress);
    bool isPrimary = address?.isPrimary ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(address == null ? 'Tambah Alamat' : 'Edit Alamat', style: GoogleFonts.poppins()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField('Label (Rumah, Kantor, dll)', labelController),
                _buildDialogField('Nama Penerima', nameController),
                _buildDialogField('No. Handphone', phoneController, isPhone: true),
                _buildDialogField('Alamat Lengkap', addressController, maxLines: 3),
                CheckboxListTile(
                  title: Text('Alamat Utama', style: GoogleFonts.poppins(fontSize: 14)),
                  value: isPrimary,
                  onChanged: (val) => setDialogState(() => isPrimary = val ?? false),
                  contentPadding: EdgeInsets.zero,
                  activeColor: const Color(0xFF54B7C2),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final userId = Supabase.instance.client.auth.currentUser?.id;
                if (userId == null) return;

                final newAddress = AddressModel(
                  id: address?.id ?? '',
                  userId: userId,
                  label: labelController.text,
                  recipientName: nameController.text,
                  phone: phoneController.text,
                  fullAddress: addressController.text,
                  isPrimary: isPrimary,
                );

                try {
                  if (address == null) {
                    await _buyerRepo.addAddress(newAddress);
                  } else {
                    await _buyerRepo.updateAddress(newAddress);
                  }
                  if (isPrimary) {
                    await _buyerRepo.setPrimaryAddress(userId, address?.id ?? '');
                  }
                  _loadAddresses();
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF54B7C2)),
              child: Text('Simpan', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller, {bool isPhone = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(fontSize: 12),
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF54B7C2))),
        ),
        style: GoogleFonts.poppins(fontSize: 14),
      ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context, {
    required String label,
    required String name,
    required String address,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF4F4F4), // Light grey background
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            label,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: const Color(0xFF31476C), // Navy blue
                            ),
                          ),
                          if (isPrimary) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF54B7C2).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Utama',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: const Color(0xFF54B7C2),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF6B6B6B),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Icon(
                    Icons.chevron_right,
                    size: 24,
                    color: Color(0xFF54B7C2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String label,
    int index,
    IconData icon,
  ) {
    const yellow = Color(0xFFFFE14F);
    const navyBlue = Color(0xFF31476C);
    final bool isActive = index == 3;

    return GestureDetector(
      onTap: () {
        if (isActive) {
          context.pop();
        } else {
          context.go('/buyer', extra: index);
        }
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
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repositories/user_settings_repository.dart';

class BuyerAppNotificationsPage extends StatefulWidget {
  const BuyerAppNotificationsPage({super.key});

  @override
  State<BuyerAppNotificationsPage> createState() =>
      _BuyerAppNotificationsPageState();
}

class _BuyerAppNotificationsPageState extends State<BuyerAppNotificationsPage> {
  final UserSettingsRepository _settingsRepo = UserSettingsRepository();
  bool _isLoading = true;

  // Settings map
  Map<String, dynamic> _settings = {
    'app': true,
    'surat': false,
    'orders': true,
    'chat': true,
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      final settings = await _settingsRepo.getNotificationSettings(userId);
      if (mounted) {
        setState(() {
          _settings.addAll(settings);
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateSetting(String key, bool value) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() {
      _settings[key] = value;
      // If main app toggle is off, turn off everything? Or just keep them as is.
      // For now let's just update the value.
    });

    try {
      // Get all current settings (including email/whatsapp if we merged them)
      // For now just save the current map state merged with what we have
      await _settingsRepo.saveNotificationSettings(userId, _settings);
    } catch (e) {
      // Revert on error?
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan pengaturan')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifikasi Aplikasi',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  // Main toggle section
                  _buildSection(
                    children: [
                      _buildSwitchItem(
                        'Notifikasi di Aplikasi',
                        _settings['app'] ?? true,
                        (val) => _updateSetting('app', val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Sub notification toggles
                  // Only active if main toggle is on? Or independent?
                  // Usually if main is off, others are disabled or hidden.
                  Opacity(
                    opacity: (_settings['app'] ?? true) ? 1.0 : 0.5,
                    child: IgnorePointer(
                      ignoring: !(_settings['app'] ?? true),
                      child: _buildSection(
                        children: [
                          _buildSwitchItem(
                            'Surat Notifikasi',
                            _settings['surat'] ?? false,
                            (val) => _updateSetting('surat', val),
                            showDivider: true,
                          ),
                          _buildSwitchItem(
                            'Pesanan',
                            _settings['orders'] ?? true,
                            (val) => _updateSetting('orders', val),
                            showDivider: true,
                          ),
                          _buildSwitchItem(
                            'Chat',
                            _settings['chat'] ?? true,
                            (val) => _updateSetting('chat', val),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSection({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSwitchItem(
    String label,
    bool value,
    ValueChanged<bool> onChanged, {
    bool showDivider = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.grey[700],
              activeTrackColor: Colors.grey[300],
            ),
          ],
        ),
        if (showDivider)
          const Divider(height: 24, thickness: 1, color: Color(0xFFE0E0E0)),
      ],
    );
  }
}

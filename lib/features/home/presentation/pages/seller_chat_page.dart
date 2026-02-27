import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/seller_repository.dart';
import '../../data/models/conversation_model.dart';
import '../../../auth/data/repositories/auth_repository.dart';

class SellerChatPage extends StatefulWidget {
  const SellerChatPage({super.key});

  @override
  State<SellerChatPage> createState() => _SellerChatPageState();
}

class _SellerChatPageState extends State<SellerChatPage> {
  final SellerRepository _sellerRepo = SellerRepository();
  final AuthRepository _authRepo = AuthRepository();

  List<ConversationModel> _conversations = [];
  Map<String, int> _unreadCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchConversations() async {
    final user = _authRepo.currentUser;
    if (user != null) {
      final conversations = await _sellerRepo.getSellerConversations(user.id);

      // Fetch unread counts for each conversation
      final Map<String, int> counts = {};
      for (var conv in conversations) {
        counts[conv.id] = await _sellerRepo.getUnreadCount(conv.id, user.id);
      }

      if (mounted) {
        setState(() {
          _conversations = conversations;
          _unreadCounts = counts;
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openConversation(ConversationModel conversation) async {
    final user = _authRepo.currentUser;
    if (user != null) {
      // Mark as read immediately when opened
      await _sellerRepo.markMessagesAsRead(conversation.id, user.id);
    }
    await context.push('/seller/chat/detail', extra: conversation);
    _fetchConversations();
  }

  @override
  Widget build(BuildContext context) {
    return _buildConversationListView();
  }

  // ==================== CONVERSATION LIST VIEW ====================

  Widget _buildConversationListView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada obrolan',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Obrolan dengan pembeli akan muncul di sini',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        final unreadCount = _unreadCounts[conversation.id] ?? 0;
        return _buildConversationTile(conversation, unreadCount);
      },
    );
  }

  Widget _buildConversationTile(
    ConversationModel conversation,
    int unreadCount,
  ) {
    final timeString = _formatTime(conversation.lastMessageAt);

    // Profile color logic matching comment section
    final buyerName = conversation.buyerName ?? 'Nama Pembeli';
    final colors = [
      const Color(0xFFF5793B),
      const Color(0xFF54B7C2),
      const Color(0xFF31476C),
      const Color(0xFFFFE14F),
    ];
    final colorIndex = buyerName.codeUnitAt(0) % colors.length;
    final profileColor = colors[colorIndex];

    return InkWell(
      onTap: () => _openConversation(conversation),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: profileColor,
                image: conversation.buyerAvatarUrl != null
                    ? DecorationImage(
                        image: NetworkImage(conversation.buyerAvatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: conversation.buyerAvatarUrl == null
                  ? const Center(
                      child: Icon(Icons.person, color: Colors.white, size: 32),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Name and message preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.buyerName ?? 'Nama Pembeli',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.lastMessage ?? 'Belum ada pesan',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Time and unread badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeString,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF54B7C2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: const Color(0xFFFFE14F),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HELPERS ====================

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

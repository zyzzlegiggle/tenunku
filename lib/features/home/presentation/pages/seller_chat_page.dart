import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/repositories/seller_repository.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/message_model.dart';
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

  // Selected conversation for chat detail view
  ConversationModel? _selectedConversation;
  List<MessageModel> _messages = [];
  bool _isLoadingMessages = false;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
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
    setState(() {
      _selectedConversation = conversation;
      _isLoadingMessages = true;
    });

    final user = _authRepo.currentUser;
    if (user != null) {
      // Mark messages as read
      await _sellerRepo.markMessagesAsRead(conversation.id, user.id);

      // Fetch messages
      final messages = await _sellerRepo.getMessages(conversation.id);

      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoadingMessages = false;
          _unreadCounts[conversation.id] = 0;
        });

        // Scroll to bottom after messages load
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _selectedConversation == null) return;

    final user = _authRepo.currentUser;
    if (user == null) return;

    _messageController.clear();

    await _sellerRepo.sendMessage(_selectedConversation!.id, user.id, content);

    // Refresh messages
    final messages = await _sellerRepo.getMessages(_selectedConversation!.id);

    if (mounted) {
      setState(() {
        _messages = messages;
      });

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

      // Refresh conversations to update last message
      _fetchConversations();
    }
  }

  void _goBack() {
    setState(() {
      _selectedConversation = null;
      _messages = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedConversation != null) {
      return _buildChatDetailView();
    }
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF9E9E9E),
                image: conversation.buyerAvatarUrl != null
                    ? DecorationImage(
                        image: NetworkImage(conversation.buyerAvatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: conversation.buyerAvatarUrl == null
                  ? const Icon(Icons.person, color: Colors.white, size: 28)
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
                      color: const Color(0xFF757575),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.white,
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

  // ==================== CHAT DETAIL VIEW ====================

  Widget _buildChatDetailView() {
    return Column(
      children: [
        // Chat header
        _buildChatHeader(),
        // Messages
        Expanded(
          child: _isLoadingMessages
              ? const Center(child: CircularProgressIndicator())
              : _buildMessagesList(),
        ),
        // Message input
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: _goBack,
          ),
          const SizedBox(width: 8),
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF9E9E9E),
              image: _selectedConversation?.buyerAvatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(
                        _selectedConversation!.buyerAvatarUrl!,
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _selectedConversation?.buyerAvatarUrl == null
                ? const Icon(Icons.person, color: Colors.white, size: 24)
                : null,
          ),
          const SizedBox(width: 12),
          // Name and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedConversation?.buyerName ?? 'Nama Pembeli',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4CAF50), // Green for online
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Online',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Right side avatar (smaller, as in screenshot)
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF9E9E9E),
              image: _selectedConversation?.buyerAvatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(
                        _selectedConversation!.buyerAvatarUrl!,
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _selectedConversation?.buyerAvatarUrl == null
                ? const Icon(Icons.person, color: Colors.white, size: 20)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_messages.isEmpty) {
      return Center(
        child: Text(
          'Mulai percakapan',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
        ),
      );
    }

    final userId = _authRepo.currentUser?.id;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isMe = message.senderId == userId;
        return _buildMessageBubble(message, isMe);
      },
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    final timeString = _formatMessageTime(message.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            // Buyer avatar on left for received messages
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF9E9E9E),
                image: message.senderAvatarUrl != null
                    ? DecorationImage(
                        image: NetworkImage(message.senderAvatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: message.senderAvatarUrl == null
                  ? const Icon(Icons.person, color: Colors.white, size: 18)
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          // Message bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? Colors.white : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border: isMe
                    ? Border.all(color: const Color(0xFFE0E0E0), width: 1)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeString,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Ketik pesan...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: GoogleFonts.poppins(fontSize: 14),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF616161),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HELPERS ====================

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}';
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatMessageTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

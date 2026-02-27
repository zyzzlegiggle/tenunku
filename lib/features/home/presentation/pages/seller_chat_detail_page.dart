import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories/seller_repository.dart';
import '../../../auth/data/repositories/auth_repository.dart';

class SellerChatDetailPage extends StatefulWidget {
  final ConversationModel conversation;

  const SellerChatDetailPage({super.key, required this.conversation});

  @override
  State<SellerChatDetailPage> createState() => _SellerChatDetailPageState();
}

class _SellerChatDetailPageState extends State<SellerChatDetailPage> {
  final SellerRepository _sellerRepo = SellerRepository();
  final AuthRepository _authRepo = AuthRepository();

  List<MessageModel> _messages = [];
  bool _isLoadingMessages = true;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final user = _authRepo.currentUser;
    if (user != null) {
      // Mark messages as read
      await _sellerRepo.markMessagesAsRead(widget.conversation.id, user.id);

      // Fetch messages
      final messages = await _sellerRepo.getMessages(widget.conversation.id);

      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoadingMessages = false;
        });

        // Scroll to bottom after messages load
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final user = _authRepo.currentUser;
    if (user == null) return;

    _messageController.clear();

    await _sellerRepo.sendMessage(widget.conversation.id, user.id, content);

    // Refresh messages
    final messages = await _sellerRepo.getMessages(widget.conversation.id);

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
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
        ),
      ),
    );
  }

  Widget _buildChatHeader() {
    final buyerName = widget.conversation.buyerName ?? 'Nama Pembeli';

    return Column(
      children: [
        // App header style (Cyan Blue)
        Container(
          color: const Color(0xFF54B7C2),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              Image.asset('assets/logo.png', width: 36, height: 36),
            ],
          ),
        ),

        // Chat info header (White)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFC3C3C3), width: 1),
            ),
          ),
          child: Column(
            children: [
              Text(
                'Anda sedang melakukan obrolan dengan',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF464646),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                buyerName,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF464646),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
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

    // Common Profile logic
    final senderName = isMe ? 'User' : (widget.conversation.buyerName ?? 'B');
    final colors = [
      const Color(0xFFF5793B),
      const Color(0xFF54B7C2),
      const Color(0xFF31476C),
      const Color(0xFFFFE14F),
    ];
    final colorIndex = senderName.codeUnitAt(0) % colors.length;
    final profileColor = colors[colorIndex];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment
            .start, // Align to top (faces down style logic involves tail/placement)
        children: [
          if (!isMe) ...[
            // Buyer avatar on left
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: profileColor,
                image: message.senderAvatarUrl != null
                    ? DecorationImage(
                        image: NetworkImage(message.senderAvatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: message.senderAvatarUrl == null
                  ? const Center(
                      child: Icon(Icons.person, color: Colors.white, size: 20),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],

          // Message bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.only(
                left: 14,
                right: 14,
                top: 10,
                bottom: 6,
              ),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF54B7C2) : const Color(0xFF31476C),
                borderRadius: BorderRadius.only(
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                  topLeft: Radius.circular(
                    isMe ? 16 : 4,
                  ), // Tail is Top Left for them
                  topRight: Radius.circular(
                    isMe ? 4 : 16,
                  ), // Tail is Top Right for you
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      message.content,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isMe ? Colors.black87 : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeString,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: isMe ? Colors.black54 : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isMe) ...[
            const SizedBox(width: 8),
            // User avatar on right
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    profileColor, // using identical color logic for demo or use current user profile
              ),
              child: const Center(
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 12),
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _messageController,
            decoration: InputDecoration(
              hintText: 'Ketik pesan anda...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 1,
                ), // Optional white line if active
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: GoogleFonts.poppins(fontSize: 14),
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _sendMessage(),
          ),
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

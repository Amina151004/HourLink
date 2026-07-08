import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/chat_preview.dart';
import 'package:hourlink/features/auth/data/models/message.dart';
import 'package:hourlink/features/auth/data/services/chat_service.dart';
import 'package:hourlink/features/auth/presentation/pages/user_profile_screen.dart';
import 'package:hourlink/features/auth/presentation/widgets/chat_input_bar.dart';
import 'package:hourlink/features/auth/presentation/widgets/message_bubble.dart';

class ChatRoomScreen extends StatefulWidget {
  final ChatPreview chat;
  final String currentUserId;

  const ChatRoomScreen({
    super.key,
    required this.chat,
    required this.currentUserId,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();

  StreamSubscription<List<Message>>? _messagesSubscription;
  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _subscribeToMessages();
    _markAsSeen();
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _subscribeToMessages() {
    _messagesSubscription = _chatService
        .getMessagesStream(widget.chat.id)
        .listen(
          (messages) {
            if (mounted) {
              setState(() {
                _messages = messages;
                _isLoading = false;
              });
              _scrollToBottom();
            }
          },
          onError: (e) {
            if (mounted) setState(() => _isLoading = false);
            debugPrint('MessagesStream error: $e');
          },
        );
  }

  Future<void> _markAsSeen() async {
    try {
      await _chatService.markAsSeen(widget.chat.id);
    } catch (e) {
      debugPrint('markAsSeen error: $e');
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    _controller.clear();
    setState(() => _isSending = true);

    try {
      await _chatService.sendMessage(chatId: widget.chat.id, text: text);
    } catch (e) {
      debugPrint('sendMessage error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const SizedBox(height: 60),

          // ── Header ────────────────────────────────────────────────────
          _ChatHeader(chat: widget.chat, currentUserId: widget.currentUserId),

          // ── Messages ──────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet\nSay hello! 👋',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) => MessageBubble(
                      message: _messages[index],
                      isMe: _messages[index].isMe(widget.currentUserId),
                    ),
                  ),
          ),

          // ── Input bar ─────────────────────────────────────────────────
          ChatInputBar(controller: _controller, onSend: _sendMessage),
        ],
      ),
    );
  }
}

// ── Chat header ───────────────────────────────────────────────────────────────
class _ChatHeader extends StatelessWidget {
  final ChatPreview chat;
  final String currentUserId;

  const _ChatHeader({required this.chat, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    // pour les DM, afficher l'autre utilisateur ; pour les groupes, le nom du groupe
    final otherUser = chat.members
        .where((m) => m.id != currentUserId)
        .firstOrNull;

    final displayName = chat.isGroup
        ? (chat.name ?? 'Group')
        : (otherUser?.name ?? 'Unknown');

    final photoUrl = chat.isGroup ? '' : (otherUser?.photoUrl ?? '');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // ── Back button ───────────────────────────────────────────────
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 28),
            onPressed: () => Navigator.pop(context),
          ),

          // ── Avatar ────────────────────────────────────────────────────
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.avatarPlaceholder,
              shape: BoxShape.circle,
              image: photoUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(photoUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: photoUrl.isEmpty
                ? Center(
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : '?',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // ── Name ──────────────────────────────────────────────────────
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (otherUser != null && !chat.isGroup) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserProfileScreen(
                        user: otherUser,
                        currentUserId: currentUserId,
                      ),
                    ),
                  );
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Call button ───────────────────────────────────────────────
          IconButton(
            icon: const Icon(Icons.phone_outlined, size: 22),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

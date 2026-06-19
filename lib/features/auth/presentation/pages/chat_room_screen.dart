import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/chat_preview.dart';
import 'package:hourlink/features/auth/data/models/message.dart';
import 'package:hourlink/features/auth/presentation/pages/user_profile_screen.dart';
import 'package:hourlink/features/auth/presentation/widgets/chat_input_bar.dart';
import 'package:hourlink/features/auth/presentation/widgets/message_bubble.dart';

class ChatRoomScreen extends StatefulWidget {
  final ChatPreview chat;

  const ChatRoomScreen({super.key, required this.chat});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ── Mock messages ─────────────────────────────────────────────────────
  final List<Message> _messages = [
    Message(
      text:
          'Ajouter un message gghghg ghhghgh hhghg ghghghhgh dghsgdhsgf g er bd dcc',
      isMe: false,
      time: '12:00',
    ),
    Message(
      text:
          'Ajouter un message gghghg ghhghgh hhghg ghghghhgh dghsgdhsgf g er bd dcc',
      isMe: true,
      time: '12:01',
    ),
  ];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(Message(text: text, isMe: true, time: ''));
      _controller.clear();
    });

    // scroll to bottom after send
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
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const SizedBox(height: 60),

          // ── Header ────────────────────────────────────────────────────
          _ChatHeader(chat: widget.chat),

          // ── Messages ──────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  MessageBubble(message: _messages[index]),
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

  const _ChatHeader({required this.chat});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 28),
            onPressed: () => Navigator.pop(context),
          ),

          // Avatar
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.avatarPlaceholder,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),

          // Name + status
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserProfileScreen(user: chat.user),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.user.name,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Online',
                    style: AppTextStyles.date.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Call button
          IconButton(
            icon: const Icon(Icons.phone_outlined, size: 22),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

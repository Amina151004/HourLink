import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/chat_preview.dart';
import 'package:hourlink/features/auth/data/models/user.dart';
import 'package:hourlink/features/auth/presentation/pages/chat_room_screen.dart';
import 'package:hourlink/features/auth/presentation/widgets/app_search_bar.dart';
import 'package:hourlink/features/auth/presentation/widgets/chat_list_item.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  final List<ChatPreview> _chats = [
    ChatPreview(
      user: User(
        name: 'User Name',
        title: '',
        location: '',
        description: '',
        email: '',
        phone: '',
      ),
      lastMessage: 'new message is waiting ....',
      time: '12:00',
    ),
    ChatPreview(
      user: User(
        name: 'User Name',
        title: '',
        location: '',
        description: '',
        email: '',
        phone: '',
      ),
      lastMessage: 'new message is waiting ....',
      time: '12:00',
    ),
    ChatPreview(
      user: User(
        name: 'User Name',
        title: '',
        location: '',
        description: '',
        email: '',
        phone: '',
      ),
      lastMessage: 'new message is waiting ....',
      time: '12:00',
    ),
    ChatPreview(
      user: User(
        name: 'User Name',
        title: '',
        location: '',
        description: '',
        email: '',
        phone: '',
      ),
      lastMessage: 'new message is waiting ....',
      time: '12:00',
    ),
  ];

  List<ChatPreview> get _filtered => _query.isEmpty
      ? _chats
      : _chats
            .where(
              (c) =>
                  c.user.name.toLowerCase().contains(_query.toLowerCase()) ||
                  c.lastMessage.toLowerCase().contains(_query.toLowerCase()),
            )
            .toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),

          // ── Header ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                Text('Chats', style: AppTextStyles.subheading),
                const Spacer(),
                IconButton(icon: const Icon(Icons.add), onPressed: () {}),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Search bar ────────────────────────────────────────────────
          AppSearchBar(
            controller: _searchController,
            hintText: 'Search',
            onChanged: (val) => setState(() => _query = val),
            onClear: () => setState(() => _query = ''),
          ),

          const SizedBox(height: 20),

          // ── Chat list ─────────────────────────────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      'No chats found',
                      style: AppTextStyles.date.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 90),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) => ChatListItem(
                      chat: _filtered[index],
                      onTap: () {
                        // ✅ navigation vers ChatRoomScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ChatRoomScreen(chat: _filtered[index]),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

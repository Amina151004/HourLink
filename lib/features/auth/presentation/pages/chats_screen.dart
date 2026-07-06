import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/app_user.dart';
import 'package:hourlink/features/auth/data/models/chat_preview.dart';
import 'package:hourlink/features/auth/data/services/chat_service.dart';
import 'package:hourlink/features/auth/data/services/user_service.dart';
import 'package:hourlink/features/auth/presentation/pages/chat_room_screen.dart';
import 'package:hourlink/features/auth/presentation/widgets/app_search_bar.dart';
import 'package:hourlink/features/auth/presentation/widgets/chat_list_item.dart';

class ChatsScreen extends StatefulWidget {
  final String currentUserId;

  const ChatsScreen({super.key, required this.currentUserId});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _newChatController = TextEditingController();
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();

  // ── Ajout : stocker la subscription pour la cancel dans dispose()
  StreamSubscription<List<ChatPreview>>? _chatSubscription;

  String _query = '';
  List<ChatPreview> _chats = [];
  bool _isLoading = true;
  List<AppUser> _searchResults = [];

  List<ChatPreview> get _filtered {
    if (_query.isEmpty) return _chats;
    final q = _query.toLowerCase();
    return _chats.where((c) {
      final name = c.chatName(widget.currentUserId).toLowerCase();
      return name.contains(q) || c.lastMessage.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  @override
  void dispose() {
    _chatSubscription?.cancel(); // ← annuler proprement
    _searchController.dispose();
    _newChatController.dispose();
    super.dispose();
  }

  void _loadChats() {
    // ── Correction principale : transformer le stream correctement
    final enrichedStream = _chatService.getUserChatsStream().asyncMap((
      chats,
    ) async {
      if (chats.isEmpty) return <ChatPreview>[];
      final enriched = await Future.wait(
        chats.map((chat) async {
          final members = await Future.wait(
            chat.memberIds.map((id) => _userService.getUserById(id)),
          );
          return chat.copyWith(members: members.whereType<AppUser>().toList());
        }),
      );
      return enriched;
    });

    _chatSubscription = enrichedStream.listen(
      (chats) {
        if (mounted) {
          setState(() {
            _chats = chats;
            _isLoading = false;
          });
        }
      },
      onError: (e) {
        if (mounted) setState(() => _isLoading = false);
        debugPrint('ChatsStream error: $e');
      },
    );
  }

  void _showNewChatSheet() {
    _newChatController.clear();
    _searchResults = [];

    final screenContext = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textGrey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('New Conversation', style: AppTextStyles.subheading),
                const SizedBox(height: 16),
                TextField(
                  controller: _newChatController,
                  autofocus: true,
                  style: AppTextStyles.body,
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    hintText: 'Search by name or email...',
                    hintStyle: AppTextStyles.caption,
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) async {
                    final results = await _userService.searchUsers(val);
                    setSheetState(() => _searchResults = results);
                  },
                ),
                const SizedBox(height: 12),
                if (_searchResults.isEmpty &&
                    _newChatController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'No users found',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _searchResults.length,
                    itemBuilder: (_, index) {
                      final user = _searchResults[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.avatarPlaceholder,
                            shape: BoxShape.circle,
                            image: user.photoUrl.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(user.photoUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: user.photoUrl.isEmpty
                              ? Center(
                                  child: Text(
                                    user.name.isNotEmpty
                                        ? user.name[0].toUpperCase()
                                        : '?',
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        title: Text(
                          user.name,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          user.email,
                          style: AppTextStyles.caption,
                        ),
                        onTap: () async {
                          Navigator.pop(sheetContext);

                          // ── Correction : montrer un indicateur pendant la création
                          showDialog(
                            context: screenContext,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          try {
                            final chat = await _chatService
                                .getOrCreateDirectChat(user);

                            if (!screenContext.mounted) return;
                            Navigator.pop(screenContext); // fermer le loader

                            Navigator.push(
                              screenContext,
                              MaterialPageRoute(
                                builder: (_) => ChatRoomScreen(
                                  chat: chat,
                                  currentUserId: widget.currentUserId,
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            Navigator.pop(screenContext); // fermer le loader
                            debugPrint('Error creating chat: $e');
                            ScaffoldMessenger.of(screenContext).showSnackBar(
                              SnackBar(
                                content: Text('Failed to open chat: $e'),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                Text('Chats', style: AppTextStyles.subheading),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.add, color: AppColors.textDark),
                  onPressed: _showNewChatSheet,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppSearchBar(
            controller: _searchController,
            hintText: 'Search',
            onChanged: (val) => setState(() => _query = val),
            onClear: () => setState(() => _query = ''),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                ? Center(
                    child: Text(
                      _query.isEmpty
                          ? 'No chats yet\nTap + to start a conversation'
                          : 'No chats matching "$_query"',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 90),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) => ChatListItem(
                      chat: _filtered[index],
                      currentUserId: widget.currentUserId,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatRoomScreen(
                              chat: _filtered[index],
                              currentUserId: widget.currentUserId,
                            ),
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

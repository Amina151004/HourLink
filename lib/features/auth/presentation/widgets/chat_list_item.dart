import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/chat_preview.dart';

class ChatListItem extends StatelessWidget {
  final ChatPreview chat;
  final String currentUserId;
  final VoidCallback? onTap;

  const ChatListItem({
    super.key,
    required this.chat,
    required this.currentUserId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ chatName() retourne le nom de l'autre user pour les DMs
    final name = chat.chatName(currentUserId);

    // ✅ formattedTime depuis lastMessageAt (DateTime)
    final time = chat.lastMessageAt != null
        ? '${chat.lastMessageAt!.hour.toString().padLeft(2, '0')}:${chat.lastMessageAt!.minute.toString().padLeft(2, '0')}'
        : '';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
            child: Row(
              children: [
                // ── Avatar ────────────────────────────────────────────────
                // ── Avatar ────────────────────────────────────────────────────
                Builder(
                  builder: (_) {
                    final otherUser = chat.members
                        .where((m) => m.id != currentUserId)
                        .firstOrNull;
                    final photoUrl = otherUser?.photoUrl ?? '';
                    final initiale = (otherUser?.name.isNotEmpty == true)
                        ? otherUser!.name[0].toUpperCase()
                        : '?';

                    return Container(
                      width: 50,
                      height: 50,
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
                                initiale,
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : null,
                    );
                  },
                ),
                const SizedBox(width: 14),

                // ── Name + last message ───────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chat.lastMessage,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ── Time ──────────────────────────────────────────────────
                Text(time, style: AppTextStyles.caption),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: AppColors.divider,
            indent: 25,
            endIndent: 25,
          ),
        ],
      ),
    );
  }
}

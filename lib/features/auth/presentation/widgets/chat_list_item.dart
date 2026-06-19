import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/chat_preview.dart';

class ChatListItem extends StatelessWidget {
  final ChatPreview chat;
  final VoidCallback? onTap;

  const ChatListItem({super.key, required this.chat, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
            child: Row(
              children: [
                // ── Avatar ───────────────────────────────────────────────
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.avatarPlaceholder,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),

                // ── Name + last message ───────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat.user.name,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chat.lastMessage,
                        style: AppTextStyles.date,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ── Time ─────────────────────────────────────────────────
                Text(chat.time, style: AppTextStyles.date),
              ],
            ),
          ),
          const Divider(
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

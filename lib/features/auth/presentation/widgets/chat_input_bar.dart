import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.06,
        vertical: 16,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: AppColors.textDark, width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        margin: EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            // ── Text field ─────────────────────────────────────────────
            Expanded(
              child: TextField(
                controller: controller,
                style: AppTextStyles.body.copyWith(fontSize: 12),
                maxLines: null, // multi-line
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Send a message',
                  hintStyle: AppTextStyles.body.copyWith(
                    fontSize: 12,
                    color: AppColors.textDark.withValues(alpha: 0.5),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),

            // ── Send button ─────────────────────────────────────────────
            GestureDetector(
              onTap: onSend,
              child: Icon(
                Icons.send_rounded,
                color: AppColors.textDark,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

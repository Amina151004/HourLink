import 'package:flutter/material.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/data/models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: screenWidth * 0.72),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
          border: Border.all(color: AppColors.textDark, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: AppTextStyles.body.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              message.formattedTime,
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:hourlink/features/auth/data/models/user.dart';

/// Represents a single row in the chats list — pairs a [User]
/// with the last message preview and timestamp shown in the UI.
class ChatPreview {
  final User user;
  final String lastMessage;
  final String time;
  final bool hasUnread;

  const ChatPreview({
    required this.user,
    required this.lastMessage,
    required this.time,
    this.hasUnread = false,
  });
}

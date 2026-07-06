import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String text;
  final String senderId;
  final DateTime sentAt;
  final List<String> seenBy;

  const Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.sentAt,
    this.seenBy = const [],
  });

  // helper used in UI to check if message is mine
  bool isMe(String currentUserId) => senderId == currentUserId;

  String get formattedTime {
    final h = sentAt.hour.toString().padLeft(2, '0');
    final m = sentAt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      text: data['text'] ?? '',
      senderId: data['senderId'] ?? '',
      sentAt: (data['sentAt'] as Timestamp).toDate(),
      seenBy: List<String>.from(data['seenBy'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'senderId': senderId,
      'sentAt': FieldValue.serverTimestamp(),
      'seenBy': seenBy,
    };
  }
}

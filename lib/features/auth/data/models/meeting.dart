import 'package:cloud_firestore/cloud_firestore.dart';

class Meeting {
  final String id;
  final String title;
  final String? platform;
  final bool showBadge;
  final DateTime scheduledAt;
  final String status;
  final String createdBy;

  const Meeting({
    required this.id,
    required this.title,
    this.platform,
    this.showBadge = false,
    required this.scheduledAt,
    this.status = 'coming',
    required this.createdBy,
  });

  String get formattedTime {
    final h = scheduledAt.hour;
    final m = scheduledAt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'pm' : 'am';
    final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$h12:$m$period';
  }

  factory Meeting.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Meeting(
      id: doc.id,
      title: data['title'] ?? '',
      platform: data['platform'],
      showBadge: data['status'] == 'coming',
      scheduledAt: (data['scheduledAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'coming',
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'platform': platform,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'status': status,
      'createdBy': createdBy,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final String title;
  final String location;
  final String description;
  final String phone;
  final DateTime? createdAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl = '',
    this.title = '',
    this.location = '',
    this.description = '',
    this.phone = '',
    this.createdAt,
  });

  // ── From Firestore document ────────────────────────────────────────────
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      title: data['title'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      phone: data['phone'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // ── To Firestore map ───────────────────────────────────────────────────
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'title': title,
      'location': location,
      'description': description,
      'phone': phone,
    };
  }

  // ── CopyWith for local updates ─────────────────────────────────────────
  AppUser copyWith({
    String? name,
    String? photoUrl,
    String? title,
    String? location,
    String? description,
    String? phone,
  }) {
    return AppUser(
      id: id,
      email: email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      title: title ?? this.title,
      location: location ?? this.location,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      createdAt: createdAt,
    );
  }
}

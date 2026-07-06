import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hourlink/features/auth/data/models/app_user.dart';
import 'package:hourlink/features/auth/data/models/chat_preview.dart';
import 'package:hourlink/features/auth/data/models/message.dart';

class ChatService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;
  CollectionReference get _chats => _firestore.collection('chats');

  // ── 1. GET or CREATE a direct message chat between 2 users ────────────
  Future<ChatPreview> getOrCreateDirectChat(AppUser otherUser) async {
    final ids = [_uid, otherUser.id]..sort();
    final chatId = ids.join('_');

    debugPrint('=== getOrCreateDirectChat ===');
    debugPrint('currentUid: $_uid');
    debugPrint('otherUserId: ${otherUser.id}');
    debugPrint('chatId: $chatId');

    final ref = _chats.doc(chatId);
    final doc = await ref.get();

    debugPrint('doc exists: ${doc.exists}');

    if (!doc.exists) {
      try {
        await ref.set({
          'isGroup': false,
          'memberIds': ids,
          'lastMessage': '',
          'lastMessageAt': FieldValue.serverTimestamp(),
        });
        debugPrint('chat created successfully');
      } catch (e) {
        debugPrint('ERROR creating chat: $e');
        rethrow;
      }
    } else {
      final data = doc.data() as Map<String, dynamic>;
      debugPrint('existing doc data: $data');
    }

    final fresh = await ref.get();
    final chat = ChatPreview.fromFirestore(fresh);
    return chat.copyWith(members: [otherUser]);
  }

  // ── 2. STREAM all chats for current user ──────────────────────────────
  Stream<List<ChatPreview>> getUserChatsStream() {
    return _chats
        .where('memberIds', arrayContains: _uid) // ← corrigé
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => ChatPreview.fromFirestore(d)).toList(),
        );
  }

  // ── 3. STREAM messages in a chat (real-time) ───────────────────────────
  Stream<List<Message>> getMessagesStream(String chatId) {
    return _chats
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Message.fromFirestore(d)).toList());
  }

  // ── 4. SEND a message ──────────────────────────────────────────────────
  Future<void> sendMessage({
    required String chatId,
    required String text,
  }) async {
    final batch = _firestore.batch();

    final msgRef = _chats.doc(chatId).collection('messages').doc();
    batch.set(msgRef, {
      'text': text,
      'senderId': _uid,
      'sentAt': FieldValue.serverTimestamp(),
      'seenBy': [_uid],
    });

    batch.update(_chats.doc(chatId), {
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // ── 5. MARK messages as seen ───────────────────────────────────────────
  Future<void> markAsSeen(String chatId) async {
    final unseen = await _chats
        .doc(chatId)
        .collection('messages')
        .where('seenBy', whereNotIn: [_uid])
        .get();

    final batch = _firestore.batch();
    for (final doc in unseen.docs) {
      batch.update(doc.reference, {
        'seenBy': FieldValue.arrayUnion([_uid]),
      });
    }
    await batch.commit();
  }
}

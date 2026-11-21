import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_service.dart';

class BoardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create a stable ID for each new post.
  String newMessageId() {
    return _db.collection('messages').doc().id;
  }

  // Create a message using its stable document ID.
  Future<void> postMessage(String text, String messageId) async {
    final user = authService.currentUser;

    if (user == null) {
      throw StateError('Please sign in first.');
    }

    final message = text.trim();

    if (message.isEmpty || message.length > 500) {
      throw ArgumentError('Enter 1 to 500 characters.');
    }

    await _db.collection('messages').doc(messageId).set({
      'text': message,
      'authorUid': user.uid,
      'authorName': user.displayName ?? 'User',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Read messages through a live Firestore stream.
  Stream<QuerySnapshot<Map<String, dynamic>>> messageBoard() {
    return _db
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots(includeMetadataChanges: true);
  }

  // Update an existing message.
  Future<void> editMessage(String messageId, String text) async {
    await _db.collection('messages').doc(messageId).update({
      'text': text.trim(),
      'editedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete one message by its document ID.
  Future<void> deleteMessage(String messageId) async {
    await _db.collection('messages').doc(messageId).delete();
  }
}

final boardService = BoardService();

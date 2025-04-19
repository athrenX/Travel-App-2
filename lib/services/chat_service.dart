import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ChatMessage>> fetchMessages() async {
    final query =
        await _firestore
            .collection('chats')
            .orderBy('timestamp', descending: false)
            .get();

    return query.docs.map((doc) {
      return ChatMessage(
        id: doc.id,
        sender: doc['sender'],
        message: doc['message'],
        timestamp: (doc['timestamp'] as Timestamp).toDate(),
      );
    }).toList();
  }

  Future<void> sendMessage(String sender, String message) async {
    await _firestore.collection('chats').add({
      'sender': sender,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

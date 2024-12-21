import 'package:cloud_firestore/cloud_firestore.dart';

class ChatController {
  Future<List<Map<String, dynamic>>> loadMessages(String chatId, String currentUserEmail) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'sender': data['sender'],
        'message': data['message'],
        'isMe': data['sender'] == currentUserEmail,
      };
    }).toList();
  }

  Future<void> sendMessage(String chatId, String sender, String message) async {
    await FirebaseFirestore.instance.collection('chats').add({
      'chatId': chatId,
      'sender': sender,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  String generateChatId(String email1, String email2) {
    final sortedEmails = [email1, email2]..sort();
    return '${sortedEmails[0]}_${sortedEmails[1]}';
  }
}
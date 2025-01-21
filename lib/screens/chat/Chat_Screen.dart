import 'package:flutter/material.dart';
import 'package:mobile_project/controllers/ChatController.dart';
import 'package:mobile_project/services/socket_service.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserEmail;
  final String targetEmail;

  const ChatScreen({
    required this.currentUserEmail,
    required this.targetEmail,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final SocketService _socketService = SocketService();
  final ChatController _chatController = ChatController();
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _connectToSocket();
    _loadMessagesFromFirestore();
  }

  void _connectToSocket() {
    _socketService.connectToSocket(
      '10.0.2.2',
      widget.currentUserEmail,
      (data) {
        print('Received message from socket: $data'); // Log received messages
        setState(() {
          _messages.insert(0, {
            'sender': data['sender'],
            'message': data['message'],
            'isMe': data['sender'] == widget.currentUserEmail,
          });
        });
      },
    );
  }

  void _loadMessagesFromFirestore() async {
    final chatId = _chatController.generateChatId(
        widget.currentUserEmail, widget.targetEmail);
    final messages =
        await _chatController.loadMessages(chatId, widget.currentUserEmail);
    setState(() {
      _messages = messages;
    });

    // Add a Firestore listener for real-time updates
    _chatController.loadMessages(
        chatId,
        (newMessages) {
          setState(() {
            _messages = newMessages;
          });
        } as String);
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final chatId = _chatController.generateChatId(
        widget.currentUserEmail, widget.targetEmail);

    _socketService.sendMessage(
        widget.currentUserEmail, widget.targetEmail, message);

    _chatController.sendMessage(chatId, widget.currentUserEmail, message);

    _messageController.clear();

    setState(() {
      _messages.insert(0, {
        'sender': widget.currentUserEmail,
        'message': message,
        'isMe': true,
      });
    });
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.targetEmail}'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message['isMe']
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          message['isMe'] ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(message['message']),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

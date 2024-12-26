import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket _socket;

  // Connect to the Socket.IO server
  void connectToSocket(
      String serverIp, String currentUserEmail, Function onMessageReceived) {
    _socket = IO.io('http://$serverIp:4000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.connect();

    _socket.on('connect', (_) {
      _socket.emit('join', {'email': currentUserEmail});
    });

    _socket.on('receive_message', (data) {
      onMessageReceived(data);
    });
  }

  // Send a message via Socket.IO
  void sendMessage(String sender, String receiver, String message) {
    _socket.emit('send_message', {
      'sender': sender,
      'receiver': receiver,
      'message': message,
    });
  }

  // Disconnect from the Socket.IO server
  void disconnect() {
    _socket.disconnect();
  }
}

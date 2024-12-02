import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:web_socket_channel/io.dart';

class ServerScreen extends StatefulWidget {
  const ServerScreen({super.key});

  @override
  State<ServerScreen> createState() => _ServerScreenState();
}

class _ServerScreenState extends State<ServerScreen> {
  HttpServer? _server;
  List<WebSocket> _clients = [];
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _startServer();
  }

  void _startServer() async {
    _server = await HttpServer.bind(InternetAddress.anyIPv4, 4040);
    _server!.listen((HttpRequest request) async {
      if (request.uri.path == '/ws') {
        var socket = await WebSocketTransformer.upgrade(request);
        _clients.add(socket);
        socket.listen((message) {
          setState(() {
            _messages.add('Client: $message');
          });
        }, onDone: () {
          _clients.remove(socket);
        });
      }
    });
  }

  void _sendMessage() {
    final message = _messageController.text;
    for (var client in _clients) {
      client.add(message);
    }
    setState(() {
      _messages.add('Server: $message');
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Server Mode'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
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
                      labelText: 'Enter message',
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

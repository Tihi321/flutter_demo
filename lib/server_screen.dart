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
    try {
      print('Starting server on port 4040...');
      _server = await HttpServer.bind(InternetAddress.anyIPv4, 4040);
      print('Server started successfully. Listening on ${_server!.address.address}:${_server!.port}');
      
      _server!.listen((HttpRequest request) async {
        print('Received request for: ${request.uri.path}');
        if (request.uri.path == '/ws') {
          print('Upgrading connection to WebSocket');
          try {
            var socket = await WebSocketTransformer.upgrade(request);
            print('WebSocket connection established');
            _clients.add(socket);
            socket.listen(
              (message) {
                print('Received message from client: $message');
                setState(() {
                  _messages.add('Client: $message');
                });
              },
              onError: (error) => print('WebSocket error on server: $error'),
              onDone: () {
                print('Client disconnected');
                _clients.remove(socket);
              }
            );
          } catch (e) {
            print('Error upgrading to WebSocket: $e');
          }
        }
      });
    } catch (e) {
      print('Error starting server: $e');
    }
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

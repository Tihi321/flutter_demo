import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert'; // Add this import at the top
import 'utils/platform.dart';
import 'utils/address.dart';

class ServerScreen extends StatefulWidget {
  const ServerScreen({super.key});

  @override
  State<ServerScreen> createState() => _ServerScreenState();
}

class Message {
  final String username;
  final String content;
  Message(this.username, this.content);
}

class _ServerScreenState extends State<ServerScreen> {
  HttpServer? _server;
  final Map<WebSocket, String> _clients =
      {}; // Change list to map of WebSocket to username
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _portController =
      TextEditingController(text: '4040');
  final List<Message> _messages =
      []; // Change from List<String> to List<Message>
  bool _isServerStarted = false;

  @override
  void initState() {
    super.initState();
  }

  void _startServer() async {
    final port = int.tryParse(_portController.text);
    if (port == null || port < 1 || port > 65535) {
      setState(() {
        _messages.add(Message('System',
            'Invalid port number. Please enter a number between 1 and 65535.'));
      });
      return;
    }

    try {
      print('Starting server on port $port...');

      // Get the WiFi IP address
      List<NetworkInterface> interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );

      bool isEmulator = await checkIsEmulator();

      String? serverIp = getServerAddress(interfaces, isEmulator);
      print('Binding server to IP: $serverIp');
      _server = await HttpServer.bind(serverIp, port, shared: true);
      print(
          'Server started successfully on ${_server!.address.address}:${_server!.port}');

      setState(() {
        _isServerStarted = true;
        _messages.add(Message('System',
            'Server started on ${_server!.address.address}:${_server!.port}'));
      });

      _server!.listen(
        (HttpRequest request) async {
          print('Received request for: ${request.uri.path}');
          if (request.uri.path == '/ws') {
            print('Upgrading connection to WebSocket');
            try {
              var socket = await WebSocketTransformer.upgrade(request);
              print('WebSocket connection established');
              _clients[socket] = ''; // Initialize with empty username

              // Send welcome message to the new client
              socket.add(
                  'Connected to server at ${_server!.address.address}:${_server!.port}');

              socket.listen(
                (message) {
                  print('Received message from client: $message');
                  _handleIncomingMessage(message, socket);
                },
                onError: (error) {
                  print('WebSocket error on server: $error');
                  _clients.remove(socket);
                },
                onDone: () {
                  print('Client disconnected');
                  _clients.remove(socket);
                },
              );
            } catch (e) {
              print('Error upgrading to WebSocket: $e');
              request.response.statusCode = HttpStatus.internalServerError;
              request.response.close();
            }
          } else {
            print('Invalid path: ${request.uri.path}');
            request.response.statusCode = HttpStatus.notFound;
            request.response.close();
          }
        },
        onError: (error) {
          print('Server error: $error');
        },
      );
    } catch (e) {
      print('Error starting server: $e');
      setState(() {
        _messages.add(Message('System', 'Error starting server: $e'));
      });
    }
  }

  void _handleIncomingMessage(String message, WebSocket client) {
    if (message.startsWith('USERNAME:')) {
      // Handle username registration
      String username = message.substring(9);
      _clients[client] = username;
      _broadcastMessage('$username joined the chat', isSystem: true);
    } else {
      // Handle regular message
      String username = _clients[client] ?? 'Unknown';
      if (message.startsWith('$username: ')) {
        // If message already contains username prefix, strip it
        String content = message.substring(username.length + 2);
        _addMessage(username, content);
        _broadcastMessage(message);
      } else {
        _addMessage(username, message);
        _broadcastMessage('$username: $message');
      }
    }
  }

  void _broadcastMessage(String message, {bool isSystem = false}) {
    for (var client in _clients.keys) {
      client.add(message);
    }
    if (isSystem) {
      setState(() {
        _messages.add(Message('System', message));
      });
    }
  }

  void _addMessage(String username, String content) {
    setState(() {
      _messages.add(Message(username, content));
    });
  }

  void _sendMessage() {
    final message = _messageController.text;
    for (var client in _clients.keys) {
      client.add(message);
    }
    setState(() {
      _messages.add(Message('Server', message));
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
          if (!_isServerStarted) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _portController,
                    decoration: const InputDecoration(
                      labelText: 'Enter port number (1-65535)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _startServer,
                    child: const Text('Start Server'),
                  ),
                ],
              ),
            ),
          ],
          if (_isServerStarted) ...[
            // Add QR code button at the top
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Server running on ${_server?.address.address}:${_server?.port}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Server IP QR Code'),
                            content: SizedBox(
                              width: 200,
                              height: 200,
                              child: QrImageView(
                                data: jsonEncode({
                                  'ip': _server?.address.address,
                                  'port': _server?.port.toString()
                                }),
                                version: QrVersions.auto,
                                size: 200.0,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return ListTile(
                    title: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${message.username}: ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: message.content,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
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
        ],
      ),
    );
  }
}

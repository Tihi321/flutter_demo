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

class _ServerScreenState extends State<ServerScreen> {
  HttpServer? _server;
  List<WebSocket> _clients = [];
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _portController =
      TextEditingController(text: '4040');
  final List<String> _messages = [];
  bool _isServerStarted = false;

  @override
  void initState() {
    super.initState();
  }

  void _startServer() async {
    final port = int.tryParse(_portController.text);
    if (port == null || port < 1 || port > 65535) {
      setState(() {
        _messages.add(
            'Invalid port number. Please enter a number between 1 and 65535.');
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
        _messages.add(
            'Server started on ${_server!.address.address}:${_server!.port}');
      });

      _server!.listen(
        (HttpRequest request) async {
          print('Received request for: ${request.uri.path}');
          if (request.uri.path == '/ws') {
            print('Upgrading connection to WebSocket');
            try {
              var socket = await WebSocketTransformer.upgrade(request);
              print('WebSocket connection established');
              _clients.add(socket);

              // Send welcome message to the new client
              socket.add(
                  'Connected to server at ${_server!.address.address}:${_server!.port}');

              socket.listen(
                (message) {
                  print('Received message from client: $message');
                  setState(() {
                    if (message.toString().startsWith('USERNAME:')) {
                      String username = message.toString().substring(9);
                      _messages.add('Client connected: $username');
                      // Broadcast to all clients that a new user joined
                      for (var client in _clients) {
                        if (client != socket) {
                          client.add('User $username joined the chat');
                        }
                      }
                    } else {
                      _messages.add('Client: $message');
                    }
                  });
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
        _messages.add('Error starting server: $e');
      });
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
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
                child: const Text('Show QR Code'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

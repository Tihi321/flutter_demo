import 'package:flutter/material.dart';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  WebSocketChannel? _channel;
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final List<String> _messages = [];
  bool _isConnected = false;
  bool _isScanning = false;
  String? _connectionError;

  @override
  void initState() {
    super.initState();
    _usernameController.text = 'Client 1';
  }

  void _connectToServer([String? ip]) {
    if (_usernameController.text.isEmpty) {
      setState(() {
        _connectionError = 'Please enter a username';
      });
      return;
    }

    final serverIp = ip ?? _ipController.text;
    if (serverIp.isEmpty) {
      setState(() {
        _connectionError = 'Please enter a server IP address';
      });
      return;
    }

    final wsUrl = 'ws://$serverIp:4040/ws';
    print('Attempting to connect to: $wsUrl');
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      print('WebSocket channel created, waiting for connection...');
      
      _channel!.stream.listen(
        (message) {
          print('Received message from server: $message');
          setState(() {
            _messages.add('Server: $message');
            _isConnected = true;
            _connectionError = null;
          });
        },
        onError: (error) {
          print('WebSocket error: $error');
          setState(() {
            _isConnected = false;
            _connectionError = 'Connection error: $error';
          });
        },
        onDone: () {
          print('WebSocket connection closed');
          setState(() {
            _isConnected = false;
            _connectionError = 'Connection closed';
          });
        },
      );
      
      print('Sending username to server...');
      _channel?.sink.add('USERNAME:${_usernameController.text}');
      print('Username sent successfully');
    } catch (e) {
      print('Connection error: $e');
      setState(() {
        _isConnected = false;
        _connectionError = 'Failed to connect: $e';
      });
    }
  }

  void _sendMessage() {
    final message = _messageController.text;
    _channel?.sink.add(message);
    setState(() {
      _messages.add('Client: $message');
      _messageController.clear();
    });
  }

  void _startQRScanner() {
    setState(() {
      _isScanning = true;
    });
  }

  void _stopQRScanner() {
    setState(() {
      _isScanning = false;
    });
  }

  Widget _buildQRScanner() {
    return Stack(
      children: [
        MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                _ipController.text = barcode.rawValue!;
                _stopQRScanner();
                break;
              }
            }
          },
        ),
        Positioned(
          top: 20,
          right: 20,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _stopQRScanner,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Mode'),
        actions: [
          if (_isConnected)
            Icon(Icons.circle, color: Colors.green)
          else
            Icon(Icons.circle, color: Colors.red),
        ],
      ),
      body: _isScanning
          ? _buildQRScanner()
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Enter username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_connectionError != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _connectionError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ipController,
                            decoration: const InputDecoration(
                              labelText: 'Enter server IP',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.qr_code_scanner),
                          onPressed: _startQRScanner,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: _connectToServer,
                        child: const Text(
                          'Connect to Server',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
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
            ),
    );
  }
}

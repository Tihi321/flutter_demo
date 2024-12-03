import 'package:flutter/material.dart';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:io';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  WebSocketChannel? _channel;
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];
  List<NetworkInterface> _interfaces = [];

  @override
  void initState() {
    super.initState();
    _listNetworkInterfaces();
  }

  void _listNetworkInterfaces() async {
    _interfaces = await NetworkInterface.list();
    setState(() {});
  }

  void _connectToServer([String? ip]) {
    final serverIp = ip ?? _ipController.text;
    _channel = WebSocketChannel.connect(Uri.parse('ws://$serverIp:4040/ws'));
    _channel!.stream.listen((message) {
      setState(() {
        _messages.add('Server: $message');
      });
    });
  }

  void _sendMessage() {
    final message = _messageController.text;
    _channel?.sink.add(message);
    setState(() {
      _messages.add('Client: $message');
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Mode'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<NetworkInterface>(
              hint: const Text('Select Network Interface'),
              items: _interfaces.map((interface) {
                return DropdownMenuItem<NetworkInterface>(
                  value: interface,
                  child: Text(interface.name),
                );
              }).toList(),
              onChanged: (selectedInterface) {
                if (selectedInterface != null && selectedInterface.addresses.isNotEmpty) {
                  _connectToServer(selectedInterface.addresses.first.address);
                }
              },
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
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.link),
                  onPressed: () => _connectToServer(),
                ),
              ],
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
    );
  }
}

import 'package:flutter/material.dart';
import 'server_screen.dart';
import 'client_screen.dart';
import 'utils/platform.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDevMode = false;

  @override
  void initState() {
    super.initState();
    _checkDevMode();
  }

  Future<void> _checkDevMode() async {
    final isDevMode = await checkIsEmulator();
    setState(() {
      _isDevMode = isDevMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Local Chat'),
            Text(
              _isDevMode ? 'Development' : 'Production',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ServerScreen()),
                );
              },
              child: const Text('Server Mode'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ClientScreen()),
                );
              },
              child: const Text('Client Mode'),
            ),
          ],
        ),
      ),
    );
  }
}

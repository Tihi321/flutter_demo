# Flutter WebSocket Chat Demo

A real-time chat application built with Flutter that enables direct device-to-device communication using WebSockets. Perfect for scenarios where you need local network communication without internet connectivity.

## Features

- 🌐 Server/Client architecture
- 📱 Cross-platform support (iOS & Android)
- 🔌 Direct device-to-device communication
- 📷 QR code scanning for easy connection
- 👥 Multiple client support
- 🚀 Real-time messaging
- ⚙️ Configurable server port
- 📡 Works over local WiFi/hotspot

## Prerequisites

- Flutter SDK (2.0.0 or higher)
- Dart SDK (2.12.0 or higher)
- Android Studio / VS Code
- Physical Android/iOS devices for testing

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  web_socket_channel: ^2.4.0
  qr_flutter: ^4.1.0
  qr_code_scanner: ^1.0.1
```

## Installation

1. Clone the repository

```bash
git clone https://github.com/yourusername/local_chat.git
cd local_chat
```

2. Install dependencies

```bash
flutter pub get
```

3. Run the app

```bash
# Start an emulator or connect a physical device
flutter emulators --launch Pixel_9_API_35  # Or your preferred emulator
flutter run
```

4. Multiple emulators can be launched simultaneously by running:

```bash
flutter devices
flutter emulators

flutter emulators --launch <emulator1_id>
flutter emulators --launch <emulator2_id>

flutter run -d <device1_id>
flutter run -d <device2_id>
```

## Building

### Debug Build

```bash
flutter build apk --debug
```

### Release Build

```bash
# For Android
flutter build apk --release

# For iOS
flutter build ios --release
```

### Clean Build

```bash
flutter clean
flutter pub get
flutter build apk --release
```

## Testing

For best results, test with physical devices:

1. Install the app on two or more devices
2. Enable WiFi hotspot on the server device
3. Connect client devices to the server's hotspot
4. Follow the in-app instructions for connection

## Project Structure

```
lib/
├── main.dart           # App entry point
├── server_screen.dart  # Server mode implementation
├── client_screen.dart  # Client mode implementation
└── models/            # Data models and utilities
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Contributors and testers
- [QR Flutter](https://pub.dev/packages/qr_flutter) package
- [Web Socket Channel](https://pub.dev/packages/web_socket_channel) package

## Support

For detailed information about the app's functionality, please check the [Info.md](Info.md) file.

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/yourusername/flutter_demo/issues) page
2. Create a new issue with detailed information about your problem
3. Join our [Discord community](your-discord-link) for real-time support

## Screenshots

[Add screenshots of your app here]

## Development Tools

### List Available Emulators

Run the following command to see all available emulators:

```bash
flutter emulators
```

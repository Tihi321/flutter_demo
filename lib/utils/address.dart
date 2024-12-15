import 'dart:io';

String getServerAddress(List<NetworkInterface> interfaces, bool isEmulator) {
  if (isEmulator) {
    // Find eth0 interface for emulator
    for (var interface in interfaces) {
      if (interface.name == 'eth0') {
        return interface.addresses.first.address;
      }
    }
    // Fallback to default emulator address
    return '10.0.2.15';
  }

  // Original WiFi logic for physical devices
  for (var interface in interfaces) {
    if (interface.name.toLowerCase().contains('wlan') ||
        interface.name.toLowerCase().contains('wifi') ||
        interface.name.toLowerCase().contains('wireless')) {
      return interface.addresses.first.address;
    }
  }

  return InternetAddress.anyIPv4.address;
}

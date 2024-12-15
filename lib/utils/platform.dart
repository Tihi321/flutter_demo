Future<bool> checkIsEmulator() async {
  // Check for compile-time configuration first
  const forceEmulator =
      String.fromEnvironment('FORCE_EMULATOR', defaultValue: '');
  if (forceEmulator.isNotEmpty) {
    print('Emulator detection via dart-define: $forceEmulator');
    return forceEmulator.toLowerCase() == 'true';
  }

  return false;
}

Future<String> getDevServerAddress({String defaultAddress = ''}) async {
  // Check for compile-time configuration first
  const serverAddress =
      String.fromEnvironment('SERVER_ADDRESS', defaultValue: '');
  if (serverAddress.isNotEmpty) {
    print('Server address via dart-define: $serverAddress');
    return serverAddress;
  }

  return defaultAddress;
}

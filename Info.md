# Flutter WebSocket Chat App

This Flutter application enables real-time communication between mobile devices using WebSocket technology. The app has two modes: Server and Client.

## Setup Requirements

1. Two or more mobile devices with the app installed
2. One device to act as server (host)
3. Other devices to act as clients
4. WiFi hotspot capability on the server device

## Server Mode

The server mode allows you to host a chat server that clients can connect to.

### Setting up Server:
1. Create a WiFi hotspot on your device
2. Open the app and select "Server Mode"
3. Enter desired port number (1-65535, default: 4040)
4. Click "Start Server"
5. Once server starts, you can:
   - View connected clients and their messages
   - Send messages to all connected clients
   - Show QR code for easy client connection

### Server Features:
- Custom port selection
- Real-time message broadcasting
- Connected clients tracking
- QR code sharing for easy connection
- Message history display

## Client Mode

The client mode allows you to connect to a running server and participate in the chat.

### Connecting as Client:
1. Connect your device to the server's WiFi hotspot
2. Open the app and select "Client Mode"
3. Connect to server either by:
   - Scanning the server's QR code (recommended)
   - Manually entering server address (IP:PORT)
4. Enter your username
5. Click "Connect"

### Client Features:
- QR code scanner for easy connection
- Manual address input option
- Username customization
- Real-time message sending/receiving
- Connection status display

## How It Works

1. Server Setup:
   - Server starts on specified port
   - Generates connection QR code (IP:PORT format)
   - Listens for incoming connections

2. Client Connection:
   - Connects to server's WiFi
   - Scans QR code or enters address
   - Establishes WebSocket connection
   - Sends username to server

3. Communication:
   - Server broadcasts messages to all connected clients
   - Clients send messages visible to everyone
   - Real-time updates for connections/disconnections

## Technical Details

- Uses WebSocket protocol for real-time communication
- Supports multiple simultaneous client connections
- QR code for simplified connection process
- Custom port configuration for flexibility
- Built with Flutter for cross-platform compatibility
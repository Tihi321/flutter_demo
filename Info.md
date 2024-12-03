Flutter app, have 2 modes, server and client.

User requirements, user on one mobile device, creates hotspot, client on other mobile device, connects to hotspot.
Server mode shows blutton and address, button will show qr code of address for client to scan and connect to server.
When client cellphone is conneted to hoptpot, in app user clicks client mode. App shows qr code scanner, scan then copy address to input. Or add manualy hotspot address.
Clients also has field to add name.
Then clients click connect. Upon connection message appears on server client connected with name that user entered and on client connected to server.
When client and server are connected, server app is server for communication between clients and server, over sockets or real time messaging. 

Server:

1. Start server
2. Server sends messages to client


Client:

1. Connect to server
2. Client sends messages to server
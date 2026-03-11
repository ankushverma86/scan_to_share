import 'dart:io';

class WifiHostService {
  ServerSocket? _server;

  Future<void> startServer(
    void Function(Socket client) onClient,
  ) async {
    try {
      _server = await ServerSocket.bind(
        InternetAddress.anyIPv4,
        8080,
        shared: true,
      );

      print("✅ SERVER STARTED on port 8080");

      _server!.listen(onClient);
    } catch (e) {
      print("❌ SERVER ERROR: $e");
      rethrow;
    }
  }

  void dispose() {
    _server?.close();
    print("🛑 SERVER CLOSED");
  }
}

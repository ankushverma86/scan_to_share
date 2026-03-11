import 'dart:convert';
import 'package:uuid/uuid.dart';

class QrService {
  static String generateQr({
    required String username,
    required String ip,
    required int port,
  }) {
    return jsonEncode({
      "username": username,
      "ip": ip,
      "port": port,
      "sessionId": const Uuid().v4(), // 🔥 always new QR
      "expiresAt": DateTime.now()
          .add(const Duration(minutes: 1))
          .millisecondsSinceEpoch,
    });
  }
}

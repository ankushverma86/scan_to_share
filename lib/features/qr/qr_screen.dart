import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/services/network/network_service.dart';
import '../../core/services/wifi/wifi_host_service.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  final WifiHostService _hostService = WifiHostService();

  String? qrData;
  String? hostIp;
  Socket? clientSocket;

  static const int port = 8080;

  @override
  void initState() {
    super.initState();
    _initHost();
  }

  Future<void> _initHost() async {
    try {
      final ip = await NetworkService.getLocalIp();

      if (ip == null || ip.isEmpty) {
        debugPrint("❌ NO WIFI IP FOUND");
        return;
      }

      hostIp = ip;
      debugPrint("📡 HOST IP: $hostIp");

      await _hostService.startServer((client) {
        clientSocket = client;
        debugPrint("🤝 CLIENT CONNECTED: ${client.remoteAddress}");
      });

      debugPrint("✅ SERVER STARTED on port $port");

      setState(() {
        qrData = jsonEncode({
          "ip": hostIp,
          "port": port,
          "username": "ankush_tech",
          "expiresAt": DateTime.now()
              .add(const Duration(minutes: 1))
              .millisecondsSinceEpoch,
        });
      });
    } catch (e) {
      debugPrint("❌ HOST INIT ERROR: $e");
    }
  }

  @override
  void dispose() {
    debugPrint("🛑 HOST DISPOSED");
    _hostService.dispose();
    clientSocket?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your QR")),
      body: Center(
        child: qrData == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QrImageView(
                    data: qrData!,
                    size: 220,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Host IP: $hostIp",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Both devices must be on the same Wi-Fi",
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
      ),
    );
  }
}

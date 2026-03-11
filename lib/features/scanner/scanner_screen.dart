import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// import '../chat/chat_screen.dart';
import '../transfer/transfer_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool scanned = false;
  bool connecting = false;

  Future<void> _handleQr(String raw) async {
    try {
      final data = jsonDecode(raw);

      // ⏳ Expiry check
      final expiresAt = data['expiresAt'];
      if (expiresAt != null &&
          DateTime.now().millisecondsSinceEpoch > expiresAt) {
        throw Exception("QR expired");
      }

      setState(() {
        connecting = true;
      });

      debugPrint("🔌 CONNECTING TO ${data['ip']}:${data['port']}");

      final socket = await Socket.connect(
        data['ip'],
        data['port'],
        timeout: const Duration(seconds: 5),
      );

      debugPrint("✅ SOCKET CONNECTED");

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TransferScreen(
            socket: socket,
            peerName: data['username'],
          ),
        ),
      );
//     Navigator.pushReplacement( 
    } catch (e) {
      debugPrint("❌ CONNECTION ERROR: $e");

      setState(() {
        scanned = false;
        connecting = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains("expired")
                ? "QR expired. Please rescan."
                : "Connection failed. Check Wi-Fi.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR")),
      body: connecting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Connecting..."),
                ],
              ),
            )
          : MobileScanner(
              onDetect: (capture) {
                if (scanned) return;
                scanned = true;

                for (final barcode in capture.barcodes) {
                  final raw = barcode.rawValue;
                  if (raw != null) {
                    _handleQr(raw);
                    break;
                  }
                }
              },
            ),
    );
  }
}

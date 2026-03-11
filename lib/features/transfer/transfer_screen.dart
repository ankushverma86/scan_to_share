import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/services/file/file_transfer_service.dart';
import '../../core/services/history/history_service.dart';

class TransferScreen extends StatefulWidget {
  final Socket socket;
  final String peerName;

  const TransferScreen({
    super.key,
    required this.socket,
    required this.peerName,
  });

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  double progress = 0;
  String status = "Connected";
  bool pickerOpened = false;
  bool isSending = false;
  bool success = false;

  @override
  void initState() {
    super.initState();

    // 🔥 Auto-open picker once UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pickAndSendFile();
    });
  }

  Future<void> _pickAndSendFile() async {
    if (pickerOpened || isSending) return;
    pickerOpened = true;

    try {
      final result = await FilePicker.platform.pickFiles();

      if (result == null) {
        setState(() {
          status = "No file selected";
        });
        return;
      }

      final file = File(result.files.single.path!);

      setState(() {
        isSending = true;
        success = false;
        status = "Sending ${file.path.split('/').last}";
        progress = 0;
      });

      await FileTransferService.sendFile(
        widget.socket,
        file,
        (p) {
          if (!mounted) return;
          setState(() => progress = p);
        },
      );

      HistoryService.add(
        name: file.path.split('/').last,
        type: "Sent",
      );

      if (!mounted) return;

      setState(() {
        isSending = false;
        success = true;
        status = "File sent successfully";
        progress = 0;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSending = false;
        success = false;
        status = "Transfer failed";
        progress = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("File transfer failed. Connection lost."),
        ),
      );
    }
  }

  void _sendAnotherFile() {
    setState(() {
      pickerOpened = false;
      success = false;
      status = "Connected";
    });

    _pickAndSendFile();
  }

  @override
  void dispose() {
    widget.socket.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.peerName),
            Text(
              status,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔄 Progress bar
            if (isSending)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: LinearProgressIndicator(value: progress),
              ),

            const SizedBox(height: 30),

            // 🔔 Status icon
            Icon(
              success
                  ? Icons.check_circle
                  : isSending
                      ? Icons.swap_horiz
                      : Icons.insert_drive_file,
              size: 80,
              color: success
                  ? Colors.green
                  : isSending
                      ? Colors.blueAccent
                      : Colors.grey,
            ),

            const SizedBox(height: 16),

            Text(
              success
                  ? "Transfer complete"
                  : isSending
                      ? "Sending file…"
                      : "Ready to send",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            // 🔁 Send another file
            if (success)
              ElevatedButton.icon(
                onPressed: _sendAnotherFile,
                icon: const Icon(Icons.attach_file),
                label: const Text("Send another file"),
              ),
          ],
        ),
      ),
    );
  }
}

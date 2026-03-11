import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class FileTransferService {
  /// ================= SEND FILE =================
  static Future<void> sendFile(
    Socket socket,
    File file,
    void Function(double progress) onProgress,
  ) async {
    final int fileSize = await file.length();
    final String fileName = file.path.split('/').last;

    // 1️⃣ Send metadata
    socket.write(jsonEncode({
      "type": "file",
      "name": fileName,
      "size": fileSize,
    }) + "\n");

    // 2️⃣ Send file bytes EXACTLY
    int sent = 0;
    await for (final Uint8List chunk
        in file.openRead().map((d) => Uint8List.fromList(d))) {
      socket.add(chunk);
      sent += chunk.length;
      onProgress(sent / fileSize);
    }

    await socket.flush();

    // 3️⃣ Wait for ACK
    final String response = await socket
        .cast<List<int>>()
        .transform(utf8.decoder)
        .firstWhere((msg) => msg.contains('ACK'));

    if (!response.contains('SUCCESS')) {
      throw Exception('Transfer failed');
    }
  }

  /// ================= RECEIVE FILE =================
  static Future<File> receiveFile(
    Socket socket,
    Map<String, dynamic> meta,
    void Function(double progress) onProgress,
  ) async {
    final int totalSize = meta['size'];
    int received = 0;

    final Directory dir = Directory('/storage/emulated/0/Download');
    if (!dir.existsSync()) dir.createSync(recursive: true);

    final File file = File('${dir.path}/${meta['name']}');
    final IOSink sink = file.openWrite();

    await for (final Uint8List data in socket) {
      sink.add(data);
      received += data.length;
      onProgress(received / totalSize);

      if (received >= totalSize) break;
    }

    await sink.flush();
    await sink.close();

    // 4️⃣ Send ACK
    socket.write('ACK_SUCCESS\n');

    return file;
  }
}

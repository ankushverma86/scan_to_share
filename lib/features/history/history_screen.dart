import 'package:flutter/material.dart';
import '../../core/services/history/history_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = HistoryService.all;

    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: history.isEmpty
          ? const Center(child: Text("No transfers yet"))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (_, i) {
                final item = history[i];
                return ListTile(
                  leading: Icon(
                    item['type'] == "Sent"
                        ? Icons.upload
                        : Icons.download,
                  ),
                  title: Text(item['name']!),
                  subtitle: Text(item['type']!),
                  trailing: Text(
                    item['time']!.split('.')[0],
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              },
            ),
    );
  }
}

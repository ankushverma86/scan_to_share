class HistoryService {
  static final List<Map<String, String>> _history = [];

  static void add({
    required String name,
    required String type,
  }) {
    _history.insert(0, {
      "name": name,
      "type": type,
      "time": DateTime.now().toString(),
    });
  }

  static List<Map<String, String>> get all => _history;
}

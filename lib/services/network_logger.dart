import '../models/network_log.dart';

class NetworkLogger {
  NetworkLogger._();

  static final List<NetworkLog> logs = [];

  static void add(NetworkLog log) {
    logs.insert(0, log);
  }

  static void clear() {
    logs.clear();
  }

  static NetworkLog? find(String id) {
    try {
      return logs.firstWhere((log) => log.id == id);
    } catch (_) {
      return null;
    }
  }

  static void update({
    required String id,
    required int statusCode,
    required dynamic response,
    required bool success,
    String? error,
  }) {
    final log = find(id);

    if (log == null) {
      return;
    }

    log.responseTime = DateTime.now();

    log.duration =
        log.responseTime!.difference(log.requestTime);

    log.statusCode = statusCode;

    log.response = response;

    log.success = success;

    log.error = error;
  }
}
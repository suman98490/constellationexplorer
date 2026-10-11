import '../models/network_log.dart';

class NetworkLogger {
  NetworkLogger._();

  static final List<NetworkLog> logs = [];

  // ============================================================
  // ADD NEW LOG
  // ============================================================

  static void add(NetworkLog log) {
    try {
      logs.insert(0, log);
    } catch (_) {
      // Network logging must never break the application.
    }
  }

  // ============================================================
  // CLEAR LOGS
  // ============================================================

  static void clear() {
    try {
      logs.clear();
    } catch (_) {
      // Ignore logging errors.
    }
  }

  // ============================================================
  // FIND LOG
  // ============================================================

  static NetworkLog? find(String id) {
    try {
      return logs.firstWhere(
            (log) => log.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // UPDATE LOG WITH RESPONSE
  // ============================================================

  static void update({
    required String id,
    required int statusCode,
    required dynamic response,
    required bool success,
    String? error,
    Map<String, dynamic>? responseHeaders,
  }) {
    try {
      final log = find(id);

      if (log == null) {
        return;
      }

      log.responseTime = DateTime.now();

      log.duration =
          log.responseTime!.difference(
            log.requestTime,
          );

      log.statusCode = statusCode;

      log.response = response;

      log.success = success;

      log.error = error;

      // ----------------------------------------------------------
      // RESPONSE HEADERS
      // ----------------------------------------------------------

      if (responseHeaders != null) {
        log.responseHeaders
          ..clear()
          ..addAll(responseHeaders);
      }
    } catch (_) {
      // ----------------------------------------------------------
      // IMPORTANT
      //
      // Network logging should NEVER cause an API call to fail.
      // ----------------------------------------------------------
    }
  }
}
class NetworkLog {
  final String id;

  final String description;

  final String method;

  final String endpoint;

  final DateTime requestTime;

  DateTime? responseTime;

  Duration? duration;

  int? statusCode;

  bool success;

  dynamic request;

  dynamic response;

  String? error;

  // ============================================================
  // HTTP HEADERS
  // ============================================================

  /// Headers sent with the request
  final Map<String, dynamic> requestHeaders;

  /// Headers received in the response
  final Map<String, dynamic> responseHeaders;

  NetworkLog({
    required this.id,
    required this.description,
    required this.method,
    required this.endpoint,
    required this.requestTime,
    this.responseTime,
    this.duration,
    this.statusCode,
    this.success = false,
    this.request,
    this.response,
    this.error,

    // Always create mutable maps.
    Map<String, dynamic>? requestHeaders,
    Map<String, dynamic>? responseHeaders,
  })  : requestHeaders =
  requestHeaders != null
      ? Map<String, dynamic>.from(requestHeaders)
      : <String, dynamic>{},
        responseHeaders =
        responseHeaders != null
            ? Map<String, dynamic>.from(responseHeaders)
            : <String, dynamic>{};

  // ============================================================
  // STATUS TEXT
  // ============================================================

  String get statusText {
    if (statusCode == null) {
      return "Pending";
    }

    if (statusCode! >= 200 && statusCode! < 300) {
      return "Success";
    }

    if (statusCode! >= 400 && statusCode! < 500) {
      return "Client Error";
    }

    if (statusCode! >= 500) {
      return "Server Error";
    }

    return "Unknown";
  }

  // ============================================================
  // DURATION TEXT
  // ============================================================

  String get durationText {
    if (duration == null) {
      return "--";
    }

    return "${duration!.inMilliseconds} ms";
  }
}
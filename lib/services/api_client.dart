import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

import '../models/network_log.dart';
import 'auth_service.dart';
import 'network_logger.dart';
import 'session_manager.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  final Dio _dio = Dio();

  final AuthService _authService = AuthService();

  // =========================================================
  // HEADER SANITIZATION
  // =========================================================

  Map<String, dynamic> _sanitizeHeaders(
      Map<String, dynamic> headers,
      ) {
    final result = <String, dynamic>{};

    try {
      headers.forEach((key, value) {
        final lowerKey = key.toLowerCase();

        if (lowerKey == "authorization" ||
            lowerKey == "cookie" ||
            lowerKey == "set-cookie" ||
            lowerKey.contains("client-secret") ||
            lowerKey.contains("api-key")) {
          result[key] = "[REDACTED]";
        } else {
          result[key] = value;
        }
      });
    } catch (_) {
      // Header logging must never affect API execution.
    }

    return result;
  }

  // =========================================================
  // GET
  // =========================================================

  Future<Response> get({
    required String endpoint,
    required String purpose,
    Map<String, dynamic>? queryParameters,
  }) async {
    debugPrint("******** GET API CALLED ********");

    final requestId = const Uuid().v4();

    final token = await _authService.getAccessToken();

    final requestHeaders = <String, dynamic>{
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };

    // ---------------------------------------------------------
    // NETWORK LOGGING
    // ---------------------------------------------------------

    try {
      final log = NetworkLog(
        id: requestId,
        description: purpose,
        method: "GET",
        endpoint: endpoint,
        requestTime: DateTime.now(),
        request: queryParameters,
        requestHeaders: _sanitizeHeaders(requestHeaders),
      );

      NetworkLogger.add(log);
    } catch (e) {
      debugPrint(
        "Network logging failed while creating GET log: $e",
      );
    }

    // ---------------------------------------------------------
    // API CALL
    // ---------------------------------------------------------

    try {
      final response = await _dio.get(
        "${SessionManager.baseUrl}/$endpoint",
        queryParameters: queryParameters,
        options: Options(
          headers: requestHeaders,
        ),
      );

      // -------------------------------------------------------
      // UPDATE NETWORK LOG
      // -------------------------------------------------------

      try {
        NetworkLogger.update(
          id: requestId,
          statusCode: response.statusCode ?? 200,
          response: response.data,
          responseHeaders: Map<String, dynamic>.from(
            response.headers.map,
          ),
          success: true,
        );
      } catch (e) {
        debugPrint(
          "Network logging failed after GET response: $e",
        );
      }

      return response;
    } on DioException catch (e) {
      // -------------------------------------------------------
      // LOG FAILED RESPONSE
      // -------------------------------------------------------

      try {
        NetworkLogger.update(
          id: requestId,
          statusCode: e.response?.statusCode ?? 500,
          response: e.response?.data,
          responseHeaders: e.response == null
              ? {}
              : Map<String, dynamic>.from(
            e.response!.headers.map,
          ),
          success: false,
          error: e.message,
        );
      } catch (logError) {
        debugPrint(
          "Network logging failed after GET error: $logError",
        );
      }

      rethrow;
    }
  }

  // =========================================================
  // POST
  // =========================================================

  Future<Response> post({
    required String endpoint,
    required String purpose,
    dynamic body,
    Map<String, dynamic>? queryParameters,
  }) async {
    debugPrint("******** POST API CALLED ********");

    final requestId =
    DateTime.now().microsecondsSinceEpoch.toString();

    final token = await _authService.getAccessToken();

    final requestHeaders = <String, dynamic>{
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };

    // ---------------------------------------------------------
    // NETWORK LOGGING
    // ---------------------------------------------------------

    try {
      final log = NetworkLog(
        id: requestId,
        description: purpose,
        method: "POST",
        endpoint: endpoint,
        requestTime: DateTime.now(),
        request: body,
        requestHeaders: _sanitizeHeaders(requestHeaders),
      );

      NetworkLogger.add(log);
    } catch (e) {
      debugPrint(
        "Network logging failed while creating POST log: $e",
      );
    }

    // ---------------------------------------------------------
    // API CALL
    // ---------------------------------------------------------

    try {
      final response = await _dio.post(
        "${SessionManager.baseUrl}$endpoint",
        data: body,
        queryParameters: queryParameters,
        options: Options(
          headers: requestHeaders,
        ),
      );

      // -------------------------------------------------------
      // UPDATE NETWORK LOG
      // -------------------------------------------------------

      try {
        NetworkLogger.update(
          id: requestId,
          statusCode: response.statusCode ?? 200,
          response: response.data,
          responseHeaders: Map<String, dynamic>.from(
            response.headers.map,
          ),
          success: true,
        );
      } catch (e) {
        debugPrint(
          "Network logging failed after POST response: $e",
        );
      }

      return response;
    } on DioException catch (e) {
      // -------------------------------------------------------
      // LOG FAILED RESPONSE
      // -------------------------------------------------------

      try {
        NetworkLogger.update(
          id: requestId,
          statusCode: e.response?.statusCode ?? 500,
          response: e.response?.data,
          responseHeaders: e.response == null
              ? {}
              : Map<String, dynamic>.from(
            e.response!.headers.map,
          ),
          success: false,
          error: e.message,
        );
      } catch (logError) {
        debugPrint(
          "Network logging failed after POST error: $logError",
        );
      }

      rethrow;
    }
  }

  // =========================================================
  // PATCH
  // =========================================================

  Future<Response> patch({
    required String endpoint,
    required String purpose,
    dynamic body,
    Map<String, dynamic>? queryParameters,

    /// Additional request headers
    Map<String, String>? headers,
  }) async {
    debugPrint("******** PATCH API CALLED ********");

    final requestId = const Uuid().v4();

    final token = await _authService.getAccessToken();

    // ---------------------------------------------------------
    // REQUEST HEADERS
    // ---------------------------------------------------------

    final requestHeaders = <String, dynamic>{
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",

      // Merge custom headers such as:
      // if-match
      ...?headers,
    };

    // ---------------------------------------------------------
    // NETWORK LOGGING
    // ---------------------------------------------------------

    try {
      final log = NetworkLog(
        id: requestId,
        description: purpose,
        method: "PATCH",
        endpoint: endpoint,
        requestTime: DateTime.now(),
        request: body,
        requestHeaders: _sanitizeHeaders(requestHeaders),
      );

      NetworkLogger.add(log);
    } catch (e) {
      debugPrint(
        "Network logging failed while creating PATCH log: $e",
      );
    }

    // ---------------------------------------------------------
    // API CALL
    // ---------------------------------------------------------

    try {
      final response = await _dio.patch(
        "${SessionManager.baseUrl}$endpoint",
        data: body,
        queryParameters: queryParameters,
        options: Options(
          headers: requestHeaders,
        ),
      );

      // -------------------------------------------------------
      // UPDATE NETWORK LOG
      // -------------------------------------------------------

      try {
        NetworkLogger.update(
          id: requestId,
          statusCode: response.statusCode ?? 200,
          response: response.data,
          responseHeaders: Map<String, dynamic>.from(
            response.headers.map,
          ),
          success: true,
        );
      } catch (e) {
        debugPrint(
          "Network logging failed after PATCH response: $e",
        );
      }

      return response;
    } on DioException catch (e) {
      // -------------------------------------------------------
      // LOG FAILED RESPONSE
      // -------------------------------------------------------

      try {
        NetworkLogger.update(
          id: requestId,
          statusCode: e.response?.statusCode ?? 500,
          response: e.response?.data,
          responseHeaders: e.response == null
              ? {}
              : Map<String, dynamic>.from(
            e.response!.headers.map,
          ),
          success: false,
          error: e.message,
        );
      } catch (logError) {
        debugPrint(
          "Network logging failed after PATCH error: $logError",
        );
      }

      rethrow;
    }
  }
}
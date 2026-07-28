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

  Future<Response> get({
    required String endpoint,
    required String purpose,
    Map<String, dynamic>? queryParameters,
  }) async {
    debugPrint("******** GET API CALLED ********");
    final requestId = const Uuid().v4();

    final token = await _authService.getAccessToken();

    final log = NetworkLog(
      id: requestId,
      description: purpose,
      method: "GET",
      endpoint: endpoint,
      requestTime: DateTime.now(),
      request: queryParameters,
    );

    NetworkLogger.add(log);

    try {
      final response = await _dio.get(
        "${SessionManager.baseUrl}/$endpoint",
        queryParameters: queryParameters,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      NetworkLogger.update(
        id: requestId,
        statusCode: response.statusCode ?? 200,
        response: response.data,
        success: true,
      );

      return response;
    } on DioException catch (e) {
      NetworkLogger.update(
        id: requestId,
        statusCode: e.response?.statusCode ?? 500,
        response: e.response?.data,
        success: false,
        error: e.message,
      );

      rethrow;
    }
  }

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

    final log = NetworkLog(
      id: requestId,
      description: purpose,
      method: "POST",
      endpoint: endpoint,
      requestTime: DateTime.now(),
      request: body,
    );

    NetworkLogger.add(log);

    try {
      final response = await _dio.post(
        "${SessionManager.baseUrl}$endpoint",
        data: body,
        queryParameters: queryParameters,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      NetworkLogger.update(
        id: requestId,
        statusCode: response.statusCode ?? 200,
        response: response.data,
        success: true,
      );

      return response;
    } on DioException catch (e) {
      NetworkLogger.update(
        id: requestId,
        statusCode: e.response?.statusCode ?? 500,
        response: e.response?.data,
        success: false,
        error: e.message,
      );

      rethrow;
    }
  }

  Future<Response> patch({
    required String endpoint,
    required String purpose,
    dynamic body,
    Map<String, dynamic>? queryParameters,

    /// Additional request headers
    Map<String, String>? headers,
  }) async {

    final requestId =
    const Uuid().v4();

    final token =
    await _authService.getAccessToken();

    final log = NetworkLog(
      id: requestId,
      description: purpose,
      method: "PATCH",
      endpoint: endpoint,
      requestTime: DateTime.now(),
      request: body,
    );

    NetworkLogger.add(log);

    try {

      final response = await _dio.patch(

        "${SessionManager.baseUrl}$endpoint",

        data: body,

        queryParameters:
        queryParameters,

        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",

            // Merge any custom headers
            ...?headers,
          },
        ),
      );

      NetworkLogger.update(
        id: requestId,
        statusCode:
        response.statusCode ?? 200,
        response: response.data,
        success: true,
      );

      return response;

    } on DioException catch (e) {

      NetworkLogger.update(
        id: requestId,
        statusCode:
        e.response?.statusCode ?? 500,
        response: e.response?.data,
        success: false,
        error: e.message,
      );

      rethrow;
    }
  }
}
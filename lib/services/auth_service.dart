import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../models/auth_token.dart';
import 'session_manager.dart';

class AuthService {
  final Dio dio = Dio();

  Future<bool> login({
    required String baseUrl,
    required String clientId,
    required String clientSecret,
  }) async {
    try {
      final basicAuth = base64Encode(
        utf8.encode('$clientId:$clientSecret'),
      );

      final response = await dio.post(
        '$baseUrl/PRRestService/oauth2/v1/token',
        data: {
          "grant_type": "client_credentials",
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Authorization": "Basic $basicAuth",
          },
        ),
      );

      final token = AuthToken.fromJson(response.data);

      SessionManager.baseUrl = baseUrl;
      SessionManager.clientId = clientId;
      SessionManager.clientSecret = clientSecret;
      SessionManager.token = token;

      debugPrint("========== JWT ==========");
      debugPrint(JwtDecoder.decode(token.accessToken).toString());
      debugPrint("=========================");

      return true;
    } on DioException catch (e) {
      debugPrint("Login Failed");

      if (e.response != null) {
        debugPrint("Status : ${e.response?.statusCode}");
        debugPrint("Data   : ${e.response?.data}");
      } else {
        debugPrint(e.message);
      }

      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<void> refreshToken() async {
    await login(
      baseUrl: SessionManager.baseUrl!,
      clientId: SessionManager.clientId!,
      clientSecret: SessionManager.clientSecret!,
    );
  }

  Future<String> getAccessToken() async {
    if (SessionManager.token == null) {
      throw Exception("User is not authenticated.");
    }

    if (SessionManager.token!.isExpired) {
      debugPrint("Access Token Expired. Refreshing...");

      await refreshToken();
    }

    return SessionManager.token!.accessToken;
  }
}
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../config/pega_sso_config.dart';
import '../models/network_log.dart';
import 'network_logger.dart';
import 'storage_service.dart';

class PegaSsoService {
  final StorageService _storage = StorageService();

  // ============================================================
  // LOGIN WITH PEGA
  // ============================================================

  Future<void> loginWithPega(
      PegaSsoConfig config,
      ) async {
    // ----------------------------------------------------------
    // Generate PKCE verifier
    // ----------------------------------------------------------

    final codeVerifier = _generateCodeVerifier();

    debugPrint(
      'PKCE Code Verifier generated.'
          ' Length = ${codeVerifier.length}',
    );

    // ----------------------------------------------------------
    // Generate OAuth state
    // ----------------------------------------------------------

    final state = _generateCodeVerifier();

    debugPrint(
      'OAuth State generated.'
          ' Length = ${state.length}',
    );

    // ----------------------------------------------------------
    // Generate PKCE challenge
    // ----------------------------------------------------------

    final codeChallenge =
    _generateCodeChallenge(codeVerifier);

    debugPrint(
      'PKCE Code Challenge generated.'
          ' Length = ${codeChallenge.length}',
    );

    // ----------------------------------------------------------
    // Save configuration
    // ----------------------------------------------------------

    await _storage.savePegaSsoConfig(
      baseUrl: config.baseUrl,
      clientId: config.clientId,
      redirectUri: config.redirectUri,
      authorizationEndpoint:
      config.authorizationEndpoint,
      tokenEndpoint:
      config.tokenEndpoint,
    );

    debugPrint(
      'Pega SSO configuration saved.',
    );

    // ----------------------------------------------------------
    // Save PKCE verifier
    // ----------------------------------------------------------

    await _storage.saveCodeVerifier(
      codeVerifier,
    );

    debugPrint(
      'PKCE code verifier saved.',
    );

    // ----------------------------------------------------------
    // Save OAuth state
    // ----------------------------------------------------------

    await _storage.saveState(
      state,
    );

    debugPrint(
      'OAuth state saved.',
    );

    // ----------------------------------------------------------
    // Build authorization URL
    // ----------------------------------------------------------

    final authorizationUri =
    Uri.parse(
      config.authorizationEndpoint,
    ).replace(
      queryParameters: {
        'response_type': 'code',
        'client_id': config.clientId,
        'redirect_uri': config.redirectUri,
        'scope': config.scopes.join(' '),
        'code_challenge': codeChallenge,
        'code_challenge_method': 'S256',
        'state': state,
      },
    );

    // ----------------------------------------------------------
    // DEBUG LOGGING
    // ----------------------------------------------------------

    debugPrint(
      '==============================================',
    );

    debugPrint(
      'AUTHORIZATION REQUEST',
    );

    debugPrint(
      '==============================================',
    );

    debugPrint(
      'Authorization URL:',
    );

    debugPrint(
      authorizationUri.toString(),
    );

    debugPrint('');

    debugPrint(
      'Authorization Parameters:',
    );

    debugPrint(
      'response_type: code',
    );

    debugPrint(
      'client_id: ${config.clientId}',
    );

    debugPrint(
      'redirect_uri: ${config.redirectUri}',
    );

    debugPrint(
      'scope: ${config.scopes.join(' ')}',
    );

    debugPrint(
      'code_challenge: '
          '${_mask(codeChallenge)}',
    );

    debugPrint(
      'code_challenge_method: S256',
    );

    debugPrint(
      'state: ${_mask(state)}',
    );

    // ----------------------------------------------------------
    // Redirect browser to Pega
    // ----------------------------------------------------------

    debugPrint(
      'REDIRECTING BROWSER TO PEGA',
    );

    final launched = await launchUrl(
      authorizationUri,
      webOnlyWindowName: '_self',
    );

    if (!launched) {
      throw Exception(
        'Unable to open Pega authorization URL.',
      );
    }

    debugPrint(
      'Pega authorization page opened successfully.',
    );
  }

  // ============================================================
  // EXCHANGE AUTHORIZATION CODE FOR TOKEN
  // ============================================================

  Future<Map<String, dynamic>> exchangeCodeForToken(
      String code,
      ) async {
    debugPrint(
      '==============================================',
    );

    debugPrint(
      'STARTING AUTHORIZATION CODE TOKEN EXCHANGE',
    );

    debugPrint(
      '==============================================',
    );

    // ----------------------------------------------------------
    // Get saved configuration
    // ----------------------------------------------------------

    final config =
    await _storage.getPegaSsoConfig();

    if (config == null) {
      throw Exception(
        'Pega SSO configuration not found.',
      );
    }

    // ----------------------------------------------------------
    // Get PKCE verifier
    // ----------------------------------------------------------

    final codeVerifier =
    await _storage.getCodeVerifier();

    if (codeVerifier == null) {
      throw Exception(
        'PKCE code verifier not found.',
      );
    }

    // ----------------------------------------------------------
    // Get saved state
    // ----------------------------------------------------------

    final savedState =
    await _storage.getState();

    debugPrint(
      'Saved OAuth state exists: '
          '${savedState != null}',
    );

    // ----------------------------------------------------------
    // TOKEN ENDPOINT
    // ----------------------------------------------------------

    final tokenEndpoint =
    config["tokenEndpoint"]!;

    final tokenUri =
    Uri.parse(tokenEndpoint);

    // ----------------------------------------------------------
    // TOKEN REQUEST BODY
    // ----------------------------------------------------------

    final requestBody = {
      'grant_type': 'authorization_code',
      'client_id': config["clientId"]!,
      'code': code,
      'redirect_uri': config["redirectUri"]!,
      'code_verifier': codeVerifier,
    };

    // ----------------------------------------------------------
    // TOKEN REQUEST HEADERS
    // ----------------------------------------------------------

    final requestHeaders = {
      'Content-Type':
      'application/x-www-form-urlencoded',
      'Accept':
      'application/json',
    };

    // ==========================================================
    // CREATE NETWORK LOG
    // ==========================================================

    final logId =
        'oauth-token-${DateTime.now().microsecondsSinceEpoch}';

    final requestTime =
    DateTime.now();

    final tokenLog = NetworkLog(
      id: logId,
      description: 'OAuth Token Endpoint',
      method: 'POST',
      endpoint: tokenEndpoint,
      requestTime: requestTime,

      request: _safeRequestBody(
        requestBody,
      ),

      requestHeaders:
      requestHeaders,
    );

    NetworkLogger.add(
      tokenLog,
    );

    // ----------------------------------------------------------
    // DEBUG
    // ----------------------------------------------------------

    debugPrint(
      'TOKEN REQUEST',
    );

    debugPrint(
      'POST $tokenEndpoint',
    );

    _logMap(
      'TOKEN REQUEST HEADERS',
      requestHeaders,
    );

    _logMap(
      'TOKEN REQUEST BODY',
      requestBody,
      sensitiveKeys: [
        'code',
        'code_verifier',
      ],
    );

    // ==========================================================
    // EXECUTE TOKEN REQUEST
    // ==========================================================

    http.Response response;

    try {
      response = await http.post(
        tokenUri,
        headers: requestHeaders,
        body: requestBody,
      );
    } catch (e, stackTrace) {
      // --------------------------------------------------------
      // UPDATE NETWORK LOG ON EXCEPTION
      // --------------------------------------------------------

      NetworkLogger.update(
        id: logId,
        statusCode: 0,
        response: null,
        success: false,
        error: e.toString(),
      );

      debugPrint(
        'TOKEN HTTP REQUEST EXCEPTION',
      );

      debugPrint(
        'Exception: $e',
      );

      debugPrint(
        'StackTrace: $stackTrace',
      );

      rethrow;
    }

    // ==========================================================
    // TOKEN RESPONSE
    // ==========================================================

    final safeResponse =
    _safeTokenResponse(
      response.body,
    );

    // ----------------------------------------------------------
    // UPDATE NETWORK LOG
    // ----------------------------------------------------------

    NetworkLogger.update(
      id: logId,
      statusCode: response.statusCode,
      response: safeResponse,
      success:
      response.statusCode >= 200 &&
          response.statusCode < 300,
      error:
      response.statusCode >= 200 &&
          response.statusCode < 300
          ? null
          : 'HTTP ${response.statusCode}',
      responseHeaders:
      response.headers,
    );

    // ----------------------------------------------------------
    // DEBUG LOGGING
    // ----------------------------------------------------------

    debugPrint(
      'TOKEN RESPONSE',
    );

    debugPrint(
      'HTTP Status: ${response.statusCode}',
    );

    _logMap(
      'TOKEN RESPONSE HEADERS',
      response.headers,
    );

    debugPrint(
      'TOKEN RESPONSE BODY:',
    );

    _logTokenResponse(
      response.body,
    );

    // ==========================================================
    // HANDLE HTTP ERROR
    // ==========================================================

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Token request failed: '
            '${response.statusCode} '
            '${response.body}',
      );
    }

    // ==========================================================
    // PARSE RESPONSE
    // ==========================================================

    final tokenResponse =
    jsonDecode(response.body)
    as Map<String, dynamic>;

    debugPrint(
      'TOKEN RESPONSE PARSED',
    );

    debugPrint(
      'Response fields: '
          '${tokenResponse.keys.toList()}',
    );

    debugPrint(
      'Access token present: '
          '${tokenResponse.containsKey(
        'access_token',
      )}',
    );

    debugPrint(
      'ID token present: '
          '${tokenResponse.containsKey(
        'id_token',
      )}',
    );

    debugPrint(
      'Refresh token present: '
          '${tokenResponse.containsKey(
        'refresh_token',
      )}',
    );

    // ==========================================================
    // CLEAR TEMPORARY OAUTH DATA
    // ==========================================================

    await _storage.clearSsoTemporaryData();

    debugPrint(
      'Temporary OAuth data cleared.',
    );

    return tokenResponse;
  }

  // ============================================================
  // SAFE REQUEST BODY
  // ============================================================

  Map<String, dynamic> _safeRequestBody(
      Map<String, dynamic> body,
      ) {
    final result =
    <String, dynamic>{};

    body.forEach(
          (key, value) {
        if (key == 'code' ||
            key == 'code_verifier') {
          result[key] =
              _mask(
                value?.toString() ?? '',
              );
        } else {
          result[key] = value;
        }
      },
    );

    return result;
  }

  // ============================================================
  // SAFE TOKEN RESPONSE
  // ============================================================

  dynamic _safeTokenResponse(
      String responseBody,
      ) {
    try {
      final decoded =
      jsonDecode(responseBody);

      if (decoded is Map<String, dynamic>) {
        final safeResponse =
        <String, dynamic>{};

        decoded.forEach(
              (key, value) {
            if (key == 'access_token' ||
                key == 'id_token' ||
                key == 'refresh_token') {
              safeResponse[key] =
                  _mask(
                    value?.toString() ?? '',
                  );
            } else {
              safeResponse[key] = value;
            }
          },
        );

        return safeResponse;
      }

      return decoded;
    } catch (_) {
      return responseBody;
    }
  }

  // ============================================================
  // SAFE TOKEN RESPONSE DEBUG LOGGER
  // ============================================================

  void _logTokenResponse(
      String responseBody,
      ) {
    try {
      final decoded =
      jsonDecode(responseBody);

      if (decoded is Map<String, dynamic>) {
        final safeResponse =
        <String, dynamic>{};

        decoded.forEach(
              (key, value) {
            if (key == 'access_token' ||
                key == 'id_token' ||
                key == 'refresh_token') {
              safeResponse[key] =
                  _mask(
                    value?.toString() ?? '',
                  );
            } else {
              safeResponse[key] =
                  value;
            }
          },
        );

        debugPrint(
          const JsonEncoder.withIndent(
            '  ',
          ).convert(
            safeResponse,
          ),
        );

        return;
      }

      debugPrint(
        responseBody,
      );
    } catch (_) {
      debugPrint(
        responseBody,
      );
    }
  }

  // ============================================================
  // DEBUG MAP LOGGER
  // ============================================================

  void _logMap(
      String title,
      Map<dynamic, dynamic> map, {
        List<String> sensitiveKeys = const [],
      }) {
    debugPrint(
      '========== $title ==========',
    );

    map.forEach(
          (key, value) {
        final keyString =
        key.toString();

        if (sensitiveKeys.contains(
          keyString,
        )) {
          debugPrint(
            '$keyString: '
                '${_mask(value.toString())}',
          );
        } else {
          debugPrint(
            '$keyString: $value',
          );
        }
      },
    );

    debugPrint(
      '==============================',
    );
  }

  // ============================================================
  // MASK SENSITIVE VALUE
  // ============================================================

  String _mask(
      String value,
      ) {
    if (value.isEmpty) {
      return '<EMPTY>';
    }

    if (value.length <= 8) {
      return '********';
    }

    return
      '${value.substring(0, 4)}'
          '********'
          '${value.substring(
        value.length - 4,
      )}';
  }

  // ============================================================
  // GENERATE PKCE CODE VERIFIER
  // ============================================================

  String _generateCodeVerifier() {
    final random =
    Random.secure();

    final bytes =
    List<int>.generate(
      32,
          (_) => random.nextInt(256),
    );

    return base64UrlEncode(
      bytes,
    ).replaceAll(
      '=',
      '',
    );
  }

  // ============================================================
  // GENERATE PKCE CODE CHALLENGE
  // ============================================================

  String _generateCodeChallenge(
      String verifier,
      ) {
    final bytes =
    utf8.encode(verifier);

    final digest =
    sha256.convert(bytes);

    return base64UrlEncode(
      digest.bytes,
    ).replaceAll(
      '=',
      '',
    );
  }
}
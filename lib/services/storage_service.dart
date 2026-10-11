import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // --------------------------------------------------
  // Existing Client Credentials keys
  // --------------------------------------------------

  static const String baseUrlKey = "baseUrl";
  static const String clientIdKey = "clientId";
  static const String clientSecretKey = "clientSecret";

  // --------------------------------------------------
  // Pega SSO configuration keys
  // --------------------------------------------------

  static const String ssoBaseUrlKey = "ssoBaseUrl";
  static const String ssoClientIdKey = "ssoClientId";
  static const String ssoRedirectUriKey = "ssoRedirectUri";
  static const String ssoAuthorizationEndpointKey =
      "ssoAuthorizationEndpoint";
  static const String ssoTokenEndpointKey = "ssoTokenEndpoint";

  // --------------------------------------------------
  // OAuth temporary values
  // --------------------------------------------------

  static const String ssoCodeVerifierKey =
      "ssoCodeVerifier";

  static const String ssoStateKey =
      "ssoState";

  // NEW
  static const String ssoAuthorizationStartTimeKey =
      "ssoAuthorizationStartTime";

  // --------------------------------------------------
  // Existing Client Credentials
  // --------------------------------------------------

  Future<void> saveConnection({
    required String baseUrl,
    required String clientId,
    required String clientSecret,
  }) async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setString(
      baseUrlKey,
      baseUrl,
    );

    await prefs.setString(
      clientIdKey,
      clientId,
    );

    await prefs.setString(
      clientSecretKey,
      clientSecret,
    );
  }

  Future<Map<String, String>?> getConnection() async {
    final prefs =
    await SharedPreferences.getInstance();

    final baseUrl =
    prefs.getString(baseUrlKey);

    final clientId =
    prefs.getString(clientIdKey);

    final clientSecret =
    prefs.getString(clientSecretKey);

    if (baseUrl == null ||
        clientId == null ||
        clientSecret == null) {
      return null;
    }

    return {
      "baseUrl": baseUrl,
      "clientId": clientId,
      "clientSecret": clientSecret,
    };
  }

  // --------------------------------------------------
  // Save Pega SSO configuration
  // --------------------------------------------------

  Future<void> savePegaSsoConfig({
    required String baseUrl,
    required String clientId,
    required String redirectUri,
    required String authorizationEndpoint,
    required String tokenEndpoint,
  }) async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setString(
      ssoBaseUrlKey,
      baseUrl,
    );

    await prefs.setString(
      ssoClientIdKey,
      clientId,
    );

    await prefs.setString(
      ssoRedirectUriKey,
      redirectUri,
    );

    await prefs.setString(
      ssoAuthorizationEndpointKey,
      authorizationEndpoint,
    );

    await prefs.setString(
      ssoTokenEndpointKey,
      tokenEndpoint,
    );
  }

  // --------------------------------------------------
  // Get Pega SSO configuration
  // --------------------------------------------------

  Future<Map<String, String>?> getPegaSsoConfig() async {
    final prefs =
    await SharedPreferences.getInstance();

    final baseUrl =
    prefs.getString(ssoBaseUrlKey);

    final clientId =
    prefs.getString(ssoClientIdKey);

    final redirectUri =
    prefs.getString(ssoRedirectUriKey);

    final authorizationEndpoint =
    prefs.getString(
      ssoAuthorizationEndpointKey,
    );

    final tokenEndpoint =
    prefs.getString(
      ssoTokenEndpointKey,
    );

    if (baseUrl == null ||
        clientId == null ||
        redirectUri == null ||
        authorizationEndpoint == null ||
        tokenEndpoint == null) {
      return null;
    }

    return {
      "baseUrl": baseUrl,
      "clientId": clientId,
      "redirectUri": redirectUri,
      "authorizationEndpoint":
      authorizationEndpoint,
      "tokenEndpoint":
      tokenEndpoint,
    };
  }

  // --------------------------------------------------
  // Save PKCE Code Verifier
  // --------------------------------------------------

  Future<void> saveCodeVerifier(
      String codeVerifier,
      ) async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setString(
      ssoCodeVerifierKey,
      codeVerifier,
    );
  }

  // --------------------------------------------------
  // Get PKCE Code Verifier
  // --------------------------------------------------

  Future<String?> getCodeVerifier() async {
    final prefs =
    await SharedPreferences.getInstance();

    return prefs.getString(
      ssoCodeVerifierKey,
    );
  }

  // --------------------------------------------------
  // Save OAuth State
  // --------------------------------------------------

  Future<void> saveState(
      String state,
      ) async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setString(
      ssoStateKey,
      state,
    );
  }

  // --------------------------------------------------
  // Get OAuth State
  // --------------------------------------------------

  Future<String?> getState() async {
    final prefs =
    await SharedPreferences.getInstance();

    return prefs.getString(
      ssoStateKey,
    );
  }

  // --------------------------------------------------
  // NEW: Save OAuth Authorization Start Time
  // --------------------------------------------------

  Future<void> saveAuthorizationStartTime(
      DateTime time,
      ) async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setInt(
      ssoAuthorizationStartTimeKey,
      time.millisecondsSinceEpoch,
    );
  }

  // --------------------------------------------------
  // NEW: Get OAuth Authorization Start Time
  // --------------------------------------------------

  Future<DateTime?> getAuthorizationStartTime() async {
    final prefs =
    await SharedPreferences.getInstance();

    final timestamp =
    prefs.getInt(
      ssoAuthorizationStartTimeKey,
    );

    if (timestamp == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(
      timestamp,
    );
  }

  // --------------------------------------------------
  // Clear temporary OAuth values
  // --------------------------------------------------

  Future<void> clearSsoTemporaryData() async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.remove(
      ssoCodeVerifierKey,
    );

    await prefs.remove(
      ssoStateKey,
    );

    // NEW
    await prefs.remove(
      ssoAuthorizationStartTimeKey,
    );
  }

  // --------------------------------------------------
  // Clear everything
  // --------------------------------------------------

  Future<void> clearConnection() async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.clear();
  }
}
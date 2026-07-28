import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String baseUrlKey = "baseUrl";
  static const String clientIdKey = "clientId";
  static const String clientSecretKey = "clientSecret";

  Future<void> saveConnection({
    required String baseUrl,
    required String clientId,
    required String clientSecret,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(baseUrlKey, baseUrl);
    await prefs.setString(clientIdKey, clientId);
    await prefs.setString(clientSecretKey, clientSecret);
  }

  Future<Map<String, String>?> getConnection() async {
    final prefs = await SharedPreferences.getInstance();

    final baseUrl = prefs.getString(baseUrlKey);
    final clientId = prefs.getString(clientIdKey);
    final clientSecret = prefs.getString(clientSecretKey);

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

  Future<void> clearConnection() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();
  }
}
import '../models/auth_token.dart';

class SessionManager {
  static String? baseUrl;
  static String? clientId;
  static String? clientSecret;

  static AuthToken? token;

  static bool get isLoggedIn => token != null;

  static void clear() {
    baseUrl = null;
    clientId = null;
    clientSecret = null;
    token = null;
  }
}
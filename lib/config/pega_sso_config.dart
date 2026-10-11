class PegaSsoConfig {
  final String baseUrl;
  final String clientId;
  final String redirectUri;
  final String authorizationEndpoint;
  final String tokenEndpoint;

  final List<String> scopes;

  const PegaSsoConfig({
    required this.baseUrl,
    required this.clientId,
    required this.redirectUri,
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    this.scopes = const [
      'openid',
      'profile',
    ],
  });
}
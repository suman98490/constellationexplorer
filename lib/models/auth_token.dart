class AuthToken {
  final String accessToken;
  final String tokenType;
  final int expiresIn;

  /// Time when token was received
  final DateTime issuedAt;

  /// Time when token expires
  final DateTime expiryTime;

  AuthToken({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.issuedAt,
    required this.expiryTime,
  });

  factory AuthToken.fromJson(Map<String, dynamic> json) {

    final issuedAt = DateTime.now();

    return AuthToken(
      accessToken: json["access_token"],
      tokenType: json["token_type"],
      expiresIn: json["expires_in"],
      issuedAt: issuedAt,
      expiryTime: issuedAt.add(
        Duration(seconds: json["expires_in"]),
      ),
    );
  }

  bool get isExpired {
    return DateTime.now().isAfter(expiryTime);
  }

  Duration get remainingTime {
    return expiryTime.difference(DateTime.now());
  }
}
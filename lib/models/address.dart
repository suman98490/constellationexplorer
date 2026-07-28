class Address {

  final String id;
  final String streetAddress;

  const Address({
    required this.id,
    required this.streetAddress,
  });

  factory Address.fromJson(
      Map<String, dynamic> json) {

    return Address(
      id: json["pyGUID"] ?? "",
      streetAddress:
      json["StreetAddress"] ?? "",
    );
  }
}
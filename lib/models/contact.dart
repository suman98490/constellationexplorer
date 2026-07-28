class Contact {

  final String id;
  final String fullName;
  final String phoneNumber;
  final String emailAddress;

  const Contact({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.emailAddress,
  });

  factory Contact.fromJson(
      Map<String, dynamic> json) {

    return Contact(
      id: json["pyGUID"] ?? "",
      fullName: json["FullName"] ?? "",
      phoneNumber: json["PhoneNumber"] ?? "",
      emailAddress: json["EmailAddress"] ?? "",
    );
  }
}
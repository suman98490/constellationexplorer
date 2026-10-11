class ApiParameter {

  final String name;

  /// path, query, header, cookie
  final String location;

  final String type;

  final bool required;

  final String description;

  const ApiParameter({

    required this.name,

    required this.location,

    required this.type,

    required this.required,

    required this.description,

  });

}
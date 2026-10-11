class ApiResponse {

  final String statusCode;

  final String description;

  final String? schema;

  const ApiResponse({

    required this.statusCode,

    required this.description,

    this.schema,

  });

}
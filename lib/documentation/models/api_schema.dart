class ApiSchema {

  final String name;

  final String type;

  final bool required;

  final String? description;

  final List<ApiSchema> children;

  const ApiSchema({

    required this.name,

    required this.type,

    this.required = false,

    this.description,

    this.children = const [],

  });

}
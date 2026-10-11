import 'api_parameter.dart';
import 'api_schema.dart';


class ApiEndpoint {

  final String method;

  final String path;

  final String summary;

  final String description;

  final String tag;

  /// Path/Header/Query parameters
  final List<ApiParameter> parameters;

  /// Request Body Schema
  final ApiSchema? requestSchema;

  /// Response Body Schema
  final ApiSchema? responseSchema;

  const ApiEndpoint({

    required this.method,

    required this.path,

    required this.summary,

    required this.description,

    required this.tag,

    this.parameters = const [],

    this.requestSchema,

    this.responseSchema,

  });

}
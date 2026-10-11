import 'api_endpoint.dart';

class ApiGroup {

  final String name;

  final List<ApiEndpoint> endpoints;

  const ApiGroup({

    required this.name,

    required this.endpoints,

  });

}
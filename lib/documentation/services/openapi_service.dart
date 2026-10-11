import '../models/api_endpoint.dart';

class OpenApiService {

  static List<ApiEndpoint> get endpoints => [

    ApiEndpoint(

      method: "PATCH",

      path:
      "/assignments/{assignmentID}/actions/{actionID}",

      tag: "Assignment",

      summary: "Perform Assignment",

      description:
      "Submits the current assignment and returns the next assignment.",

    ),

    ApiEndpoint(

      method: "GET",

      path:
      "/assignments/{assignmentID}",

      tag: "Assignment",

      summary: "Get Assignment",

      description:
      "Returns assignment details.",

    ),

    ApiEndpoint(

      method: "POST",

      path:
      "/cases",

      tag: "Case",

      summary: "Create Case",

      description:
      "Creates a new case.",

    ),

    ApiEndpoint(

      method: "POST",

      path:
      "/data_views/{dataView}",

      tag: "Data Views",

      summary: "Execute Data View",

      description:
      "Executes a data view.",

    ),

  ];

}
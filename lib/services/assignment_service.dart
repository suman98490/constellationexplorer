import 'package:dio/dio.dart';

import '../runtime/patch_payload_builder.dart';
import 'api_client.dart';

class AssignmentService {

  Future<Response> submitAssignment({

    required String assignmentId,
    required String actionName,
    required String ifMatch,

  }) {

    final payload =
    PatchPayloadBuilder().build();

    return ApiClient.instance.patch(

      endpoint:
      "/api/application/v2/assignments/"
          "$assignmentId/actions/$actionName",

      purpose: "Submit Assignment",

      queryParameters: {
        "viewType": "page",
      },

      body: payload,

      headers: {
        "If-Match": ifMatch,
      },
    );
  }
}
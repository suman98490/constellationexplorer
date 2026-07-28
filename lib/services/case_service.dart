import 'package:dio/dio.dart';

import 'api_client.dart';

class CaseService {
  Future<Response> createCase({
    required String caseTypeId,
    String processId = "pyStartCase",
  }) {
    return ApiClient.instance.post(
      endpoint: "/api/application/v2/cases",
      queryParameters: {
        "viewType": "page",
      },
      purpose: "Create Case",
      body: {
        "caseTypeID": caseTypeId,
        "content": {},
        "processID": processId,
      },
    );
  }
}
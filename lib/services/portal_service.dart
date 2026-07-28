import 'package:dio/dio.dart';

import 'api_client.dart';

class PortalService {
  Future<Response> getPortal() async {
    return ApiClient.instance.get(
      endpoint: "/api/application/v2/portals/WebPortal",
      purpose: "Load Portal Metadata",
    );
  }
}
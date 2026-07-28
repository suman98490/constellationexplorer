import 'package:dio/dio.dart';

import 'api_client.dart';

class DataViewService {
  Future<Response> getDataView({
    required String dataViewName,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await ApiClient.instance.get(
      endpoint: "api/application/v2/data_views/$dataViewName",
      purpose: "Load Data View ($dataViewName)",
      queryParameters: queryParameters,
    );
  }
}
import 'package:dio/dio.dart';
import '../models/pega_component.dart';
import '../services/api_client.dart';
import 'data_source_cache.dart';

class DataViewExecutor {

  /// First call made by Constellation
  /// Used to get totalCount and metadata.
  Future<Response> preview(
      PegaComponent component,
      ) {

    return _execute(
      component: component,
      pageSize: 1,
      includeTotalCount: true,
    );
  }

  /// Second call made immediately after preview.
  /// Used to load actual records.
  Future<Response> load(
      PegaComponent component, {
        int pageSize = 61,
      }) async {

    final response = await _execute(
      component: component,
      pageSize: pageSize,
      includeTotalCount: false,
    );

    final data =
    response.data["data"] as List<dynamic>;

    DataSourceCache.put(
      component.datasource!,
      List<Map<String, dynamic>>.from(data),
    );


    return response;
  }

  Future<Response> _execute({
    required PegaComponent component,
    required int pageSize,
    required bool includeTotalCount,
  }) {

    final body = {

      "query": {
        "select": component.selectFields
            .map((field) => {
          "field": field,
        })
            .toList(),
      },

      "paging": {
        "pageNumber": 1,
        "pageSize": pageSize,
      },

      "dataViewParameters": {},

      if (includeTotalCount) ...{
        "useExtendedTimeout": true,
        "includeTotalCount": true,
        "includeTotalCountLimit": 5000,
      },
    };

    return ApiClient.instance.post(

      endpoint:
      "/api/application/v2/data_views/${component.datasource}",

      purpose:
      "Load ${component.datasource}",

      body: body,
    );
  }

  Future<Response> loadAutoComplete(
      PegaComponent component,
      ) async {

    final body = {

      "query": {

        "select":
        component.selectFields
            .map(
              (field) => {
            "field": field,
          },
        )
            .toList(),

        "distinctResultsOnly": "true",
      },

      "paging": {
        "pageNumber": 1,
        "pageSize": 50,
      },

      "dataViewParameters": {},
    };

    final response =
    await ApiClient.instance.post(

      endpoint:
      "/api/application/v2/data_views/${component.datasource}",

      purpose:
      "Load ${component.datasource}",

      body: body,
    );
    final data =
    response.data["data"] as List<dynamic>;

    DataSourceCache.put(
      component.datasource!,
      List<Map<String, dynamic>>.from(data),
    );

    return response;
  }
}
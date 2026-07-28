import 'package:dio/dio.dart';

import '../engine/metadata_parser.dart';
import '../models/pega_component.dart';

import '../models/runtime_header_model.dart';
import 'runtime_context.dart';

class RuntimeLoader {

  Future<List<PegaComponent>> load(
      Response response) async {

    final caseInfo =
    response.data["data"]["caseInfo"];
    final viewName =
    caseInfo["content"]["pyViewName"];

    RuntimeContext.instance.header =
        RuntimeHeaderModel(
          caseTypeName:
          caseInfo["caseTypeName"],
          stageName:
          caseInfo["stageLabel"],
          assignmentName:
          caseInfo["assignments"][0]["name"],
          status:
          caseInfo["status"],
          caseId:
          caseInfo["businessID"],
          assignmentTitle:
          caseInfo["assignments"][0]["name"],

          viewName:
          viewName,
        );

    final assignment =
    caseInfo["assignments"][0];

    RuntimeContext.instance.assignmentId =
    assignment["ID"];

    RuntimeContext.instance.actionName =
    assignment["actions"][0]["ID"];

    RuntimeContext.instance.ifMatch =
        response.headers.value("etag");

    final components =
    MetadataParser.parse(
      response.data,
    );

    RuntimeContext.instance.components =
        components;

    return components;
  }
}
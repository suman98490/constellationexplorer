import '../models/available_case_type.dart';

class CaseTypeParser {
  static List<AvailableCaseType> parse(
      Map<String, dynamic> response) {

    final List<AvailableCaseType> result = [];

    final list =
    response["pyCaseTypesAvailableToCreate"] as List;

    for (final item in list) {

      result.add(

        AvailableCaseType(

          className: item["pyClassName"],

          label: item["pyLabel"],

        ),

      );
    }

    return result;
  }
}
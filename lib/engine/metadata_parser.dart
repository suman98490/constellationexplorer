import '../models/pega_component.dart';

class MetadataParser {
  static List<PegaComponent> parse(
      Map<String, dynamic> response) {

    final List<PegaComponent> components = [];

    final caseInfo =
    response["data"]["caseInfo"];

    final resources =
    response["uiResources"]["resources"];

    final views =
    resources["views"];

    final fieldsMetadata =
    resources["fields"];

    final viewName =
    caseInfo["content"]["pyViewName"];

    final currentView =
    views[viewName][0];

    final regions =
    currentView["children"] as List<dynamic>;

    for (final region in regions) {

      final regionChildren =
      region["children"] as List<dynamic>;

      for (final component in regionChildren) {

        switch (component["type"]) {

          case "TextInput":

            _parseTextInput(
              component,
              fieldsMetadata,
              components,
            );

            break;

          case "reference":

            _parseReference(
              component,
              views,
              components,
            );

            break;
        }
      }
    }

    return components;
  }

  static void _parseTextInput(
      Map<String, dynamic> component,
      Map<String, dynamic> fieldsMetadata,
      List<PegaComponent> components,
      ) {

    final config = component["config"];

    final binding =
    _extractBinding(
      config["value"] ?? "",
    );

    final propertyName =
    _propertyName(binding);

    String label =
    _extractLabel(
      config["label"] ?? "",
    );

    if (fieldsMetadata[propertyName] != null) {

      final field =
      fieldsMetadata[propertyName][0];

      label = field["label"] ?? label;
    }

    components.add(
      PegaComponent(
        type: "TextInput",
        label: label,
        binding: binding,
        readOnly:
        config["readOnly"] ?? false,
      ),
    );
  }

  static void _parseReference(
      Map<String, dynamic> component,
      Map<String, dynamic> views,
      List<PegaComponent> components,
      ) {

    final config = component["config"];

    final referenceView =
    config["name"];

    final inheritedProps =
    config["inheritedProps"] as List?;

    String label = referenceView;

    if (inheritedProps != null &&
        inheritedProps.isNotEmpty) {

      label = _extractLabel(
        inheritedProps.first["value"] ?? "",
      );
    }

    final reference =
    views[referenceView][0];

    final children =
    reference["children"] as List;

    for (final child in children) {

      switch (child["type"]) {

        case "AutoComplete":

          _parseAutoComplete(
            child,
            label,
            referenceView,
            components,
          );

          break;

        case "SimpleTableSelect":

          _parseSimpleTableSelect(
            child,
            label,
            referenceView,
            components,
          );

          break;
      }
    }
  }

  static void _parseAutoComplete(
      Map<String, dynamic> component,
      String label,
      String referenceView,
      List<PegaComponent> components,
      ) {

    final config =
    component["config"];

    final selectFields = <String>[];

    final columns =
    config["columns"] as List?;

    if (columns != null) {

      for (final column in columns) {

        final value = column["value"];

        if (value != null) {

          selectFields.add(
            value
                .toString()
                .replaceFirst(".", ""),
          );
        }
      }
    }

    components.add(
      PegaComponent(
        type: "AutoComplete",
        label: label,
        binding: _extractBinding(
          config["value"] ?? "",
        ),
        datasource:
        config["datasource"],
        deferDatasource:
        config["deferDatasource"] ??
            false,
        listType:
        config["listType"],
        referenceView:
        referenceView,
        readOnly: false,
        selectFields:
        selectFields,
      ),
    );
  }

  static void _parseSimpleTableSelect(
      Map<String, dynamic> component,
      String label,
      String referenceView,
      List<PegaComponent> components,
      ) {

    final config =
    component["config"];

    final selectFields = <String>[];

    final presets =
    config["presets"] as List?;

    if (presets != null &&
        presets.isNotEmpty) {

      final preset =
          presets.first;

      final presetRegions =
      preset["children"] as List?;

      if (presetRegions != null &&
          presetRegions.isNotEmpty) {

        final columns =
        presetRegions.first["children"]
        as List?;

        if (columns != null) {

          for (final column in columns) {

            final columnConfig =
            column["config"];

            final value =
            columnConfig["value"];

            if (value != null) {

              selectFields.add(
                _extractBinding(value)
                    .replaceFirst(".", ""),
              );
            }
          }
        }
      }
    }

    if (!selectFields.contains("pyGUID")) {
      selectFields.add("pyGUID");
    }

    components.add(
      PegaComponent(
        type: "SimpleTableSelect",
        label: label,
        binding: _extractBinding(
          config["selectionList"] ?? "",
        ),
        datasource:
        config["referenceList"],
        deferDatasource: false,
        referenceView:
        referenceView,
        selectionMode:
        config["selectionMode"],
        readOnly: false,
        selectFields:
        selectFields,
      ),
    );
  }

  static String _extractBinding(
      String value) {

    return value.replaceAll("@P ", "");
  }

  static String _extractLabel(
      String value) {

    return value
        .replaceAll("@FL ", "")
        .replaceAll("@L ", "");
  }

  static String _propertyName(
      String binding) {

    return binding.replaceFirst(".", "");
  }
}
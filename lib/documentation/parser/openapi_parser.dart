import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';
import '../models/api_endpoint.dart';
import '../models/api_parameter.dart';
import '../models/api_schema.dart';
import '../models/openapi_document.dart';

class OpenApiParser {

  Future<OpenApiDocument> parse() async {

    //--------------------------------------------------
    // Load YAML
    //--------------------------------------------------

    final yamlText = await rootBundle.loadString(
      "assets/openapi/constellation_openapi.yaml",
    );

    final yaml = loadYaml(yamlText);

    //--------------------------------------------------
// Components
//--------------------------------------------------

    final components =
    yaml["components"] as YamlMap?;

    //--------------------------------------------------
    // Read Paths
    //--------------------------------------------------

    final paths = yaml["paths"] as YamlMap;

    final endpoints = <ApiEndpoint>[];

    for (final pathEntry in paths.entries) {

      final path = pathEntry.key.toString();

      final methods = pathEntry.value as YamlMap;

      for (final methodEntry in methods.entries) {

        final method =
        methodEntry.key
            .toString()
            .toUpperCase();

        final api = methodEntry.value as YamlMap;

        //------------------------------------------
        // Tag
        //------------------------------------------

        String tag = "Others";

        if (api["tags"] != null) {

          tag = api["tags"][0].toString();

        }

        //------------------------------------------
        // Summary
        //------------------------------------------

        final summary =
            api["summary"]?.toString() ?? "";

        //------------------------------------------
        // Description
        //------------------------------------------

        final description =
            api["description"]?.toString() ?? "";

        //------------------------------------------
        // Parameters
        //------------------------------------------

        final parameters =
        <ApiParameter>[];

        if (api["parameters"] != null) {

          for (final p
          in api["parameters"]) {

            final parameter =
            p as YamlMap;

            parameters.add(

              ApiParameter(

                name:
                parameter["name"]
                    ?.toString() ??
                    "",

                location:
                parameter["in"]
                    ?.toString() ??
                    "",

                required:
                parameter["required"] ==
                    true,

                description:
                parameter["description"]
                    ?.toString() ??
                    "",

                type: (() {

                  final schema = parameter["schema"];

                  if (schema is YamlMap) {

                    return schema["type"]?.toString() ?? "";

                  }

                  return "";

                })(),

              ),

            );

          }

        }

        //------------------------------------------
// Request Schema
//------------------------------------------

        ApiSchema? requestSchema;

        final requestBody = api["requestBody"];

        if (requestBody is YamlMap) {

          final content = requestBody["content"];

          if (content is YamlMap) {

            final jsonContent = content["application/json"];

            if (jsonContent is YamlMap) {

              requestSchema = _parseSchema(
                jsonContent["schema"],
                components,
              );

            }

          }

        }
//------------------------------------------
// Response Schema
//------------------------------------------

        ApiSchema? responseSchema;

        final responses = api["responses"];

        if (responses is YamlMap) {

          YamlMap? successResponse;

          //--------------------------------------------------
          // Pick the first successful (2xx) response
          //--------------------------------------------------

          for (final entry in responses.entries) {

            final statusCode = entry.key.toString();

            if (statusCode.startsWith("2")) {

              if (entry.value is YamlMap) {

                successResponse = entry.value as YamlMap;

                break;

              }

            }

          }

          //--------------------------------------------------
          // Parse schema
          //--------------------------------------------------

          if (successResponse != null) {

            final content = successResponse["content"];

            if (content is YamlMap) {

              final jsonContent =
              content["application/json"];

              if (jsonContent is YamlMap) {

                responseSchema = _parseSchema(
                  jsonContent["schema"],
                  components,
                );

              }

            }

          }

        }

        //------------------------------------------
        // Create Endpoint
        //------------------------------------------

        endpoints.add(

            ApiEndpoint(

              method: method,

              path: path,

              tag: tag,

              summary: summary,

              description: description,

              parameters: parameters,

              requestSchema: requestSchema,

              responseSchema: responseSchema,

            )

        );


        if (responseSchema != null) {
          print(
            "✔ RESPONSE ${summary} -> ${responseSchema.children.length} root properties",
          );
        }


      }

    }

    //--------------------------------------------------
    // Sort
    //--------------------------------------------------

    endpoints.sort(

          (a, b) {

        if (a.tag == b.tag) {

          return a.summary.compareTo(
              b.summary);

        }

        return a.tag.compareTo(
            b.tag);

      },

    );

    return OpenApiDocument(

      endpoints: endpoints,

    );

  }

  ApiSchema? _parseSchema(
      dynamic schema,
      YamlMap? components,
      ) {

    if (schema == null) {
      return null;
    }

    if (schema is! YamlMap) {
      return null;
    }

    //---------------------------------------
// Resolve $ref
//---------------------------------------

    if (schema.containsKey(r'$ref')) {

      final ref = schema[r'$ref']?.toString();

      if (ref != null) {

        final resolved =
        _resolveRef(ref, components);

        if (resolved != null) {

          return _parseSchema(
            resolved,
            components,
          );

        }

      }

    }

    final type =
        schema["type"]?.toString() ?? "object";

    final children = <ApiSchema>[];

    //---------------------------------------
    // Object
    //---------------------------------------

    if (type == "object") {

      final properties =
      schema["properties"];

      if (properties is YamlMap) {

        final requiredFields =
            (schema["required"] as YamlList?)
                ?.map((e) => e.toString())
                .toSet() ??
                {};

        for (final property
        in properties.entries) {

          final child =
          _parseSchema(
            property.value,
            components,
          );

          if (child != null) {

            print(
              "${property.key} -> ${child.type} -> ${child.children.length}",
            );

            children.add(

              ApiSchema(

                name: property.key.toString(),

                type: child.type,

                description:
                child.description,

                required:
                requiredFields.contains(
                  property.key.toString(),
                ),

                children:
                child.children,

              ),

            );

          }

        }

      }

    }

    //---------------------------------------
    // Array
    //---------------------------------------

    if (type == "array") {

      final item =
      _parseSchema(
        schema["items"],
        components,
      );

      if (item != null) {

        children.add(item);

      }

    }

    return ApiSchema(

      name: "",

      type: type,

      description:
      schema["description"]?.toString(),

      children: children,

    );

  }

  YamlMap? _resolveRef(
      String ref,
      YamlMap? components,
      ) {

    //---------------------------------------
    // Local Component
    //---------------------------------------

    if (ref.startsWith("#/components/")) {

      if (components == null) {
        return null;
      }

      final parts = ref.split("/");

      if (parts.length < 4) {
        return null;
      }

      final section = parts[2];
      final name = parts[3];

      final componentSection = components[section];

      if (componentSection is! YamlMap) {
        return null;
      }

      final schema = componentSection[name];

      if (schema is YamlMap) {
        return schema;
      }

      return null;
    }

    //---------------------------------------
    // External YAML
    //---------------------------------------

    if (ref.endsWith(".yaml")) {

      print("");
      print("======================================");
      print("Missing External Schema");
      print(ref);
      print("======================================");
      print("");

      return null;
    }

    return null;
  }

}
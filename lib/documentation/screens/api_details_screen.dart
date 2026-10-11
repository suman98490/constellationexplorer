import 'package:flutter/material.dart';

import '../../widgets/schema_tree_view.dart';
import '../models/api_endpoint.dart';
import '../widgets/api_header.dart';
import '../widgets/api_overview_card.dart';
import '../widgets/parameters_section.dart';

class ApiDetailsScreen extends StatelessWidget {
  final ApiEndpoint endpoint;

  const ApiDetailsScreen({
    super.key,
    required this.endpoint,
  });

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(value),
          ),
        ],
      ),
    );
  }

  Color _methodColor(String method) {
    switch (method.toUpperCase()) {
      case "GET":
        return Colors.blue;
      case "POST":
        return Colors.green;
      case "PATCH":
        return Colors.orange;
      case "DELETE":
        return Colors.red;
      case "PUT":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {

    print(
      "Request: ${endpoint.requestSchema != null}, "
          "Response: ${endpoint.responseSchema != null}",
    );

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "API Documentation",
        ),

      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(24),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            //--------------------------------------------------
            // Header
            //--------------------------------------------------

            ApiHeader(
              endpoint: endpoint,
            ),

            const SizedBox(height: 20),

            //--------------------------------------------------
            // Overview
            //--------------------------------------------------

            ApiOverviewCard(
              endpoint: endpoint,
            ),

            const SizedBox(height: 30),

            const Text(

              "Parameters",

              style: TextStyle(

                fontSize: 22,

                fontWeight: FontWeight.bold,

              ),

            ),

            const SizedBox(height: 12),

            ParametersSection(

              parameters: endpoint.parameters,

            ),

            const SizedBox(height: 12),



            //--------------------------------------------------
            // Request Structure
            //--------------------------------------------------

            const Text(

              "Request Structure",

              style: TextStyle(

                fontSize: 22,

                fontWeight: FontWeight.bold,

              ),

            ),

            const SizedBox(height: 12),

            Card(

              child: Padding(

                padding:
                const EdgeInsets.all(12),

                child: endpoint.requestSchema == null

                    ? const Padding(

                  padding:
                  EdgeInsets.all(20),

                  child: Text(

                    "No request schema available.",

                  ),

                )

                    : SchemaTreeView(

                  schema:
                  endpoint.requestSchema!,

                ),

              ),

            ),

            const SizedBox(height: 30),

            const Text(
              "Response Structure",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: endpoint.responseSchema == null
                    ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "No response schema available.",
                  ),
                )
                    : SchemaTreeView(
                  schema: endpoint.responseSchema!,
                ),
              ),
            ),
          ],

        ),

      ),

    );

  }
}
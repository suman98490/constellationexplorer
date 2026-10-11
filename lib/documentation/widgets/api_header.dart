import 'package:flutter/material.dart';

import '../models/api_endpoint.dart';

class ApiHeader extends StatelessWidget {

  final ApiEndpoint endpoint;

  const ApiHeader({
    super.key,
    required this.endpoint,
  });

  Color _methodColor(String method) {

    switch (method.toUpperCase()) {

      case "GET":
        return Colors.blue;

      case "POST":
        return Colors.green;

      case "PATCH":
        return Colors.orange;

      case "PUT":
        return Colors.purple;

      case "DELETE":
        return Colors.red;

      default:
        return Colors.grey;

    }

  }

  @override
  Widget build(BuildContext context) {

    return Card(

      elevation: 0,

      margin: EdgeInsets.zero,

      shape: RoundedRectangleBorder(

        borderRadius: BorderRadius.circular(12),

      ),

      child: Padding(

        padding: const EdgeInsets.all(24),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Row(

              children: [

                Container(

                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(

                    color: _methodColor(
                      endpoint.method,
                    ),

                    borderRadius:
                    BorderRadius.circular(30),

                  ),

                  child: Text(

                    endpoint.method,

                    style: const TextStyle(

                      color: Colors.white,

                      fontWeight: FontWeight.bold,

                    ),

                  ),

                ),

                const SizedBox(width: 16),

                Expanded(

                  child: Text(

                    endpoint.summary,

                    style: const TextStyle(

                      fontSize: 28,

                      fontWeight: FontWeight.bold,

                    ),

                  ),

                ),

              ],

            ),

            const SizedBox(height: 20),

            SelectableText(

              endpoint.path,

              style: TextStyle(

                fontSize: 16,

                color: Colors.grey.shade700,

              ),

            ),

            const SizedBox(height: 12),

            Row(

              children: [

                const Icon(
                  Icons.folder,
                  size: 18,
                  color: Colors.blue,
                ),

                const SizedBox(width: 8),

                Text(

                  "${endpoint.tag} API",

                  style: TextStyle(

                    color: Colors.grey.shade700,

                    fontWeight: FontWeight.w600,

                  ),

                ),

              ],

            ),

          ],

        ),

      ),

    );

  }

}
import 'package:flutter/material.dart';

import '../models/api_endpoint.dart';

class ApiOverviewCard extends StatelessWidget {

  final ApiEndpoint endpoint;

  const ApiOverviewCard({
    super.key,
    required this.endpoint,
  });

  Widget _buildItem(
      IconData icon,
      String title,
      String value,
      ) {

    return Expanded(

      child: Container(

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(

          color: Colors.grey.shade50,

          borderRadius: BorderRadius.circular(12),

          border: Border.all(
            color: Colors.grey.shade300,
          ),

        ),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Row(

              children: [

                Icon(
                  icon,
                  size: 18,
                  color: Colors.blue,
                ),

                const SizedBox(width: 8),

                Text(

                  title,

                  style: TextStyle(

                    color: Colors.grey.shade700,

                    fontWeight: FontWeight.w600,

                  ),

                ),

              ],

            ),

            const SizedBox(height: 12),

            SelectableText(

              value,

              style: const TextStyle(

                fontSize: 15,

                fontWeight: FontWeight.w500,

              ),

            ),

          ],

        ),

      ),

    );

  }

  @override
  Widget build(BuildContext context) {

    return Card(

      elevation: 0,

      margin: const EdgeInsets.only(top: 20),

      child: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(

              "Overview",

              style: TextStyle(

                fontSize: 22,

                fontWeight: FontWeight.bold,

              ),

            ),

            const SizedBox(height: 20),

            Row(

              children: [

                _buildItem(

                  Icons.category,

                  "Category",

                  endpoint.tag,

                ),

                const SizedBox(width: 16),

                _buildItem(

                  Icons.http,

                  "HTTP Method",

                  endpoint.method,

                ),

              ],

            ),

            const SizedBox(height: 16),

            Row(

              children: [

                _buildItem(

                  Icons.lock,

                  "Authentication",

                  "OAuth 2.0",

                ),

                const SizedBox(width: 16),

                _buildItem(

                  Icons.route,

                  "API Path",

                  endpoint.path,

                ),

              ],

            ),

            const SizedBox(height: 20),

            const Text(

              "Purpose",

              style: TextStyle(

                fontWeight: FontWeight.bold,

                fontSize: 18,

              ),

            ),

            const SizedBox(height: 10),

            Text(

              endpoint.description.isEmpty
                  ? "No description available."
                  : endpoint.description,

              style: TextStyle(

                color: Colors.grey.shade800,

                height: 1.5,

              ),

            ),

          ],

        ),

      ),

    );

  }

}
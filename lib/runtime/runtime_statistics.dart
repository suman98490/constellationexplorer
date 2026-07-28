import 'package:flutter/material.dart';

class RuntimeStatistics extends StatelessWidget {

  final int totalComponents;
  final int renderedComponents;
  final int pendingComponents;

  const RuntimeStatistics({
    super.key,
    required this.totalComponents,
    required this.renderedComponents,
    required this.pendingComponents,
  });

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [

        Expanded(
          child: _card(
            Icons.widgets_outlined,
            "Components",
            totalComponents.toString(),
            Colors.blue,
          ),
        ),

        const SizedBox(width: 20),

        Expanded(
          child: _card(
            Icons.check_circle_outline,
            "Rendered",
            renderedComponents.toString(),
            Colors.green,
          ),
        ),

        const SizedBox(width: 20),

        Expanded(
          child: _card(
            Icons.pending_actions,
            "Pending",
            pendingComponents.toString(),
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _card(
      IconData icon,
      String title,
      String value,
      Color color,
      ) {

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(.12),
              child: Icon(
                icon,
                color: color,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              value,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
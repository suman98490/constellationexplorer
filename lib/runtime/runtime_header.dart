import 'package:flutter/material.dart';

import '../models/runtime_header_model.dart';

class RuntimeHeader extends StatelessWidget {
  final RuntimeHeaderModel model;

  const RuntimeHeader({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [

                Expanded(
                  child: Text(
                    model.caseTypeName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius:
                    BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      Icon(
                        Icons.circle,
                        size: 10,
                        color: Colors.green.shade700,
                      ),

                      const SizedBox(width: 8),

                      Text(
                        model.status,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              "${model.stageName} • ${model.assignmentName}",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [

                _InfoChip(
                  title: "Stage",
                  value: model.stageName,
                ),

                const SizedBox(width: 15),

                _InfoChip(
                  title: "Case ID",
                  value: model.caseId,
                ),

                const SizedBox(width: 15),

                const _InfoChip(
                  title: "Runtime",
                  value: "Metadata",
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String title;
  final String value;

  const _InfoChip({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffF7F9FC),
        borderRadius:
        BorderRadius.circular(10),
      ),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [

            TextSpan(
              text: "$title: ",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),

            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
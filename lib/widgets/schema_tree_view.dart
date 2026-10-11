import 'package:flutter/material.dart';

import '../documentation/models/api_schema.dart';


class SchemaTreeView extends StatelessWidget {

  final ApiSchema schema;

  const SchemaTreeView({
    super.key,
    required this.schema,
  });

  @override
  Widget build(BuildContext context) {

    return _buildNode(
      schema,
      true,
    );

  }

  Widget _buildNode(
      ApiSchema node,
      bool expanded,
      ) {

    //--------------------------------------------------
    // OBJECT / ARRAY
    //--------------------------------------------------

    if (node.children.isNotEmpty) {

      return ExpansionTile(

        initiallyExpanded: expanded,

        leading: Icon(

          _icon(node.type),

          color: _iconColor(node.type),

        ),

        title: Row(

          children: [

            Expanded(

              child: Text(

                node.name.isEmpty
                    ? "Root"
                    : node.name,

                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),

              ),

            ),

            _typeBadge(node.type),

            if (node.required)
              _requiredBadge(),

          ],

        ),

        children: node.children.map(

              (child) {

            return Padding(

              padding: const EdgeInsets.only(
                left: 20,
              ),

              child: _buildNode(
                child,
                false,
              ),

            );

          },

        ).toList(),

      );

    }

    //--------------------------------------------------
    // Primitive Property
    //--------------------------------------------------

    return Padding(

      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),

      child: Row(

        children: [

          Icon(
            Icons.description_outlined,
            size: 18,
            color: Colors.grey.shade700,
          ),

          const SizedBox(width: 8),

          Expanded(

            child: Text(

              node.name,

              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),

            ),

          ),

          _typeBadge(node.type),

          if (node.required)
            _requiredBadge(),

        ],

      ),

    );

  }

  //--------------------------------------------------
  // Type Badge
  //--------------------------------------------------

  Widget _typeBadge(
      String type,
      ) {

    return Container(

      margin: const EdgeInsets.only(
        left: 10,
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),

      decoration: BoxDecoration(

        color: _badgeColor(type),

        borderRadius:
        BorderRadius.circular(20),

      ),

      child: Text(

        type.toUpperCase(),

        style: const TextStyle(

          color: Colors.white,

          fontSize: 11,

          fontWeight: FontWeight.bold,

        ),

      ),

    );

  }

  //--------------------------------------------------
  // Required Badge
  //--------------------------------------------------

  Widget _requiredBadge() {

    return Container(

      margin: const EdgeInsets.only(
        left: 8,
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),

      decoration: BoxDecoration(

        color: Colors.red,

        borderRadius:
        BorderRadius.circular(20),

      ),

      child: const Text(

        "Required",

        style: TextStyle(

          color: Colors.white,

          fontSize: 10,

          fontWeight: FontWeight.bold,

        ),

      ),

    );

  }

  //--------------------------------------------------
  // Icons
  //--------------------------------------------------

  IconData _icon(
      String type,
      ) {

    switch (type) {

      case "object":
        return Icons.folder_open;

      case "array":
        return Icons.view_list;

      default:
        return Icons.description_outlined;

    }

  }

  //--------------------------------------------------
  // Icon Colors
  //--------------------------------------------------

  Color _iconColor(
      String type,
      ) {

    switch (type) {

      case "object":
        return Colors.blue;

      case "array":
        return Colors.green;

      default:
        return Colors.grey;

    }

  }

  //--------------------------------------------------
  // Badge Colors
  //--------------------------------------------------

  Color _badgeColor(
      String type,
      ) {

    switch (type) {

      case "object":
        return Colors.blue;

      case "array":
        return Colors.green;

      case "string":
        return Colors.deepPurple;

      case "integer":
      case "number":
        return Colors.orange;

      case "boolean":
        return Colors.red;

      default:
        return Colors.grey;

    }

  }

}
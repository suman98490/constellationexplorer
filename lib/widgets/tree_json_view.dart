import 'package:flutter/material.dart';

class TreeJsonView extends StatelessWidget {
  final dynamic data;

  const TreeJsonView({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return _buildNode(
      "Root",
      data,
      true,
    );
  }

  Widget _buildNode(
      String title,
      dynamic value,
      bool expanded,
      ) {
    //------------------------------------------------------
    // MAP
    //------------------------------------------------------

    if (value is Map) {
      final properties = <MapEntry>[];
      final objects = <MapEntry>[];
      final lists = <MapEntry>[];

      for (final entry in value.entries) {
        if (entry.value is List) {
          lists.add(entry);
        } else if (entry.value is Map) {
          objects.add(entry);
        } else {
          properties.add(entry);
        }
      }

      return ExpansionTile(
        initiallyExpanded: expanded,
        leading: const Icon(
          Icons.folder_open,
          color: Colors.blue,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [

          //--------------------------------------------------
          // Properties
          //--------------------------------------------------

          if (properties.isNotEmpty) ...[

            _sectionHeader(
              Icons.text_fields,
              Colors.black87,
              "Properties",
            ),

            ...properties.map(
                  (entry) => _propertyRow(
                entry.key.toString(),
                entry.value,
              ),
            ),
          ],

          //--------------------------------------------------
          // Objects
          //--------------------------------------------------

          if (objects.isNotEmpty) ...[

            _sectionHeader(
              Icons.folder,
              Colors.blue,
              "Pages",
            ),

            ...objects.map(
                  (entry) => Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                ),
                child: _buildNode(
                  entry.key.toString(),
                  entry.value,
                  false,
                ),
              ),
            ),
          ],

          //--------------------------------------------------
          // Lists
          //--------------------------------------------------

          if (lists.isNotEmpty) ...[

            _sectionHeader(
              Icons.view_list,
              Colors.green,
              "Page Lists",
            ),

            ...lists.map(
                  (entry) => Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                ),
                child: _buildNode(
                  entry.key.toString(),
                  entry.value,
                  false,
                ),
              ),
            ),
          ],
        ],
      );
    }

    //------------------------------------------------------
    // LIST
    //------------------------------------------------------

    if (value is List) {
      return ExpansionTile(
        leading: const Icon(
          Icons.view_list,
          color: Colors.green,
        ),
        title: Text(
          "$title (${value.length})",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: List.generate(
          value.length,
              (index) {

            return Padding(
              padding: const EdgeInsets.only(
                left: 20,
              ),
              child: _buildNode(
                "[$index]",
                value[index],
                false,
              ),
            );

          },
        ),
      );
    }

    //------------------------------------------------------
    // Primitive
    //------------------------------------------------------

    return _propertyRow(
      title,
      value,
    );
  }

  //----------------------------------------------------------
  // Property Row
  //----------------------------------------------------------

  Widget _propertyRow(
      String property,
      dynamic value,
      ) {

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),

      child: Row(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Expanded(
            flex: 3,
            child: Text(
              property,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            flex: 5,
            child: SelectableText(
              value?.toString() ?? "",
            ),
          ),
        ],
      ),
    );
  }

  //----------------------------------------------------------
  // Section Header
  //----------------------------------------------------------

  Widget _sectionHeader(
      IconData icon,
      Color color,
      String title,
      ) {

    return Padding(
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
        top: 12,
        bottom: 6,
      ),

      child: Row(

        children: [

          Icon(
            icon,
            size: 18,
            color: color,
          ),

          const SizedBox(width: 8),

          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Divider(
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
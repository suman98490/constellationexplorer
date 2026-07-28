import 'package:flutter/material.dart';

import '../models/pega_component.dart';
import '../runtime/data_source_cache.dart';

class ReferenceSelectionDialog extends StatefulWidget {

  final PegaComponent component;

  final List<Map<String, dynamic>> initialSelection;

  const ReferenceSelectionDialog({
    super.key,
    required this.component,
    this.initialSelection = const [],
  });

  @override
  State<ReferenceSelectionDialog> createState() =>
      _ReferenceSelectionDialogState();
}

class _ReferenceSelectionDialogState
    extends State<ReferenceSelectionDialog> {

  late final List<Map<String, dynamic>> rows;

  final Set<String> selectedIds = {};

  @override
  void initState() {
    super.initState();

    rows =
        DataSourceCache.get<List<Map<String, dynamic>>>(
          widget.component.datasource!,
        ) ??
            [];

    for (final row in widget.initialSelection) {
      selectedIds.add(row["pyGUID"]);
    }
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      title: Text(
        "Select ${widget.component.label}",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

      content: SizedBox(
        width: 900,
        height: 400,

        child: SingleChildScrollView(

          child: DataTable(

            showCheckboxColumn: true,

            headingRowColor:
            WidgetStateProperty.all(
              Colors.grey.shade100,
            ),

            columns: widget.component.selectFields
                .map(

                  (field) => DataColumn(

                label: Text(

                  field,

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
                .toList(),

            rows: rows.map(

                  (row) {

                final id =
                row["pyGUID"].toString();

                return DataRow(

                  selected:
                  selectedIds.contains(id),

                  onSelectChanged: (selected) {

                    setState(() {

                      if (selected == true) {

                        selectedIds.add(id);

                      } else {

                        selectedIds.remove(id);

                      }

                    });

                  },

                  cells: widget.component.selectFields
                      .map(

                        (field) => DataCell(

                      Text(
                        row[field]?.toString() ?? "",
                      ),
                    ),
                  )
                      .toList(),
                );
              },
            ).toList(),
          ),
        ),
      ),

      actions: [

        TextButton(

          onPressed: () {

            Navigator.pop(context);

          },

          child: const Text("Cancel"),
        ),

        ElevatedButton(

          onPressed: () {

            final selectedRows =
            rows.where(

                  (row) => selectedIds.contains(
                row["pyGUID"],
              ),

            ).toList();

            Navigator.pop(
              context,
              selectedRows,
            );

          },

          child: Text(
            "Select (${selectedIds.length})",
          ),
        ),
      ],
    );
  }
}
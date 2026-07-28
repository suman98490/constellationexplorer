import 'package:flutter/material.dart';

import '../models/pega_component.dart';
import '../runtime/runtime_state.dart';
import 'reference_selection_dialog.dart';

class PegaSimpleTableSelect extends StatefulWidget {
  final PegaComponent component;

  const PegaSimpleTableSelect({
    super.key,
    required this.component,
  });

  @override
  State<PegaSimpleTableSelect> createState() =>
      _PegaSimpleTableSelectState();
}

class _PegaSimpleTableSelectState
    extends State<PegaSimpleTableSelect> {

  List<Map<String, dynamic>> selectedRows = [];

  @override
  Widget build(BuildContext context) {
    debugPrint(
        "Datasource : ${widget.component.datasource}");

    debugPrint(
        "Display Field : ${widget.component.displayField}");

    debugPrint(
        "Select Fields : ${widget.component.selectFields}");


    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(
            widget.component.label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            width: double.infinity,

            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(

              border: Border.all(
                color: Colors.grey.shade400,
              ),

              borderRadius:
              BorderRadius.circular(10),

              color: Colors.white,
            ),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                if (selectedRows.isEmpty)

                  Padding(
                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 8,
                    ),

                    child: Text(
                      "No ${widget.component.label} selected",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),



                Wrap(

                  spacing: 8,
                  runSpacing: 8,

                  children: [

                    ...selectedRows.map(

                          (row) {

                        return InputChip(

                          avatar: CircleAvatar(
                            radius: 12,

                            child: Text(

                              row[
                              widget.component.displayField]
                                  .toString()[0],

                              style: const TextStyle(
                                fontSize: 11,
                              ),
                            ),
                          ),

                          label: Text(

                            row[
                            widget.component.displayField]
                                .toString(),

                          ),

                          onDeleted: () {

                            setState(() {

                              selectedRows.remove(
                                row,
                              );

                            });

                            RuntimeState.instance.setValue(
                              widget.component.binding,
                              selectedRows,
                            );
                          },
                        );
                      },
                    ),

                    ActionChip(

                      avatar: const Icon(
                        Icons.add,
                        size: 18,
                      ),

                      label: Text(

                        selectedRows.isEmpty
                            ? "Select"
                            : "Add",

                      ),

                      onPressed: () async {

                        final result =
                        await showDialog<
                            List<Map<String, dynamic>>>(

                          context: context,

                          builder: (_) {

                            return ReferenceSelectionDialog(

                              component:
                              widget.component,

                              initialSelection:
                              selectedRows,

                            );

                          },
                        );

                        if (result == null) {
                          return;
                        }

                        setState(() {

                          selectedRows = result;

                        });

                        RuntimeState.instance.setValue(

                          widget.component.binding,

                          result,

                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
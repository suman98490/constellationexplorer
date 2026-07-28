import 'package:flutter/material.dart';

import '../models/pega_component.dart';
import '../runtime/data_source_cache.dart';
import '../runtime/data_view_executor.dart';
import '../runtime/runtime_state.dart';

class PegaAutoComplete extends StatefulWidget {
  final PegaComponent component;

  const PegaAutoComplete({
    super.key,
    required this.component,
  });

  @override
  State<PegaAutoComplete> createState() =>
      _PegaAutoCompleteState();
}

class _PegaAutoCompleteState
    extends State<PegaAutoComplete> {

  Map<String, dynamic>? selectedRow;

  late Future<void> loadFuture;

  Future<void> _loadData() async {

    final cached =
    DataSourceCache.get<List<Map<String, dynamic>>>(
      widget.component.datasource!,
    );

    if (cached != null) {

      debugPrint(
        "Using cached ${widget.component.datasource} : ${cached.length}",
      );

      return;
    }

    debugPrint(
      "Loading ${widget.component.datasource}...",
    );

    await DataViewExecutor().loadAutoComplete(
      widget.component,
    );

    final rows =
    DataSourceCache.get<List<Map<String, dynamic>>>(
      widget.component.datasource!,
    );

    debugPrint(
      "Cached ${widget.component.datasource} : ${rows?.length}",
    );
  }

  @override
  void initState() {
    super.initState();

    loadFuture = _loadData();
  }

  @override
  Widget build(BuildContext context) {

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

          FutureBuilder(

            future: loadFuture,

            builder: (context, snapshot) {

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {

                return const TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    hintText: "Loading...",
                  ),
                );
              }

              final rows =
                  DataSourceCache.get<
                      List<Map<String, dynamic>>>(
                    widget.component.datasource!,
                  ) ??
                      [];

              return Autocomplete<Map<String, dynamic>>(

                displayStringForOption: (row) {

                  return row[
                  widget.component.displayField]
                      ?.toString() ??
                      "";

                },

                optionsBuilder:
                    (textEditingValue) {

                  if (textEditingValue.text.isEmpty) {
                    return rows;
                  }

                  return rows.where(

                        (row) {

                      final value = row[
                      widget.component
                          .displayField]
                          ?.toString()
                          .toLowerCase();

                      return value?.contains(
                          textEditingValue.text
                              .toLowerCase()) ??
                          false;

                    },

                  );
                },

                onSelected: (row) {

                  setState(() {

                    selectedRow = row;

                  });

                  RuntimeState.instance.setValue(
                    widget.component.binding,
                    row,
                  );

                  debugPrint(
                    RuntimeState.instance.values
                        .toString(),
                  );
                },

                fieldViewBuilder: (

                    context,
                    controller,
                    focusNode,
                    onSubmitted,

                    ) {

                  if (selectedRow != null &&
                      controller.text.isEmpty) {

                    controller.text = selectedRow![
                    widget.component
                        .displayField]
                        .toString();

                  }

                  return TextField(

                    controller: controller,

                    focusNode: focusNode,

                    decoration: InputDecoration(

                      prefixIcon:
                      const Icon(Icons.search),

                      suffixIcon: const Icon(
                          Icons.arrow_drop_down),

                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(
                            10),
                      ),
                    ),
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }
}
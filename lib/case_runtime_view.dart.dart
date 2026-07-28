import 'package:constellation_explorer/runtime/data_source_cache.dart';
import 'package:constellation_explorer/runtime/data_view_executor.dart';
import 'package:constellation_explorer/runtime/patch_payload_builder.dart';
import 'package:constellation_explorer/runtime/runtime_context.dart';
import 'package:constellation_explorer/runtime/runtime_header.dart';
import 'package:constellation_explorer/runtime/runtime_loader.dart';
import 'package:constellation_explorer/runtime/runtime_statistics.dart';
import 'package:constellation_explorer/services/assignment_service.dart';
import 'package:constellation_explorer/services/data_view_service.dart';
import 'package:constellation_explorer/widgets/pega_auto_complete.dart';
import 'package:constellation_explorer/widgets/pega_simple_table_select.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../engine/metadata_parser.dart';
import '../models/pega_component.dart';
import '../services/case_service.dart';
import '../widgets/pega_text_input.dart';
import 'models/contact.dart';
import 'models/runtime_header_model.dart';

class CaseRuntimeView  extends StatefulWidget {
  final String caseTypeId;
  const CaseRuntimeView ({
    super.key,
    required this.caseTypeId

  });

  @override
  State<CaseRuntimeView> createState() =>
      _CaseRuntimeViewState();
}

class _CaseRuntimeViewState extends State<CaseRuntimeView> {
  bool submitting = false;

  List<PegaComponent> components = [];

  bool loading = true;



  @override
  void initState() {
    super.initState();
    loadComponents();
  }

  Future<void> loadComponents() async {

    final response =
    await CaseService().createCase(
      caseTypeId:
      widget.caseTypeId,
    );

    final parsedComponents =
    await RuntimeLoader()
        .load(response);

    await _preloadDataSources(
        parsedComponents);

    setState(() {

      components = parsedComponents;

      loading = false;

    });
  }

  Future<void> _preloadDataSources(
      List<PegaComponent> components) async {

    final futures = <Future>[];

    for (final component in components) {

      // Ignore components without datasource
      if (component.datasource == null) {
        continue;
      }

      // Skip lazy-loaded components
      if (component.deferDatasource) {
        debugPrint(
          "Skipping ${component.datasource} (Deferred)",
        );
        continue;
      }

      debugPrint(
        "Preloading ${component.datasource}",
      );

      final executor = DataViewExecutor();

      futures.add(
        executor.preview(component).then((_) {
          return executor.load(component);
        }),
      );
    }

    await Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: [

        // MAIN UI
        Container(
          color: const Color(0xffF4F6FA),
          padding: const EdgeInsets.all(30),
          child: ListView(
            children: [

              RuntimeHeader(
                model: RuntimeContext.instance.header!,
              ),

              const SizedBox(height: 15),

              Card(
                elevation: 1,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [

                    // HEADER
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 18,
                      ),
                      child: Row(
                        children: [

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [

                                Text(
                                  RuntimeContext.instance.header!.assignmentTitle,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  RuntimeContext.instance.header!.viewName,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${components.length} Fields",
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    // FORM
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: LayoutBuilder(
                        builder: (context, constraints) {

                          final fieldWidth =
                              (constraints.maxWidth - 24) / 2;

                          return Wrap(
                            spacing: 24,
                            runSpacing: 12,
                            children: components.map((component) {

                              switch (component.type) {

                                case "TextInput":

                                  return SizedBox(
                                    width: fieldWidth,
                                    child: PegaTextInput(
                                      component: component,
                                    ),
                                  );

                                case "AutoComplete":

                                  return SizedBox(
                                    width: fieldWidth,
                                    child: PegaAutoComplete(
                                      component: component,
                                    ),
                                  );

                                case "SimpleTableSelect":

                                  return SizedBox(
                                    width: fieldWidth,
                                    child: PegaSimpleTableSelect(
                                      component: component,
                                    ),
                                  );

                                default:

                                  return const SizedBox();
                              }

                            }).toList(),
                          );
                        },
                      ),
                    ),

                    const Divider(height: 1),

                    // FOOTER
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [

                          Text(
                            "${components.length} fields loaded from Constellation",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),

                          const Spacer(),

                          OutlinedButton(
                            onPressed: () {},
                            child: const Text("Cancel"),
                          ),

                          const SizedBox(width: 12),

                          FilledButton.tonal(
                            onPressed: () {},
                            child: const Text("Save Draft"),
                          ),

                          const SizedBox(width: 12),

                          ElevatedButton.icon(
                            onPressed: submitting
                                ? null
                                : () async {

                              setState(() {
                                submitting = true;
                              });

                              try {

                                final response =
                                await AssignmentService()
                                    .submitAssignment(

                                  assignmentId: RuntimeContext
                                      .instance
                                      .assignmentId!,

                                  actionName: RuntimeContext
                                      .instance
                                      .actionName!,

                                  ifMatch: RuntimeContext
                                      .instance
                                      .ifMatch!,
                                );

                                final newComponents =
                                await RuntimeLoader()
                                    .load(response);

                                await _preloadDataSources(
                                  newComponents,
                                );

                                setState(() {

                                  components = newComponents;

                                });

                              } catch (e, stackTrace) {

                                debugPrint("PATCH FAILED");
                                debugPrint(e.toString());
                                debugPrint(stackTrace.toString());

                              } finally {

                                if (mounted) {

                                  setState(() {

                                    submitting = false;

                                  });

                                }

                              }

                            },
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text("Next"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // LOADING OVERLAY
        if (submitting)
          Positioned.fill(
            child: AbsorbPointer(
              child: Container(
                color: Colors.black38,
                child: Center(
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 35,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          const SizedBox(
                            width: 45,
                            height: 45,
                            child: CircularProgressIndicator(),
                          ),

                          const SizedBox(height: 24),

                          const Text(
                            "Loading next assignment...",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Please wait while the next assignment is being prepared.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );  }
}
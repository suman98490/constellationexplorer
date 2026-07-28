import 'package:flutter/material.dart';

import '../models/pega_component.dart';
import '../runtime/runtime_state.dart';

class PegaTextInput extends StatefulWidget {
  final PegaComponent component;

  const PegaTextInput({
    super.key,
    required this.component,
  });

  @override
  State<PegaTextInput> createState() =>
      _PegaTextInputState();
}

class _PegaTextInputState
    extends State<PegaTextInput> {

  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController();

    // Restore previously entered value if available
    final existingValue =
    RuntimeState.instance.getValue<String>(
      widget.component.binding,
    );

    if (existingValue != null) {
      controller.text = existingValue;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          Text(
            widget.component.label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          TextField(

            controller: controller,

            readOnly:
            widget.component.readOnly,

            onChanged: (value) {

              RuntimeState.instance.setValue(
                widget.component.binding,
                value,
              );

              // Temporary debug
              debugPrint(
                RuntimeState.instance.values
                    .toString(),
              );
            },

            decoration: InputDecoration(

              hintText:
              "Enter ${widget.component.label}",

              filled: true,

              fillColor: Colors.white,

              contentPadding:
              const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),

              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(10),
              ),

              enabledBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),

              focusedBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(10),
                borderSide:
                const BorderSide(
                  color: Colors.blue,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
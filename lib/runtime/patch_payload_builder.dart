import 'package:constellation_explorer/runtime/runtime_context.dart';

import '../models/address.dart';
import '../models/contact.dart';
import 'runtime_state.dart';

class PatchPayloadBuilder {

  Map<String, dynamic> build() {

    final content = <String, dynamic>{};

    final pageInstructions = <Map<String, dynamic>>[];

    for (final component
    in RuntimeContext.instance.components) {

      final binding = component.binding;

      final value =
      RuntimeState.instance.getValue(binding);

      if (value == null) {
        continue;
      }

      final property =
      binding.replaceFirst(".", "");

      //--------------------------------------------------
      // Contacts
      //--------------------------------------------------

      if (value is List<Contact>) {

        int index = 1;

        for (final contact in value) {

          pageInstructions.add({

            "target": binding,

            "content": {
              "pyGUID": contact.id,
            },

            "listIndex": index++,

            "instruction": "INSERT",
          });
        }

        continue;
      }

      //--------------------------------------------------
      // Address
      //--------------------------------------------------

      if (value is Address) {

        final pageName =
        property.replaceAll(
          ".pyGUID",
          "",
        );

        content[pageName] = {

          "pyGUID": value.id,
        };

        continue;
      }

      //--------------------------------------------------
      // Scalar
      //--------------------------------------------------

      content[property] = value;
    }

    return {

      "content": content,

      "pageInstructions":
      pageInstructions,
    };
  }
}
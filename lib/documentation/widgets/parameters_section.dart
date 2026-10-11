import 'package:flutter/material.dart';

import '../models/api_parameter.dart';

class ParametersSection extends StatelessWidget {

  final List<ApiParameter> parameters;

  const ParametersSection({
    super.key,
    required this.parameters,
  });

  @override
  Widget build(BuildContext context) {

    if (parameters.isEmpty) {

      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "No parameters available.",
          ),
        ),
      );

    }

    return Card(

      child: Padding(

        padding: const EdgeInsets.all(16),

        child: SingleChildScrollView(

          scrollDirection: Axis.horizontal,

          child: DataTable(

            columnSpacing: 30,

            columns: const [

              DataColumn(
                label: Text("Name"),
              ),

              DataColumn(
                label: Text("In"),
              ),

              DataColumn(
                label: Text("Type"),
              ),

              DataColumn(
                label: Text("Required"),
              ),

            ],

            rows: parameters.map(

                  (parameter) {

                return DataRow(

                  cells: [

                    DataCell(
                      Text(parameter.name),
                    ),

                    DataCell(
                      Text(parameter.location),
                    ),

                    DataCell(
                      Text(parameter.type),
                    ),

                    DataCell(

                      Icon(

                        parameter.required
                            ? Icons.check_circle
                            : Icons.remove_circle_outline,

                        color: parameter.required
                            ? Colors.green
                            : Colors.grey,

                      ),

                    ),

                  ],

                );

              },

            ).toList(),

          ),

        ),

      ),

    );

  }

}
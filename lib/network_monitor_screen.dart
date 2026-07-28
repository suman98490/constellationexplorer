import 'dart:convert';

import 'package:flutter/material.dart';

import '../services/network_logger.dart';

class NetworkMonitorScreen extends StatefulWidget {
  const NetworkMonitorScreen({super.key});

  @override
  State<NetworkMonitorScreen> createState() =>
      _NetworkMonitorScreenState();
}

class _NetworkMonitorScreenState
    extends State<NetworkMonitorScreen> {

  @override
  Widget build(BuildContext context) {

    final logs = NetworkLogger.logs;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Network Monitor",
        ),
        actions: [

          IconButton(
            onPressed: () {

              setState(() {});

            },
            icon: const Icon(
              Icons.refresh,
            ),
          ),

          IconButton(
            onPressed: () {

              NetworkLogger.clear();

              setState(() {});

            },
            icon: const Icon(
              Icons.delete,
            ),
          ),

        ],
      ),

      body: logs.isEmpty
          ? const Center(
        child: Text(
          "No API Calls Yet",
        ),
      )
          : ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {

          final log = logs[index];

          return Card(
            margin:
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),

            child: ListTile(

              leading: Icon(
                log.success
                    ? Icons.check_circle
                    : Icons.error,
                color: log.success
                    ? Colors.green
                    : Colors.red,
              ),

              title: Text(
                log.description,
                style: const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              subtitle: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 6),

                  Text(log.method),

                  Text(log.endpoint),

                  Text(
                    "${log.statusCode} • ${log.durationText}",
                  ),
                ],
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),

              onTap: () {

                showDialog(

                  context: context,

                  builder: (_) {

                    return AlertDialog(

                      title: Text(
                        log.description,
                      ),

                      content: SizedBox(

                        width: 700,

                        child:
                        SingleChildScrollView(

                          child: SelectableText(

                            const JsonEncoder
                                .withIndent(
                                "  ")
                                .convert(
                              {
                                "Method":
                                log.method,

                                "Endpoint":
                                log.endpoint,

                                "Status":
                                log.statusCode,

                                "Duration":
                                log.durationText,

                                "Request":
                                log.request,

                                "Response":
                                log.response,
                              },
                            ),

                          ),

                        ),

                      ),

                      actions: [

                        TextButton(

                          onPressed: () {

                            Navigator.pop(
                                context);

                          },

                          child: const Text(
                            "Close",
                          ),

                        ),

                      ],

                    );

                  },

                );

              },

            ),

          );

        },

      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {});
        },
        icon: const Icon(Icons.refresh),
        label: const Text("Refresh"),
      ),

    );

  }
}
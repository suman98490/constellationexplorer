import 'dart:convert';

import 'package:constellation_explorer/widgets/tree_json_view.dart';
import 'package:flutter/material.dart';

import '../services/network_logger.dart';
import 'export/html/html_downloader.dart';
import 'export/html/html_session_exporter.dart';

class NetworkMonitorScreen extends StatefulWidget {
  const NetworkMonitorScreen({super.key});

  @override
  State<NetworkMonitorScreen> createState() =>
      _NetworkMonitorScreenState();
}

class _NetworkMonitorScreenState
    extends State<NetworkMonitorScreen> {

  // ---------------------------------------------------------
  // INFO ROW
  // ---------------------------------------------------------

  Widget _infoRow(
      String label,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // HEADER VALUE
  // ---------------------------------------------------------

  String _headerValueToString(dynamic value) {
    if (value is List) {
      return value.join(", ");
    }

    return value?.toString() ?? "";
  }

  // ---------------------------------------------------------
  // HEADER ICON
  // ---------------------------------------------------------

  IconData _headerIcon(String name) {
    final lowerName = name.toLowerCase();

    if (lowerName == "etag") {
      return Icons.fingerprint;
    }

    if (lowerName == "if-match") {
      return Icons.lock_open;
    }

    if (lowerName == "content-type") {
      return Icons.description;
    }

    if (lowerName == "authorization") {
      return Icons.lock;
    }

    if (lowerName == "accept") {
      return Icons.check_circle_outline;
    }

    return Icons.label_outline;
  }

  // ---------------------------------------------------------
  // HEADER BADGE
  // ---------------------------------------------------------

  Widget _headerBadge(String name) {
    final lowerName = name.toLowerCase();

    if (lowerName == "etag") {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.green.shade200,
          ),
        ),
        child: Text(
          "ETAG",
          style: TextStyle(
            color: Colors.green.shade700,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (lowerName == "if-match") {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.orange.shade200,
          ),
        ),
        child: Text(
          "IF-MATCH",
          style: TextStyle(
            color: Colors.orange.shade800,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ---------------------------------------------------------
  // HEADERS VIEW
  // ---------------------------------------------------------

  Widget _buildHeadersView(
      Map<String, dynamic> headers,
      ) {
    if (headers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.http,
              size: 50,
              color: Colors.grey,
            ),
            SizedBox(height: 12),
            Text(
              "No headers available",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    final entries = headers.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];

        final name = entry.key;
        final value = _headerValueToString(entry.value);

        final lowerName = name.toLowerCase();

        final isEtag = lowerName == "etag";
        final isIfMatch = lowerName == "if-match";

        return Card(
          margin: const EdgeInsets.only(
            bottom: 10,
          ),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isEtag
                        ? Colors.green.shade50
                        : isIfMatch
                        ? Colors.orange.shade50
                        : Colors.blue.shade50,
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _headerIcon(name),
                    size: 20,
                    color: isEtag
                        ? Colors.green
                        : isIfMatch
                        ? Colors.orange
                        : Colors.blue,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  flex: 2,
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SelectableText(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      _headerBadge(name),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  flex: 4,
                  child: SelectableText(
                    value,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: isEtag
                          ? Colors.green.shade800
                          : isIfMatch
                          ? Colors.orange.shade800
                          : Colors.black87,
                      fontWeight: isEtag || isIfMatch
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------
  // EMPTY JSON VIEW
  // ---------------------------------------------------------

  Widget _buildJsonView(dynamic data) {
    if (data == null) {
      return const Center(
        child: Text(
          "No data available",
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        const JsonEncoder
            .withIndent("  ")
            .convert(data),
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final logs = NetworkLogger.logs;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Network Monitor",
        ),
        actions: [

          // REFRESH
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(
              Icons.refresh,
            ),
          ),

          // CLEAR
          IconButton(
            onPressed: () {
              NetworkLogger.clear();

              setState(() {});
            },
            icon: const Icon(
              Icons.delete,
            ),
          ),

          // EXPORT
          IconButton(
            tooltip: "Export Constellation Session",
            icon: const Icon(
              Icons.download,
            ),
            onPressed: () {

              final html =
              HtmlSessionExporter().generate(
                NetworkLogger.logs,
              );

              HtmlDownloader.download(
                "constellation_session.html",
                html,
              );

              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    "Session exported successfully.",
                  ),
                ),
              );
            },
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

              // STATUS ICON
              leading: Icon(
                log.success
                    ? Icons.check_circle
                    : Icons.error,
                color: log.success
                    ? Colors.green
                    : Colors.red,
              ),

              // DESCRIPTION
              title: Text(
                log.description,
                style: const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              // API DETAILS
              subtitle: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 6),

                  Text(
                    log.method,
                    style: const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  Text(
                    log.endpoint,
                  ),

                  Text(
                    "${log.statusCode} • ${log.durationText}",
                  ),
                ],
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),

              // OPEN DETAILS
              onTap: () {

                showDialog(
                  context: context,
                  builder: (_) {

                    return AlertDialog(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              log.description,
                            ),
                          ),

                          Container(
                            padding:
                            const EdgeInsets
                                .symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration:
                            BoxDecoration(
                              color: log.success
                                  ? Colors.green
                                  .shade50
                                  : Colors.red
                                  .shade50,
                              borderRadius:
                              BorderRadius
                                  .circular(
                                20,
                              ),
                            ),
                            child: Text(
                              log.statusText,
                              style: TextStyle(
                                color: log.success
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight:
                                FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      content: SizedBox(
                        width: 950,
                        height: 700,

                        child:
                        DefaultTabController(
                          length: 7,

                          child: Column(
                            children: [

                              // ------------------------------------------------
                              // TABS
                              // ------------------------------------------------

                              const TabBar(
                                isScrollable: true,
                                tabs: [

                                  Tab(
                                    icon: Icon(
                                      Icons.info_outline,
                                      size: 18,
                                    ),
                                    text: "General",
                                  ),

                                  Tab(
                                    icon: Icon(
                                      Icons.upload,
                                      size: 18,
                                    ),
                                    text: "Request",
                                  ),

                                  Tab(
                                    icon: Icon(
                                      Icons.download,
                                      size: 18,
                                    ),
                                    text: "Response",
                                  ),

                                  Tab(
                                    icon: Icon(
                                      Icons.http,
                                      size: 18,
                                    ),
                                    text:
                                    "Request Headers",
                                  ),

                                  Tab(
                                    icon: Icon(
                                      Icons.http,
                                      size: 18,
                                    ),
                                    text:
                                    "Response Headers",
                                  ),

                                  Tab(
                                    icon: Icon(
                                      Icons.data_object,
                                      size: 18,
                                    ),
                                    text:
                                    "JSON Request",
                                  ),

                                  Tab(
                                    icon: Icon(
                                      Icons.data_object,
                                      size: 18,
                                    ),
                                    text:
                                    "JSON Response",
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height: 12,
                              ),

                              // ------------------------------------------------
                              // TAB CONTENT
                              // ------------------------------------------------

                              Expanded(
                                child:
                                TabBarView(
                                  children: [

                                    // ==========================================
                                    // GENERAL
                                    // ==========================================

                                    ListView(
                                      padding:
                                      const EdgeInsets
                                          .all(16),
                                      children: [

                                        _infoRow(
                                          "Method",
                                          log.method,
                                        ),

                                        _infoRow(
                                          "Endpoint",
                                          log.endpoint,
                                        ),

                                        _infoRow(
                                          "Status",
                                          log.statusCode
                                              .toString(),
                                        ),

                                        _infoRow(
                                          "Status Text",
                                          log.statusText,
                                        ),

                                        _infoRow(
                                          "Duration",
                                          log.durationText,
                                        ),

                                        _infoRow(
                                          "Request Time",
                                          log.requestTime
                                              .toString(),
                                        ),

                                        if (log.responseTime !=
                                            null)
                                          _infoRow(
                                            "Response Time",
                                            log.responseTime!
                                                .toString(),
                                          ),

                                        if (log.error !=
                                            null)
                                          _infoRow(
                                            "Error",
                                            log.error!,
                                          ),
                                      ],
                                    ),

                                    // ==========================================
                                    // REQUEST TREE
                                    // ==========================================

                                    SingleChildScrollView(
                                      child:
                                      TreeJsonView(
                                        data: log.request,
                                      ),
                                    ),

                                    // ==========================================
                                    // RESPONSE TREE
                                    // ==========================================

                                    SingleChildScrollView(
                                      child:
                                      TreeJsonView(
                                        data: log.response,
                                      ),
                                    ),

                                    // ==========================================
                                    // REQUEST HEADERS
                                    // ==========================================

                                    _buildHeadersView(
                                      log.requestHeaders,
                                    ),

                                    // ==========================================
                                    // RESPONSE HEADERS
                                    // ==========================================

                                    _buildHeadersView(
                                      log.responseHeaders,
                                    ),

                                    // ==========================================
                                    // JSON REQUEST
                                    // ==========================================

                                    _buildJsonView(
                                      log.request,
                                    ),

                                    // ==========================================
                                    // JSON RESPONSE
                                    // ==========================================

                                    _buildJsonView(
                                      log.response,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ------------------------------------------------
                      // CLOSE
                      // ------------------------------------------------

                      actions: [

                        TextButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                            );
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

      // ---------------------------------------------------------
      // REFRESH BUTTON
      // ---------------------------------------------------------

      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: () {
          setState(() {});
        },
        icon: const Icon(
          Icons.refresh,
        ),
        label: const Text(
          "Refresh",
        ),
      ),
    );
  }
}
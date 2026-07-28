import 'package:constellation_explorer/case_runtime_view.dart.dart';
import '../engine/case_type_parser.dart';
import '../models/available_case_type.dart';
import '../services/data_view_service.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../services/session_manager.dart';
import 'models/portal_page.dart';
import 'network_monitor_screen.dart';

enum DashboardPage {
  home,
  runtime,
  dataViews,
  apiExplorer,
  networkMonitor,
  settings,
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  List<AvailableCaseType> caseTypes = [];

  String? selectedCaseType;

  bool loading = true;

  String? error;

  DashboardPage currentPage = DashboardPage.home;

  @override
  void initState() {
    super.initState();

    loadCaseTypes();
  }

  Future<void> loadCaseTypes() async {

    try {

      final response =
      await DataViewService().getDataView(
        dataViewName:
        "D_pxAvailableCaseTypesForPortal",
      );

      caseTypes = CaseTypeParser.parse(
        response.data,
      );

      loading = false;

      if (mounted) {
        setState(() {});
      }

    } catch (e) {

      loading = false;

      error = e.toString();

      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget _summaryRow(
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ),

          const Text(
            ": ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {

    switch (currentPage) {

      case DashboardPage.runtime:
        return CaseRuntimeView(
          caseTypeId: selectedCaseType!,
        );

      case DashboardPage.networkMonitor:
        return const NetworkMonitorScreen();

      default:
        return _buildHome();
    }
  }

  Widget _buildHome() {

    final token = SessionManager.token!;
    final payload = JwtDecoder.decode(
      token.accessToken,
    );

    return Padding(
      padding: const EdgeInsets.all(30),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            const Text(
              "Home",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [

                _infoCard(
                  "Environment",
                  SessionManager.baseUrl ?? "",
                ),

                _infoCard(
                  "Application",
                  payload["app_name"] ?? "",
                ),

                _infoCard(
                  "Operator",
                  payload["sub"] ?? "",
                ),

                _infoCard(
                  "Token Type",
                  token.tokenType,
                ),

                _infoCard(
                  "Token Status",
                  token.isExpired
                      ? "Expired"
                      : "Valid",
                ),

                _infoCard(
                  "Expires In",
                  "${token.remainingTime.inMinutes} Minutes",
                ),
              ],
            ),

            const SizedBox(height: 40),

            const Text(
              "Portal Summary",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Card(
              child: Padding(
                padding:
                const EdgeInsets.all(20),
                child: loading
                    ? const Padding(
                  padding:
                  EdgeInsets.all(30),
                  child: Center(
                    child:
                    CircularProgressIndicator(),
                  ),
                )
                    : error != null
                    ? SelectableText(error!)
                    : Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [

                    _summaryRow(
                      "Data View",
                      "D_pxAvailableCaseTypesForPortal",
                    ),

                    _summaryRow(
                      "Portal Loaded",
                      "Yes",
                    ),

                    _summaryRow(
                      "Available Case Types",
                      caseTypes.length.toString(),
                    ),

                    _summaryRow(
                      "Network Requests",
                      "1",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final token = SessionManager.token!;
    final payload = JwtDecoder.decode(token.accessToken);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // LEFT MENU
                Container(
                  width: 260,
                  color: Colors.blueGrey.shade900,
                  child: Column(
                    children: [

                      const SizedBox(height: 25),

                      const Text(
                        "Constellation\nExplorer",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 30),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [

                              _menu(
                                Icons.home,
                                "Home",
                                DashboardPage.home,
                              ),

                              ExpansionTile(
                                initiallyExpanded: true,
                                leading: const Icon(
                                  Icons.workspaces_outline,
                                  color: Colors.white,
                                ),
                                title: const Text(
                                  "Create Case",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                collapsedIconColor: Colors.white,
                                iconColor: Colors.white,
                                children: caseTypes
                                    .map(
                                      (caseType) => ListTile(
                                    dense: true,
                                    contentPadding:
                                    const EdgeInsets.only(left: 45),
                                    leading: const Icon(
                                      Icons.circle,
                                      size: 8,
                                      color: Colors.white70,
                                    ),
                                    title: Text(
                                      caseType.label,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                          onTap: () {

                                            selectedCaseType =
                                                caseType.className;

                                            setState(() {
                                              currentPage =
                                                  DashboardPage.runtime;
                                            });

                                          }
                                  ),
                                )
                                    .toList(),
                              ),

                              _menu(
                                Icons.table_chart_outlined,
                                "Data Views",
                                DashboardPage.dataViews,
                              ),
                              _menu(
                                Icons.api,
                                "API Explorer",
                                DashboardPage.apiExplorer,
                              ),

                              ListTile(
                                leading: const Icon(
                                  Icons.monitor,
                                  color: Colors.white,
                                ),
                                title: const Text(
                                  "Network Monitor",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const NetworkMonitorScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Divider(
                        color: Colors.white24,
                      ),

                      _menu(
                        Icons.settings,
                        "Settings",
                        DashboardPage.settings,
                      ),

                      const SizedBox(height: 15),
                    ],
                  ),
                ),

                // RIGHT CONTENT
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),

          // STATUS BAR
          Container(
            color: Colors.blueGrey.shade900,
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.cloud_done,
                  color: Colors.green,
                  size: 18,
                ),
                const SizedBox(width: 8),

                const Text(
                  "Connected",
                  style: TextStyle(color: Colors.white),
                ),

                const SizedBox(width: 25),

                Text(
                  payload["app_name"] ?? "",
                  style: const TextStyle(color: Colors.white),
                ),

                const SizedBox(width: 25),

                Text(
                  token.isExpired ? "Expired" : "Token Valid",
                  style: const TextStyle(color: Colors.white),
                ),

                const SizedBox(width: 25),

                Text(
                  "${token.remainingTime.inMinutes} Minutes Left",
                  style: const TextStyle(color: Colors.white),
                ),

                const Spacer(),

                Text(
                  SessionManager.baseUrl ?? "",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _menu(
      IconData icon,
      String title,
      DashboardPage page,
      ) {
    return Container(
      color: currentPage == page
          ? Colors.white12
          : Colors.transparent,
      child: ListTile(
        onTap: () {
          setState(() {
            currentPage = page;
          });
        },
        leading: Icon(
          icon,
          color: Colors.white,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      )
    );
  }

  Widget _infoCard(
      String title,
      String value,
      ) {
    return SizedBox(
      width: 280,
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 10),
              SelectableText(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
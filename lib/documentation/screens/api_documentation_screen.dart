import 'package:flutter/material.dart';

import '../models/api_endpoint.dart';
import '../models/api_group.dart';
import '../models/repository/openapi_repository.dart';
import '../services/openapi_service.dart';
import 'api_details_screen.dart';

class ApiDocumentationScreen extends StatefulWidget {
  const ApiDocumentationScreen({
    super.key,
  });

  @override
  State<ApiDocumentationScreen> createState() =>
      _ApiDocumentationScreenState();
}

class _ApiDocumentationScreenState
    extends State<ApiDocumentationScreen> {
  late Future<void> _loadFuture;

  @override
  void initState() {

    super.initState();

    _loadFuture = OpenApiRepository.instance.load();

  }



  Widget _buildApiList(
      List<ApiGroup> groups,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Constellation API Explorer",
        ),
      ),

      body: Container(
        color: Colors.grey.shade100,

        child: Scrollbar(

    thumbVisibility: true,

    child: ListView(

    physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),

          children: groups.map((group) {

            return Card(
              margin: const EdgeInsets.only(
                bottom: 10,
              ),

              elevation: 1,

              child: ExpansionTile(

                key: PageStorageKey(group.name),

                initiallyExpanded: false,

                leading: const Icon(
                  Icons.folder_open,
                  color: Colors.blue,
                ),

                title: Text(
                  "${group.name} (${group.endpoints.length})",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                children: group.endpoints.map((endpoint) {

                  return ListTile(

                    dense: true,

                    leading: Container(

                      width: 55,

                      alignment: Alignment.center,

                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),

                      decoration: BoxDecoration(

                        color: _methodColor(
                          endpoint.method,
                        ),

                        borderRadius:
                        BorderRadius.circular(20),

                      ),

                      child: Text(

                        endpoint.method,

                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight:
                          FontWeight.bold,
                          fontSize: 10,
                        ),

                      ),

                    ),

                    title: Text(
                      endpoint.summary,
                    ),

                    subtitle: Text(
                      endpoint.path,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                    ),

                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),

                    onTap: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              ApiDetailsScreen(
                                endpoint: endpoint,
                              ),

                        ),

                      );

                    },

                  );

                }).toList(),

              ),
            );

          }).toList(),

        ),

      ),
      ),

    );
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(

      future: _loadFuture,

      builder: (context, snapshot) {

        if (snapshot.connectionState != ConnectionState.done) {

          return const Center(
            child: CircularProgressIndicator(),
          );

        }

        if (snapshot.hasError) {

          return Center(
            child: Text(snapshot.error.toString()),
          );

        }

        final repository = OpenApiRepository.instance;

        if (repository.endpoints.isEmpty) {

          return const Center(
            child: Text("No APIs Found"),
          );

        }



        return _buildApiList(
          repository.groups,
        );

      },

    );

  }



  Color _methodColor(
      String method,
      ) {

    switch (method) {

      case "GET":
        return Colors.blue;

      case "POST":
        return Colors.green;

      case "PATCH":
        return Colors.orange;

      case "DELETE":
        return Colors.red;

      default:
        return Colors.grey;

    }

  }

}
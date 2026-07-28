
import 'package:constellation_explorer/services/storage_service.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'dashboard_screen.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final baseUrlController = TextEditingController();

  final clientIdController = TextEditingController();

  final clientSecretController = TextEditingController();

  bool loading = false;

  final auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Constellation Explorer"),
      ),
      body: Center(
        child: SizedBox(
          width: 450,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  TextField(
                    controller: baseUrlController,
                    decoration: const InputDecoration(
                      labelText: "Base URL",
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: clientIdController,
                    decoration: const InputDecoration(
                      labelText: "Client ID",
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: clientSecretController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Client Secret",
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading
                          ? null
                          : () async {

                        setState(() {
                          loading = true;
                        });

                        bool success = await auth.login(
                          baseUrl: baseUrlController.text.trim(),
                          clientId: clientIdController.text.trim(),
                          clientSecret:
                          clientSecretController.text.trim(),
                        );

                        setState(() {
                          loading = false;
                        });

                        if (!mounted) return;

                        if (success) {

                          await StorageService().saveConnection(
                            baseUrl: baseUrlController.text.trim(),
                            clientId: clientIdController.text.trim(),
                            clientSecret: clientSecretController.text.trim(),
                          );

                          if (!mounted) return;

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DashboardScreen(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Authentication Failed",
                              ),
                            ),
                          );
                        }
                      },
                      child: loading
                          ? const CircularProgressIndicator()
                          : const Text("CONNECT"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
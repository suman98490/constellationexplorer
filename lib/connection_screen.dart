import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'dashboard_screen.dart';
import 'documentation/screens/api_documentation_screen.dart';

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

  Widget _buildHeroBanner() {

    return Container(

      height: 180,

      width: double.infinity,

      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(24),

        gradient: const LinearGradient(

          colors: [

            Color(0xff0F4C81),

            Color(0xff2563EB),

          ],

        ),

      ),

      child: Padding(

        padding: const EdgeInsets.symmetric(
          horizontal: 50,
        ),

        child: Row(

          children: [

            Expanded(

              child: Column(

                mainAxisAlignment:
                MainAxisAlignment.center,

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  const Text(

                    "CONSTELLATION EXPLORER",

                    style: TextStyle(

                      color: Colors.white,

                      fontSize: 30,

                      fontWeight: FontWeight.bold,

                      height: 1.1,

                    ),

                  ),

                  const SizedBox(height: 20),

                  Text(

                    "The Ultimate Developer Toolkit for Pega Constellation",

                    style: TextStyle(

                      fontSize: 15,

                      color: Colors.white.withOpacity(.9),

                    ),

                  ),

                  const SizedBox(height: 20),

                  Wrap(

                    spacing: 12,

                    runSpacing: 12,

                    children: [

                      _heroChip(
                        Icons.arrow_forward,
                        "Open API Explorer",
                      ),

                    ],

                  ),

                ],

              ),

            ),

            const Icon(

              Icons.hub,

              size: 120,

              color: Colors.white,

            ),

          ],

        ),

      ),

    );

  }

  Widget _heroChip(
      IconData icon,
      String text,
      ) {

    return InkWell(
      onTap: (){
        HapticFeedback.lightImpact();

        if(text == "Open API Explorer"){
          Navigator.push(

            context,

            MaterialPageRoute(

              builder: (_) =>
              const ApiDocumentationScreen(),

            ),

          );
        }
      },
      child: Container(

        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),

        decoration: BoxDecoration(

          color: Colors.white24,

          borderRadius:
          BorderRadius.circular(30),

        ),

        child: Row(

          mainAxisSize: MainAxisSize.min,

          children: [

            Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),

            const SizedBox(width: 8),

            Text(

              text,

              style: const TextStyle(
                color: Colors.white,
              ),

            ),

          ],

        ),

      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1200,
            ),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [

                //--------------------------------------------------
                // HERO
                //--------------------------------------------------

                _buildHeroBanner(),

                const SizedBox(height: 25),



                //--------------------------------------------------
                // CONNECTION CARD
                //--------------------------------------------------

                Card(

                  elevation: 6,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Padding(

                    padding: const EdgeInsets.all(30),

                    child: Column(

                      crossAxisAlignment:
                      CrossAxisAlignment.stretch,

                      children: [

                        const Row(
                          children: [
                            Icon(Icons.link, color: Colors.blue),
                            SizedBox(width: 10),
                            Text(
                              "Connect to Pega Environment",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        TextField(
                          controller: baseUrlController,
                          decoration: const InputDecoration(
                            labelText: "Base URL",
                            hintText: "https://company.pega.com/prweb",
                            prefixIcon: Icon(Icons.language),
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        TextField(
                          controller: clientIdController,
                          decoration: const InputDecoration(
                            labelText: "Client ID",
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        TextField(
                          controller: clientSecretController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Client Secret",
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            icon: loading
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Icon(Icons.login),
                            label: Text(
                              loading ? "CONNECTING..." : "CONNECT TO PEGA",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: loading
                                ? null
                                : () async {
                              setState(() {
                                loading = true;
                              });

                              final success = await auth.login(
                                baseUrl: baseUrlController.text.trim(),
                                clientId: clientIdController.text.trim(),
                                clientSecret: clientSecretController.text.trim(),
                              );

                              if (success) {
                                await StorageService().saveConnection(
                                  baseUrl: baseUrlController.text.trim(),
                                  clientId: clientIdController.text.trim(),
                                  clientSecret: clientSecretController.text.trim(),
                                );
                              }

                              if (!mounted) return;

                              setState(() {
                                loading = false;
                              });

                              if (success) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DashboardScreen(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Authentication Failed"),
                                  ),
                                );
                              }
                            },
                          ),
                        ),

                      ],

                    ),

                  ),

                ),
              ],

            ),

          ),
        ),
      ),
    );
  }
}
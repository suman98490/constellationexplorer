
import 'package:constellation_explorer/services/storage_service.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'connection_screen.dart';
import 'dashboard_screen.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {

  String status = "Checking saved connection...";

  @override
  void initState() {
    super.initState();

    initialize();
  }

  Future<void> initialize() async {

    final connection =
    await StorageService().getConnection();

    if (connection == null) {

      navigateToConnection();

      return;
    }

    setState(() {
      status = "Connecting to Pega...";
    });

    final success = await AuthService().login(
      baseUrl: connection["baseUrl"]!,
      clientId: connection["clientId"]!,
      clientSecret: connection["clientSecret"]!,
    );

    if (!mounted) return;

    if (success) {
      navigateToDashboard();
    } else {
      navigateToConnection();
    }
  }

  void navigateToDashboard() {

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const DashboardScreen(),
      ),
    );
  }

  void navigateToConnection() {

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ConnectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Icon(
                Icons.hub,
                size: 80,
                color: Colors.blue,
              ),

              const SizedBox(height: 20),

              const Text(
                "Constellation Explorer",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              const CircularProgressIndicator(),

              const SizedBox(height: 20),

              Text(status),
            ],
          ),
        ),
      ),
    );
  }
}
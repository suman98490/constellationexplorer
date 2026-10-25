import 'package:flutter/material.dart';

import '../models/auth_token.dart';
import '../services/session_manager.dart';
import '../config/pega_sso_config.dart';
import '../services/pega_sso_service.dart';
import 'connection_screen.dart';
import 'dashboard_screen.dart';

import '../services/storage_service.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  String status = "Enter your Pega SSO configuration";

  // ============================================================
  // USER INPUT FIELDS
  // ============================================================

  final TextEditingController baseUrlController =
  TextEditingController();

  final TextEditingController clientIdController =
  TextEditingController();

  // ============================================================
  // FIXED / DYNAMIC VALUES
  // ============================================================

  static const String redirectUri =
      "https://suman98490.github.io/constellationexplorer/";

  static const String authorizationPath =
      "/PRRestService/oauth2/v1/authorize";

  static const String tokenPath =
      "/PRRestService/oauth2/v1/token";

  // ============================================================

  bool isLoading = false;

  final PegaSsoService _pegaSsoService =
  PegaSsoService();

  final StorageService _storage =
  StorageService();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    initialize();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    baseUrlController.dispose();
    clientIdController.dispose();

    super.dispose();
  }

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> initialize() async {
    try {
      final uri = Uri.base;

      debugPrint("==============================================");
      debugPrint("STARTUP SCREEN INITIALIZATION");
      debugPrint("==============================================");

      debugPrint(
        "Current URL: ${uri.toString()}",
      );

      // ========================================================
      // 1. CHECK FOR OAUTH ERROR
      // ========================================================

      final error =
      uri.queryParameters['error'];

      if (error != null) {
        final errorDescription =
        uri.queryParameters['error_description'];

        debugPrint(
          "Pega OAuth Error: $error",
        );

        debugPrint(
          "Pega OAuth Error Description: "
              "$errorDescription",
        );

        if (!mounted) return;

        setState(() {
          status = errorDescription != null
              ? "Pega SSO failed: $errorDescription"
              : "Pega SSO failed: $error";

          isLoading = false;
        });

        return;
      }

      // ========================================================
      // 2. CHECK FOR AUTHORIZATION CODE
      // ========================================================

      final code =
      uri.queryParameters['code'];

      final returnedState =
      uri.queryParameters['state'];

      if (code != null && code.isNotEmpty) {
        debugPrint(
          "==============================================",
        );

        debugPrint(
          "OAUTH CALLBACK DETECTED",
        );

        debugPrint(
          "==============================================",
        );

        debugPrint(
          "Authorization code received: true",
        );

        debugPrint(
          "Authorization code length: "
              "${code.length}",
        );

        debugPrint(
          "State received: "
              "${returnedState != null}",
        );

        await completeSsoLogin(
          code,
          returnedState,
        );

        return;
      }

      // ========================================================
      // 3. NORMAL STARTUP
      // ========================================================

      debugPrint(
        "No OAuth authorization code found.",
      );

      await loadSavedSsoConfiguration();

      if (!mounted) return;

      setState(() {
        status =
        "Ready. Click 'Login with Pega SSO'.";
        isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint(
        "Startup initialization error: $e",
      );

      debugPrint(
        stackTrace.toString(),
      );

      if (!mounted) return;

      setState(() {
        status =
        "Startup failed: $e";
        isLoading = false;
      });
    }
  }

  // ============================================================
  // BUILD ENDPOINTS FROM BASE URL
  // ============================================================

  String buildAuthorizationEndpoint(
      String baseUrl,
      ) {
    return "$baseUrl$authorizationPath";
  }

  String buildTokenEndpoint(
      String baseUrl,
      ) {
    return "$baseUrl$tokenPath";
  }

  // ============================================================
  // LOAD SAVED SSO CONFIGURATION
  // ============================================================

  Future<void> loadSavedSsoConfiguration() async {
    final ssoConfig =
    await _storage.getPegaSsoConfig();

    if (ssoConfig == null) {
      debugPrint(
        "No saved Pega SSO configuration found.",
      );

      return;
    }

    debugPrint(
      "Saved Pega SSO configuration found.",
    );

    baseUrlController.text =
        ssoConfig["baseUrl"] ?? "";

    clientIdController.text =
        ssoConfig["clientId"] ?? "";
  }

  // ============================================================
  // COMPLETE SSO LOGIN
  // ============================================================

  Future<void> completeSsoLogin(
      String code,
      String? returnedState,
      ) async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      status =
      "Completing Pega SSO authentication...";
    });

    try {
      debugPrint(
        "==============================================",
      );

      debugPrint(
        "STARTING AUTHORIZATION CODE TOKEN EXCHANGE",
      );

      debugPrint(
        "==============================================",
      );

      // ========================================================
      // 1. GET SAVED STATE
      // ========================================================

      final savedState =
      await _storage.getState();

      debugPrint(
        "Saved OAuth state exists: "
            "${savedState != null}",
      );

      debugPrint(
        "Returned OAuth state exists: "
            "${returnedState != null}",
      );

      // ========================================================
      // 2. VALIDATE STATE
      // ========================================================

      if (savedState == null) {
        throw Exception(
          "OAuth state was not found in storage.",
        );
      }

      if (returnedState == null) {
        throw Exception(
          "OAuth state was not returned by Pega.",
        );
      }

      if (savedState != returnedState) {
        debugPrint(
          "OAuth state mismatch.",
        );

        throw Exception(
          "OAuth state mismatch.",
        );
      }

      debugPrint(
        "OAuth state validation successful.",
      );

      // ========================================================
      // 3. EXCHANGE AUTHORIZATION CODE
      // ========================================================

      debugPrint(
        "Calling Pega token endpoint...",
      );

      final tokenResponse =
      await _pegaSsoService
          .exchangeCodeForToken(code);

      debugPrint(
        "Token exchange completed successfully.",
      );

      // ========================================================
      // 4. GET ACCESS TOKEN
      // ========================================================

      final accessToken =
      tokenResponse["access_token"];

      final tokenType =
      tokenResponse["token_type"];

      final expiresIn =
      tokenResponse["expires_in"];

      // ========================================================
      // 5. LOG TOKEN RESPONSE
      // ========================================================

      debugPrint(
        "==============================================",
      );

      debugPrint(
        "TOKEN RESPONSE PROCESSED",
      );

      debugPrint(
        "==============================================",
      );

      debugPrint(
        "Access Token received: "
            "${accessToken != null}",
      );

      debugPrint(
        "Token Type: $tokenType",
      );

      debugPrint(
        "Expires In: $expiresIn",
      );

      debugPrint(
        "ID Token received: "
            "${tokenResponse["id_token"] != null}",
      );

      debugPrint(
        "==============================================",
      );

      // ========================================================
      // 6. VALIDATE ACCESS TOKEN
      // ========================================================

      if (accessToken == null ||
          accessToken.toString().isEmpty) {
        throw Exception(
          "Pega did not return an access token.",
        );
      }

      // ========================================================
      // 7. CREATE AuthToken
      // ========================================================

      final authToken =
      AuthToken.fromJson(tokenResponse);

      debugPrint(
        "AuthToken object created successfully.",
      );

      debugPrint(
        "Token issued at: "
            "${authToken.issuedAt}",
      );

      debugPrint(
        "Token expiry time: "
            "${authToken.expiryTime}",
      );

      debugPrint(
        "Token remaining time: "
            "${authToken.remainingTime}",
      );

      // ========================================================
      // 8. STORE TOKEN IN SESSION MANAGER
      // ========================================================

      SessionManager.token =
          authToken;

      // ========================================================
      // 9. STORE PEGA CONNECTION DETAILS
      // ========================================================

      final ssoConfig =
      await _storage.getPegaSsoConfig();

      if (ssoConfig != null) {
        SessionManager.baseUrl =
        ssoConfig["baseUrl"];

        SessionManager.clientId =
        ssoConfig["clientId"];

        // Authorization Code + PKCE
        // does not require client secret.
        SessionManager.clientSecret =
        null;
      }

      debugPrint(
        "SessionManager.token initialized: "
            "${SessionManager.token != null}",
      );

      debugPrint(
        "SessionManager.baseUrl: "
            "${SessionManager.baseUrl}",
      );

      debugPrint(
        "SessionManager.clientId: "
            "${SessionManager.clientId}",
      );

      // ========================================================
      // 10. AUTHENTICATION SUCCESS
      // ========================================================

      debugPrint(
        "Pega authentication successful.",
      );

      // ========================================================
      // 11. NAVIGATE TO DASHBOARD
      // ========================================================

      if (!mounted) return;

      setState(() {
        isLoading = false;
        status =
        "Pega SSO login successful.";
      });

      debugPrint(
        "Navigating to DashboardScreen...",
      );

      navigateToDashboard();
    } catch (e, stackTrace) {
      debugPrint(
        "==============================================",
      );

      debugPrint(
        "PEGA SSO LOGIN FAILED",
      );

      debugPrint(
        "==============================================",
      );

      debugPrint(
        "Error: $e",
      );

      debugPrint(
        stackTrace.toString(),
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
        status =
        "Pega SSO authentication failed.";
      });
    }
  }

  // ============================================================
  // START PEGA SSO LOGIN
  // ============================================================

  Future<void> loginWithPegaSso() async {
    // ========================================================
    // 1. VALIDATE BASE URL
    // ========================================================

    final baseUrl =
    baseUrlController.text.trim();

    final clientId =
    clientIdController.text.trim();

    if (baseUrl.isEmpty ||
        clientId.isEmpty) {
      setState(() {
        status =
        "Please enter Pega Base URL and Client ID.";
      });

      return;
    }

    // ========================================================
    // 2. CLEAN BASE URL
    // ========================================================

    final cleanBaseUrl =
    baseUrl.endsWith("/")
        ? baseUrl.substring(
      0,
      baseUrl.length - 1,
    )
        : baseUrl;

    // ========================================================
    // 3. BUILD OAUTH ENDPOINTS
    // ========================================================

    final authorizationEndpoint =
    buildAuthorizationEndpoint(
      cleanBaseUrl,
    );

    final tokenEndpoint =
    buildTokenEndpoint(
      cleanBaseUrl,
    );

    // ========================================================
    // 4. CREATE PEGA SSO CONFIGURATION
    // ========================================================

    final config = PegaSsoConfig(
      baseUrl: cleanBaseUrl,
      clientId: clientId,
      redirectUri: redirectUri,
      authorizationEndpoint:
      authorizationEndpoint,
      tokenEndpoint:
      tokenEndpoint,
    );

    // ========================================================
    // 5. UPDATE UI
    // ========================================================

    setState(() {
      isLoading = true;
      status =
      "Redirecting to Pega...";
    });

    try {
      debugPrint(
        "==============================================",
      );

      debugPrint(
        "STARTING PEGA SSO LOGIN",
      );

      debugPrint(
        "==============================================",
      );

      debugPrint(
        "Base URL: ${config.baseUrl}",
      );

      debugPrint(
        "Client ID: ${config.clientId}",
      );

      debugPrint(
        "Redirect URI: ${config.redirectUri}",
      );

      debugPrint(
        "Authorization Endpoint: "
            "${config.authorizationEndpoint}",
      );

      debugPrint(
        "Token Endpoint: "
            "${config.tokenEndpoint}",
      );

      await _pegaSsoService
          .loginWithPega(config);

      // Browser normally navigates away.
    } catch (e, stackTrace) {
      debugPrint(
        "Unable to start Pega SSO: $e",
      );

      debugPrint(
        stackTrace.toString(),
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
        status =
        "Unable to start Pega SSO.";
      });
    }
  }

  // ============================================================
  // NAVIGATE TO DASHBOARD
  // ============================================================

  void navigateToDashboard() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const DashboardScreen(),
      ),
    );
  }

  // ============================================================
  // NAVIGATE TO CONNECTION SCREEN
  // ============================================================

  void navigateToConnection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const ConnectionScreen(),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
  }) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null
              ? Icon(icon)
              : null,
          border:
          const OutlineInputBorder(),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.all(24),
          child: SizedBox(
            width: 500,
            child: Column(
              children: [
                const Icon(
                  Icons.hub,
                  size: 80,
                  color: Colors.blue,
                ),

                const SizedBox(
                  height: 20,
                ),

                const Text(
                  "Constellation Explorer",
                  textAlign:
                  TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                const Text(
                  "Connect to Pega using SSO",
                  textAlign:
                  TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                // =================================================
                // PEGA SSO CONFIGURATION
                // =================================================

                Card(
                  elevation: 3,
                  child: Padding(
                    padding:
                    const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Pega SSO Configuration",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        // BASE URL
                        buildTextField(
                          controller:
                          baseUrlController,
                          label:
                          "Pega Base URL",
                          hint:
                          "https://your-pega-server/prweb",
                          icon:
                          Icons.cloud,
                        ),

                        // CLIENT ID
                        buildTextField(
                          controller:
                          clientIdController,
                          label:
                          "Client ID",
                          hint:
                          "OAuth Client ID",
                          icon:
                          Icons.key,
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        // INFORMATION
                        Container(
                          width:
                          double.infinity,
                          padding:
                          const EdgeInsets.all(
                              12),
                          decoration:
                          BoxDecoration(
                            color: Colors.blue
                                .withOpacity(
                                0.05),
                            borderRadius:
                            BorderRadius
                                .circular(
                                8),
                          ),
                          child: const Text(
                            "OAuth endpoints and redirect URI "
                                "are automatically derived from "
                                "the Pega Base URL.",
                            style: TextStyle(
                              fontSize: 13,
                              color:
                              Colors.grey,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        SizedBox(
                          width:
                          double.infinity,
                          height: 50,
                          child:
                          ElevatedButton.icon(
                            onPressed:
                            isLoading
                                ? null
                                : loginWithPegaSso,
                            icon:
                            const Icon(
                              Icons.login,
                            ),
                            label:
                            const Text(
                              "Login with Pega SSO",
                              style:
                              TextStyle(
                                fontSize: 16,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                // =================================================
                // LOADING
                // =================================================

                if (isLoading)
                  const Padding(
                    padding:
                    EdgeInsets.only(
                      bottom: 15,
                    ),
                    child:
                    CircularProgressIndicator(),
                  ),

                // =================================================
                // STATUS
                // =================================================

                Text(
                  status,
                  textAlign:
                  TextAlign.center,
                ),

                const SizedBox(
                  height: 15,
                ),

                // =================================================
                // OLD CLIENT CREDENTIALS OPTION
                // =================================================

                TextButton(
                  onPressed:
                  isLoading
                      ? null
                      : navigateToConnection,
                  child:
                  const Text(
                    "Use Client Credentials instead",
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
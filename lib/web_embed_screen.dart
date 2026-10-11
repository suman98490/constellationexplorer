import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

class WebEmbedScreen extends StatefulWidget {
  const WebEmbedScreen({super.key});

  @override
  State<WebEmbedScreen> createState() => _WebEmbedScreenState();
}

class _WebEmbedScreenState extends State<WebEmbedScreen> {

  late final String viewType;

  @override
  void initState() {
    super.initState();

    viewType =
    'pega-web-embed-${DateTime.now().millisecondsSinceEpoch}';

    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
          (int viewId) {
        return _buildPegaPage();
      },
    );
  }

  // ============================================================
  // PEGA WEB EMBED PAGE
  // ============================================================

  html.DivElement _buildPegaPage() {

    final container = html.DivElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.overflow = 'auto'
      ..style.backgroundColor = '#ffffff';

    // ==========================================================
    // PEGA WEB EMBED JAVASCRIPT
    //
    // Normally you don't need to change this.
    //
    // If Pega gives you a new <script> URL,
    // change it here.
    // ==========================================================

    final script = html.ScriptElement()
      ..src =
          'https://3pnryoc8.pegace.net/prweb/PRRestService/c11nsvc/v1/pega-embed.js'
      ..type = 'text/javascript';

    // ==========================================================
    // PEGA WEB EMBED CODE
    //
    // ==========================================================
    //
    // IMPORTANT:
    //
    // When Pega gives you a new Web Embed code,
    // change ONLY the attributes in this section.
    //
    // Example Pega code:
    //
    // <pega-embed
    //   id="theEmbed"
    //   action="createCase"
    //   caseTypeID="..."
    //   ...
    // >
    // </pega-embed>
    //
    // You don't need to change the Flutter UI below.
    //
    // ==========================================================

    final embed = html.Element.tag('pega-embed');

    // ----------------------------------------------------------
    // PASTE / UPDATE PEGA ATTRIBUTES HERE
    // ----------------------------------------------------------

    embed.setAttribute(
      'id',
      'theEmbed',
    );

    embed.setAttribute(
      'action',
      'createCase',
    );

    embed.setAttribute(
      'caseTypeID',
      'MyOrg-CLMClient-Work-ClientLifecycleManagementnewCustome',
    );

    embed.setAttribute(
      'themeID',
      'pzCosmosDefault',
    );

    embed.setAttribute(
      'casePage',
      'simplifiedAssignment',
    );

    embed.setAttribute(
      'appAlias',
      'clm--client-onboarding-for-financial-services',
    );

    embed.setAttribute(
      'pegaServerUrl',
      'https://3pnryoc8.pegace.net/prweb/',
    );

    embed.setAttribute(
      'autoReauth',
      'true',
    );

    embed.setAttribute(
      'authService',
      'pega',
    );

    embed.setAttribute(
      'clientId',
      '98180738476292365769',
    );

    // ----------------------------------------------------------
    // SIZE
    //
    // Keep these unless Pega specifically provides different
    // styling requirements.
    // ----------------------------------------------------------

    embed.style.width = '100%';
    embed.style.height = '100%';
    embed.style.display = 'block';

    // ==========================================================
    // WAIT FOR PEGA WEB EMBED JAVASCRIPT
    // ==========================================================

    script.onLoad.listen((event) {

      // Pega's custom element is now available.
      container.append(embed);
    });

    // ==========================================================
    // SCRIPT LOAD ERROR
    // ==========================================================

    script.onError.listen((event) {

      final errorContainer = html.DivElement()
        ..style.padding = '30px'
        ..style.fontFamily = 'Arial, sans-serif'
        ..style.color = '#b42318'
        ..style.backgroundColor = '#fff5f5';

      errorContainer.text =
      'Unable to load Pega Web Embed JavaScript.';

      container.append(errorContainer);
    });

    // ==========================================================
    // ADD PEGA SCRIPT TO PAGE
    // ==========================================================

    container.append(script);

    return container;
  }

  // ============================================================
  // FLUTTER UI
  // ============================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Pega Web Embed',
        ),
      ),

      body: HtmlElementView(
        viewType: viewType,
      ),
    );
  }
}
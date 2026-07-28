class PortalPage {
  final String label;
  final String ruleName;
  final String className;
  final String icon;
  final bool isLandingPage;

  PortalPage({
    required this.label,
    required this.ruleName,
    required this.className,
    required this.icon,
    required this.isLandingPage,
  });

  factory PortalPage.fromJson(Map<String, dynamic> json) {
    return PortalPage(
      label: json["pyLabel"] ?? "",
      ruleName: json["pyRuleName"] ?? "",
      className: json["pyClassName"] ?? "",
      icon: json["pxPageViewIcon"] ?? "",
      isLandingPage:
      json["classID"] == "Rule-UI-View-LandingPage",
    );
  }
}
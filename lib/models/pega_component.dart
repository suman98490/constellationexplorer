class PegaComponent {
  final String type;
  final String label;
  final String binding;
  final bool readOnly;

  // Data source related
  final String? datasource;
  final bool deferDatasource;
  final String? listType;

  // Reference related
  final String? referenceView;

  // Table related
  final String? selectionMode;

  /// Fields returned by the Data View.
  /// Example:
  /// Contact      -> FullName, PhoneNumber, EmailAddress, pyGUID
  /// Product      -> ProductName, ProductCode, pyGUID
  /// Address      -> StreetAddress, pyGUID
  final List<String> selectFields;

  const PegaComponent({
    required this.type,
    required this.label,
    required this.binding,
    required this.readOnly,
    this.datasource,
    this.deferDatasource = false,
    this.listType,
    this.referenceView,
    this.selectionMode,
    this.selectFields = const [],
  });

  /// Returns the field that should be displayed to the user.
  ///
  /// Contact      -> FullName
  /// Product      -> ProductName
  /// Address      -> StreetAddress
  ///
  /// pyGUID is never used as the display field.
  String get displayField {
    return selectFields.firstWhere(
          (field) => field != "pyGUID",
      orElse: () => "pyGUID",
    );
  }
}
class RuntimeState {

  RuntimeState._();

  static final RuntimeState instance =
  RuntimeState._();

  final Map<String, dynamic> _values = {};

  void setValue(
      String binding,
      dynamic value,
      ) {
    _values[binding] = value;
  }

  T? getValue<T>(String binding) {
    return _values[binding] as T?;
  }

  Map<String, dynamic> get values => _values;

  void clear() {
    _values.clear();
  }
}
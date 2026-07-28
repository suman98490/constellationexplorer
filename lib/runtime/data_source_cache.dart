class DataSourceCache {

  DataSourceCache._();

  static final Map<String, dynamic> _cache = {};

  static void put(
      String datasource,
      dynamic value,
      ) {

    _cache[datasource] = value;
  }

  static T? get<T>(
      String datasource,
      ) {

    return _cache[datasource] as T?;
  }

  static void clear() {

    _cache.clear();
  }
}
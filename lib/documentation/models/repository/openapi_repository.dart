
import '../../parser/openapi_parser.dart';
import '../api_endpoint.dart';
import '../api_group.dart';
import '../openapi_document.dart';

class OpenApiRepository {

  OpenApiRepository._();

  static final OpenApiRepository instance =
  OpenApiRepository._();

  final List<ApiEndpoint> _endpoints = [];

  final List<ApiGroup> _groups = [];

  bool _loaded = false;

  bool get isLoaded => _loaded;

  List<ApiEndpoint> get endpoints => _endpoints;

  List<ApiGroup> get groups => _groups;

  //--------------------------------------------------

  Future<void> load() async {

    if (_loaded) {
      return;
    }

    final OpenApiDocument document =
    await OpenApiParser().parse();

    _endpoints.clear();

    _endpoints.addAll(
      document.endpoints,
    );

    _buildGroups();

    _loaded = true;

  }

  //--------------------------------------------------

  void _buildGroups() {

    _groups.clear();

    final Map<String,List<ApiEndpoint>> map = {};

    for(final endpoint in _endpoints){

      map.putIfAbsent(
        endpoint.tag,
            ()=>[],
      );

      map[endpoint.tag]!.add(endpoint);

    }

    final keys = map.keys.toList()
      ..sort();

    for(final key in keys){

      final list = map[key]!;

      list.sort(

            (a,b)=>a.summary.compareTo(
          b.summary,
        ),

      );

      _groups.add(

        ApiGroup(

          name: key,

          endpoints: list,

        ),

      );

    }

  }

  //--------------------------------------------------

  List<ApiEndpoint> search(
      String text,
      ){

    if(text.trim().isEmpty){

      return _endpoints;

    }

    final query =
    text.toLowerCase();

    return _endpoints.where(

          (e){

        return

          e.summary
              .toLowerCase()
              .contains(query)

              ||

              e.path
                  .toLowerCase()
                  .contains(query)

              ||

              e.tag
                  .toLowerCase()
                  .contains(query);

      },

    ).toList();

  }

}
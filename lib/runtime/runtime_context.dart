import '../models/pega_component.dart';
import '../models/runtime_header_model.dart';


class RuntimeContext {

  RuntimeContext._();

  static final RuntimeContext instance =
  RuntimeContext._();

  RuntimeHeaderModel? header;

  String? assignmentId;

  String? actionName;

  String? ifMatch;

  List<PegaComponent> components = [];
}
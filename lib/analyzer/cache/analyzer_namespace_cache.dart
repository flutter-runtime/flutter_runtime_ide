import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:analyzer/src/dart/resolver/scope.dart';
import '../../app/modules/fix_config/controllers/fix_select_controller.dart';
import 'analyzer_cache.dart';

class AnalyzerNameSpaceCache<T> extends AnalyzerCache<T> {
  List<String> exportNames = [];
  AnalyzerNameSpaceCache(super.element, super.map);

  @override
  void addToMap() {
    super.addToMap();
    this['exportNames'] = exportNames;
  }

  @override
  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    exportNames = JSON(element)['exportNames']
        .listValue
        .map((e) => JSON(e).stringValue)
        .toList();
  }
}

class AnalyzerNameSpaceCacheImpl extends AnalyzerNameSpaceCache<Namespace> {
  AnalyzerNameSpaceCacheImpl(super.element, super.map);

  @override
  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    exportNames = element.definedNames.keys.toList();
  }
}

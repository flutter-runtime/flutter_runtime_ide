import 'package:analyze_cache/analyze_cache.dart';
import 'package:analyzer/src/dart/resolver/scope.dart';

class AnalyzerNameSpaceCacheImpl extends AnalyzerNameSpaceCache<Namespace> {
  AnalyzerNameSpaceCacheImpl(super.element, super.map, [super.parent]);

  @override
  void fromMap(Map map) {
    super.fromMap(map);
    exportNames = element.definedNames.keys.toList();
  }
}

import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:analyzer/src/dart/resolver/scope.dart';
import 'analyzer_cache.dart';

abstract class AnalyzerNameSpaceCache<T> extends AnalyzerCache<T> {
  List<String> get exportNames;

  AnalyzerNameSpaceCache(super.element);

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson()}..addAll(
        {
          'isEnable': isEnable,
          'exportNames': exportNames,
        },
      );
  }
}

class AnalyzerNameSpaceJsonCacheImpl
    extends AnalyzerNameSpaceCache<Map<String, dynamic>> {
  AnalyzerNameSpaceJsonCacheImpl(super.element);

  @override
  List<String> get exportNames => JSON(element)['exportNames']
      .listValue
      .map((e) => JSON(e).stringValue)
      .toList();
}

class AnalyzerNameSpaceCacheImpl extends AnalyzerNameSpaceCache<Namespace> {
  AnalyzerNameSpaceCacheImpl(super.element);

  @override
  List<String> get exportNames => element.definedNames.keys.toList();
}

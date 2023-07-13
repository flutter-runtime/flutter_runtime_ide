import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter_runtime_ide/analyzer/analyzer_package_manager.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_file_cache.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_namespace_cache.dart';

import '../../app/modules/fix_config/controllers/fix_select_controller.dart';
import 'analyzer_cache.dart';

class AnalyzerImportCache<T> extends AnalyzerCache<T> with FixSelectItem {
  String? uriContent;
  String? asName;
  List<String> shownNames = [];
  List<String> hideNames = [];
  AnalyzerNameSpaceCache? namespace;
  int index = 0;
  AnalyzerImportCache(super.element, super.map, [super.parent]);

  @override
  void addToMap() {
    super.addToMap();
    this['uriContent'] = uriContent;
    this['asName'] = asName;
    this['shownNames'] = shownNames;
    this['hideNames'] = hideNames;
    this['namespace'] = namespace;
    this['index'] = index;
  }

  List<String> hideNamesFromFileCache(AnalyzerFileCache fileCache) {
    final hideNames2 = [...hideNames];
    final exportNames = namespace?.exportNames ?? [];
    for (final e in fileCache.exportNames) {
      if (exportNames.contains(e)) {
        hideNames2.add(e);
      }
    }
    return hideNames2;
  }

  @override
  void fromMap(Map map) {
    super.fromMap(map);
    uriContent = JSON(element)['uriContent'].string;
    asName = JSON(element)['asName'].string;
    shownNames = JSON(element)['shownNames']
        .listValue
        .map((e) => JSON(e).stringValue)
        .toList();
    hideNames = JSON(element)['hideNames']
        .listValue
        .map((e) => JSON(e).stringValue)
        .toList();
    namespace = Unwrap(JSON(element)['namespace'].rawValue)
        .map((e) => AnalyzerNameSpaceCache(e as Map, e, this))
        .value;
    index = JSON(element)['index'].intValue;
  }

  @override
  String get name => uriContent ?? '';
}

class AnalyzerImportDirectiveCacheImpl
    extends AnalyzerImportCache<ImportDirectiveImpl> {
  AnalyzerImportDirectiveCacheImpl(super.element, super.map, [super.parent]);
  @override
  void fromMap(Map map) {
    super.fromMap(map);
    uriContent = element.uriContent;
    asName = element.asName;
    shownNames = element.shownNames;
    hideNames = element.hideNames;
    namespace = element.namespace(map, this);
  }
}

extension ImportDirectiveImplAnalyzer on ImportDirectiveImpl {
  String? get uriContent =>
      Unwrap(element).map((e) {
        return e.importedLibrary;
      }).map((e) {
        return e.source.fullName;
      }).map((e) {
        final info = AnalyzerPackageManager().getPackageInfoFromFullPath(e);
        if (info == null) return null;
        return 'package:${info.name}/${e.split('/lib/')[1]}';
      }).value ??
      uri.stringValue;

  String? get asName => prefix?.name;

  List<String> get shownNames => combinators
      .whereType<ShowCombinatorImpl>()
      .map((e) => e.shownNames)
      .map((e) => e.map((e) => e.name))
      .expand((element) => element)
      .toList();

  List<String> get hideNames => combinators
      .whereType<HideCombinatorImpl>()
      .map((e) => e.hiddenNames)
      .map((e) => e.map((e) => e.name))
      .expand((element) => element)
      .toList();

  AnalyzerNameSpaceCache? namespace(Map map, AnalyzerImportCache importCache) =>
      Unwrap(uriContent)
          .map((e) =>
              AnalyzerPackageManager().getResolvedLibraryFromUriContent(e))
          .map((e) => e.element)
          .map((e) => e.exportNamespace)
          .map(
            (e) => AnalyzerNameSpaceCacheImpl(
              e,
              JSON(map)['namespaces'].mapValue,
              importCache,
            ),
          )
          .value;
}

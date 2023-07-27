// ignore_for_file: implementation_imports

import 'package:analyze_cache/analyze_cache.dart';
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter_runtime_ide/analyzer/analyzer_package_manager.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_namespace_cache.dart';

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

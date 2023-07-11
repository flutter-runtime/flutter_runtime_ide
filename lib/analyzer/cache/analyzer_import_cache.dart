import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter_runtime_ide/analyzer/analyzer_package_manager.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_file_cache.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_namespace_cache.dart';

import 'analyzer_cache.dart';

abstract class AnalyzerImportCache<T> extends AnalyzerCache<T> {
  String? get uriContent;
  String? get asName;
  List<String> get shownNames;
  List<String> get hideNames;
  AnalyzerNameSpaceCache? get namespace;
  AnalyzerImportCache(super.element);

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson()}..addAll(
        {
          'isEnable': isEnable,
          'uriContent': uriContent,
          'asName': asName,
          'shownNames': shownNames,
          'hideNames': hideNames,
          'namespace': namespace?.toJson(),
        },
      );
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
}

class AnalyzerImportJsonCacheImpl
    extends AnalyzerImportCache<Map<String, dynamic>> {
  AnalyzerImportJsonCacheImpl(super.element);

  @override
  String? get uriContent => JSON(element)['uriContent'].string;

  @override
  String? get asName => JSON(element)['asName'].string;

  @override
  List<String> get hideNames => JSON(element)['hideNames']
      .listValue
      .map((e) => JSON(e).stringValue)
      .toList();

  @override
  List<String> get shownNames => JSON(element)['shownNames']
      .listValue
      .map((e) => JSON(e).stringValue)
      .toList();

  @override
  AnalyzerNameSpaceCache? get namespace =>
      Unwrap(JSON(element)['namespace'].rawValue)
          .map((e) => AnalyzerNameSpaceJsonCacheImpl(e as Map<String, dynamic>))
          .value;
}

class AnalyzerImportDirectiveCacheImpl
    extends AnalyzerImportCache<ImportDirectiveImpl> {
  AnalyzerImportDirectiveCacheImpl(super.element);

  @override
  String? get uriContent => element.uriContent;

  @override
  String? get asName => element.asName;

  @override
  List<String> get hideNames => element.hideNames;

  @override
  List<String> get shownNames => element.shownNames;

  @override
  AnalyzerNameSpaceCache? get namespace => element.namespace;
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

  AnalyzerNameSpaceCache? get namespace => Unwrap(uriContent)
      .map((e) => AnalyzerPackageManager().getResolvedLibraryFromUriContent(e))
      .map((e) => e.element)
      .map((e) => e.exportNamespace)
      .map((e) => AnalyzerNameSpaceCacheImpl(e))
      .value;
}

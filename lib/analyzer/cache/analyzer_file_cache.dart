// ignore_for_file: implementation_imports

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter_runtime_ide/analyzer/analyzer_package_manager.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_import_cache.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_property_accessor_cache.dart';
import 'package:path/path.dart';
import 'package:analyzer/src/dart/resolver/scope.dart';

import 'analyzer_cache.dart';
import 'analyzer_class_cache.dart';
import 'analyzer_extension_cache.dart';
import 'analyzer_method_cache.dart';
import 'analyzer_enum_cache.dart';
import 'analyzer_mixin_cache.dart';

abstract class AnalyzerFileCache<T> extends AnalyzerCache<T> {
  List<AnalyzerClassCache> get classs;
  List<AnalyzerExtensionCache> get extensions;
  List<AnalyzerPropertyAccessorCache> get topLevelVariables;
  List<AnalyzerMethodCache> get functions;
  List<AnalyzerEnumCache> get enums;
  List<AnalyzerMixinCache> get mixins;
  List<AnalyzerImportCache> get imports;
  AnalyzerFileCache(super.element);

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson()}..addAll(
        {
          'isEnable': isEnable,
          'classs': classs.map((e) => e.toJson()).toList(),
          'extensions': extensions.map((e) => e.toJson()).toList(),
          'topLevelVariables':
              topLevelVariables.map((e) => e.toJson()).toList(),
          'functions': functions.map((e) => e.toJson()).toList(),
          'enums': enums.map((e) => e.toJson()).toList(),
          'mixins': mixins.map((e) => e.toJson()).toList(),
          'imports': imports.map((e) => e.toJson()).toList(),
        },
      );
  }

  List<String> get exportNames => [
        classs.map((e) => e.name),
        functions.map((e) => e.name),
        enums.map((e) => e.name),
        mixins.map((e) => e.name),
        extensions.map((e) => e.name ?? ''),
        topLevelVariables.map((e) => e.name),
      ].expand((element) => element).toList();
}

class AnalyzerFileJsonCacheImpl
    extends AnalyzerFileCache<Map<String, dynamic>> {
  AnalyzerFileJsonCacheImpl(super.element);

  @override
  List<AnalyzerClassCache> get classs => JSON(element)['classs']
      .listValue
      .map((e) => AnalyzerClassJsonCacheImpl(e))
      .toList();

  @override
  List<AnalyzerEnumCache> get enums => JSON(element)['enums']
      .listValue
      .map((e) => AnalyzerEnumJsonCacheImpl(e))
      .toList();

  @override
  List<AnalyzerExtensionCache> get extensions => JSON(element)['extensions']
      .listValue
      .map((e) => AnalyzerExtensionJsonCacheImpl(e))
      .toList();

  @override
  List<AnalyzerMethodCache> get functions => JSON(element)['functions']
      .listValue
      .map((e) => AnalyzerMethodJsonCacheImpl(e))
      .toList();

  @override
  List<AnalyzerMixinCache> get mixins => JSON(element)['mixins']
      .listValue
      .map((e) => AnalyzerMixinJsonCacheImpl(e))
      .toList();

  @override
  List<AnalyzerPropertyAccessorCache> get topLevelVariables =>
      JSON(element)['topLevelVariables']
          .listValue
          .map((e) => AnalyzerPropertyAccessorJsonCacheImpl(e))
          .toList();

  @override
  List<AnalyzerImportCache> get imports => JSON(element)['imports']
      .listValue
      .map((e) => AnalyzerImportJsonCacheImpl(e))
      .toList();
}

class AnalyzerLibraryElementCacheImpl
    extends AnalyzerFileCache<ResolvedLibraryResult> {
  AnalyzerLibraryElementCacheImpl(super.element);

  @override
  List<AnalyzerClassCache> get classs => element.libraryElement.units
      .map((e) => e.classes)
      .expand((element) => element)
      .map((e) => AnalyzerClassElementCacheImpl(e))
      .toList();

  @override
  List<AnalyzerEnumCache> get enums => element.libraryElement.units
      .map((e) => e.enums)
      .expand((element) => element)
      .map((e) => AnalyzerEnumElementCacheImpl(e))
      .toList();

  @override
  List<AnalyzerExtensionCache> get extensions => element.libraryElement.units
      .map((e) => e.extensions)
      .expand((element) => element)
      .map((e) => AnalyzerExtensionElementCacheImpl(e))
      .toList();

  @override
  List<AnalyzerMethodCache> get functions => element.libraryElement.units
      .map((e) => e.functions)
      .expand((element) => element)
      .map((e) => AnalyzerFunctionElementCacheImpl(e))
      .toList();

  @override
  List<AnalyzerMixinCache> get mixins => element.libraryElement.units
      .map((e) => e.mixins)
      .expand((element) => element)
      .map((e) => AnalyzerMixinElementCacheImpl(e))
      .toList();

  @override
  List<AnalyzerPropertyAccessorCache> get topLevelVariables =>
      element.libraryElement.units
          .map((e) => e.topLevelVariables)
          .expand((element) => element)
          .map((e) => AnalyzerTopLevelVariableElementCacheImpl(e))
          .toList();

  @override
  List<AnalyzerImportCache> get imports => element.importCaches;
}

extension ResolvedLibraryResultAnalyzer on ResolvedLibraryResult {
  LibraryElementImpl get libraryElement => element as LibraryElementImpl;

  List<AnalyzerImportCache> get importCaches {
    List<AnalyzerImportCache> imports = [];
    final directives = units
        .map((e) => e.unit)
        .map((e) => e.directives)
        .expand((element) => element)
        .whereType<ImportDirectiveImpl>()
        .toList();

    for (final element in directives) {
      final uriContent = element.uriContent;
      if (uriContent == null) continue;
      // Namespace? nameSpace = getLibrary(uriContent)?.element.exportNamespace;
      final filterImports = [
        'dart:_js_embedded_names',
        'dart:_js_helper',
        'dart:_foreign_helper',
        'dart:_rti',
        'dart:html_common',
        'dart:indexed_db',
        'dart:_native_typed_data',
        'dart:svg',
        'dart:web_audio',
        'dart:web_gl',
        'dart:mirrors',
      ];
      if (filterImports.contains(JSON(uriContent).stringValue)) {
        continue;
      }
      if (JSON(uriContent).stringValue.startsWith("package:flutter/")) {
        continue;
      }
      imports.add(AnalyzerImportDirectiveCacheImpl(element));
    }
    return imports;
  }
}

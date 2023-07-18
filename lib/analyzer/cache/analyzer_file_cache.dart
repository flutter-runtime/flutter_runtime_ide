// ignore_for_file: implementation_imports

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_import_cache.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_property_accessor_cache.dart';
import 'package:get/get.dart';

import 'analyzer_cache.dart';
import 'analyzer_class_cache.dart';
import 'analyzer_extension_cache.dart';
import 'analyzer_method_cache.dart';
import 'analyzer_enum_cache.dart';
import 'analyzer_mixin_cache.dart';

class AnalyzerFileCache<T> extends AnalyzerCache<T> {
  List<AnalyzerClassCache> classs = [];
  List<AnalyzerExtensionCache> extensions = [];
  List<AnalyzerPropertyAccessorCache> topLevelVariables = [];
  List<AnalyzerMethodCache> functions = [];
  List<AnalyzerEnumCache> enums = [];
  List<AnalyzerMixinCache> mixins = [];
  List<AnalyzerImportCache> imports = [];
  AnalyzerFileCache(super.element, super.map);

  @override
  void addToMap() {
    super.addToMap();
    this['classs'] = classs.map((e) => e.toJson()).toList();
    this['extensions'] = extensions.map((e) => e.toJson()).toList();
    this['topLevelVariables'] =
        topLevelVariables.map((e) => e.toJson()).toList();
    this['functions'] = functions.map((e) => e.toJson()).toList();
    this['enums'] = enums.map((e) => e.toJson()).toList();
    this['mixins'] = mixins.map((e) => e.toJson()).toList();
    this['imports'] = imports.map((e) => e.toJson()).toList();
  }

  @override
  void fromMap(Map map) {
    classs = JSON(map)['classs']
        .listValue
        .map((e) => AnalyzerClassCache(e, e, this))
        .toList();

    enums = JSON(map)['enums']
        .listValue
        .map((e) => AnalyzerEnumCache(e, e, this))
        .toList();

    extensions = JSON(map)['extensions']
        .listValue
        .map((e) => AnalyzerExtensionCache(e, e, this))
        .toList();

    functions = JSON(map)['functions']
        .listValue
        .map((e) => AnalyzerMethodCache(e, e, this))
        .toList();

    mixins = JSON(map)['mixins']
        .listValue
        .map((e) => AnalyzerMixinCache(e, e, this))
        .toList();

    topLevelVariables = JSON(map)['topLevelVariables']
        .listValue
        .map((e) => AnalyzerPropertyAccessorCache(e, e, this))
        .toList();

    imports = JSON(map)['imports']
        .listValue
        .map((e) => AnalyzerImportCache(e, e, this))
        .toList();
  }

  List<String> get exportNames => [
        classs.map((e) => e.name),
        functions.map((e) => e.name),
        enums.map((e) => e.name),
        mixins.map((e) => e.name),
        extensions.map((e) => e.name),
        topLevelVariables.map((e) => e.name),
      ].expand((element) => element).toList();

  String? defaultValueCodeFromTopLevelVariable(String name) {
    return topLevelVariables
        .firstWhereOrNull((e) => e.name == name)
        ?.defaultValueCode;
  }
}

class AnalyzerLibraryElementCacheImpl
    extends AnalyzerFileCache<ResolvedLibraryResult> {
  AnalyzerLibraryElementCacheImpl(super.element, super.map);

  @override
  void fromMap(Map map) {
    super.fromMap(map);

    classs = element.libraryElement.units
        .map((e) => e.classes)
        .expand((element) => element)
        .map(
          (e) => AnalyzerClassElementCacheImpl(
              e, map.getClass(e.name) ?? {}, this),
        )
        .toList();
    enums = element.libraryElement.units
        .map((e) => e.enums)
        .expand((element) => element)
        .map((e) =>
            AnalyzerEnumElementCacheImpl(e, map.getEnum(e.name) ?? {}, this))
        .toList();
    extensions = element.libraryElement.units
        .map((e) => e.extensions)
        .expand((element) => element)
        .where((element) => element.name != null)
        .map((e) => AnalyzerExtensionElementCacheImpl(
            e, map.getExtension(e.name ?? '') ?? {}, this))
        .toList();
    functions = element.libraryElement.units
        .map((e) => e.functions)
        .expand((element) => element)
        .map((e) => AnalyzerFunctionElementCacheImpl(
            e, map.getFunction(e.name) ?? {}, this))
        .toList();
    mixins = element.libraryElement.units
        .map((e) => e.mixins)
        .expand((element) => element)
        .map((e) =>
            AnalyzerMixinElementCacheImpl(e, map.getMixin(e.name) ?? {}, this))
        .toList();
    topLevelVariables = element.libraryElement.units
        .map((e) => e.topLevelVariables)
        .expand((element) => element)
        .map((e) => AnalyzerTopLevelVariableElementCacheImpl(
            e, map.getTopLevelVariable(e.name) ?? {}, this))
        .toList();
    imports = element.importCaches(
      JSON(map)['imports'].listValue.map((e) => e as Map).toList(),
      this,
    );
  }
}

extension ResolvedLibraryResultAnalyzer on ResolvedLibraryResult {
  LibraryElementImpl get libraryElement => element as LibraryElementImpl;

  List<AnalyzerImportCache> importCaches(
      List<Map> maps, AnalyzerFileCache fileCache) {
    List<AnalyzerImportCache> imports = [];
    final directives = units
        .map((e) => e.unit)
        .map((e) => e.directives)
        .expand((element) => element)
        .whereType<ImportDirectiveImpl>()
        .toList();

    int index = -1;
    for (final element in directives) {
      index++;
      final uriContent = element.uriContent;
      if (uriContent == null) continue;
      // // Namespace? nameSpace = getLibrary(uriContent)?.element.exportNamespace;
      // final filterImports = [
      //   'dart:_js_embedded_names',
      //   'dart:_js_helper',
      //   'dart:_foreign_helper',
      //   'dart:_rti',
      //   'dart:html_common',
      //   'dart:indexed_db',
      //   'dart:_native_typed_data',
      //   'dart:svg',
      //   'dart:web_audio',
      //   'dart:web_gl',
      //   'dart:mirrors',
      // ];
      // if (filterImports.contains(JSON(uriContent).stringValue)) {
      //   continue;
      // }
      // if (JSON(uriContent).stringValue.startsWith("package:flutter/")) {
      //   continue;
      // }
      final cache = AnalyzerImportDirectiveCacheImpl(
        element,
        JSON(maps)[index]
            .mapValue
            .map((key, value) => MapEntry(key as String, value)),
        fileCache,
      );
      cache.index = index;
      imports.add(cache);
    }
    return imports;
  }
}

extension on Map {
  Map? getClass(String name) {
    return JSON(this)['classs'].listValue.firstWhereOrNull((element) {
      return JSON(element)['name'].stringValue == name;
    });
  }

  Map? getEnum(String name) {
    return JSON(this)['enums'].listValue.firstWhereOrNull((element) {
      return JSON(element)['name'].stringValue == name;
    });
  }

  Map? getMixin(String name) {
    return JSON(this)['mixins'].listValue.firstWhereOrNull((element) {
      return JSON(element)['name'].stringValue == name;
    });
  }

  Map? getExtension(String name) {
    return JSON(this)['extensions'].listValue.firstWhereOrNull((element) {
      return JSON(element)['name'].stringValue == name;
    });
  }

  Map? getFunction(String name) {
    return JSON(this)['functions'].listValue.firstWhereOrNull((element) {
      return JSON(element)['name'].stringValue == name;
    });
  }

  Map? getTopLevelVariable(String name) {
    return JSON(this)['topLevelVariables']
        .listValue
        .firstWhereOrNull((element) {
      return JSON(element)['name'].stringValue == name;
    });
  }

  Map? getImport(String name) {
    return JSON(this)['imports'].listValue.firstWhereOrNull((element) {
      return JSON(element)['name'].stringValue == name;
    });
  }
}

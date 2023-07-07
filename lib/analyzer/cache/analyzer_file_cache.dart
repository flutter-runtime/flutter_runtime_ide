// ignore_for_file: implementation_imports

import 'package:analyzer/src/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_property_accessor_cache.dart';

import 'analyzer_class_cache.dart';
import 'analyzer_extension_cache.dart';
import 'analyzer_method_cache.dart';
import 'analyzer_enum_cache.dart';
import 'analyzer_mixin_cache.dart';

abstract class AnalyzerFileCache<T> {
  final T element;
  bool isEnable = true;
  List<AnalyzerClassCache> get classs;
  List<AnalyzerExtensionCache> get extensions;
  List<AnalyzerPropertyAccessorCache> get topLevelVariables;
  List<AnalyzerMethodCache> get functions;
  List<AnalyzerEnumCache> get enums;
  List<AnalyzerMixinCache> get mixins;
  AnalyzerFileCache(this.element);

  Map<String, dynamic> toJson() {
    return {
      'isEnable': isEnable,
      'classs': classs.map((e) => e.toJson()).toList(),
      'extensions': extensions.map((e) => e.toJson()).toList(),
      'topLevelVariables': topLevelVariables.map((e) => e.toJson()).toList(),
      'functions': functions.map((e) => e.toJson()).toList(),
      'enums': enums.map((e) => e.toJson()).toList(),
      'mixins': mixins.map((e) => e.toJson()).toList(),
    };
  }
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
}

class AnalyzerLibraryElementCacheImpl
    extends AnalyzerFileCache<LibraryElementImpl> {
  AnalyzerLibraryElementCacheImpl(super.element);

  @override
  List<AnalyzerClassCache> get classs => element.units
      .map((e) => e.classes)
      .expand((element) => element)
      .map((e) => AnalyzerClassElementCacheImpl(e))
      .toList();

  @override
  List<AnalyzerEnumCache> get enums => element.units
      .map((e) => e.enums)
      .expand((element) => element)
      .map((e) => AnalyzerEnumElementCacheImpl(e))
      .toList();

  @override
  List<AnalyzerExtensionCache> get extensions => element.units
      .map((e) => e.extensions)
      .expand((element) => element)
      .map((e) => AnalyzerExtensionElementCacheImpl(e))
      .toList();

  @override
  List<AnalyzerMethodCache> get functions => element.units
      .map((e) => e.functions)
      .expand((element) => element)
      .map((e) => AnalyzerFunctionElementCacheImpl(e))
      .toList();

  @override
  List<AnalyzerMixinCache> get mixins => element.units
      .map((e) => e.mixins)
      .expand((element) => element)
      .map((e) => AnalyzerMixinElementCacheImpl(e))
      .toList();

  @override
  List<AnalyzerPropertyAccessorCache> get topLevelVariables => element.units
      .map((e) => e.topLevelVariables)
      .expand((element) => element)
      .map((e) => AnalyzerTopLevelVariableElementCacheImpl(e))
      .toList();
}

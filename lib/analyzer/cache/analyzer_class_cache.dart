// ignore_for_file: implementation_imports

import 'package:analyzer/src/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_cache.dart';
import 'analyzer_property_accessor_cache.dart';
import 'analyzer_method_cache.dart';

abstract class AnalyzerClassCache<T> extends AnalyzerCache<T> {
  AnalyzerClassCache(super.element);
  List<AnalyzerPropertyAccessorCache> get fields;
  List<AnalyzerMethodCache> get methods;
  List<AnalyzerMethodCache> get constructors;
  String get name;
  bool get isAbstract;

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson()}..addAll(
        {
          'isAbstract': isAbstract,
          'name': name,
          'fields': fields.map((e) => e.toJson()).toList(),
          'methods': methods.map((e) => e.toJson()).toList(),
          'constructors': constructors.map((e) => e.toJson()).toList(),
          'isEnabled': isEnable,
        },
      );
  }
}

class AnalyzerClassJsonCacheImpl
    extends AnalyzerClassCache<Map<String, dynamic>> {
  AnalyzerClassJsonCacheImpl(super.element);

  @override
  List<AnalyzerMethodCache> get constructors => JSON(element)['constructors']
      .listValue
      .map((e) => AnalyzerMethodJsonCacheImpl(e))
      .toList();

  @override
  List<AnalyzerPropertyAccessorCache> get fields => JSON(element)['fields']
      .listValue
      .map((e) => AnalyzerPropertyAccessorJsonCacheImpl(e))
      .toList();

  @override
  bool get isAbstract => JSON(element)['isAbstract'].boolValue;

  @override
  List<AnalyzerMethodCache> get methods => JSON(element)['methods']
      .listValue
      .map((e) => AnalyzerMethodJsonCacheImpl(e))
      .toList();

  @override
  String get name => JSON(element)['name'].stringValue;
}

class AnalyzerClassElementCacheImpl
    extends AnalyzerClassCache<ClassElementImpl> {
  AnalyzerClassElementCacheImpl(super.element);

  @override
  List<AnalyzerMethodCache> get constructors => element.constructors
      .map((e) => AnalyzerConstructorElementCacheImpl(e))
      .toList();

  @override
  List<AnalyzerPropertyAccessorCache> get fields =>
      element.fields.map((e) => AnalyzerFieldElementCacheImpl(e)).toList();

  @override
  bool get isAbstract => element.isAbstract;

  @override
  List<AnalyzerMethodCache> get methods =>
      element.methods.map((e) => AnalyzerMethodElementCacheImpl(e)).toList();

  @override
  String get name => element.name;
}

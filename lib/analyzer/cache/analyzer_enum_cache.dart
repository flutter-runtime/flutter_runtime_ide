// ignore_for_file: implementation_imports

import 'package:analyzer/src/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'analyzer_property_accessor_cache.dart';
import 'analyzer_method_cache.dart';

abstract class AnalyzerEnumCache<T> {
  final T element;
  bool isEnable = true;
  List<AnalyzerPropertyAccessorCache> get fields;
  List<AnalyzerMethodCache> get methods;
  String get name;
  AnalyzerEnumCache(this.element);

  Map<String, dynamic> toJson() {
    return {
      'isEnable': isEnable,
      'name': name,
      'fields': fields.map((e) => e.toJson()).toList(),
      'methods': methods.map((e) => e.toJson()).toList(),
    };
  }
}

class AnalyzerEnumJsonCacheImpl
    extends AnalyzerEnumCache<Map<String, dynamic>> {
  AnalyzerEnumJsonCacheImpl(super.element);

  @override
  String get name => JSON(element)['name'].stringValue;

  @override
  List<AnalyzerPropertyAccessorCache> get fields => JSON(element)['fields']
      .listValue
      .map((e) => AnalyzerPropertyAccessorJsonCacheImpl(e))
      .toList();

  @override
  List<AnalyzerMethodCache> get methods => JSON(element)['methods']
      .listValue
      .map((e) => AnalyzerMethodJsonCacheImpl(e))
      .toList();
}

class AnalyzerEnumElementCacheImpl extends AnalyzerEnumCache<EnumElementImpl> {
  AnalyzerEnumElementCacheImpl(super.element);

  @override
  List<AnalyzerPropertyAccessorCache> get fields =>
      element.fields.map((e) => AnalyzerFieldElementCacheImpl(e)).toList();

  @override
  List<AnalyzerMethodCache> get methods =>
      element.methods.map((e) => AnalyzerMethodElementCacheImpl(e)).toList();

  @override
  String get name => element.name;
}

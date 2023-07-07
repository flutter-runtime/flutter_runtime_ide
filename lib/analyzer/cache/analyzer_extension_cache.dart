// ignore_for_file: implementation_imports

import 'package:analyzer/src/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'analyzer_property_accessor_cache.dart';
import 'analyzer_method_cache.dart';

abstract class AnalyzerExtensionCache<T> {
  final T element;
  bool isEnable = true;
  List<AnalyzerPropertyAccessorCache> get fields;
  List<AnalyzerMethodCache> get methods;
  String? get name;
  AnalyzerExtensionCache(this.element);

  Map<String, dynamic> toJson() {
    return {
      'fields': fields.map((e) => e.toJson()).toList(),
      'methods': methods.map((e) => e.toJson()).toList(),
      'name': name,
      'isEnable': isEnable,
    };
  }
}

class AnalyzerExtensionJsonCacheImpl
    extends AnalyzerExtensionCache<Map<String, dynamic>> {
  AnalyzerExtensionJsonCacheImpl(super.element);

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

  @override
  String? get name => JSON(element)['name'].string;
}

class AnalyzerExtensionElementCacheImpl
    extends AnalyzerExtensionCache<ExtensionElementImpl> {
  AnalyzerExtensionElementCacheImpl(super.element);

  @override
  List<AnalyzerPropertyAccessorCache> get fields =>
      element.fields.map((e) => AnalyzerFieldElementCacheImpl(e)).toList();

  @override
  List<AnalyzerMethodCache> get methods =>
      element.methods.map((e) => AnalyzerMethodElementCacheImpl(e)).toList();

  @override
  String? get name => element.name;
}

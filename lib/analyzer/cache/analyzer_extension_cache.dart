// ignore_for_file: implementation_imports

import 'package:analyzer/src/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'analyzer_cache.dart';
import 'analyzer_property_accessor_cache.dart';
import 'analyzer_method_cache.dart';

abstract class AnalyzerExtensionCache<T> extends AnalyzerCache<T> {
  List<AnalyzerPropertyAccessorCache> get fields;
  List<AnalyzerMethodCache> get methods;
  String? get name;

  /// 扩展名称
  String get extensionName;
  AnalyzerExtensionCache(super.element);

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson()}..addAll(
        {
          'fields': fields.map((e) => e.toJson()).toList(),
          'methods': methods.map((e) => e.toJson()).toList(),
          'name': name,
          'isEnable': isEnable,
          'extensionName': extensionName,
        },
      );
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

  @override
  String get extensionName => JSON(element)['extensionName'].stringValue;
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

  @override
  String get extensionName => element.extendedType.toString();
}

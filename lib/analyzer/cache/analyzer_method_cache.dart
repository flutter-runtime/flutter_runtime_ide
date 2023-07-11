// ignore_for_file: implementation_imports

import 'package:analyzer/src/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'analyzer_cache.dart';
import 'analyzer_property_accessor_cache.dart';

abstract class AnalyzerMethodCache<T> extends AnalyzerCache<T> {
  String get name;
  List<AnalyzerPropertyAccessorCache> get parameters;
  bool get isStatic;
  AnalyzerMethodCache(super.element);

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson()}..addAll(
        {
          'isStatic': isStatic,
          'name': name,
          'parameters': parameters.map((e) => e.toJson()).toList(),
        },
      );
  }
}

class AnalyzerMethodJsonCacheImpl
    extends AnalyzerMethodCache<Map<String, dynamic>> {
  AnalyzerMethodJsonCacheImpl(super.element);

  @override
  bool get isStatic => JSON(element)['isStatic'].boolValue;

  @override
  String get name => JSON(element)['name'].stringValue;

  @override
  List<AnalyzerPropertyAccessorCache> get parameters =>
      JSON(element)['parameters']
          .listValue
          .map((e) => AnalyzerPropertyAccessorJsonCacheImpl(e))
          .toList();
}

class AnalyzerFunctionElementCacheImpl
    extends AnalyzerMethodCache<FunctionElementImpl> {
  AnalyzerFunctionElementCacheImpl(super.element);

  @override
  bool get isStatic => element.isStatic;

  @override
  String get name => element.name;

  @override
  List<AnalyzerPropertyAccessorCache> get parameters => element.parameters
      .map((e) => AnalyzerParameterElementCacheImpl(e as ParameterElementImpl))
      .toList();
}

class AnalyzerConstructorElementCacheImpl
    extends AnalyzerMethodCache<ConstructorElementImpl> {
  AnalyzerConstructorElementCacheImpl(super.element);

  @override
  bool get isStatic => element.isStatic;

  @override
  String get name => element.name;

  @override
  List<AnalyzerPropertyAccessorCache> get parameters => element.parameters
      .map((e) => AnalyzerParameterElementCacheImpl(e as ParameterElementImpl))
      .toList();
}

class AnalyzerMethodElementCacheImpl
    extends AnalyzerMethodCache<MethodElementImpl> {
  AnalyzerMethodElementCacheImpl(super.element);

  @override
  bool get isStatic => element.isStatic;

  @override
  String get name => element.name;

  @override
  List<AnalyzerPropertyAccessorCache> get parameters => element.parameters
      .map((e) => AnalyzerParameterElementCacheImpl(e as ParameterElementImpl))
      .toList();
}

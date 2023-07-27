// ignore_for_file: implementation_imports

import 'package:analyze_cache/analyze_cache.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'analyzer_property_accessor_cache.dart';

class AnalyzerFunctionElementCacheImpl
    extends AnalyzerMethodCache<FunctionElementImpl> {
  AnalyzerFunctionElementCacheImpl(super.element, super.map, [super.parent]);

  @override
  void fromMap(Map map) {
    super.fromMap(map);
    parameters = element.parameters
        .map((e) => AnalyzerParameterElementCacheImpl(e as ParameterElementImpl,
            JSON(map)['parameters'][e.name].mapValue, this))
        .toList();
    isStatic = element.isStatic;
    name = element.name;
  }
}

class AnalyzerConstructorElementCacheImpl
    extends AnalyzerMethodCache<ConstructorElementImpl> {
  AnalyzerConstructorElementCacheImpl(super.element, super.map, [super.parent]);

  @override
  void fromMap(Map map) {
    super.fromMap(map);
    parameters = element.parameters
        .map((e) => AnalyzerParameterElementCacheImpl(
            e as ParameterElementImpl, map.getParameter(e.name) ?? {}, this))
        .toList();
    isStatic = element.isStatic;
    name = element.name;
  }
}

class AnalyzerMethodElementCacheImpl
    extends AnalyzerMethodCache<MethodElementImpl> {
  AnalyzerMethodElementCacheImpl(super.element, super.map, [super.parent]);
  @override
  void fromMap(Map map) {
    super.fromMap(map);
    parameters = element.parameters
        .map((e) => AnalyzerParameterElementCacheImpl(
            e as ParameterElementImpl, map.getParameter(e.name) ?? {}, this))
        .toList();
    isStatic = element.isStatic;
    name = element.name;
  }
}

extension on Map {
  Map? getParameter(String name) {
    return JSON(this)['parameters'].listValue.firstWhereOrNull((element) {
      return JSON(element)['name'].stringValue == name;
    });
  }
}

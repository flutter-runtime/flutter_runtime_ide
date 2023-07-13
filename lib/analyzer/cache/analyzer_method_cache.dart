// ignore_for_file: implementation_imports

import 'package:analyzer/src/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter_runtime_ide/common/common_function.dart';
import 'package:get/get.dart';
import '../../app/modules/fix_config/controllers/fix_select_controller.dart';
import 'analyzer_cache.dart';
import 'analyzer_property_accessor_cache.dart';

class AnalyzerMethodCache<T> extends AnalyzerCache<T> with FixSelectItem {
  @override
  late String name;
  List<AnalyzerPropertyAccessorCache> parameters = [];
  late bool isStatic;
  AnalyzerMethodCache(super.element, super.map, [super.parent]);

  @override
  void addToMap() {
    super.addToMap();
    this['isStatic'] = isStatic;
    this['name'] = name;
    this['parameters'] = parameters.map((e) => e.toJson()).toList();
  }

  @override
  void fromMap(Map map) {
    super.fromMap(map);
    parameters = JSON(element)['parameters']
        .listValue
        .map((e) => AnalyzerPropertyAccessorCache(e, e, this))
        .toList();
    isStatic = JSON(element)['isStatic'].boolValue;
    name = JSON(element)['name'].stringValue;
  }
}

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

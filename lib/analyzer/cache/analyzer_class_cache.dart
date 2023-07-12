// ignore_for_file: implementation_imports

import 'package:analyzer/src/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_cache.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_select_controller.dart';
import 'package:get/get.dart';
import 'analyzer_property_accessor_cache.dart';
import 'analyzer_method_cache.dart';

class AnalyzerClassCache<T> extends AnalyzerCache<T> with FixSelectItem {
  AnalyzerClassCache(super.element, super.map);
  List<AnalyzerPropertyAccessorCache> fields = [];
  List<AnalyzerMethodCache> methods = [];
  List<AnalyzerMethodCache> constructors = [];
  @override
  late String name;
  late bool isAbstract;

  @override
  void addToMap() {
    super.addToMap();
    this['isAbstract'] = isAbstract;
    this['name'] = name;
    this['fields'] = fields.map((e) => e.toJson()).toList();
    this['methods'] = methods.map((e) => e.toJson()).toList();
    this['constructors'] = constructors.map((e) => e.toJson()).toList();
  }

  @override
  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    constructors = JSON(element)['constructors']
        .listValue
        .map((e) => AnalyzerMethodCache(e, e))
        .toList();
    fields = JSON(element)['fields']
        .listValue
        .map((e) => AnalyzerPropertyAccessorCache(e, e))
        .toList();
    methods = JSON(element)['methods']
        .listValue
        .map((e) => AnalyzerMethodCache(e, e))
        .toList();
  }
}

class AnalyzerClassElementCacheImpl
    extends AnalyzerClassCache<ClassElementImpl> {
  AnalyzerClassElementCacheImpl(super.element, super.map);

  @override
  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    constructors = element.constructors
        .map((e) => AnalyzerConstructorElementCacheImpl(
              e,
              map.getConstructor(e.name) ?? {},
            ))
        .toList();
    fields = element.fields
        .map((e) =>
            AnalyzerFieldElementCacheImpl(e, map.getFields(e.name) ?? {}))
        .toList();
    methods = element.methods
        .map((e) =>
            AnalyzerMethodElementCacheImpl(e, map.getMethod(e.name) ?? {}))
        .toList();
    isAbstract = element.isAbstract;
    name = element.name;
  }
}

extension on Map<String, dynamic> {
  Map<String, dynamic>? getConstructor(String name) {
    return JSON(this)['constructors'].listValue.firstWhereOrNull((element) {
      return JSON(element)['name'].stringValue == name;
    });
  }

  Map<String, dynamic>? getMethod(String name) {
    return JSON(this)['methods'].listValue.firstWhereOrNull((element) {
      return JSON(element)['name'].stringValue == name;
    });
  }

  Map<String, dynamic>? getFields(String name) {
    return JSON(this)['fields'].listValue.firstWhereOrNull((element) {
      return JSON(element)['name'].stringValue == name;
    });
  }
}

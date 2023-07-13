// ignore_for_file: implementation_imports

import 'package:analyzer/src/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_cache.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_select_controller.dart';
import 'package:get/get.dart';
import 'analyzer_property_accessor_cache.dart';
import 'analyzer_method_cache.dart';

class AnalyzerClassCache<T> extends AnalyzerCache<T> with FixSelectItem {
  AnalyzerClassCache(super.element, super.map, [super.parent]);
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
  void fromMap(Map map) {
    super.fromMap(map);
    constructors = JSON(map)['constructors']
        .listValue
        .map((e) => AnalyzerMethodCache(e, e, this))
        .toList();
    fields = JSON(map)['fields']
        .listValue
        .map((e) => AnalyzerPropertyAccessorCache(e, e, this))
        .toList();
    methods = JSON(map)['methods']
        .listValue
        .map((e) => AnalyzerMethodCache(e, e, this))
        .toList();
    name = JSON(map)['name'].stringValue;
    isAbstract = JSON(map)['isAbstract'].boolValue;
  }

  String? defaultValueCodeFromClass(String name) {
    final field = fields.firstWhereOrNull((element) => element.name == name);
    if (field != null && field.isStatic) {
      return '${this.name}.${field.name}';
    }
    return null;
  }
}

class AnalyzerClassElementCacheImpl
    extends AnalyzerClassCache<ClassElementImpl> {
  AnalyzerClassElementCacheImpl(super.element, super.map, [super.parent]);

  @override
  void fromMap(Map map) {
    super.fromMap(map);
    constructors = element.constructors
        .map((e) => AnalyzerConstructorElementCacheImpl(
            e, map.getConstructor(e.name) ?? {}, this))
        .toList();
    fields = element.fields
        .map((e) =>
            AnalyzerFieldElementCacheImpl(e, map.getFields(e.name) ?? {}, this))
        .toList();
    methods = element.methods
        .map((e) => AnalyzerMethodElementCacheImpl(
            e, map.getMethod(e.name) ?? {}, this))
        .toList();
    isAbstract = element.isAbstract;
    name = element.name;
  }
}

extension on Map {
  Map? getConstructor(String name) {
    return JSON(this)['constructors'].listValue.firstWhereOrNull((element) {
      return JSON(element)['name'].stringValue == name;
    });
  }

  Map? getMethod(String name) {
    return JSON(this)['methods'].listValue.firstWhereOrNull((element) {
      return JSON(element)['name'].stringValue == name;
    });
  }

  Map? getFields(String name) {
    return JSON(this)['fields'].listValue.firstWhereOrNull((element) {
      return JSON(element)['name'].stringValue == name;
    });
  }
}

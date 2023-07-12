// ignore_for_file: implementation_imports

import 'package:analyzer/src/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:get/get.dart';
import '../../app/modules/fix_config/controllers/fix_select_controller.dart';
import 'analyzer_cache.dart';
import 'analyzer_property_accessor_cache.dart';
import 'analyzer_method_cache.dart';

class AnalyzerEnumCache<T> extends AnalyzerCache<T> with FixSelectItem {
  List<AnalyzerPropertyAccessorCache> fields = [];
  List<AnalyzerMethodCache> methods = [];
  @override
  late String name;
  AnalyzerEnumCache(super.element, super.map);

  @override
  void addToMap() {
    super.addToMap();
    this['fields'] = fields.map((e) => e.toJson()).toList();
    this['methods'] = methods.map((e) => e.toJson()).toList();
    this['name'] = name;
  }

  @override
  void fromMap(Map map) {
    super.fromMap(map);
    fields = JSON(element)['fields']
        .listValue
        .map((e) => AnalyzerPropertyAccessorCache(e, e))
        .toList();
    methods = JSON(element)['methods']
        .listValue
        .map((e) => AnalyzerMethodCache(e, e))
        .toList();
    name = JSON(element)['name'].stringValue;
  }
}

class AnalyzerEnumElementCacheImpl extends AnalyzerEnumCache<EnumElementImpl> {
  AnalyzerEnumElementCacheImpl(super.element, super.map);

  @override
  void fromMap(Map map) {
    super.fromMap(map);
    fields = element.fields
        .map(
            (e) => AnalyzerFieldElementCacheImpl(e, map.getField(e.name) ?? {}))
        .toList();
    methods = element.methods
        .map((e) =>
            AnalyzerMethodElementCacheImpl(e, map.getMethod(e.name) ?? {}))
        .toList();
    name = element.name;
  }
}

extension on Map {
  Map? getField(String name) {
    return JSON(this)['fields'].listValue.firstWhereOrNull((element) {
      return JSON(element)['name'].stringValue == name;
    });
  }

  Map? getMethod(String name) {
    return JSON(this)['methods'].listValue.firstWhereOrNull((element) {
      return JSON(element)['name'].stringValue == name;
    });
  }
}

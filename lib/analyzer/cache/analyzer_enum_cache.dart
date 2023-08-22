// ignore_for_file: implementation_imports

import 'package:analyze_cache/analyze_cache.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'analyzer_property_accessor_cache.dart';
import 'analyzer_method_cache.dart';

class AnalyzerEnumElementCacheImpl extends AnalyzerEnumCache<EnumElementImpl> {
  AnalyzerEnumElementCacheImpl(super.element, super.map, [super.parent]);

  @override
  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    fields = element.fields
        .map((e) =>
            AnalyzerFieldElementCacheImpl(e, map.getField(e.name) ?? {}, this))
        .toList();
    methods = element.methods
        .map((e) => AnalyzerMethodElementCacheImpl(
            e, map.getMethod(e.name) ?? {}, this))
        .toList();
    name = element.name;
  }
}

extension on Map {
  Map<String, dynamic>? getField(String name) {
    return JSON(this)['fields'].listValue.firstWhereOrNull((element) {
      return JSON(element)['name'].stringValue == name;
    });
  }

  Map<String, dynamic>? getMethod(String name) {
    return JSON(this)['methods'].listValue.firstWhereOrNull((element) {
      return JSON(element)['name'].stringValue == name;
    });
  }
}

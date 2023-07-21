// ignore_for_file: implementation_imports

import 'package:analyze_cache/analyze_cache.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'analyzer_method_cache.dart';
import 'analyzer_property_accessor_cache.dart';

class AnalyzerMixinElementCacheImpl
    extends AnalyzerMixinCache<MixinElementImpl> {
  AnalyzerMixinElementCacheImpl(super.element, super.map, [super.parent]);

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

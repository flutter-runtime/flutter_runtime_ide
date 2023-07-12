// ignore_for_file: implementation_imports

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter_runtime_ide/common/common_function.dart';
import 'package:get/get.dart';
import '../../app/modules/fix_config/controllers/fix_select_controller.dart';
import 'analyzer_cache.dart';
import 'analyzer_property_accessor_cache.dart';
import 'analyzer_method_cache.dart';

class AnalyzerExtensionCache<T> extends AnalyzerCache<T> with FixSelectItem {
  List<AnalyzerPropertyAccessorCache> fields = [];
  List<AnalyzerMethodCache> methods = [];
  @override
  late String name;

  /// 扩展名称
  String? extensionName;
  AnalyzerExtensionCache(super.element, super.map);

  @override
  void addToMap() {
    super.addToMap();
    this['fields'] = fields.map((e) => e.toJson()).toList();
    this['methods'] = methods.map((e) => e.toJson()).toList();
    this['name'] = name;
    this['extensionName'] = extensionName;
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
    extensionName = JSON(element)['extensionName'].stringValue;
    name = JSON(element)['name'].stringValue;
  }
}

class AnalyzerExtensionElementCacheImpl
    extends AnalyzerExtensionCache<ExtensionElementImpl> {
  AnalyzerExtensionElementCacheImpl(super.element, super.map);

  @override
  void fromMap(Map map) {
    super.fromMap(map);
    fields = element.fields
        .map((e) => AnalyzerFieldElementCacheImpl(
              e,
              map.getField(e.name) ?? {},
            ))
        .toList();
    methods = element.methods
        .map((e) => AnalyzerMethodElementCacheImpl(
              e,
              map.getMethod(e.name) ?? {},
            ))
        .toList();
    name = element.name ?? '';

    final node = getAstNodeFromElement(element);

    Unwrap(node)
        .map((e) => e as ExtensionDeclaration)
        .map((e) => e.extendedType.toSource())
        .map((e) => extensionName = e);
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

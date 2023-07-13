// ignore_for_file: implementation_imports

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import '../../app/modules/fix_config/controllers/fix_select_controller.dart';
import '../../common/common_function.dart';
import 'analyzer_cache.dart';

class AnalyzerPropertyAccessorCache<T> extends AnalyzerCache<T>
    with FixSelectItem {
  @override
  late String name;
  late bool isStatic;
  late bool isGetter;
  late bool isSetter;
  late bool isNamed;
  late bool hasDefaultValue;
  String? defaultValueCode;
  String? asName;
  AnalyzerPropertyAccessorCache(super.element, super.map, [super.parent]);

  @override
  void addToMap() {
    super.addToMap();
    this['isStatic'] = isStatic;
    this['name'] = name;
    this['isGetter'] = isGetter;
    this['isSetter'] = isSetter;
    this['isNamed'] = isNamed;
    this['hasDefaultValue'] = hasDefaultValue;
    this['defaultValueCode'] = defaultValueCode;
    this['asName'] = asName;
  }

  @override
  void fromMap(Map map) {
    super.fromMap(map);

    isStatic = JSON(element)['isStatic'].boolValue;
    name = JSON(element)['name'].stringValue;
    isGetter = JSON(element)['isGetter'].boolValue;
    isSetter = JSON(element)['isSetter'].boolValue;
    isNamed = JSON(element)['isNamed'].boolValue;
    hasDefaultValue = JSON(element)['hasDefaultValue'].boolValue;
    defaultValueCode = JSON(element)['defaultValueCode'].string;
    asName = JSON(element)['asName'].string;
  }
}

class AnalyzerPropertyAccessorElementCacheImpl
    extends AnalyzerPropertyAccessorCache<PropertyAccessorElementImpl> {
  AnalyzerPropertyAccessorElementCacheImpl(super.element, super.map,
      [super.parent]);

  @override
  void fromMap(Map map) {
    super.fromMap(map);

    isStatic = element.isStatic;
    name = element.name;
    isGetter = element.isGetter;
    isSetter = element.isSetter;
  }
}

class AnalyzerParameterElementCacheImpl
    extends AnalyzerPropertyAccessorCache<ParameterElementImpl> {
  AnalyzerParameterElementCacheImpl(super.element, super.map, [super.parent]);

  @override
  void fromMap(Map map) {
    super.fromMap(map);

    isStatic = element.isStatic;
    name = element.name;
    isNamed = element.isNamed;
    hasDefaultValue = element.hasDefaultValue;
    defaultValueCode = element.defaultValueCode;
    final type = element.type;
    if (type is InvalidType) {
      // final node = getAstNodeFromElement(element);
      // if (node is SimpleFormalParameter) {

      // }
      // logger.i(node);
    } else {
      final asName2 = element.asName;
      Unwrap(asName2).map((e) => asName = e);
    }
  }
}

class AnalyzerFieldElementCacheImpl
    extends AnalyzerPropertyAccessorCache<FieldElementImpl> {
  AnalyzerFieldElementCacheImpl(super.element, super.map, [super.parent]);

  @override
  void fromMap(Map map) {
    super.fromMap(map);

    isStatic = element.isStatic;
    name = element.name;
  }
}

class AnalyzerTopLevelVariableElementCacheImpl
    extends AnalyzerPropertyAccessorCache<TopLevelVariableElementImpl> {
  AnalyzerTopLevelVariableElementCacheImpl(super.element, super.map,
      [super.parent]);

  @override
  void fromMap(Map map) {
    super.fromMap(map);
    isStatic = element.isStatic;
    name = element.name;
    Unwrap(element.constantInitializer)
        .map((e) => defaultValueCode = e.toSource());
  }
}

extension on ParameterElementImpl {
  String? get asName => type.bound2?.name;
}

extension DartTypeBound on DartType {
  DartType? get bound2 {
    if (this is TypeParameterType) {
      final type = this as TypeParameterType;
      final bound = type.bound;
      if (bound is InvalidType) return null;
      final bound0 = bound.bound2;
      return bound0 ?? bound;
    } else {
      return null;
    }
  }
}

extension on SimpleFormalParameter {}

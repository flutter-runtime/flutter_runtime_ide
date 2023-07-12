// ignore_for_file: implementation_imports

import 'package:analyzer/src/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import '../../app/modules/fix_config/controllers/fix_select_controller.dart';
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
  AnalyzerPropertyAccessorCache(super.element, super.map);

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
  void fromMap(Map<String, dynamic> map) {
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
  AnalyzerPropertyAccessorElementCacheImpl(super.element, super.map);

  @override
  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);

    isStatic = element.isStatic;
    name = element.name;
    isGetter = element.isGetter;
    isSetter = element.isSetter;
  }
}

class AnalyzerParameterElementCacheImpl
    extends AnalyzerPropertyAccessorCache<ParameterElementImpl> {
  AnalyzerParameterElementCacheImpl(super.element, super.map);

  @override
  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);

    isStatic = element.isStatic;
    name = element.name;
    isNamed = element.isNamed;
    hasDefaultValue = element.hasDefaultValue;
    defaultValueCode = element.defaultValueCode;
  }
}

class AnalyzerFieldElementCacheImpl
    extends AnalyzerPropertyAccessorCache<FieldElementImpl> {
  AnalyzerFieldElementCacheImpl(super.element, super.map);

  @override
  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);

    isStatic = element.isStatic;
    name = element.name;
  }
}

class AnalyzerTopLevelVariableElementCacheImpl
    extends AnalyzerPropertyAccessorCache<TopLevelVariableElementImpl> {
  AnalyzerTopLevelVariableElementCacheImpl(super.element, super.map);

  @override
  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    isStatic = element.isStatic;
    name = element.name;
  }
}

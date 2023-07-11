// ignore_for_file: implementation_imports

import 'package:analyzer/src/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

import 'analyzer_cache.dart';

abstract class AnalyzerPropertyAccessorCache<T> extends AnalyzerCache<T> {
  String get name;
  bool get isStatic;
  bool get isGetter;
  bool get isSetter;
  bool get isNamed;
  bool get hasDefaultValue;
  String? get defaultValueCode;
  AnalyzerPropertyAccessorCache(super.element);

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson()}..addAll(
        {
          'isStatic': isStatic,
          'name': name,
          'isGetter': isGetter,
          'isSetter': isSetter,
          'isEnable': isEnable,
          'hasDefaultValue': hasDefaultValue,
          'isNamed': isNamed,
          'defaultValueCode': defaultValueCode,
        },
      );
  }
}

class AnalyzerPropertyAccessorJsonCacheImpl
    extends AnalyzerPropertyAccessorCache<Map<String, dynamic>> {
  AnalyzerPropertyAccessorJsonCacheImpl(super.element);

  @override
  bool get isStatic => JSON(element)['isStatic'].boolValue;

  @override
  String get name => JSON(element)['name'].stringValue;

  @override
  bool get isGetter => JSON(element)['isGetter'].boolValue;

  @override
  bool get isSetter => JSON(element)['isSetter'].boolValue;

  @override
  bool get isEnable => JSON(element)['isEnable'].bool ?? super.isEnable;

  @override
  bool get isNamed => JSON(element)['isNamed'].boolValue;

  @override
  bool get hasDefaultValue => JSON(element)['hasDefaultValue'].boolValue;

  @override
  String? get defaultValueCode => JSON(element)['defaultValueCode'].string;
}

class AnalyzerPropertyAccessorElementCacheImpl
    extends AnalyzerPropertyAccessorCache<PropertyAccessorElementImpl> {
  AnalyzerPropertyAccessorElementCacheImpl(super.element);

  @override
  bool get isStatic => element.isStatic;

  @override
  String get name => element.name;

  @override
  bool get isGetter => element.isGetter;

  @override
  bool get isSetter => element.isSetter;

  @override
  bool get isNamed => false;

  @override
  bool get hasDefaultValue => false;

  @override
  String? get defaultValueCode => null;
}

class AnalyzerParameterElementCacheImpl
    extends AnalyzerPropertyAccessorCache<ParameterElementImpl> {
  AnalyzerParameterElementCacheImpl(super.element);

  @override
  bool get isStatic => element.isStatic;

  @override
  String get name => element.name;

  @override
  bool get isGetter => false;

  @override
  bool get isSetter => false;

  @override
  bool get isNamed => element.isNamed;

  @override
  bool get hasDefaultValue => element.hasDefaultValue;

  @override
  String? get defaultValueCode => element.defaultValueCode;
}

class AnalyzerFieldElementCacheImpl
    extends AnalyzerPropertyAccessorCache<FieldElementImpl> {
  AnalyzerFieldElementCacheImpl(super.element);

  @override
  bool get isGetter => false;

  @override
  bool get isSetter => false;

  @override
  bool get isStatic => element.isStatic;

  @override
  String get name => element.name;

  @override
  bool get isNamed => false;

  @override
  bool get hasDefaultValue => false;

  @override
  String? get defaultValueCode => null;
}

class AnalyzerTopLevelVariableElementCacheImpl
    extends AnalyzerPropertyAccessorCache<TopLevelVariableElementImpl> {
  AnalyzerTopLevelVariableElementCacheImpl(super.element);

  @override
  bool get isGetter => element.getter != null;

  @override
  bool get isSetter => element.setter != null;

  @override
  bool get isStatic => element.isStatic;

  @override
  String get name => element.name;

  @override
  bool get isNamed => false;

  @override
  bool get hasDefaultValue => false;

  @override
  String? get defaultValueCode => null;
}

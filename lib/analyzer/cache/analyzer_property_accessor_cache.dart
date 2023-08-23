// ignore_for_file: implementation_imports, deprecated_member_use

import 'package:analyze_cache/analyze_cache.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import '../../common/common_function.dart';

class AnalyzerPropertyAccessorElementCacheImpl
    extends AnalyzerPropertyAccessorCache<PropertyAccessorElementImpl> {
  AnalyzerPropertyAccessorElementCacheImpl(super.element, super.map,
      [super.parent]);

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
  AnalyzerParameterElementCacheImpl(super.element, super.map, [super.parent]);

  @override
  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);

    isStatic = element.isStatic;
    name = element.name;
    isNamed = element.isNamed;
    hasDefaultValue = element.hasDefaultValue;
    defaultValueCode = element.constantValue ?? element.defaultValueCode;
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
  void fromMap(Map<String, dynamic> map) {
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
  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    isStatic = element.isStatic;
    name = element.name;
    Unwrap(element.constantInitializer)
        .map((e) => defaultValueCode = e.toSource());
  }
}

extension on ParameterElementImpl {
  String? get asName => type.bound2?.name;

  String? get constantValue {
    return Unwrap(constantInitializer).map((e) {
      if (e is SimpleIdentifier) {
        return Unwrap(e.staticElement).map((e) {
          if (e is PropertyAccessorElementImpl) {
            return Unwrap(e.variable).map((e) {
              if (e is ConstFieldElementImpl) {
                return Unwrap(e.constantInitializer).map((e) {
                  if (e is DoubleLiteral) {
                    return e.literal.lexeme;
                  } else {
                    logger.e(e.runtimeType);
                  }
                  return null;
                }).value;
              }
              return null;
            }).value;
          }
          return null;
        }).value;
      }
      return null;
    }).value;
  }
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

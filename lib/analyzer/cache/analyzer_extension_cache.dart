import 'package:analyze_cache/analyze_cache.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter_runtime_ide/common/common_function.dart';
import 'package:get/get.dart';
import '../../app/modules/fix_config/controllers/fix_select_controller.dart';
import 'analyzer_cache.dart';
import 'analyzer_property_accessor_cache.dart';
import 'analyzer_method_cache.dart';

class AnalyzerExtensionElementCacheImpl
    extends AnalyzerExtensionCache<ExtensionElementImpl> {
  AnalyzerExtensionElementCacheImpl(super.element, super.map, [super.parent]);

  @override
  void fromMap(Map map) {
    super.fromMap(map);
    fields = element.fields
        .map((e) =>
            AnalyzerFieldElementCacheImpl(e, map.getField(e.name) ?? {}, this))
        .toList();
    methods = element.methods
        .map((e) => AnalyzerMethodElementCacheImpl(
            e, map.getMethod(e.name) ?? {}, this))
        .toList();
    name = element.name ?? '';

    final node = getAstNodeFromElement(element);

    Unwrap(node)
        .map((e) => e as ExtensionDeclaration)
        .map((e) => e.extendedType.toSource())
        .map((e) {
      final typeParameterMap = element.typeParameterMap;
      return extensionName = convertToDefaultType(e, typeParameterMap);
    });
  }

  /// 将泛型转换为默认类型
  String convertToDefaultType(
      String content, Map<String, String> typeParameterMap) {
    final allMatches = content.typeParameterMatchs;
    if (allMatches.isEmpty) return typeParameterMap[content] ?? content;
    if (allMatches.length != 1) {
      throw UnimplementedError();
    }
    final match = allMatches.first;
    final prefix = content.substring(0, match.start);
    final suffix = content.substring(match.start + 1, match.end - 1);
    final types = suffix.split(',').map((e) {
      return convertToDefaultType(e, typeParameterMap);
    });
    final prefixType = typeParameterMap[prefix] ?? prefix;
    final converContent = '$prefixType<${types.join(', ')}>';
    return converContent;
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

extension on ExtensionElementImpl {
  Map<String, String> get typeParameterMap {
    Map<String, String> map = {};
    for (var element in typeParameters) {
      final name = element.name;
      final bound = element.bound;
      final bound2 = bound?.bound2;
      final asName = bound2?.name ?? bound?.name ?? 'dynamic';
      map[name] = asName;
    }
    return map;
  }
}

extension on String {
  Iterable<RegExpMatch> get typeParameterMatchs {
    return RegExp(r'<.*>').allMatches(this);
  }
}

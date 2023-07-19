import 'package:flutter_runtime_ide/analyzer/muatache_data/mustache_field_data.dart';
import 'package:flutter_runtime_ide/analyzer/muatache_data/mustache_method_data.dart';

import 'mustache_constructor_data.dart';

class MustacheClassData {
  final String className;
  final List<MustacheFieldData> getFields;
  final List<MustacheFieldData> setFields;
  final List<MustacheMethodData> methods;
  final List<MustacheConstructorData> constructors;
  final bool isAbstract;
  final String? runtimeTypeString;
  final String? instanceType;
  final String prefix;
  final String staticPrefix;
  final bool isGlobal;
  final List<String> runtimeNames;

  MustacheClassData({
    required this.className,
    required this.getFields,
    required this.setFields,
    required this.methods,
    required this.constructors,
    required this.isAbstract,
    required this.runtimeTypeString,
    required this.instanceType,
    required this.prefix,
    required this.staticPrefix,
    this.isGlobal = false,
    this.runtimeNames = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'className': className,
      'getFields': getFields.map((e) => e.toJson()).toList(),
      'setFields': setFields.map((e) => e.toJson()).toList(),
      'methods': methods.map((e) => e.toJson()).toList(),
      'constructors': constructors.map((e) => e.toJson()).toList(),
      'isAbstract': isAbstract,
      'runtimeType': runtimeTypeString,
      'instanceType': instanceType,
      'prefix': prefix,
      'staticPrefix': staticPrefix,
      'isGlobal': isGlobal,
      'runtimeNames': runtimeNames.map((e) => {'runtimeName': e}).toList(),
    };
  }
}

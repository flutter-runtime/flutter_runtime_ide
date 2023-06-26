// ignore_for_file: implementation_imports

import 'dart:math';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter_runtime_ide/analyzer/analyzer_package_manager.dart';
import 'package:flutter_runtime_ide/analyzer/import_analysis.dart';
import 'package:flutter_runtime_ide/analyzer/mustache.dart';
import 'package:flutter_runtime_ide/analyzer/mustache_manager.dart';
import 'package:flutter_runtime_ide/app/data/package_config.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:flutter_runtime_ide/common/common_function.dart';
import 'package:analyzer/src/dart/analysis/results.dart';

class FileRuntimeGenerate {
  final String sourcePath;
  final PackageConfig packageConfig;
  final PackageInfo info;
  final ResolvedLibraryResultImpl library;
  late List<CompilationUnitElementImpl> _units;

  final List<ClassElementImpl> _classs = [];
  final List<ExtensionElementImpl> _extensions = [];
  final List<TopLevelVariableElementImpl> _topLevelVariables = [];
  final List<FunctionElementImpl> _functions = [];
  final List<EnumElementImpl> _enums = [];
  final List<MixinElementImpl> _mixins = [];
  final List<TypeAliasElementImpl> _typeAliases = [];
  final List<PropertyAccessorElementImpl> _accessors = [];
  // List<PartElementImpl> _parts = [];

  Set<String> importPathSets = {};

  List<ImportAnalysis> importAnalysis = [];

  FileRuntimeGenerate(
    this.sourcePath,
    this.packageConfig,
    this.info,
    this.library,
    this.importAnalysis,
  ) {
    importPathSets.add(sourcePath);
  }

  Future<String> generateCode() async {
    _units =
        library.element.units.whereType<CompilationUnitElementImpl>().toList();
    for (var unit in _units) {
      _classs.addAll(unit.classes.where((element) => !element.name.isPrivate));
      _extensions.addAll(unit.extensions.where((element) =>
          Unwrap(element.name).map((e) => !e.isPrivate).defaultValue(false)));
      _topLevelVariables.addAll(
          unit.topLevelVariables.where((element) => !element.name.isPrivate));
      _functions
          .addAll(unit.functions.where((element) => !element.name.isPrivate));
      _enums.addAll(unit.enums.where((element) => !element.name.isPrivate));
      _mixins.addAll(unit.mixins.where((element) => !element.name.isPrivate));
      _typeAliases
          .addAll(unit.typeAliases.where((element) => !element.name.isPrivate));
      _accessors
          .addAll(unit.accessors.where((element) => !element.name.isPrivate));
    }
    final classes = _classs
        .where((element) {
          final metadata = element.metadata;
          if (metadata.isEmpty) return true;
          return metadata.any((element) {
            return (element as ElementAnnotationImpl).annotationAst.name.name !=
                "visibleForTesting";
          });
        })
        .map((e) => toClassData(e))
        .toList();
    // assert(_extensions.isEmpty);
    classes.add(toGlobalClass());
    classes.addAll(_extensions.map((e) => toExtensionData(e)).toList());
    classes.addAll(_enums.map((e) => toEnumData(e)).toList());
    classes.addAll(_mixins.map((e) => toMixinData(e)).toList());

    final data = {
      "pubName": info.name,
      "classes": classes,
    };
    // logger.e(importPathSets);
    final pathDatas = importPathSets.map((e) => {"sourcePath": e}).toList();
    data['paths'] = pathDatas;
    return MustacheManager().render(fileMustache, data);
  }

  Map<String, dynamic> toGlobalClass() {
    final getFields = _topLevelVariables
        .map((e) => e.getter)
        .whereType<PropertyAccessorElementImpl>()
        .map((e) => toPropertyAccessorData(e))
        .toList();
    getFields.addAll(_typeAliases.map((e) => toTypeAliasData(e)).toList());

    final setFields = _topLevelVariables
        .map((e) => e.setter)
        .whereType<PropertyAccessorElementImpl>()
        .map((e) => toPropertyAccessorData(e))
        .toList();
    final methods = _functions.map((e) => toFunctionData(e)).toList();
    return {
      "className": "FR${md5(sourcePath)}",
      "getFields": getFields,
      "setFields": setFields,
      "methods": methods,
      "constructors": [],
      "isAbstract": false,
      'runtimeType': 'dynamic',
      'prefix': '',
      'staticPrefix': '',
    };
  }

  void assertNames(Iterable<Iterable<String>> names) {
    final allNames = names.fold<List<String>>(
        [], (previousValue, element) => previousValue..addAll(element));
    final filterNames = allNames.toSet().toList();
    assert(allNames.length == filterNames.length);
  }

  Map<String, dynamic> toClassData(ClassElementImpl element) {
    final getFields = element.fields
        .map((e) => e.getter)
        .whereType<PropertyAccessorElementImpl>()
        .where((element) => !element.name.isPrivate)
        .map((e) {
      return toPropertyAccessorData(e);
    }).toList();
    final setFields = element.fields
        .map((e) => e.setter)
        .whereType<PropertyAccessorElementImpl>()
        .where((element) => !element.name.isPrivate)
        .map((e) {
      return toPropertyAccessorData(e);
    }).toList();
    final methods = element.methods
        .where((element) => !element.isPrivate)
        .map((e) => toMethodData(e))
        .toList();
    final constructors = element.constructors
        .where((element) => !element.name.isPrivate)
        .map((e) => toConstructorData(e))
        .toList();
    return {
      "className": '\$${element.name}\$',
      "getFields": getFields,
      "setFields": setFields,
      "methods": methods,
      "constructors": constructors,
      "isAbstract": element.isAbstract,
      'runtimeType': element.name,
      'prefix': 'runtime.',
      'staticPrefix': '${element.name}.',
    };
  }

  Map<String, dynamic> toEnumData(EnumElementImpl element) {
    final getFields = element.fields
        .where((element) => !element.name.isPrivate)
        .map((e) => e.getter)
        .whereType<PropertyAccessorElementImpl>()
        .map((e) {
      return toPropertyAccessorData(e);
    }).toList();
    final setFields = element.fields
        .where((element) => !element.name.isPrivate)
        .map((e) => e.setter)
        .whereType<PropertyAccessorElementImpl>()
        .map((e) {
      return toPropertyAccessorData(e);
    }).toList();
    final methods = element.methods
        .where((element) => !element.isPrivate)
        .map((e) => toMethodData(e))
        .toList();
    // final constructors = element.constructors
    //     .where((element) => !element.name.isPrivate)
    //     .map((e) => toConstructorData(e))
    //     .toList();
    return {
      "className": '\$${element.name}\$',
      "getFields": getFields,
      "setFields": setFields,
      "methods": methods,
      "constructors": [],
      "isAbstract": false,
      'runtimeType': element.name,
      'prefix': 'runtime.',
      'staticPrefix': '${element.name}.',
    };
  }

  Map<String, dynamic> toMixinData(MixinElementImpl element) {
    final getFields = element.fields
        .map((e) => e.getter)
        .whereType<PropertyAccessorElementImpl>()
        .where((element) => !element.name.isPrivate)
        .map((e) {
      return toPropertyAccessorData(e);
    }).toList();
    final setFields = element.fields
        .map((e) => e.setter)
        .whereType<PropertyAccessorElementImpl>()
        .where((element) => !element.name.isPrivate)
        .map((e) {
      return toPropertyAccessorData(e);
    }).toList();
    final methods = element.methods
        .where((element) => !element.isPrivate)
        .map((e) => toMethodData(e))
        .toList();
    final constructors = element.constructors
        .where((element) => !element.name.isPrivate)
        .map((e) => toConstructorData(e))
        .toList();
    return {
      "className": '\$${element.name}\$',
      "getFields": getFields,
      "setFields": setFields,
      "methods": methods,
      "constructors": constructors,
      "isAbstract": false,
      'runtimeType': element.name,
      'prefix': 'runtime.',
      'staticPrefix': '${element.name}.',
    };
  }

  Map<String, dynamic> toTypeAliasData(TypeAliasElementImpl element) {
    return {
      "fieldName": element.name.replaceAll("\$", "\\\$"),
      'fieldValue': element.name,
      "isStatic": true,
    };
  }

  Map<String, dynamic> toFunctionData(FunctionElementImpl element) {
    String? customCallCode;
    if (element.name == '[]=' && element.parameters.length == 2) {
      customCallCode =
          '''runtime[args['${element.parameters[0].name}']] = args['${element.parameters[1].name}']''';
    } else if (element.name == '==' && element.parameters.length == 1) {
      customCallCode = '''runtime == args['${element.parameters[0].name}']''';
    } else if (element.name == '[]') {
      customCallCode = '''runtime[args['${element.parameters[0].name}']]''';
    }
    final parameters = element.parameters
        .map((e) => toParametersData(e as ParameterElementImpl))
        .toList();
    return {
      "methodName": element.name,
      "parameters": parameters,
      'customCallCode': customCallCode,
      'isCustomCall': customCallCode != null,
      'isStatic': element.isStatic,
    };
  }

  Map<String, dynamic> toPropertyAccessorData(
    PropertyAccessorElementImpl element,
  ) {
    String fieldName = element.name;
    if (fieldName.endsWith("=")) {
      fieldName = fieldName.substring(0, fieldName.length - 1);
    }
    return {
      "fieldName": fieldName.replaceAll("\$", "\\\$"),
      'fieldValue': fieldName,
      "isStatic": element.isStatic,
    };
  }

  Map<String, dynamic> toExtensionData(ExtensionElementImpl element) {
    final getFields = element.fields
        .where((element) => !element.name.isPrivate)
        .map((e) => e.getter)
        .whereType<PropertyAccessorElementImpl>()
        .map((e) => toPropertyAccessorData(e))
        .toList();
    final setFields = element.fields
        .where((element) => !element.name.isPrivate)
        .map((e) => e.setter)
        .whereType<PropertyAccessorElementImpl>()
        .map((e) => toPropertyAccessorData(e))
        .toList();
    final methods = element.methods
        .where((element) => !element.isPrivate)
        .map((e) => toMethodData(e))
        .toList();
    final runtimeType = runtimeNameWithType(element.extendedType);
    return {
      "className": '\$${element.name}\$',
      "getFields": getFields,
      "setFields": setFields,
      "methods": methods,
      "constructors": [],
      "isAbstract": false,
      'runtimeType': runtimeType,
      'prefix': '${element.name}(runtime).',
      'staticPrefix': '${element.name}.',
    };
  }

  Map<String, dynamic> toMethodData(MethodElementImpl element) {
    String? customCallCode;
    if (element.name == '[]=' && element.parameters.length == 2) {
      customCallCode =
          '''runtime[args['${element.parameters[0].name}']] = args['${element.parameters[1].name}']''';
    } else if (element.name == '==' && element.parameters.length == 1) {
      customCallCode = '''runtime == args['${element.parameters[0].name}']''';
    } else if (element.name == '[]') {
      customCallCode = '''runtime[args['${element.parameters[0].name}']]''';
    } else if (['<', '<=', '>', '>=', '+', '&', '|'].contains(element.name)) {
      customCallCode =
          '''runtime ${element.name} args['${element.parameters[0].name}']''';
    }
    final parameters = element.parameters
        .map((e) => toParametersData(e as ParameterElementImpl))
        .toList();
    return {
      "methodName": element.name,
      "parameters": parameters,
      'customCallCode': customCallCode,
      'isCustomCall': customCallCode != null,
      'isStatic': element.isStatic,
    };
  }

  Map<String, dynamic> toConstructorData(ConstructorElementImpl element) {
    final parameters = element.parameters
        .map((e) => toParametersData(e as ParameterElementImpl))
        .toList();
    return {
      "constructorName": element.name,
      "parameters": parameters,
      "isName": element.name.isNotEmpty,
    };
  }

  Map<String, dynamic> toParametersData(
    ParameterElementImpl element,
  ) {
    String readArgCode = '''args['${element.name}']''';
    DartType findType = element.type;

    if (findType is TypeParameterType) {
      readArgCode += "as ${findType.bound.name}";
    }
    // if (isDartCoreObject) {
    //   readArgCode += "as Object";
    // }
    final defaultValueImportPath0 = defaultValueImportPath(element);
    if (defaultValueImportPath0 != null) {
      importPathSets.add(defaultValueImportPath0);
    }
    return {
      "parameterName": element.name,
      "isNamed": element.isNamed,
      "hasDefaultValue": element.hasDefaultValue,
      "defaultValueCode": element.defaultValueCode,
      "createInstanceCode": readArgCode,
      // 'isDartCoreObject': element.type.isDartCoreObject,
    };
  }

  String? defaultValueImportPath(ParameterElementImpl element) {
    if (!element.hasDefaultValue || element is! ConstVariableElement) {
      return null;
    }
    final constantInitializer = element.constantInitializer;
    if (constantInitializer == null || constantInitializer is! Identifier) {
      return null;
    }
    final library = constantInitializer.staticElement?.library;
    if (library == null) return null;
    final importPath0 = importPathFromLibrary(library);
    return importPath0;
  }

  String? importPath(String sourcePath) {
    final packages = packageConfig.packages;
    List<PackageInfo> infos = packages.where((element) {
      return sourcePath.startsWith(element.rootUri);
    }).toList();
    if (infos.isEmpty) return null;
    PackageInfo info = infos[0];
    final path = sourcePath.split("/lib/").last;
    return 'package:${info.name}/$path';
  }

  String? runtimeNameWithType(DartType dartType) {
    Unwrap(importPathFromType(dartType)).map((e) {
      importPathSets.add(e);
    });
    final name0 = dartType.name;
    if (name0 == null) return null;
    if (dartType is! InterfaceType) return name0;
    if (dartType.typeArguments.isEmpty) return name0;
    final typeArguments = dartType.typeArguments
        .map((e) {
          Unwrap(importPathFromType(e)).map((e) {
            importPathSets.add(e);
          });
          if (e is InterfaceType) return e.name;
          if (e is TypeParameterType) return e.bound.name;
          if (e is InvalidType) {
            logger.e(this);
          }
          return null;
        })
        .whereType<String>()
        .toList();
    if (typeArguments.isEmpty) return name0;
    return '$name0<${typeArguments.join(",")}>';
  }

  String? importPathFromLibrary(LibraryElement library) {
    if (library.isInSdk) {
      final names = library.name.split('.');
      return names.join(":");
    }
    return importPath(library.identifier);
  }

  String? importPathFromType(DartType dartType) {
    final library = dartType.element?.library;
    if (library == null) return null;
    return importPathFromLibrary(library);
  }
}

extension StringPrivate on String {
  bool get isPrivate => startsWith("_");
}

// ignore_for_file: implementation_imports

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_class_cache.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_enum_cache.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_extension_cache.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_file_cache.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_import_cache.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_method_cache.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_mixin_cache.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_property_accessor_cache.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/analyzer/import_analysis.dart';
import 'package:flutter_runtime_ide/analyzer/mustache/mustache.dart';
import 'package:flutter_runtime_ide/analyzer/mustache/mustache_manager.dart';
import 'package:flutter_runtime_ide/analyzer/configs/package_config.dart';
import 'package:flutter_runtime_ide/common/common_function.dart';
import 'package:analyzer/src/dart/analysis/results.dart';
import 'package:analyzer/src/dart/ast/ast.dart';

class FileRuntimeGenerate {
  final String sourcePath;
  final PackageConfig packageConfig;
  final PackageInfo info;
  final AnalyzerFileCache fileCache;

  FileRuntimeGenerate(
    this.sourcePath,
    this.packageConfig,
    this.info,
    this.fileCache,
  );

  Future<String> generateCode() async {
    // await addImportHideNames();
    final classes = fileCache.classs
        .where((e) => e.isEnable && !e.name.isPrivate)
        .map((e) => toClassData(e))
        .toList();
    classes.add(toGlobalClass());
    classes.addAll(fileCache.extensions
        .where((element) {
          return element.isEnable &&
              !(element.name.isPrivate) &&
              element.name.isNotEmpty;
        })
        .map((e) => toExtensionData(e))
        .toList());
    classes.addAll(fileCache.enums
        .where((element) => element.isEnable && !element.name.isPrivate)
        .map((e) => toEnumData(e))
        .toList());
    classes.addAll(fileCache.mixins
        .where((element) => element.isEnable && !element.name.isPrivate)
        .map((e) => toMixinData(e))
        .toList());

    final data = {
      "pubName": info.name,
      "classes": classes,
    };

    var imports = [...fileCache.imports];
    final contentData = {
      'uriContent': sourcePath,
    };
    imports.add(AnalyzerImportCache(contentData, contentData));

    final pathDatas = imports.map((e) {
      final hideNames = e.hideNamesFromFileCache(fileCache);
      return {
        "uriContent": e.uriContent,
        'asName': e.asName,
        'hasAsName': e.asName != null,
        'hasShowNames': e.shownNames.isNotEmpty,
        'hasHideNames': hideNames.isNotEmpty,
        'showContent': e.shownNames.join(","),
        'hideContent': hideNames.join(','),
      };
    }).toList();
    data['paths'] = pathDatas;
    return MustacheManager().render(fileMustache, data);
  }

  Map<String, dynamic> toGlobalClass() {
    final getFields = fileCache.topLevelVariables
        .where((e) => e.isGetter && e.isEnable && !e.name.isPrivate)
        .map((e) => toPropertyAccessorData(e))
        .toList();
    // getFields.addAll(_typeAliases.map((e) => toTypeAliasData(e)).toList());

    final setFields = fileCache.topLevelVariables
        .where((e) => e.isSetter && e.isEnable && !e.name.isPrivate)
        .map((e) => toPropertyAccessorData(e))
        .toList();

    final methods = fileCache.functions
        .where((element) => element.isEnable && !element.name.isPrivate)
        .map((e) => toFunctionData(e))
        .toList();
    return {
      "className": "FR${md5(sourcePath)}",
      "getFields": getFields,
      "setFields": setFields,
      "methods": methods,
      "constructors": [],
      "isAbstract": false,
      'runtimeType': 'dynamic',
      'instanceType': 'dynamic',
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

  Map<String, dynamic> toClassData(AnalyzerClassCache element) {
    // bool isStructAndUnionSubClass =
    //     ['Struct', 'Union'].contains(element.supertype?.name);

    final getFields = element.fields
        .where((e) => e.isGetter && e.isEnable && !e.name.isPrivate)
        .map((e) => toPropertyAccessorData(e))
        .toList();
    final setFields = element.fields
        .where((e) => e.isSetter && e.isEnable && !e.name.isPrivate)
        .map((e) => toPropertyAccessorData(e))
        .toList();
    final methods = element.methods
        .where((element) => element.isEnable && !element.name.isPrivate)
        .map((e) => toMethodData(e))
        .toList();
    final constructors = element.constructors
        .where((element) => element.isEnable && !element.name.isPrivate)
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
      'instanceType': '${element.name}?',
      'prefix': 'runtime.',
      'staticPrefix': '${element.name}.',
    };
  }

  Map<String, dynamic> toEnumData(AnalyzerEnumCache element) {
    final getFields = element.fields
        .where((element) =>
            element.isEnable && element.isGetter && !element.name.isPrivate)
        .map((e) => toPropertyAccessorData(e))
        .toList();
    final setFields = element.fields
        .where((element) =>
            element.isEnable && element.isSetter && !element.name.isPrivate)
        .map((e) => toPropertyAccessorData(e))
        .toList();
    final methods = element.methods
        .where((element) => element.isEnable && !element.name.isPrivate)
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
      'instanceType': "${element.name}?",
      'prefix': 'runtime.',
      'staticPrefix': '${element.name}.',
    };
  }

  Map<String, dynamic> toMixinData(AnalyzerMixinCache element) {
    final getFields = element.fields
        .where((element) =>
            element.isEnable && element.isGetter && !element.name.isPrivate)
        .map((e) => toPropertyAccessorData(e))
        .toList();
    final setFields = element.fields
        .where((element) =>
            element.isEnable && element.isSetter && !element.name.isPrivate)
        .map((e) => toPropertyAccessorData(e))
        .toList();
    final methods = element.methods
        .where((element) => element.isEnable && !element.name.isPrivate)
        .map((e) => toMethodData(e))
        .toList();
    final constructors = element.constructors
        .where((element) => !element.name.isPrivate && !element.name.isPrivate)
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
      'instanceType': '${element.name}?',
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

  Map<String, dynamic> toFunctionData(
    AnalyzerMethodCache element,
  ) {
    String? customCallCode;
    if (element.name == '[]=' && element.parameters.length == 2) {
      customCallCode =
          '''runtime[args['${element.parameters[0].name}']] = args['${element.parameters[1].name}']''';
    } else if (element.name == '==' && element.parameters.length == 1) {
      customCallCode = '''runtime == args['${element.parameters[0].name}']''';
    } else if (element.name == '[]') {
      customCallCode = '''runtime[args['${element.parameters[0].name}']]''';
    }
    final parameters =
        element.parameters.map((e) => toParametersData(e)).toList();
    return {
      'callMethodName': element.name.replaceAll('\$', '\\\$'),
      "methodName": element.name,
      "parameters": parameters,
      'customCallCode': customCallCode,
      'isCustomCall': customCallCode != null,
      'isStatic': element.isStatic,
    };
  }

  Map<String, dynamic> toPropertyAccessorData(
    AnalyzerPropertyAccessorCache element,
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

  Map<String, dynamic> toExtensionData(AnalyzerExtensionCache element) {
    final getFields = element.fields
        .where((element) =>
            element.isEnable && element.isGetter && !element.name.isPrivate)
        .map((e) => toPropertyAccessorData(e))
        .toList();
    final setFields = element.fields
        .where((element) =>
            element.isEnable && element.isSetter && !element.name.isPrivate)
        .map((e) => toPropertyAccessorData(e))
        .toList();
    final methods = element.methods
        .where((element) => element.isEnable && !element.name.isPrivate)
        .map((e) => toMethodData(e))
        .toList();
    // final runtimeType = runtimeNameWithType(element.extendedType);
    // final runtimeType = Unwrap(element.name)
    //     .map((e) => getExtensionDeclaration(e))
    //     .map((e) => getExtensionOnType(e))
    //     .value;

    String? instanceType = Unwrap(element.extensionName).map((e) {
      if (e.endsWith("?")) return e;
      return "$e?";
    }).value;
    return {
      "className": '\$${element.name}\$',
      "getFields": getFields,
      "setFields": setFields,
      "methods": methods,
      "constructors": [],
      "isAbstract": false,
      'runtimeType': element.extensionName,
      'instanceType': instanceType,
      'prefix': '${element.name}(runtime).',
      'staticPrefix': '${element.name}.',
    };
  }

  Map<String, dynamic> toMethodData(AnalyzerMethodCache element) {
    String? customCallCode;
    // 支持的计算公式
    final supportOperations = [
      '<',
      '<=',
      '>',
      '>=',
      '+',
      '&',
      '|',
      '*',
      '/',
      '-',
      '^',
      '~/',
      '%',
      '<<',
      '>>',
      '>>>'
    ];

    if (element.name == '[]=' && element.parameters.length == 2) {
      customCallCode =
          '''runtime[args['${element.parameters[0].name}']] = args['${element.parameters[1].name}']''';
    } else if (element.name == '==' && element.parameters.length == 1) {
      customCallCode = '''runtime == args['${element.parameters[0].name}']''';
    } else if (element.name == '[]') {
      customCallCode = '''runtime[args['${element.parameters[0].name}']]''';
    } else if (supportOperations.contains(element.name)) {
      customCallCode =
          '''runtime ${element.name} args['${element.parameters[0].name}']''';
    } else if (element.name.startsWith('unary')) {
      final operation = element.name.substring(5);
      customCallCode = '''${operation}runtime''';
    } else if (element.name == '~') {
      customCallCode = '${element.name}runtime';
    }
    final parameters =
        element.parameters.map((e) => toParametersData(e)).toList();
    return {
      'callMethodName': element.name.replaceAll('\$', '\\\$'),
      "methodName": element.name,
      "parameters": parameters,
      'customCallCode': customCallCode,
      'isCustomCall': customCallCode != null,
      'isStatic': element.isStatic,
    };
  }

  Map<String, dynamic> toConstructorData(AnalyzerMethodCache element) {
    final parameters =
        element.parameters.map((e) => toParametersData(e)).toList();
    return {
      "constructorName": element.name,
      "parameters": parameters,
      "isName": element.name.isNotEmpty,
    };
  }

  Map<String, dynamic> toParametersData(AnalyzerPropertyAccessorCache element) {
    String readArgCode = '''args['${element.name}']''';
    Unwrap(element.asName).map((e) {
      readArgCode += 'as $e';
    });
    final defaultValueCode = Unwrap(element.defaultValueCode).map((e) {
          if (!e.isPrivate) return null;
          return fileCache.defaultValueCodeFromTopLevelVariable(e);
        }).value ??
        element.defaultValueCode;
    return {
      "parameterName": element.name,
      "isNamed": element.isNamed,
      "hasDefaultValue": element.hasDefaultValue,
      "defaultValueCode": defaultValueCode,
      "createInstanceCode": readArgCode,
      // 'isDartCoreObject': element.type.isDartCoreObject,
    };
  }

  // String? getParameterAsName(AnalyzerPropertyAccessorCache impl) {
  //   String? asName = impl.type.toString();
  //   if (asName.contains('InvalidType')) {
  //     asName = getParameterTypeString(impl);
  //   }
  //   var enclosingElement = impl.enclosingElement;
  //   List<TypeParameterElement> typeParameters = [];
  //   while (enclosingElement != null &&
  //       enclosingElement is! CompilationUnitElementImpl) {
  //     if (enclosingElement is TypeParameterizedElement) {
  //       typeParameters.addAll(enclosingElement.typeParameters);
  //       // if (typeParameters.isNotEmpty) {
  //       //   for (var e in typeParameters) {
  //       //     String? typeValue;
  //       //     if (e.bound != null) {
  //       //       typeValue = e.bound?.name;
  //       //     } else if (e is TypeParameterElementImpl) {
  //       //       typeValue = e.defaultType?.name;
  //       //     } else {
  //       //       throw UnimplementedError();
  //       //     }
  //       //     asName = asName?.replaceAll(e.name, typeValue ?? '');
  //       //   }
  //       // }
  //       enclosingElement = enclosingElement.enclosingElement;
  //     } else {
  //       throw UnimplementedError();
  //     }
  //   }
  //   return asName;
  // }

  String? getBoundName(DartType type) {
    if (type is TypeParameterType) {
      return getBoundName(type.bound);
    } else {
      return type.name;
    }
  }

  String? getTypeDisplayName(DartType type) {
    var boundName = getBoundName(type);
    final typeArguments = type.getTypeArguments();
    if (typeArguments.isNotEmpty) {
      boundName =
          "$boundName<${typeArguments.map((e) => getTypeDisplayName(e)).join(', ')}>";
    }
    return boundName;
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

  // ExtensionDeclarationImpl? getExtensionDeclaration(
  //   String name,
  // ) {
  //   final impls = library.units.map((e) {
  //     final declarations = e.unit.declarations.toList();

  //     return declarations
  //         .whereType<ExtensionDeclarationImpl>()
  //         .where((element) => element.name?.lexeme == name)
  //         .toList();
  //   }).fold<List<ExtensionDeclarationImpl>>([],
  //       (previousValue, element) => previousValue..addAll(element)).toList();
  //   if (impls.isEmpty) return null;
  //   return impls.first;
  // }

  // String? getExtensionOnType(ExtensionDeclarationImpl impl) {
  //   final typeParameters = <String, dynamic>{};
  //   Unwrap(impl.typeParameters).map((e) {
  //     for (TypeParameterImpl e in e.typeParameters) {
  //       final name = e.name.lexeme;
  //       final type = getTypeArgumentName(e);
  //       typeParameters[name] = type;
  //     }
  //     return e.typeParameters;
  //   });
  //   final type = impl.extendedType;
  //   var source = type.toSource();
  //   for (var element in typeParameters.keys) {
  //     source = source.replaceAll(element, typeParameters[element]);
  //   }
  //   return source;
  // }

  // 给引入的库隐藏对应的名字 防止命名冲突
  // Future<void> addImportHideNames() async {
  //   final needHideNames = <String>[];
  //   needHideNames.addAll(_classs.map((e) => e.name).toList());
  //   needHideNames
  //       .addAll(_extensions.map((e) => e.name).whereType<String>().toList());
  //   int index = 0;
  //   for (var analysis in importAnalysis) {
  //     List<String> hideNames = [];

  //     Unwrap(analysis.uriContent)
  //         .map((e) => fixConfig?.getImportConfig(index))
  //         .map((e) {
  //       hideNames.addAll(e.hideNames);
  //     });

  //     index++;

  //     for (var name in needHideNames) {
  //       final exportNames = analysis.exportNamespace?.definedNames.keys ?? [];
  //       if (exportNames.contains(name)) {
  //         hideNames.add(name);
  //       }
  //     }
  //     analysis.hideNames = hideNames.toSet().toList();
  //   }
  // }

  String? getTypeArgumentName(TypeParameterImpl impl) {
    final bound = impl.bound;
    if (bound == null) return 'dynamic';
    if (bound is NamedTypeImpl) return bound.name2.lexeme;
    if (bound is TypeParameterImpl) {
      return getTypeArgumentName(bound as TypeParameterImpl);
    }
    throw UnimplementedError();
  }

  // String? getParameterTypeString(ParameterElementImpl elementImpl) {
  //   List<Element?> elements = [elementImpl];
  //   var element = elementImpl.enclosingElement;
  //   while (element != null && element is! CompilationUnitElementImpl) {
  //     elements.add(element);
  //     element = element.enclosingElement;
  //   }
  //   elements = elements.reversed.toList();
  //   if (elements.isEmpty) return null;
  //   AstNode? member;
  //   for (var e in elements) {
  //     if (e is ClassElementImpl) {
  //       final classs = library.getClasss(e);
  //       if (classs.isEmpty) return null;
  //       member = classs.first;
  //     } else if (e is MethodElementImpl) {
  //       List<MethodDeclarationImpl>? methods;

  //       if (member != null && member is ClassDeclarationImpl) {
  //         methods = member.getMethods(e);
  //       } else if (member != null && member is MixinDeclarationImpl) {
  //         methods = member.getMethods(e);
  //       } else if (member != null && member is ExtensionDeclarationImpl) {
  //         methods = member.getMethods(e);
  //       } else {
  //         throw UnimplementedError(e.toString());
  //       }
  //       if (methods.isEmpty) return null;
  //       member = methods.first;
  //     } else if (e is MixinElementImpl) {
  //       final mixins = library.getMixins(e);
  //       if (mixins.isEmpty) return null;
  //       member = mixins.first;
  //     } else if (e is ConstructorElementImpl) {
  //       if (member != null && member is ClassDeclarationImpl) {
  //         final constructors = member.getConstructors(e);
  //         if (constructors.isEmpty) return null;
  //         member = constructors.first;
  //       } else {
  //         throw UnimplementedError(e.toString());
  //       }
  //     } else if (e is FunctionElementImpl) {
  //       final functions = library.getFunctions(e);
  //       if (functions.isEmpty) return null;
  //       member = functions.first;
  //     } else if (e is ParameterElementImpl) {
  //       List<FormalParameterImpl> parameters;
  //       if (member != null && member is MethodDeclarationImpl) {
  //         parameters = member.parameters?.parameters.toList() ?? [];
  //       } else if (member != null && member is FunctionDeclarationImpl) {
  //         parameters = member.functionExpression.parameters?.parameters ?? [];
  //       } else if (member != null && member is ConstructorDeclarationImpl) {
  //         parameters = member.parameters.parameters;
  //       } else {
  //         throw UnimplementedError(e.toString());
  //       }
  //       parameters = parameters.where((element) {
  //         return element.name?.lexeme == e.name;
  //       }).toList();
  //       if (parameters.isEmpty) return null;
  //       member = parameters.first;
  //     } else if (e is ExtensionElementImpl) {
  //       final mixins = library.getExtensions(e);
  //       if (mixins.isEmpty) return null;
  //       member = mixins.first;
  //     }
  //   }
  //   if (member == null) return null;
  //   var parameter = member;
  //   if (member is DefaultFormalParameterImpl) {
  //     parameter = member.parameter;
  //   }
  //   if (parameter is SimpleFormalParameter) {
  //     final type = parameter.type;
  //     if (type is NamedTypeImpl) {
  //       return type.toSource();
  //     } else if (type is GenericFunctionTypeImpl) {
  //       return 'dynamic';
  //     } else {
  //       throw UnimplementedError(type.toString());
  //     }
  //   } else {
  //     return null;
  //   }
  // }
}

extension StringPrivate on String {
  bool get isPrivate => startsWith("_");
}

extension on ResolvedLibraryResultImpl {
  List<ClassDeclarationImpl> getClasss(ClassElementImpl impl) {
    return units.map((element) {
      return element.unit.declarations
          .whereType<ClassDeclarationImpl>()
          .where((element) => element.name.lexeme == impl.name)
          .toList();
    }).fold<List<ClassDeclarationImpl>>([], (previousValue, element) {
      return previousValue..addAll(element);
    }).toList();
  }

  List<MixinDeclarationImpl> getMixins(MixinElementImpl impl) {
    return units.map((element) {
      return element.unit.declarations
          .whereType<MixinDeclarationImpl>()
          .where((element) => element.name.lexeme == impl.name);
    }).fold<List<MixinDeclarationImpl>>([], (previousValue, element) {
      return previousValue..addAll(element);
    }).toList();
  }

  List<FunctionDeclarationImpl> getFunctions(FunctionElementImpl impl) {
    return units.map((element) {
      return element.unit.declarations
          .whereType<FunctionDeclarationImpl>()
          .where((element) => element.name.lexeme == impl.name);
    }).fold<List<FunctionDeclarationImpl>>([], (previousValue, element) {
      return previousValue..addAll(element);
    });
  }

  List<ExtensionDeclarationImpl> getExtensions(ExtensionElementImpl impl) {
    return units.map((element) {
      return element.unit.declarations
          .whereType<ExtensionDeclarationImpl>()
          .where((element) => element.name?.lexeme == impl.name);
    }).fold<List<ExtensionDeclarationImpl>>([], (previousValue, element) {
      return previousValue..addAll(element);
    });
  }
}

extension on ClassDeclarationImpl {
  List<MethodDeclarationImpl> getMethods(MethodElementImpl impl) {
    return members
        .whereType<MethodDeclarationImpl>()
        .where((element) => element.name.lexeme == impl.name)
        .toList();
  }

  List<ConstructorDeclarationImpl> getConstructors(
      ConstructorElementImpl impl) {
    return members
        .whereType<ConstructorDeclarationImpl>()
        .where((element) => element.name?.lexeme == impl.name)
        .toList();
  }
}

extension on MixinDeclarationImpl {
  List<MethodDeclarationImpl> getMethods(MethodElementImpl impl) {
    return members
        .whereType<MethodDeclarationImpl>()
        .where((element) => element.name.lexeme == impl.name)
        .toList();
  }
}

extension on ExtensionDeclarationImpl {
  List<MethodDeclarationImpl> getMethods(MethodElementImpl impl) {
    return members
        .whereType<MethodDeclarationImpl>()
        .where((element) => element.name.lexeme == impl.name)
        .toList();
  }
}

extension on DartType {
  List<DartType> getTypeArguments() {
    if (this is ParameterizedType) {
      return (this as ParameterizedType).typeArguments;
    } else {
      return [];
    }
  }
}

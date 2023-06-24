import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/dart/analysis/results.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
// import 'package:analyzer/file_system/file_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/file_runtime_generate.dart';
import 'package:flutter_runtime_ide/analyzer/mustache.dart';
import 'package:flutter_runtime_ide/analyzer/mustache_manager.dart';
import 'package:flutter_runtime_ide/app/data/package_config.dart';
import 'package:flutter_runtime_ide/app/modules/home/controllers/home_controller.dart';
import 'package:flutter_runtime_ide/app/utils/progress_hud_util.dart';
import 'package:flutter_runtime_ide/common/common_function.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:process_run/process_run.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

// 将指定库转换为运行时库
class ConverRuntimePackage {
  // 需要分析库的路径
  final String packagePath;
  // 分析的上下文
  final AnalysisContextCollection analysisContextCollection;
  // 输入的路径
  final String outPutPath;
  // 总体的依赖配置
  final PackageConfig packageConfig;

  late PackageInfo _info;

  /// 创建转换器
  ConverRuntimePackage.fromPath(
    this.packagePath,
    this.outPutPath,
    this.packageConfig,
  ) : analysisContextCollection = AnalysisContextCollection(
          sdkPath: getDartPath(),
          includedPaths: [join(packagePath, "lib")],
        );

  FutureOr<void> conver() async {
    await analysisDartFileFromDir(join(packagePath, "lib"));
  }

  FutureOr<void> analysisDartFileFromDir(String dir) async {
    _info = packageConfig.packages.firstWhere((element) {
      return element.packagePath == packagePath;
    });

    // 获取到当前需要分析目录下面所有的子元素
    List<FileSystemEntity> entitys =
        await Directory(dir).list(recursive: true).toList();
    int index = 1;

    Map<String, List<TopLevelVariableElement>> topLevelVariables = {};
    Map<String, List<FunctionElement>> functions = {};
    Map<String, List<ExtensionElement>> extensions = {};
    Map<String, List<EnumElement>> enums = {};

    for (FileSystemEntity entity in entitys) {
      showProgressHud(progress: index / entitys.length, text: entity.path);
      if (extension(entity.path) != ".dart") continue;
      // 根据文件路径获取到分析上下文
      SomeResolvedLibraryResult result = await getResolvedLibrary(entity.path);
      if (result is ResolvedLibraryResultImpl) {
        final units = result.element.units
            .whereType<CompilationUnitElementImpl>()
            .toList();
        final libraryPath =
            entity.path.split(packageNamePath)[1].replaceFirst("/lib", "");
        final sourcePath = 'package:${_info.name}$libraryPath';
        FileRuntimeGenerate generate = FileRuntimeGenerate(
          sourcePath,
          packageConfig,
          _info,
          units,
        );
        final generateCode = generate.generateCode();
        // // 获取当前页面【export】元素
        // for (var element in result.element.libraryExports) {
        //   // 获取 export  的路径
        //   String? exportPath = getRelativePath(element.uri);
        //   if (exportPath == null) {
        //     // logger.e("$element export  没有对应路径!");
        //     continue;
        //   }

        //   // 获取 show  的类名
        //   final shownNames = element.combinators
        //       .whereType<ShowElementCombinator>()
        //       .fold<List<String>>([], (previousValue, element) {
        //     return previousValue..addAll(element.shownNames);
        //   });
        //   logger.i("[Export] $exportPath show $shownNames");
        // }

        // // 获取当前页面【import】元素
        // for (var element in result.element.libraryImports) {
        //   // 获取 import  的路径
        //   String? importPath = getRelativePath(element.uri);
        //   if (importPath == null) {
        //     // logger.e("$element import  没有对应路径!");
        //     continue;
        //   }
        //   // if (element.combinators.isNotEmpty) {
        //   //   throw UnimplementedError();
        //   // }
        // }

        // // 获取当前页面【class】元素
        // final classes = result.element.units[0].classes.where((element) {
        //   return !element.name.isPrivate;
        // });
        // // final libraryPath =
        // //     entity.path.split(packageNamePath)[1].replaceFirst("/lib", "");
        // // final sourcePath = 'package:${_info.name}$libraryPath';

        // final topLevelVariables0 = result.element.units[0].topLevelVariables
        //     .where((element) => !element.name.isPrivate)
        //     .toList();
        // if (topLevelVariables0.isNotEmpty) {
        //   topLevelVariables[sourcePath] = topLevelVariables0;
        // }

        // final functions0 = result.element.units[0].functions
        //     .where((element) => !element.name.isPrivate)
        //     .toList();
        // ;
        // if (functions0.isNotEmpty) {
        //   functions[sourcePath] = functions0;
        // }

        // // 获取扩展
        // final extensions0 = result.element.units[0].extensions;
        // if (extensions0.isNotEmpty) {
        //   extensions[sourcePath] = extensions0;
        // }
        // // 获取枚举
        // final enums0 = result.element.units[0].enums
        //     .where((element) => !element.name.isPrivate)
        //     .toList();
        // if (enums0.isNotEmpty) {
        //   enums[sourcePath] = enums0;
        // }

        // Set<String> paths = {sourcePath};

        // final importPathSets = classes.map((e) {
        //   return e.importPathSets;
        // }).fold<Set<String>>({}, (previousValue, element) {
        //   return previousValue..addAll(element);
        // });
        // paths.addAll(importPathSets);
        // final pathDatas = paths.map((e) => {"sourcePath": e}).toList();
        // // logger.e("$paths\n$pathDatas");

        // final data = {
        //   "pubName": _info.name,
        //   'paths': pathDatas,
        //   "classes": classes.map((e) => e.toData),
        // };

        // final content = MustacheManager().render(fileMustache, data);
        final outFile = "$outPutPath/$packageNamePath${'/lib$libraryPath'}";
        final file = File(outFile);
        await file.writeString(generateCode);
      } else if (result is NotLibraryButPartResult) {
        logger.v(result);
      } else {
        throw UnimplementedError(result.runtimeType.toString());
      }
      index++;
    }

    // Set<String> paths = {};
    // paths.addAll(topLevelVariables.keys);
    // paths.addAll(functions.keys);
    // paths.addAll(enums.keys);
    // paths.addAll(extensions.keys);

    // final getFieldDatas = topLevelVariables.values
    //     .fold<List<TopLevelVariableElement>>(
    //         [], (previousValue, element) => previousValue..addAll(element))
    //     .map((element) => element.getter)
    //     .whereType<PropertyAccessorElement>()
    //     .map((e) {
    //       return e.toData;
    //     });
    // final setFieldDatas = topLevelVariables.values
    //     .fold<List<TopLevelVariableElement>>(
    //         [], (previousValue, element) => previousValue..addAll(element))
    //     .map((element) => element.setter)
    //     .whereType<PropertyAccessorElement>()
    //     .map((e) => e.toData);

    // final functionDatas = functions.values.fold<List<FunctionElement>>([],
    //     (previousValue, element) {
    //   return previousValue..addAll(element);
    // }).map((e) {
    //   for (var parameter in e.parameters) {
    //     final defaultValueImportPath = parameter.defaultValueImportPath;
    //     if (defaultValueImportPath != null) {
    //       paths.add(defaultValueImportPath);
    //     }
    //   }
    //   return e.toData;
    // });

    // final enumDatas =
    //     enums.values.fold<List<EnumElement>>([], (previousValue, element) {
    //   return previousValue..addAll(element);
    // }).map((e) {
    //   return e.toData;
    // });

    // // if (extensions.isNotEmpty) {
    // //   throw UnsupportedError("extensions is not supported!");
    // // }

    // final data = {
    //   "paths": paths.toList().map((e) => {"sourcePath": e}),
    //   "pubName": _info.name,
    //   "getFields": getFieldDatas,
    //   "setFields": setFieldDatas,
    //   "functions": functionDatas,
    //   "enums": enumDatas,
    // };

    // final content = MustacheManager().render(globalMustache, data);
    // final outFile = "$outPutPath/$packageNamePath/lib/global_runtime.dart";
    // final file = File(outFile);
    // await file.writeString(content);

    await createPubspecFile();
    hideProgressHud();
    debugPrint("解析完毕!");
  }

  Future<SomeResolvedLibraryResult> getResolvedLibrary(String path) async {
    AnalysisContext context = analysisContextCollection.contextFor(path);
    return context.currentSession.getResolvedLibrary(path);
  }

  // 获取路径
  String? getRelativePath(DirectiveUri uri) {
    if (uri is DirectiveUriWithLibrary) return uri.relativeUriString;
    return null;
  }

  String get packageNamePath => basename(packagePath);

  Future<void> createPubspecFile() async {
    final pubspecFile = "$outPutPath/$packageNamePath/pubspec.yaml";
    final specName = _info.name;
    final pubspecContent = MustacheManager().render(pubspecMustache, {
      "pubName": specName,
      "pubPath": packagePath,
      'flutterRuntimePath':
          join(shellEnvironment['PWD']!, 'packages', 'flutter_runtime')
    });
    await File(pubspecFile).writeString(pubspecContent);
  }
}

extension StringPrivate on String {
  bool get isPrivate => startsWith("_");
}

extension FileWriteString on File {
  Future<void> writeString(String content) async {
    if (!await exists()) {
      await create(recursive: true);
    }
    await writeAsString(content);
  }
}

// extension ClassElementData on ClassElement {
//   Map get toData {
//     return {
//       "className": name,
//       "getFields": fields
//           .map((e) => e.getter)
//           .whereType<PropertyAccessorElement>()
//           .where((element) => !element.name.isPrivate)
//           .map((e) {
//         return e.toData;
//       }),
//       "setFields": fields
//           .map((e) => e.setter)
//           .whereType<PropertyAccessorElement>()
//           .where((element) => !element.name.isPrivate)
//           .map((e) {
//         return e.toData;
//       }),
//       "methods": _methods.map((e) => e.toData),
//       "constructors": constructors
//           .where((element) => !element.name.isPrivate)
//           .map((e) => e.toData),
//       "isAbstract": isAbstract,
//     };
//   }

//   Iterable<MethodElement> get _methods => methods
//       .where((element) => !element.name.isPrivate)
//       .where((element) => element.name != "[]");

//   Iterable<ConstructorElement> get _constructors =>
//       constructors.where((element) => !element.name.isPrivate);

//   Set<String> get importPathSets {
//     Set<String> paths = {};
//     for (var method in _methods) {
//       paths.addAll(method.parameters.map((e) {
//         return e.defaultValueImportPath;
//       }).whereType<String>());
//     }

//     for (var constructor in _constructors) {
//       paths.addAll(constructor.parameters.map((e) {
//         return e.defaultValueImportPath;
//       }).whereType<String>());
//     }
//     return paths;
//   }
// }

// extension FieldElementData on PropertyAccessorElement {
//   Map get toData {
//     String fieldName = name.replaceAll("\$", "\\\$");
//     if (fieldName.endsWith("=")) {
//       fieldName = fieldName.substring(0, fieldName.length - 1);
//     }
//     return {
//       "fieldName": fieldName,
//       'fieldValue': name,
//       "isStatic": isStatic,
//     };
//   }
// }

// extension MethodElementData on MethodElement {
//   Map get toData {
//     final customCallCode = this.customCallCode;
//     return {
//       "methodName": name,
//       "parameters": parameters.map((e) => e.toData),
//       'customCallCode': customCallCode,
//       'isCustomCall': customCallCode != null,
//     };
//   }

//   String? get customCallCode {
//     if (name == '[]=' && parameters.length == 2) {
//       return '''runtime[args['${parameters[0].name}']] = args['${parameters[1].name}']''';
//     } else if (name == '==' && parameters.length == 1) {
//       return '''runtime == args['${parameters[0].name}']''';
//     } else {
//       return null;
//     }
//   }
// }

// extension ParameterElementData on ParameterElement {
//   Map get toData {
//     // ignore: no_leading_underscores_for_local_identifiers
//     // late bool _isOptional;
//     // if (isNamed) {
//     //   _isOptional = isOptional;
//     // } else {
//     //   _isOptional = type.nullabilitySuffix == NullabilitySuffix.question;
//     // }
//     String readArgCode = '''args['$name']''';
//     return {
//       "parameterName": name,
//       "isNamed": isNamed,
//       "hasDefaultValue": hasDefaultValue,
//       "defaultValueCode": defaultValueCode,
//       "createInstanceCode": readArgCode,
//     };
//   }

//   String? get defaultValueImportPath {
//     if (!hasDefaultValue || this is! DefaultParameterElementImpl) return null;
//     DefaultParameterElementImpl parameter = this as DefaultParameterElementImpl;
//     final constantInitializer = parameter.constantInitializer;
//     if (constantInitializer == null ||
//         constantInitializer is! PrefixedIdentifier) return null;
//     return constantInitializer.staticElement?.librarySource?.importPath;
//   }
// }

// extension ConstructorElementData on ConstructorElement {
//   Map get toData {
//     return {
//       "constructorName": name,
//       "parameters": parameters.map((e) => e.toData),
//       "isName": name.isNotEmpty,
//     };
//   }
// }

// extension FunctionElementData on FunctionElement {
//   Map get toData {
//     return {
//       "methodName": name,
//       "parameters": parameters.map((e) => e.toData),
//     };
//   }
// }

// extension TopLevelVariableElementData on TopLevelVariableElement {
//   Map get toData {
//     return {
//       "variableName": name,
//     };
//   }
// }

// extension DartTypeCode on DartType {
//   String readArgCode(
//     String name,
//     bool isOptional, {
//     String argsName = 'args',
//   }) {
//     if (isDartCoreInt) {
//       return '''JSON($argsName)["$name"].int${isOptional ? "" : "Value"}''';
//     } else if (isDartCoreString) {
//       return '''JSON($argsName)["$name"].string${isOptional ? "" : "Value"}''';
//     } else if (isDartCoreDouble) {
//       return '''JSON($argsName)["$name"].double${isOptional ? "" : "Value"}''';
//     } else if (isDartCoreBool) {
//       return '''JSON($argsName)["$name"].bool${isOptional ? "" : "Value"}''';
//     } else if (isDartCoreIterable || isDartCoreList) {
//       if (this is InterfaceType) {
//         final typeArguments = (this as InterfaceType).typeArguments;
//         if (typeArguments.length != 1) {
//           return throw UnsupportedError("${toString()} not support!");
//         }
//         DartType typeArgument = typeArguments[0];
//         late String typeArgumentCode;
//         if (typeArgument.isDartCoreString) {
//           typeArgumentCode = "e as String";
//         } else if (typeArgument.isDartCoreInt) {
//           typeArgumentCode = "e as int";
//         } else if (typeArgument.isDartCoreDouble) {
//           typeArgumentCode = "e as double";
//         } else if (typeArgument.isDartCoreBool) {
//           typeArgumentCode = "e as bool";
//         } else {
//           typeArgumentCode = createInstanceCode(typeArgument);
//         }
//         String code =
//             '''JSON($argsName)["$name"].list${isOptional ? '?' : 'Value'}.map((e) => $typeArgumentCode)''';
//         if (isDartCoreList) {
//           code += ".toList()";
//         }
//         return code;
//       } else {
//         throw UnsupportedError("not support!");
//       }
//     } else {
//       return createInstanceCode(this);
//     }
//   }

//   String createInstanceCode(DartType type) {
//     final librarySource = type.element?.librarySource;
//     if (librarySource != null) {
//       final fullName = librarySource.fullName;
//       final packages =
//           Get.find<HomeController>().packageConfig.value?.packages ?? [];
//       List<PackageInfo> infos = packages.where((element) {
//         return fullName.startsWith(element.rootUri.replaceFirst("file://", ""));
//       }).toList();
//       if (infos.length == 1) {
//         PackageInfo info = infos[0];
//         String libraryPath = fullName.replaceFirst(
//             join(info.rootUri.replaceFirst("file://", ""), info.packageUri),
//             "");
//         return '''createInstance("${info.name}", '$libraryPath', '${type.name}', )''';
//       } else if (fullName.contains("dart-sdk")) {
//         return '''createInstance("dart_sdk", '${fullName.split("/dart-sdk/lib/").last}', '${type.name}', )''';
//       }
//     }
//     return '''createInstance("", '', '', )''';
//   }
// }

// extension EnumElementData on EnumElement {
//   Map get toData {
//     EnumElementImpl impl = this as EnumElementImpl;
//     return {
//       "enumName": name,
//       'constructors': impl.constants.map((e) {
//         return {
//           "constructorName": e.name,
//         };
//       }).toList()
//     };
//   }
// }

extension SourceImport on Source {
//   String? get importPath {
//     final packages =
//         Get.find<HomeController>().packageConfig.value?.packages ?? [];
//     List<PackageInfo> infos = packages.where((element) {
//       return fullName.startsWith(element.rootUri.replaceFirst("file://", ""));
//     }).toList();
//     if (infos.isEmpty) return null;
//     PackageInfo info = infos[0];
//     final path = fullName.split("/lib/").last;
//     return 'package:${info.name}/$path';
//   }
}

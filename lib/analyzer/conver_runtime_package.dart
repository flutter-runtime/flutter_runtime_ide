import 'dart:async';
import 'dart:io';
import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
// import 'package:analyzer/file_system/file_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/mustache.dart';
import 'package:flutter_runtime_ide/analyzer/mustache_manager.dart';
import 'package:flutter_runtime_ide/app/utils/progress_hud_util.dart';
import 'package:flutter_runtime_ide/common/common_function.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:process_run/process_run.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

class ConverRuntimePackage {
  // 需要分析库的路径
  final String packagePath;
  // 分析的上下文
  final AnalysisContextCollection analysisContextCollection;

  final String outPutPath;

  late Pubspec pubspec;

  ConverRuntimePackage.fromPath(this.packagePath, this.outPutPath)
      : analysisContextCollection = AnalysisContextCollection(
          sdkPath: getDartPath(),
          includedPaths: [join(packagePath, "lib")],
        );

  FutureOr<void> conver() async {
    await analysisDartFileFromDir(join(packagePath, "lib"));
  }

  FutureOr<void> analysisDartFileFromDir(String dir) async {
    final sourceFile = join(packagePath, "pubspec.yaml");
    pubspec = Pubspec.parse(await File(sourceFile).readAsString());

    // 获取到当前需要分析目录下面所有的子元素
    List<FileSystemEntity> entitys =
        await Directory(dir).list(recursive: true).toList();
    int index = 1;
    for (FileSystemEntity entity in entitys) {
      showProgressHud(progress: index / entitys.length, text: entity.path);
      if (extension(entity.path) != ".dart") continue;
      // 根据文件路径获取到分析上下文
      SomeResolvedLibraryResult result = await getResolvedLibrary(entity.path);
      if (result is ResolvedLibraryResult) {
        logger.d(result);

        // 获取当前页面【export】元素
        for (var element in result.element.libraryExports) {
          // 获取 export  的路径
          String? exportPath = getRelativePath(element.uri);
          if (exportPath == null) {
            logger.e("$element export  没有对应路径!");
            continue;
          }

          // 获取 show  的类名
          final shownNames = element.combinators
              .whereType<ShowElementCombinator>()
              .fold<List<String>>([], (previousValue, element) {
            return previousValue..addAll(element.shownNames);
          });
          logger.i("[Export] $exportPath show $shownNames");
        }

        // 获取当前页面【import】元素
        for (var element in result.element.libraryImports) {
          // 获取 import  的路径
          String? importPath = getRelativePath(element.uri);
          if (importPath == null) {
            logger.e("$element import  没有对应路径!");
            continue;
          }
          if (element.combinators.isNotEmpty) {
            throw UnimplementedError();
          }
        }

        // 获取当前页面【class】元素
        final classes = result.element.units[0].classes.where((element) {
          return !element.name.isPrivate;
        });

        // 获取全局变量
        final topLevelVariables = result.element.units[0].topLevelVariables;
        // 获取全局函数
        final functions = result.element.units[0].functions;
        // 获取扩展
        final extensions = result.element.units[0].extensions;
        // 获取枚举
        final enums = result.element.units[0].enums;

        final sourcePath = entity.path.split(packageNamePath)[1];

        final data = {
          "pubName": pubspec.name,
          'sourcePath': sourcePath.replaceFirst("/lib", ""),
          "classes": classes.map((e) => e.toData),
        };

        final content = MustacheManager().render(fileMustache, data);
        final outFile = "$outPutPath/$packageNamePath$sourcePath";
        final file = File(outFile);
        if (!await file.exists()) {
          await file.create(recursive: true);
        }
        await file.writeAsString(content);
      } else if (result is NotLibraryButPartResult) {
        logger.v(result);
      } else {
        throw UnimplementedError(result.runtimeType.toString());
      }
      index++;
    }
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
    final specName = pubspec.name;
    final pubspecContent = MustacheManager().render(pubspecMustache, {
      "pubName": specName,
      "pubPath": packagePath,
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
      await create();
    }
    await writeAsString(content);
  }
}

extension ClassElementData on ClassElement {
  Map get toData {
    return {
      "className": name,
      "getFields": fields
          .map((e) => e.getter)
          .whereType<PropertyAccessorElement>()
          .where((element) => !element.name.isPrivate)
          .map((e) {
        return e.toData;
      }),
      "setFields": fields
          .map((e) => e.setter)
          .whereType<PropertyAccessorElement>()
          .where((element) => !element.name.isPrivate)
          .map((e) {
        return e.toData;
      }),
      "methods": methods
          .where((element) => !element.name.isPrivate)
          .where((element) => element.name != "[]")
          .map((e) => e.toData),
      "constructors": constructors
          .where((element) => !element.name.isPrivate)
          .map((e) => e.toData),
      "isAbstract": isAbstract,
    };
  }
}

extension FieldElementData on PropertyAccessorElement {
  Map get toData {
    return {
      "fieldName": name,
      "isStatic": isStatic,
    };
  }
}

extension MethodElementData on MethodElement {
  Map get toData {
    return {
      "methodName": name,
      "parameters": parameters.map((e) => e.toData),
    };
  }
}

extension ParameterElementData on ParameterElement {
  Map get toData {
    return {
      "parameterName": name,
      "isNamed": isNamed,
    };
  }
}

extension ConstructorElementData on ConstructorElement {
  Map get toData {
    return {
      "constructorName": name,
      "parameters": parameters.map((e) => e.toData),
      "isName": name.isNotEmpty,
    };
  }
}

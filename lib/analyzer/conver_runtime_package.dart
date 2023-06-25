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

    showProgressHud(progress: 0, text: '开始分析: $dir');

    // 获取到当前需要分析目录下面所有的子元素
    List<FileSystemEntity> entitys =
        await Directory(dir).list(recursive: true).toList();
    int index = 1;

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

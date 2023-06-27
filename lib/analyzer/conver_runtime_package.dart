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
import 'package:flutter_runtime_ide/analyzer/analyzer_package_manager.dart';
import 'package:flutter_runtime_ide/analyzer/file_runtime_generate.dart';
import 'package:flutter_runtime_ide/analyzer/import_analysis.dart';
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
import 'package:analyzer/src/dart/ast/ast.dart';

// 将指定库转换为运行时库
class ConverRuntimePackage {
  // 输入的路径
  final String outPutPath;
  // 总体的依赖配置
  final PackageConfig packageConfig;
  // 存储依赖的层级关系
  final PackageDependency packageDependency;

  /// 创建转换器
  ConverRuntimePackage(
    this.outPutPath,
    this.packageConfig,
    this.packageDependency,
  );
  // 将指定的库转换为运行时库
  // [packageName] 需要转换的库的名字
  Future<void> conver(String packageName) async {
    List<PackageInfo> infos = getPackages(packageName)
        .map((e) {
          final packages = packageConfig.packages
              .where((element) => element.name == e.name)
              .toList();
          if (packages.isEmpty) return null;
          return packages[0];
        })
        .whereType<PackageInfo>()
        .toList();
    if (infos.isEmpty) return;
    DateTime start = DateTime.now();
    int count = infos.length + 1;
    double progressIndex = 1.0 / count;
    double currentProgress = 0;
    int index = 0;
    await showProgressHud();
    for (var info in infos) {
      _PreAnalysisDartFile analysisDartFile = _PreAnalysisDartFile(info);
      analysisDartFile.progress.listen((p0) {
        double progress = currentProgress + p0 * progressIndex;
        updateProgressHud(progress: progress);
      });
      await analysisDartFile.analysis();
      AnalyzerPackageManager()
          .results(info.rootUri.replaceFirst("file://", ""));
      index += 1;
      currentProgress = progressIndex * index;
    }
    DateTime end = DateTime.now();
    logger.i("解析代码完毕, 耗时:${end.difference(start).inMilliseconds}");
    _GenerateDartFile analysisDartFile =
        _GenerateDartFile(infos[0], outPutPath, packageConfig);
    analysisDartFile.progress.listen((p0) {
      double progress = currentProgress + p0 * progressIndex;
      updateProgressHud(progress: progress);
    });
    await analysisDartFile.analysis();
    await createPubspecFile(infos[0]);
    logger.i("生成运行时库完毕");
    updateProgressHud(progress: 1.0);
  }

  // 获取路径
  String? getRelativePath(DirectiveUri uri) {
    if (uri is DirectiveUriWithLibrary) return uri.relativeUriString;
    return null;
  }

  Future<void> createPubspecFile(PackageInfo info) async {
    String packagePath = info.rootUri.replaceFirst("file://", '');
    String packageNamePath = basename(packagePath);
    final pubspecFile = "$outPutPath/$packageNamePath/pubspec.yaml";
    final specName = info.name;
    final pubspecContent = MustacheManager().render(pubspecMustache, {
      "pubName": specName,
      "pubPath": packagePath,
      'flutterRuntimePath':
          join(shellEnvironment['PWD']!, 'packages', 'flutter_runtime')
    });
    await File(pubspecFile).writeString(pubspecContent);
  }

  List<PackageDependencyInfo> getPackages(String packageName) {
    List<PackageDependencyInfo> packages = [];
    final info = JSON(packageDependency.packages
            .where((element) => element.name == packageName)
            .toList())[0]
        .rawValue;
    if (info == null) return packages;
    packages.add(info);
    for (var package in info.dependencies) {
      packages.addAll(getPackages(package));
    }
    return packages;
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

abstract class _AnalysisDartFile {
  final PackageInfo info;
  late String packagePath;
  late String analysisDir;
  var progress = 0.0.obs;
  _AnalysisDartFile(this.info);

  Future<void> analysis() async {
    packagePath = info.rootUri.replaceFirst("file://", "");
    analysisDir = join(packagePath, info.packageUri);
    // 获取到当前需要分析目录下面所有的子元素
    List<FileSystemEntity> entitys =
        await Directory(analysisDir).list(recursive: true).toList();
    int count = entitys.length;
    int current = 0;
    for (FileSystemEntity entity in entitys) {
      final filePath = entity.path;
      if (extension(filePath) != ".dart") continue;
      logger.v(filePath);
      // 根据文件路径获取到分析上下文
      await analysisDartFile(filePath);
      current += 1;
      progress.value = current / count;
    }
  }

  Future<void> analysisDartFile(String filePath) async {
    throw UnimplementedError();
  }
}

class _PreAnalysisDartFile extends _AnalysisDartFile {
  _PreAnalysisDartFile(PackageInfo info) : super(info);

  @override
  Future<void> analysisDartFile(String filePath) async {
    await AnalyzerPackageManager().getResolvedLibrary(packagePath, filePath);
  }
}

class _GenerateDartFile extends _AnalysisDartFile {
  final String outPutPath;
  final PackageConfig packageConfig;
  _GenerateDartFile(PackageInfo info, this.outPutPath, this.packageConfig)
      : super(info);

  @override
  Future<void> analysisDartFile(String filePath) async {
    final result = await AnalyzerPackageManager().getResolvedLibrary(
      packagePath,
      filePath,
    );

    if (result is ResolvedLibraryResultImpl) {
      final libraryPath =
          filePath.split(packagePath)[1].replaceFirst("/lib", "");
      final sourcePath = 'package:${info.name}$libraryPath';
      final importAnalysisList = await getImportAnalysis(result);
      FileRuntimeGenerate generate = FileRuntimeGenerate(
        sourcePath,
        packageConfig,
        info,
        result,
        importAnalysisList,
      );
      final generateCode = await generate.generateCode();

      final outFile =
          "$outPutPath/${packagePath.split('/').last}${'/lib$libraryPath'}";
      final file = File(outFile);
      await file.writeString(generateCode);
    } else if (result is NotLibraryButPartResult) {
      logger.v(result);
    } else {
      throw UnimplementedError(result.runtimeType.toString());
    }
  }

  Future<List<ImportAnalysis>> getImportAnalysis(
      SomeResolvedLibraryResult result) async {
    if (result is! ResolvedLibraryResultImpl) return [];
    List<ImportAnalysis> imports = [];
    for (var unit in result.units) {
      for (var element in unit.unit.directives) {
        if (element is! NamespaceDirectiveImpl) continue;
        final uriContent = Unwrap(element.element).map((e) {
              if (e is! LibraryImportElementImpl) return null;
              final fullName = e.importedLibrary?.source.fullName;
              if (fullName == null) return fullName;
              final infos = packageConfig.packages
                  .where((e) => fullName.startsWith(e.packagePath))
                  .toList();
              if (infos.isEmpty) return null;
              return 'package:${infos[0].name}${fullName.split('lib')[1]}';
            }).value ??
            element.uri.stringValue;
        String? asName;
        if (element is ImportDirectiveImpl) {
          asName = element.asKeyword?.stringValue;
        }
        final shownNames = element.combinators
            .whereType<ShowCombinatorImpl>()
            .map((e) => e.shownNames.map((e) => e.name).toList())
            .fold<List<String>>(
          [],
          (previousValue, element) => previousValue..addAll(element),
        );
        final hideNames = element.combinators
            .whereType<HideCombinatorImpl>()
            .map((e) => e.hiddenNames.map((e) => e.name).toList())
            .fold<List<String>>(
          [],
          (previousValue, element) => previousValue..addAll(element),
        );
        imports.add(ImportAnalysis(
          uriContent,
          showNames: shownNames,
          hideNames: hideNames,
          asName: asName,
        ));
      }
    }
    return imports;
  }

  Future<SomeResolvedLibraryResult?> getLibrary(String uriContent) async {
    if (uriContent.startsWith("package:")) {
      // package:ffi/ffi.dart
      final content = uriContent.replaceFirst("package:", "");
      final contentPaths = content.split('/');
      final packageName = contentPaths[0];
      contentPaths.removeAt(0);
      final info = packageConfig.packages
          .firstWhere((element) => element.name == packageName);
      final prefix = info.rootUri.replaceFirst("file://", "").split('lib')[0];
      final packagePath = join(prefix, 'lib', contentPaths.join('/'));
      return AnalyzerPackageManager().getResolvedLibrary(prefix, packagePath);
    } else {
      return null;
    }
  }
}

import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/element/type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/analyzer_package_manager.dart';
import 'package:flutter_runtime_ide/analyzer/configs/package_config.dart';
import 'package:flutter_runtime_ide/analyzer/conver_runtime_package.dart';
import 'package:flutter_runtime_ide/app/utils/progress_hud_util.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:process_run/process_run.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../analyzer/file_runtime_generate.dart';
import '../../../../analyzer/mustache/mustache.dart';
import '../../../../analyzer/mustache/mustache_manager.dart';
import '../../../../common/common_function.dart';

class AnalyzerDetailController extends GetxController {
  // 当前分析库的信息
  final PackageInfo packageInfo;
  // 当前分析工程的多有依赖的信息
  final PackageConfig packageConfig;
  // 当前分析工程的依赖配置信息
  final PackageDependency packageDependency;
  // 分析过程的日志列表
  var logs = <LogEvent>[].obs;

  // 当前总分析进度
  var progress = 0.0.obs;
  // 依赖库列表的分析进度
  var itemProgressMap = <String, double>{}.obs;

  /// 保存依赖库是否开启缓存
  var dependencyCacheStates = <String, RxBool>{};

  /// 当前工程的所有依赖
  late List<PackageInfo> allDependenceInfos;

  /// 是否全部使用缓存
  var useCache = false.obs;

  final ScrollController logScrollController = ScrollController();
  final ItemScrollController itemScrollController = ItemScrollController();

  AnalyzerDetailController(
    this.packageInfo,
    this.packageConfig,
    this.packageDependency,
  ) {
    final allDependences = _getPackageAllDependencies(packageInfo.name);

    allDependenceInfos = allDependences
        .map((e) => e.name)
        .toSet()
        .map((e) {
          return packageConfig.packages.firstWhereOrNull((element) {
            return element.name == e;
          });
        })
        .whereType<PackageInfo>()
        .toList();
    for (var e in allDependenceInfos) {
      dependencyCacheStates[e.name] = true.obs;
    }

    useCache.value = dependencyCacheStates.values.every((element) {
      return element.value;
    });

    /// 每隔 500 秒自动滚动
    _autoScrollLog();
  }

  /// 获取输出运行库保存的目录
  String get outPutPath {
    return join(AnalyzerPackageManager.defaultRuntimePath, 'runtime');
  }

  // 分析依赖
  Future<void> analyzerPackage() async {
    reset();

    callback(event) => logs.add(event);
    Logger.addLogListener(callback);

    logger.i('开始分析......');

    final infos = allDependenceInfos;
    if (infos.isEmpty) {
      logger.e('没有依赖可以分析');
      return;
    }

    //先删除之前生成的库缓存
    await _deleteExitCache(infos[0]);

    // 分析开始计时
    DateTime start = DateTime.now();

    // 总共有 [count] 个任务
    int count = infos.length + 2;

    // 每个任务的进度
    double progressIndex = 1.0 / count;

    int index = 0;
    for (var info in infos) {
      itemScrollController.jumpTo(index: index);
      const ignorePackages = [
        'flutter',
        'flutter_test',
      ];
      if (ignorePackages.contains(info.name)) {
        index++;
      }
      _PreAnalysisDartFile analysisDartFile = _PreAnalysisDartFile(
        info,
        getCacheStates(info.name).value,
      );
      analysisDartFile.progress.listen((p0) {
        setItemProgress(info.name, p0);
      });
      await analysisDartFile.analysis();
      setItemProgress(info.name, 1);
      index += 1;
      progress.value = progressIndex * index;
    }
    DateTime end = DateTime.now();
    logger.i("解析代码完毕, 耗时:${end.difference(start).inMilliseconds} 毫秒");

    // 生成当前库的运行时库
    _GenerateDartFile analysisDartFile = _GenerateDartFile(
      infos[0],
      packageConfig,
      getCacheStates(infos[0].name).value,
    );
    analysisDartFile.progress.listen((p0) {
      // double progress = currentProgress + p0 * progressIndex;
    });
    await analysisDartFile.analysis();
    index++;
    progress.value = progressIndex * index;

    // 生成运行时库的依赖文件
    await createPubspecFile(infos[0]);

    // 对于代码进行格式化
    final rootPath = join(outPutPath, infos.first.cacheName);
    final dart = await which("dart");
    StreamController<List<int>> stdoutController = StreamController();
    stdoutController.stream.listen(
      (event) {
        String log = String.fromCharCodes(event);
        logger.i(log);
      },
    );
    try {
      final shell = Shell(workingDirectory: rootPath, stdout: stdoutController);
      await shell.run('''
flutter pub get
$dart format ./
''');

      // 移除监听日志
      Logger.removeLogListener(callback);
    } catch (e) {
      logger.e(e);
      Get.snackbar('代码格式错误', e.toString());
    }
    progress.value = 1;
    logger.i("生成运行时库完毕");
  }

  Future<void> createPubspecFile(PackageInfo info) async {
    final pubspecFile = "$outPutPath/${info.cacheName}/pubspec.yaml";
    final specName = info.name;
    final pubspecContent = MustacheManager().render(pubspecMustache, {
      "pubName": specName,
      "pubPath": info.packagePath,
      'flutterRuntimePath':
          join(shellEnvironment['PWD']!, 'packages', 'flutter_runtime')
    });
    await File(pubspecFile).writeString(pubspecContent);
  }

  // 获取指定库的所有依赖库
  List<PackageDependencyInfo> _getPackageAllDependencies(String packageName) {
    List<PackageDependencyInfo> packages = [];
    final info = packageDependency.packages.firstWhereOrNull((element) {
      return element.name == packageName;
    });
    if (info == null) return packages;
    if (!packages.any((element) => element.name == info.name)) {
      packages.add(info);
    }
    for (var package in info.dependencies) {
      packages.addAll(_getPackageAllDependencies(package));
    }
    return packages;
  }

  Future<void> _deleteExitCache(PackageInfo info) async {
    final cachePath = join(
      AnalyzerPackageManager.defaultRuntimePath,
      'runtime',
      info.cacheName,
    );
    if (await Directory(cachePath).exists()) {
      await Directory(cachePath).delete(recursive: true);
    }
  }

  double getItemProgress(String name) {
    return itemProgressMap[name] ?? 0.0;
  }

  void setItemProgress(String name, double progress) {
    itemProgressMap[name] = progress;
  }

  // 清理日志
  void clearLogs() {
    logs.clear();
  }

  /// 改变全部的缓存状态
  void changeAllCacheStates(bool value) {
    for (var name in dependencyCacheStates.keys) {
      dependencyCacheStates[name]?.value = value;
    }
    useCache.value = value;
  }

  /// 改变单个的缓存状态
  void changeCacheStates(String name, bool value) {
    dependencyCacheStates[name]?.value = value;
  }

  /// 获取单个的缓存状态
  RxBool getCacheStates(String name) {
    return dependencyCacheStates[name]!;
  }

  /// 重新初始化状态
  void reset() {
    progress.value = 0.0;
    clearLogs();
    itemProgressMap.clear();
  }

  openFolder() async {
    final open = await which('open');

    StreamController<List<int>> stdErrorController = StreamController();
    stdErrorController.stream.listen(
      (event) {
        Get.snackbar('错误', String.fromCharCodes(event));
      },
    );

    await Shell(stderr: stdErrorController).run('''
$open ${join(outPutPath, packageInfo.cacheName)} -a 'Visual Studio Code.app'
''');
  }

  _autoScrollLog() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!logScrollController.hasClients) {
        timer.cancel();
        return;
      }
      if (logScrollController.position.pixels ==
          logScrollController.position.maxScrollExtent) return;
      logScrollController.jumpTo(logScrollController.position.maxScrollExtent);
    });
  }
}

abstract class _AnalysisDartFile {
  final PackageInfo info;
  var progress = 0.0.obs;
  _AnalysisDartFile(this.info);

  Future<void> analysis() async {
    if (!await Directory(info.libPath).exists()) {
      return;
    }

    List<FileSystemEntity> entitys = [];
    Completer<List<FileSystemEntity>> completer = Completer();
    Directory(info.libPath).list(recursive: true).listen(
      (event) {
        entitys.add(event);
      },
      onDone: () => completer.complete(entitys),
    );
    await completer.future;
    // 获取到当前需要分析目录下面所有的子元素
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
  final bool useCache;
  _PreAnalysisDartFile(PackageInfo info, this.useCache) : super(info);

  @override
  Future<void> analysisDartFile(String filePath) async {
    await AnalyzerPackageManager().getAnalyzerFileCache(
      info,
      filePath,
      useCache,
    );
  }
}

class _GenerateDartFile extends _AnalysisDartFile {
  final PackageConfig packageConfig;
  final bool useCache;
  _GenerateDartFile(PackageInfo info, this.packageConfig, this.useCache)
      : super(info);

  @override
  Future<void> analysisDartFile(String filePath) async {
    // FixRuntimeConfiguration? fixRuntimeConfiguration =
    //     AnalyzerPackageManager().getFixRuntimeConfiguration(info);
    final libraryPath =
        filePath.split(info.packagePath)[1].replaceFirst("/lib/", "");
    // FixConfig? fixConfig = fixRuntimeConfiguration?.fixs
    //     .firstWhereOrNull((element) => element.path == libraryPath);

    final result = await AnalyzerPackageManager()
        .getAnalyzerFileCache(info, filePath, useCache);

    if (result == null) return;

    final sourcePath = 'package:${info.name}/$libraryPath';
    // final importAnalysisList = await getImportAnalysis(result);
    FileRuntimeGenerate generate = FileRuntimeGenerate(
      sourcePath,
      packageConfig,
      info,
      result,
    );
    final generateCode = await generate.generateCode();

    final outFile = join(AnalyzerPackageManager.defaultRuntimePath, 'runtime',
        info.cacheName, 'lib', libraryPath);
    final file = File(outFile);
    await file.writeString(generateCode);

    // if (result is ResolvedLibraryResultImpl) {
    //   final sourcePath = 'package:${info.name}/$libraryPath';
    //   final importAnalysisList = await getImportAnalysis(result);
    //   FileRuntimeGenerate generate = FileRuntimeGenerate(
    //     sourcePath,
    //     packageConfig,
    //     info,
    //     result,
    //     importAnalysisList,
    //     fixConfig: fixConfig,
    //   );
    //   final generateCode = await generate.generateCode();

    //   final outFile = "$outPutPath/${info.cacheName}${'/lib/$libraryPath'}";
    //   final file = File(outFile);
    //   await file.writeString(generateCode);
    // } else if (result is NotLibraryButPartResult) {
    //   logger.v(result);
    // } else {
    //   throw UnimplementedError(result.runtimeType.toString());
    // }
  }

  // Future<List<ImportAnalysis>> getImportAnalysis(
  //     SomeResolvedLibraryResult result) async {
  //   if (result is! ResolvedLibraryResultImpl) return [];
  //   List<ImportAnalysis> imports = [];
  //   for (var unit in result.units) {
  //     for (var element in unit.unit.directives) {
  //       if (element is! ImportDirectiveImpl) continue;
  //       final uriContent = Unwrap(element.element).map((e) {
  //             final fullName = e.importedLibrary?.source.fullName;
  //             if (fullName == null) return fullName;

  //             final infos = packageConfig.packages
  //                 .where((e) => fullName.startsWith(e.packagePath))
  //                 .toList();
  //             if (infos.isEmpty) return null;
  //             return 'package:${infos[0].name}/${fullName.split('/lib/')[1]}';
  //           }).value ??
  //           element.uri.stringValue;
  //       Namespace? nameSpace = await Unwrap(uriContent).map((e) async {
  //         final result = await getLibrary(e);
  //         if (result is! ResolvedLibraryResultImpl) return null;
  //         return result.element.exportNamespace;
  //       }).value;

  //       String? asName = element.prefix?.name;
  //       final shownNames = element.combinators
  //           .whereType<ShowCombinatorImpl>()
  //           .map((e) => e.shownNames.map((e) => e.name).toList())
  //           .fold<List<String>>(
  //         [],
  //         (previousValue, element) => previousValue..addAll(element),
  //       );
  //       final hideNames = element.combinators
  //           .whereType<HideCombinatorImpl>()
  //           .map((e) => e.hiddenNames.map((e) => e.name).toList())
  //           .fold<List<String>>(
  //         [],
  //         (previousValue, element) => previousValue..addAll(element),
  //       );
  //       final filterImports = [
  //         'dart:_js_embedded_names',
  //         'dart:_js_helper',
  //         'dart:_foreign_helper',
  //         'dart:_rti',
  //         'dart:html_common',
  //         'dart:indexed_db',
  //         'dart:_native_typed_data',
  //         'dart:svg',
  //         'dart:web_audio',
  //         'dart:web_gl',
  //         'dart:mirrors',
  //       ];
  //       if (filterImports.contains(JSON(uriContent).stringValue)) {
  //         continue;
  //       }
  //       if (JSON(uriContent).stringValue.startsWith("package:flutter/")) {
  //         continue;
  //       }
  //       imports.add(ImportAnalysis(
  //         uriContent,
  //         showNames: shownNames,
  //         hideNames: hideNames,
  //         asName: asName,
  //         exportNamespace: nameSpace,
  //       ));
  //     }
  //   }
  //   return imports;
  // }

  // Future<SomeResolvedLibraryResult?> getLibrary(String uriContent) async {
  //   String? packagePath;
  //   String? libraryPath;
  //   if (uriContent.startsWith("package:")) {
  //     // package:ffi/ffi.dart
  //     final content = uriContent.replaceFirst("package:", "");
  //     final contentPaths = content.split('/');
  //     final packageName = contentPaths[0];
  //     contentPaths.removeAt(0);
  //     final info = packageConfig.packages
  //         .firstWhere((element) => element.name == packageName);
  //     packagePath = info.rootUri.replaceFirst("file://", "").split('lib')[0];
  //     libraryPath = join(packagePath, 'lib', contentPaths.join('/'));
  //   }
  //   if (packagePath == null || libraryPath == null) return null;
  //   return AnalyzerPackageManager().getResolvedLibrary(
  //     packagePath,
  //     libraryPath,
  //   );
  // }
}

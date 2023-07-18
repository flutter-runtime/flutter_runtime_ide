import 'dart:async';
import 'dart:io';

import 'package:flutter_runtime_ide/analyzer/analyzer_package_manager.dart';
import 'package:flutter_runtime_ide/analyzer/configs/package_config.dart';
import 'package:flutter_runtime_ide/analyzer/conver_runtime_package.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:process_run/process_run.dart';

import '../common/common_function.dart';
import 'file_runtime_generate.dart';
import 'mustache/mustache.dart';
import 'mustache/mustache_manager.dart';

class GenerateRuntimePackage {
  final PackageInfo info;
  final PackageConfig packageConfig;
  final PackageDependency packageDependency;
  final Progress? progress;
  List<LogEvent> _logs = [];

  GenerateRuntimePackage(
    this.info,
    this.packageConfig,
    this.packageDependency, {
    this.progress,
  });

  List<LogEvent> get logs => _logs;

  // 分析依赖
  Future<void> generate() async {
    callback(event) => logs.add(event);
    Logger.addLogListener(callback);

    logger.i('开始分析......');

    final allDependences = _getPackageAllDependencies(info.name);
    final allDependenceInfos = allDependences
        .map((e) => e.name)
        .toSet()
        .map((e) {
          return AnalyzerPackageManager.getAllowGeneratedPackages(packageConfig)
              .firstWhereOrNull((element) => element.name == e);
        })
        .whereType<PackageInfo>()
        .toList();

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
      _PreAnalysisDartFile analysisDartFile = _PreAnalysisDartFile(info, true);
      analysisDartFile.progress.listen((p0) {});
      await analysisDartFile.analysis();
      index += 1;
    }
    DateTime end = DateTime.now();
    logger.i("解析代码完毕, 耗时:${end.difference(start).inMilliseconds} 毫秒");

    // 生成当前库的运行时库
    _GenerateDartFile analysisDartFile = _GenerateDartFile(
      infos[0],
      packageConfig,
      true,
    );
    analysisDartFile.progress.listen((p0) {
      // double progress = currentProgress + p0 * progressIndex;
    });
    await analysisDartFile.analysis();
    index++;

    // 生成运行时库的依赖文件
    await createPubspecFile(infos[0]);

    // 对于代码进行格式化
    final rootPath = AnalyzerPackageManager.getRuntimePath(info);
    final dart = await which("dart");
    StreamController<List<int>> stdoutController = StreamController();
    stdoutController.stream.listen(
      (event) {
        String log = String.fromCharCodes(event);
        logger.i(log);
      },
    );
    final flutter = await which('flutter');
    try {
      final shell = Shell(workingDirectory: rootPath, stdout: stdoutController);
      await shell.run('''
$flutter pub get
$dart format ./
''');

      // 移除监听日志
      Logger.removeLogListener(callback);
    } catch (e) {
      logger.e(e);
    }
  }

  Future<void> createPubspecFile(PackageInfo info) async {
    final pubspecFile =
        join(AnalyzerPackageManager.getRuntimePath(info), 'pubspec.yaml');
    var specName = info.name;
    if (info.name == 'flutter') {
      specName = 'flutter_${info.version}';
    }
    final pubspecContent = MustacheManager().render(pubspecMustache, {
      "pubName": specName,
      "pubPath": info.packagePath,
      'override': !['flutter'].contains(info.name),
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
      // 根据文件路径获取到分析上下文
      await analysisDartFile(filePath);
      current += 1;
      progress.value = current / count;
      logger.v(
          '[${info.name}:${(progress * 100).toStringAsFixed(2)}%] $filePath');
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
  }
}

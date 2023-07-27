import 'dart:async';
import 'dart:io';

import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter_runtime_ide/analyzer/analyze_info.dart';
import 'package:flutter_runtime_ide/analyzer/analyzer_package_manager.dart';
import 'package:flutter_runtime_ide/analyzer/configs/package_config.dart';
import 'package:flutter_runtime_ide/analyzer/generate_runtime_package.dart';
import 'package:flutter_runtime_ide/app/utils/progress_hud_util.dart';
import 'package:flutter_runtime_ide/common/plugin_manager.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:process_run/process_run.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../analyzer/mustache/mustache.dart';
import '../../../../analyzer/mustache/mustache_manager.dart';

class AnalyzerDetailController extends GetxController {
  // 当前分析库的信息
  final PackageInfo packageInfo;
  // 当前分析工程的多有依赖的信息
  final PackageConfig packageConfig;
  // 当前分析工程的依赖配置信息
  final PackageDependency packageDependency;
  // 分析过程的日志列表
  var logs = <GenerateRuntimePackageProgress>[].obs;

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

  final ItemScrollController logScrollController = ItemScrollController();
  final ItemScrollController itemScrollController = ItemScrollController();

  /// 分析信息
  var errorInfos = <AnalyzeInfo>[].obs;
  var warningInfos = <AnalyzeInfo>[].obs;
  var infoInfos = <AnalyzeInfo>[].obs;

  var currentAnalyzeLog = Rx<LogEvent?>(null);

  /// 修复的插件
  CommandInfo? commandInfo;

  AnalyzerDetailController(
    this.packageInfo,
    this.packageConfig,
    this.packageDependency,
    this.commandInfo,
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

    Future.delayed(const Duration(microseconds: 500), () async {
      showHUD();
      await analyzerGenerateCode();

      hideHUD();
    });
  }

  /// 获取输出运行库保存的目录
  String get outPutPath {
    return join(AnalyzerPackageManager.defaultRuntimePath, 'runtime');
  }

  /// 输出的库目录
  String get packageOutputPath => join(outPutPath, packageInfo.name);

  // 分析依赖
  Future<void> analyzerPackage() async {
    reset();
    GenerateRuntimePackage generateRuntimePackage = GenerateRuntimePackage(
      packageInfo,
      packageConfig,
      packageDependency,
      progress: (percent) => progress.value = 0.8 * percent,
      logCallback: (event) => currentAnalyzeLog.value = event,
      analyzeProgress: (progress) => _updateProgress(progress),
      commandInfo: commandInfo,
    );
    await generateRuntimePackage.generate();
    _updateProgress(GenerateRuntimePackageProgress(
      GenerateRuntimePackageProgressType.analyzeProject,
      '正在分析[${packageInfo.name}]代码',
      0,
      packageName: packageInfo.name,
    ));
    await analyzerGenerateCode();
    _updateProgress(GenerateRuntimePackageProgress(
      GenerateRuntimePackageProgressType.analyzeProject,
      '正在分析[${packageInfo.name}]代码',
      1,
      packageName: packageInfo.name,
    ));
    progress.value = 1;
    currentAnalyzeLog.value =
        LogEvent(Level.info, '生成${packageInfo.name}运行库完毕!');
  }

  void _updateProgress(GenerateRuntimePackageProgress progress) {
    final index = logs.indexWhere((element) =>
        element.progressType == progress.progressType &&
        element.packageName == progress.packageName);
    if (index == -1) {
      logs.add(progress);
      Future.delayed(const Duration(milliseconds: 500)).then(
        (value) {
          logScrollController.jumpTo(index: index + 1);
          if (progress.progressType ==
              GenerateRuntimePackageProgressType.analyze) {
            final packageIndex = allDependenceInfos.indexWhere(
              (e) => e.name == progress.packageName,
            );
            if (packageIndex != -1) {
              itemScrollController.jumpTo(index: packageIndex);
            }
          }
        },
      );
    } else {
      logs[index] = progress;
    }
    if (progress.progressType == GenerateRuntimePackageProgressType.analyze) {
      Unwrap(progress.packageName).map(
        (e) => setItemProgress(e, progress.progress),
      );
    }
  }

  Future<void> createPubspecFile(PackageInfo info) async {
    final pubspecFile = "$outPutPath/${info.cacheName}/pubspec.yaml";
    var specName = info.name;
    if (info.name == 'flutter') {
      specName = 'flutter_${info.version}';
    }
    final pubspecContent = MustacheManager().render(pubspecMustache, {
      "pubName": specName,
      "pubPath": info.packagePath,
      'override': !['flutter'].contains(info.name),
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

  double getItemProgress(String name) {
    return itemProgressMap[name] ?? 0.0;
  }

  void setItemProgress(String name, double progress) {
    itemProgressMap[name] = progress;
  }

  // 清理日志
  void clearLogs() {
    logs.value = [];
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

  Future<void> analyzerGenerateCode() async {
    final workDirectory = join(outPutPath, packageInfo.cacheName);
    if (!await Directory(workDirectory).exists()) {
      return;
    }
    final flutter = await which('flutter');
    final shell = Shell(workingDirectory: workDirectory);
    ProcessResult? result;
    try {
      result =
          await shell.run('''$flutter analyze''').then((value) => value.first);
    } catch (e) {
      if (e is ShellException) {
        result = e.result;
      }
    }
    if (result == null) return;
    final outLines = result.outLines;
    final infos = parseAnalyzeInfos(outLines);
    errorInfos.addAll(
        infos.where((element) => element.infoType == AnalyzeInfoType.error));
    warningInfos.addAll(
        infos.where((element) => element.infoType == AnalyzeInfoType.warning));
    infoInfos.addAll(
        infos.where((element) => element.infoType == AnalyzeInfoType.info));
  }
}

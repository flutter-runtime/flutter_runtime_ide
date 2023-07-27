import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:analyze_cache/analyze_cache.dart' hide StringPrivate, ListFirst;
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter_runtime_ide/analyzer/analyzer_package_manager.dart';
import 'package:flutter_runtime_ide/analyzer/configs/package_config.dart';
import 'package:flutter_runtime_ide/common/command_run.dart';
import 'package:flutter_runtime_ide/common/define.dart';
import 'package:flutter_runtime_ide/common/plugin_manager.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:process_run/process_run.dart';
import 'package:plugin_channel/plugin_channel.dart';

import '../common/common_function.dart';
import 'file_runtime_generate.dart';
import 'mustache/mustache.dart';
import 'mustache/mustache_manager.dart';

/// 生成运行时库
class GenerateRuntimePackage {
  /// 依赖库信息
  final PackageInfo info;

  /// 当前工程的第三方库的配置
  final PackageConfig packageConfig;

  /// 第三方库依赖库信息
  final PackageDependency packageDependency;

  /// 分析进度
  final Progress? progress;

  /// 分析期间产生的日志
  final LogCallback? logCallback;

  /// 分析的进度
  /// [packageName] 当前分析库名称
  /// [progress] 当前分析的进度
  final void Function(GenerateRuntimePackageProgress progress)? analyzeProgress;

  /// 是否允许生成完毕初始化工程 默认 true
  final bool allowInitProject;

  /// 修复的命令
  final CommandInfo? commandInfo;

  /// 创建运行库生成器
  /// [info] 依赖库信息
  /// [packageConfig] 当前工程的第三方库的配置
  /// [packageDependency] 第三方库依赖库信息
  GenerateRuntimePackage(
    this.info,
    this.packageConfig,
    this.packageDependency, {
    this.progress,
    this.logCallback,
    this.analyzeProgress,
    this.allowInitProject = true,
    this.commandInfo,
  });

  // 分析依赖
  Future<void> generate() async {
    /// 创建坚挺日志的回掉
    callback(event) => logCallback?.call(event);

    /// 添加日志坚挺
    Logger.addLogListener(callback);

    logger.i('开始分析......');

    final allDependences = _getPackageAllDependencies(info.name);

    /// 查询所有依赖库的库信息
    final infos = allDependences
        .map((e) => e.name)
        .toSet()
        .map((e) {
          return AnalyzerPackageManager.getAllowGeneratedPackages(packageConfig)
              .firstWhereOrNull((element) => element.name == e);
        })
        .whereType<PackageInfo>()
        .toList();

    if (infos.isEmpty) {
      logger.e('没有依赖可以分析');
      return;
    }

    //先删除之前生成的库缓存
    await _deleteExitCache(infos[0]);

    // 分析开始计时
    DateTime start = DateTime.now();

    // 总共有 [count] 个任务
    int count = infos.length + 1;
    if (allowInitProject) count++;

    int index = 0;

    /// 对于所有的库进行分析
    for (var info in infos) {
      index += 1;
      _PreAnalysisDartFile analysisDartFile = _PreAnalysisDartFile(info, true);
      analysisDartFile.progress.listen((p0) {
        analyzeProgress?.call(GenerateRuntimePackageProgress(
          GenerateRuntimePackageProgressType.analyze,
          '正在分析[${info.name}]代码',
          p0,
          packageName: info.name,
        ));
        _setProgress(count, index, itemProgress: p0);
      });
      await analysisDartFile.analysis();
    }
    DateTime end = DateTime.now();
    logger.i("解析代码完毕, 耗时:${end.difference(start).inMilliseconds} 毫秒");

    // 生成当前库的运行时库
    _GenerateDartFile analysisDartFile = _GenerateDartFile(
      infos[0],
      packageConfig,
      true,
      commandInfo,
    );
    index++;
    analysisDartFile.progress.listen((p0) {
      analyzeProgress?.call(GenerateRuntimePackageProgress(
        GenerateRuntimePackageProgressType.generate,
        '正在生成[${info.name}]代码',
        p0,
        packageName: info.name,
      ));
      _setProgress(count, index, itemProgress: p0);
    });
    await analysisDartFile.analysis();

    // 生成运行时库的依赖文件
    await createPubspecFile(infos[0]);

    if (allowInitProject) {
      index++;
      _setProgress(count, index, itemProgress: 0);
      analyzeProgress?.call(GenerateRuntimePackageProgress(
        GenerateRuntimePackageProgressType.initProject,
        '正在初始化[${info.name}]代码',
        0,
        packageName: info.name,
      ));
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
        final shell =
            Shell(workingDirectory: rootPath, stdout: stdoutController);
        await shell.run('''
$flutter pub get
$dart format ./
''');

        // 移除监听日志
        Logger.removeLogListener(callback);
      } catch (e) {
        logger.e(e.toString());
      }
      analyzeProgress?.call(GenerateRuntimePackageProgress(
        GenerateRuntimePackageProgressType.initProject,
        '正在初始化[${info.name}]代码',
        1,
        packageName: info.name,
      ));
    }
    _setProgress(count, index);
  }

  /// 设置进度
  /// [count] 总共有 [count] 个任务
  /// [index] 当前任务的索引
  /// [itemProgress] 当前任务总体的进度
  _setProgress(int count, int index, {double? itemProgress}) {
    index = max(1, index);
    double indexProgress = 1 / count;

    double currentProgress;
    if (itemProgress != null) {
      currentProgress =
          indexProgress * (index - 1) + indexProgress * itemProgress;
    } else {
      currentProgress = indexProgress * index;
    }
    currentProgress = min(1.0, currentProgress);
    progress?.call(currentProgress);
  }

  Future<void> createPubspecFile(PackageInfo info) async {
    final pubspecFile =
        join(AnalyzerPackageManager.getRuntimePath(info), 'pubspec.yaml');
    final pubspecContent = MustacheManager().render(pubspecMustache, {
      'runtimeName': info.runtimeName,
      "pubName": info.name,
      "pubPath": info.packagePath,
      'override': !['flutter'].contains(info.name),
    });
    await File(pubspecFile).writeString(pubspecContent);
  }

  // 获取指定库的所有依赖库
  /// [packageName] 依赖库名称
  List<PackageDependencyInfo> _getPackageAllDependencies(String packageName) {
    List<PackageDependencyInfo> packages = [];

    /// 获取指定库的依赖库信息
    final info = packageDependency.packages.firstWhereOrNull((element) {
      return element.name == packageName;
    });

    if (info == null) return packages;

    /// 如果列表里面没有存在同名称的库则进行添加
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

  String get action;

  Future<void> analysis() async {
    List<File> entitys = await AnalyzerPackageManager.readAllSourceFiles(info);
    if (entitys.isEmpty) {
      progress.value = 1.0;
      return;
    }
    // 获取到当前需要分析目录下面所有的子元素
    int count = entitys.length;
    int current = 0;
    for (var entity in entitys) {
      current += 1;
      final filePath = entity.path;
      // 根据文件路径获取到分析上下文
      await analysisDartFile(filePath);
      progress.value = current / count;
      logger.v(
          '[$action][${info.name}:${(progress * 100).toStringAsFixed(2)}%] $filePath');
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

  @override
  String get action => '分析';
}

class _GenerateDartFile extends _AnalysisDartFile {
  final PackageConfig packageConfig;
  final bool useCache;
  final CommandInfo? commandInfo;
  _GenerateDartFile(
    PackageInfo info,
    this.packageConfig,
    this.useCache,
    this.commandInfo,
  ) : super(info);

  @override
  Future<void> analysisDartFile(String filePath) async {
    // FixRuntimeConfiguration? fixRuntimeConfiguration =
    //     AnalyzerPackageManager().getFixRuntimeConfiguration(info);
    final libraryPath =
        filePath.split(info.packagePath)[1].replaceFirst("/lib/", "");
    // FixConfig? fixConfig = fixRuntimeConfiguration?.fixs
    //     .firstWhereOrNull((element) => element.path == libraryPath);

    var result = await AnalyzerPackageManager()
        .getAnalyzerFileCache(info, filePath, useCache);

    final sourcePath = 'package:${info.name}/$libraryPath';

    final contentData = {
      'uriContent': sourcePath,
    };
    result?.imports.add(AnalyzerImportCache(contentData, contentData));

    /// 启动修复插件让插件进行修复
    if (commandInfo != null) {
      /// 需要修复的数据
      final data = result?.toJson();

      /// 生成通道 ID
      final id = ChannelIdentifier.fromPluginName(commandInfo!.cli.name);

      /// 通道的数据
      final request = ChannelResponse.success(data);

      /// 请求资源
      final resouce = ChannelResource(id);

      /// 保存通道数据
      await resouce.saveRequestResource(request);

      /// 运行修复命令
      try {
        if (JSON(commandInfo?.isDeveloper).boolValue) {
          final name = commandInfo!.cli.name;
          await CommandRun(
            'dart',
            'run ${join(commandInfo!.cli.installPath, 'bin', '$name.dart')} $fixCommandName -i $id',
          ).run();
        } else {
          await CommandRun(
            'dcm',
            'run -n ${commandInfo!.cli.name}@${commandInfo!.cli.ref} -c $fixCommandName -i $id',
          ).run();
        }

        /// 获取返回内容
        final response = await resouce.readResponseResource();
        result = AnalyzerFileCache(response.data, response.data);

        /// 删除请求和返回的资源
        await resouce.removeRequestResource();
        await resouce.removeResponseResource();
      } on ShellException catch (e) {
        logger.e(e.result?.stdout);
      } catch (e) {
        logger.e(e.toString());
      }
    }

    if (result == null) return;

    // final importAnalysisList = await getImportAnalysis(result);
    FileRuntimeGenerate generate = FileRuntimeGenerate(
      fileCache: result,
      globalClassName:
          AnalyzerPackageManager.md5ClassName(info.relativePath(sourcePath)),
      pubName: info.name,
    );
    final generateCode = await generate.generateCode();

    final outFile = join(AnalyzerPackageManager.defaultRuntimePath, 'runtime',
        info.cacheName, 'lib', libraryPath);
    final file = File(outFile);
    await file.writeString(generateCode);
  }

  @override
  Future<void> analysis() async {
    await super.analysis();

    /// 创建统一运行入口文件

    /// 获取当前库的所有代码文件
    final sourceFiles = await AnalyzerPackageManager.readAllSourceFiles(info);

    /// 统一入口文件地址
    final entryFile = join(
      AnalyzerPackageManager.defaultRuntimePath,
      'runtime',
      info.cacheName,
      'lib',
      '${info.runtimeName}.dart',
    );

    /// 相对路径列表
    final relativePaths = sourceFiles
        .map((e) {
          final relativePath = info.relativePathFromFullPath(e.path);
          final runtimeFullPath = join(
            AnalyzerPackageManager.defaultRuntimePath,
            'runtime',
            info.cacheName,
            'lib',
            relativePath,
          );
          if (!File(runtimeFullPath).existsSync()) return null;
          return relativePath;
        })
        .whereType<String>()
        .toList();

    final map = {
      'classs': [],
      'imports': relativePaths.map((e) {
        return {
          'uriContent': e,
        };
      }).toList(),
    };

    final generate = FileRuntimeGenerate(
      globalClassName:
          AnalyzerPackageManager.md5ClassName('${info.runtimeName}.dart'),
      pubName: info.name,
      fileCache: AnalyzerFileCache(map, map),
      runtimeClassNames: relativePaths.map((e) {
        return AnalyzerPackageManager.md5ClassName(e);
      }).toList(),
    );

    final generateCode = await generate.generateCode();

    final file = File(entryFile);
    await file.writeString(generateCode);
  }

  @override
  String get action => '生成';
}

class GenerateRuntimePackageProgress {
  /// 进度类型
  final GenerateRuntimePackageProgressType progressType;

  /// 进度提示
  final String title;

  /// 进度
  final double progress;

  final String? packageName;

  GenerateRuntimePackageProgress(
    this.progressType,
    this.title,
    this.progress, {
    this.packageName,
  });

  String get log => '$title: ${(progress * 100).toStringAsFixed(2)}%';
}

enum GenerateRuntimePackageProgressType {
  /// 分析进度
  analyze,

  /// 生成进度
  generate,

  /// 初始化工程进度
  initProject,

  /// 分析工程代码
  analyzeProject,
}

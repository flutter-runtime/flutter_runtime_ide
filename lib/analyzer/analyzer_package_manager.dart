// 用于缓存分析的内容
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_file_cache.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_property_accessor_cache.dart';
import 'package:flutter_runtime_ide/analyzer/conver_runtime_package.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/analyzer/configs/package_config.dart';
import 'package:path/path.dart';
import 'package:process_run/process_run.dart';

import '../common/common_function.dart';

class AnalyzerPackageManager {
  static final AnalyzerPackageManager _instance = AnalyzerPackageManager._();
  AnalyzerPackageManager._();
  factory AnalyzerPackageManager() => _instance;
  // 存储每个文件对应解析结果的缓存
  final Map<String, Map<String, SomeResolvedLibraryResult>> _libraries = {};
  // 存储每一个库对应分析的上下文
  final Map<String, AnalysisContextCollection> _collections = {};

  List<FixRuntimeConfiguration> fixRuntimeConfiguration = [];
  PackageConfig? packageConfig;

  // 根据库的路径和文件的路径获取分析结果
  // [packagePath] 库对应路径
  // [libraryPath] 文件对应路径
  Future<SomeResolvedLibraryResult> getResolvedLibrary(
    String packagePath,
    String libraryPath,
  ) async {
    Map<String, SomeResolvedLibraryResult> results = this.results(packagePath);
    late SomeResolvedLibraryResult result;
    if (results.containsKey(libraryPath)) {
      result = results[libraryPath]!;
    } else {
      final collection = _getAnalysisContextCollection(packagePath);
      result = await collection
          .contextFor(libraryPath)
          .currentSession
          .getResolvedLibrary(libraryPath);
      results[libraryPath] = result;
      _libraries[packagePath] = results;
    }
    return result;
  }

  AnalysisContextCollection _getAnalysisContextCollection(String packagePath) {
    AnalysisContextCollection? collection = _collections[packagePath];
    if (collection != null) {
      return collection;
    }
    AnalysisContextCollection contextCollection = AnalysisContextCollection(
      sdkPath: getDartPath(),
      includedPaths: [join(packagePath, "lib")],
    );
    _collections[packagePath] = contextCollection;
    return contextCollection;
  }

  Map<String, SomeResolvedLibraryResult> results(String packagePath) {
    return _libraries[packagePath] ?? {};
  }

  Future<void> loadFixRuntimeConfiguration() async {
    final loadPath = join(defaultRuntimePath, '.fix_runtime.json');
    if (!await File(loadPath).exists()) {
      return;
    }
    final jsonText = await File(loadPath).readAsString();
    fixRuntimeConfiguration = JSON(jsonDecode(jsonText)).listValue.map((e) {
      return FixRuntimeConfiguration.fromJson(e);
    }).toList();
  }

  Future<void> saveFixRuntimeConfiguration(String root) async {
    final jsonValue = fixRuntimeConfiguration.map((e) => e.toJson()).toList();
    final jsonText = const JsonEncoder.withIndent('  ').convert(jsonValue);
    final savePath = join(root, '.fix_runtime.json');
    await File(savePath).writeAsString(jsonText);
  }

  FixRuntimeConfiguration? getFixRuntimeConfiguration(PackageInfo info) {
    final path = basename(info.rootUri);
    final configurations =
        fixRuntimeConfiguration.where((element) => element.baseName == path);
    if (configurations.isEmpty) return null;
    return configurations.first;
  }

  List<String> getPackageLibraryPaths(String packagePath) {
    return Unwrap(_libraries[packagePath]).map((e) {
          return e.keys.toList();
        }).value ??
        [];
  }

  SomeResolvedLibraryResult? getResult(String fullPath) {
    for (var list in _libraries.values) {
      if (list.containsKey(fullPath)) {
        return list[fullPath]!;
      }
    }
    return null;
  }

  static String get defaultRuntimePath {
    return join(
      platformEnvironment['HOME']!,
      '.runtime',
    );
  }

  /// 获取分析文件的缓存信息
  /// [info] 当前分析文件对应库信息
  /// [filePath] 分析的文件路径
  /// [useCache] 是否使用本地的分析缓存 默认为  true
  Future<AnalyzerFileCache> getAnalyzerFileCache(
    PackageInfo info,
    String filePath, [
    bool useCache = true,
  ]) async {
    if (useCache) {
      final cache = await readFileCache(info, filePath);
      if (cache != null) {
        logger.i('[🟢使用缓存] $filePath');
        return cache;
      }
    }
    final result = await getResolvedLibrary(info.packagePath, filePath);
    if (result is! ResolvedLibraryResult) {
      return AnalyzerFileJsonCacheImpl({});
    }
    final cache =
        AnalyzerLibraryElementCacheImpl(result.element as LibraryElementImpl);
    await saveFileCache(info, cache, filePath);
    return cache;
  }

  /// 获取指定分析库的分析缓存文件配置路径
  /// [info] 当前分析文件对应库信息
  /// [filePath] 分析文件的路径
  String getAnalyzerCacheFilePath(PackageInfo info, String filePath) {
    return join(
      defaultRuntimePath,
      'config',
      'analyzer_cache',
      info.cacheName,
      '${md5(filePath)}.json',
    );
  }

  /// 根据包信息和文件路径获取对应分析缓存信息
  /// [info] 当前分析文件对应库信息
  /// [filePath] 分析文件的路径
  Future<AnalyzerFileCache?> readFileCache(
    PackageInfo info,
    String filePath,
  ) async {
    /// 获取分析缓存文件的路径
    final path = getAnalyzerCacheFilePath(info, filePath);
    if (!await File(path).exists()) {
      return null;
    }

    /// 读取缓存文件内容
    final jsonText = await File(path).readAsString();
    return AnalyzerFileJsonCacheImpl(jsonDecode(jsonText));
  }

  /// 将分析结果写入缓存
  /// [info] 当前分析文件对应库信息
  /// [cache] 分析结果缓存
  /// [filePath] 分析文件的路径
  Future<void> saveFileCache(
    PackageInfo info,
    AnalyzerFileCache cache,
    String filePath,
  ) async {
    final jsonValue = cache.toJson();
    final jsonText = const JsonEncoder.withIndent('  ').convert(jsonValue);
    final path = getAnalyzerCacheFilePath(info, filePath);
    await File(path).writeString(jsonText);
  }
}
